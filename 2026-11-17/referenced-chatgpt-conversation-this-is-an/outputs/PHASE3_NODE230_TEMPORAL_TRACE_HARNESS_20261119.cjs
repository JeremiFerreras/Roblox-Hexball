const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const crypto = require("node:crypto");
const { spawnSync } = require("node:child_process");

const root = path.join(os.tmpdir(), "codex-haxball-oracle-230-20261118");
const source = path.join(root, "solver-instrumented");
const oracleModules = path.join(root, "oracle-install", "node_modules");
const node = path.join(root, "portable-node", "node-v24.22.3-win-x64", "node.exe");
const outputs = path.resolve(process.argv[2] || "outputs");
fs.mkdirSync(outputs, { recursive: true });
if (require(path.join(oracleModules, "node-haxball", "package.json")).version !== "2.3.0") {
  throw new Error("Only Node-HaxBall 2.3.0 is allowed");
}
if (!fs.existsSync(node)) throw new Error("Verified portable Node runtime not found");

const work = path.join(root, "temporal-instrumented-" + process.pid + "-" + Date.now());
fs.mkdirSync(path.join(work, "src"), { recursive: true });
fs.cpSync(path.join(source, "src"), path.join(work, "src"), { recursive: true });

const apiPath = path.join(work, "src", "api.js");
let api = fs.readFileSync(apiPath, "utf8");
function replaceOnce(oldText, newText, label) {
  const first = api.indexOf(oldText);
  if (first < 0 || api.indexOf(oldText, first + oldText.length) >= 0) {
    throw new Error("Non-unique/missing API anchor: " + label);
  }
  api = api.slice(0, first) + newText + api.slice(first + oldText.length);
}
const start = "E$:function(C,h){var O,p,B,s,F,I,{F:l,m:K,k:R,O:k,L$:j}=this;l.forEach(";
replaceOnce(start,
  "E$:function(C,h){var O,p,B,s,F,I,{F:l,m:K,k:R,O:k,L$:j}=this;globalThis.__NODE_TEMPORAL_TRACE?.({phase:\"e$_entry\",scenario:globalThis.__E_TRACE_CTX?.scenario,tick:globalThis.__E_TRACE_CTX?.tick,dt:C,logicalTimeSeconds:(globalThis.__E_TRACE_CTX?.tick||0)/60,discs:l.map((d,index)=>({index,x:d.B.x,y:d.B.y,vx:d.I.x,vy:d.I.y,radius:d.l,bCoef:d.a,damping:d.Z}))});l.forEach(",
  "E$ entry");
const integrationEnd = "V.y=t*(X$+o.y)}),l.forEach((i,V)=>{";
replaceOnce(integrationEnd,
  "V.y=t*(X$+o.y)}),globalThis.__NODE_TEMPORAL_TRACE?.({phase:\"post_integrate_pre_contacts\",scenario:globalThis.__E_TRACE_CTX?.scenario,tick:globalThis.__E_TRACE_CTX?.tick,dt:C,logicalTimeSeconds:(globalThis.__E_TRACE_CTX?.tick||0)/60,discs:l.map((d,index)=>({index,x:d.B.x,y:d.B.y,vx:d.I.x,vy:d.I.y,radius:d.l,bCoef:d.a,damping:d.Z}))}),l.forEach((i,V)=>{",
  "post integration");
fs.writeFileSync(apiPath, api);
const temporalApiSha256 = crypto.createHash("sha256").update(api).digest("hex");

let harness = fs.readFileSync(path.join(source, "harness-instrumented.cjs"), "utf8");
const globals = "globalThis.__E_CONTACT_ROWS=[]; globalThis.__E_CONTACT_TRACE=(row)=>globalThis.__E_CONTACT_ROWS.push(row); globalThis.__E_TRACE_CTX={};";
if (!harness.includes(globals)) throw new Error("Contact harness bootstrap changed");
harness = harness.replace(globals, globals + " globalThis.__NODE_TEMPORAL_ROWS=[]; globalThis.__NODE_TEMPORAL_TRACE=(row)=>{if(row.scenario===3 && row.tick>=3 && row.tick<=5) globalThis.__NODE_TEMPORAL_ROWS.push(row)};");
harness += "\nfs.writeFileSync(process.argv[4], JSON.stringify(globalThis.__NODE_TEMPORAL_ROWS));\n";
const temporalHarness = path.join(work, "harness-temporal.cjs");
fs.writeFileSync(temporalHarness, harness);
fs.appendFileSync(temporalHarness, "\nprocess.exit(0);\n");

const env = { ...process.env, NODE_PATH: oracleModules };
function run(script, args, label) {
  const result = spawnSync(node, [script, ...args], {
    cwd: path.dirname(script), env, encoding: "utf8", maxBuffer: 16 * 1024 * 1024
  });
  if (result.status !== 0) throw new Error(label + " failed: " + result.stderr + result.stdout);
  return result.stdout.trim();
}
const baselineHarness = path.join(work, "harness-original.cjs");
const temporalOriginalHarness = path.join(source, "harness-instrumented.cjs");
fs.copyFileSync(path.join(source, "harness-original.cjs"), baselineHarness);
fs.appendFileSync(baselineHarness, "\nprocess.exit(0);\n");
const runDir = path.join(work, "runs");
fs.mkdirSync(runDir);
const baselineA = path.join(runDir, "baseline-a.json");
const baselineB = path.join(runDir, "baseline-b.json");
const instrumentedA = path.join(runDir, "instrumented-a.json");
const instrumentedB = path.join(runDir, "instrumented-b.json");
const contactA = path.join(runDir, "contacts-a.json");
const contactB = path.join(runDir, "contacts-b.json");
const timelineA = path.join(runDir, "timeline-a.json");
const timelineB = path.join(runDir, "timeline-b.json");

const baselineLogA = run(baselineHarness, [baselineA], "baseline run A");
const baselineLogB = run(baselineHarness, [baselineB], "baseline run B");
const runInstrumented = (out, contacts, timeline) => {
  const result = spawnSync(node, [temporalHarness, out, contacts, timeline], {
    cwd: work, env, encoding: "utf8", maxBuffer: 16 * 1024 * 1024
  });
  if (result.status !== 0) throw new Error("instrumented run failed: " + result.stderr + result.stdout);
  return result.stdout.trim();
};
const instrumentedLogA = runInstrumented(instrumentedA, contactA, timelineA);
const instrumentedLogB = runInstrumented(instrumentedB, contactB, timelineB);
const sha = file => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
const physicalSha = file => {
  const doc = JSON.parse(fs.readFileSync(file, "utf8"));
  const rows = doc.scenarios.map(s => ({
    scenarioIndex: s.scenarioIndex,
    initialBallVelocity: s.initialBallVelocity,
    ticks: s.ticks.map(t => ({
      tick: t.frameNumber,
      ball: t.postStep.ball && {
        x:t.postStep.ball.x,y:t.postStep.ball.y,vx:t.postStep.ball.vx,vy:t.postStep.ball.vy
      },
      players: t.postStep.players.map(p => p.disc && ({
        playerId:p.playerId,x:p.disc.x,y:p.disc.y,vx:p.disc.vx,vy:p.disc.vy
      })),
      events: s.events.filter(e=>e.frameNumber===t.frameNumber)
    }))
  }));
  return crypto.createHash("sha256").update(JSON.stringify(rows)).digest("hex");
};
const baselineHash = sha(baselineA), instrumentedHash = sha(instrumentedA);
const repeatBaseline = baselineHash === sha(baselineB);
const repeatInstrumented = instrumentedHash === sha(instrumentedB);
const outputEquivalent = fs.readFileSync(baselineA).equals(fs.readFileSync(instrumentedA));
const stateHashBaseline = physicalSha(baselineA);
const stateHashInstrumented = physicalSha(instrumentedA);
const timeline = JSON.parse(fs.readFileSync(timelineA, "utf8"));
const timelineRepeat = fs.readFileSync(timelineA).equals(fs.readFileSync(timelineB));
const contactRepeat = fs.readFileSync(contactA).equals(fs.readFileSync(contactB));
const validation = {
  schemaVersion: 1,
  package: {version: require(path.join(oracleModules, "node-haxball", "package.json")).version, entry: require.resolve(path.join(oracleModules, "node-haxball"))},
  runtime: process.version,
  isolation: {originalInstallModified:false, sourceCopy:work, instrumentedApiSha256:temporalApiSha256},
  runs: {baselineA:baselineLogA,baselineB:baselineLogB,instrumentedA:instrumentedLogA,instrumentedB:instrumentedLogB},
  hashes: {baselineOutputSha256:baselineHash,instrumentedOutputSha256:instrumentedHash,canonicalStateSha256Baseline:stateHashBaseline,canonicalStateSha256Instrumented:stateHashInstrumented,timelineSha256:sha(timelineA)},
  validation: {baselineDeterministic:repeatBaseline,instrumentedDeterministic:repeatInstrumented,physicalOutputByteIdentical:outputEquivalent,canonicalStateHashEqual:stateHashBaseline===stateHashInstrumented,timelineDeterministic:timelineRepeat,contactTraceDeterministic:contactRepeat,scenario3Tick4IntegrationPhasesCaptured:timeline.filter(x=>x.tick===4).length,totalScenario3TimelineRows:timeline.length,uniqueScenario3TicksCaptured:[...new Set(timeline.map(x=>x.tick))]},
  timeline,
  contactTrace: JSON.parse(fs.readFileSync(contactA,"utf8")).filter(x=>x.scenario===3 && x.tick>=3 && x.tick<=5)
};
const outPath = path.join(outputs, "PHASE3_TEMPORAL_NODE230_TRACE_20261119.json");
fs.writeFileSync(outPath, JSON.stringify(validation, null, 2));
console.log(JSON.stringify({outPath,hashes:validation.hashes,validation:validation.validation,temporalApiSha256,work}));

