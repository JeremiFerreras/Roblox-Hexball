import { api } from "./oracle.mjs";
import { writeReport } from "./runtime.mjs";
import { geometry } from "./reference.mjs";
import { runLuau, lua, read } from "./runtime.mjs";
import { moduleBundle } from "./modules.mjs";
import { compareFrames } from "./assertions.mjs";
import assert from "node:assert/strict";
function disc(d, i, players) {
  return {
    id: i + 1,
    kind: players.has(d.playerId) ? "player" : "ball",
    x: d.pos.x,
    y: d.pos.y,
    vx: d.speed.x,
    vy: d.speed.y,
    radius: d.radius,
    invMass: d.invMass,
    damping: d.damping,
    bCoef: d.bCoef,
    gravityX: d.gravity.x,
    gravityY: d.gravity.y,
    collisionGroup: d.cGroup,
    collisionMask: d.cMask,
    acceleration: 0.1,
    kickAcceleration: 0.07,
    kickDamping: 0.96,
    kickStrength: 5,
    kickback: 0,
    kickable: i === 0,
    traceMotion: i === 0,
  };
}
const cases = [];
function add(name, map, setup, inputs, ticks = 120, playerCount = 2) {
  let kicks = 0,
    goals = 0,
    activeTick = 0;
  const kickEvents = [],
    goalEvents = [];
  const r = api.Room.sandbox(
    {
      onPlayerBallKick: (p) => {
        kicks++;
        assert(
          Number.isSafeInteger(p),
          "oracle kick callback must provide a player id",
        );
        kickEvents.push([activeTick, p]);
      },
      onTeamGoal: (team) => {
        goals++;
        goalEvents.push([activeTick, team]);
      },
    },
    {},
  );
  r.setSimulationSpeed(0);
  r.setCurrentStadium(
    map === "Classic"
      ? api.Utils.getDefaultStadiums().find((s) => s.name === "Classic")
      : api.Utils.parseStadium(JSON.stringify(map)),
    0,
  );
  for (let i = 1; i <= playerCount; i++) {
    r.playerJoin(i, "p" + i, "", null, "", "");
    r.setPlayerTeam(i, i <= playerCount / 2 ? 1 : 2, 0);
  }
  r.startGame(0);
  r.gameState.c = 1;
  const ps = r.gameState.physicsState;
  setup(ps.discs);
  const initial = ps.discs.map((d, i) =>
    disc(d, i, new Set(Array.from({ length: playerCount }, (_, i) => i + 1))),
  );
  const frames = [],
    steps = [],
    goalFrames = [];
  for (let t = 0; t < ticks; t++) {
    activeTick = t + 1;
    const input = inputs(t);
    steps.push(input);
    for (let i = 1; i <= playerCount; i++) {
      let q = input[i] || {};
      r.playerInput(api.Utils.keyState(q.x || 0, q.y || 0, !!q.kick), i);
    }
    r.gameState.c = 1;
    let previousGoals = goals;
    r.gameState.runSteps(1);
    goalFrames.push(goals - previousGoals);
    frames.push(ps.discs.map((d) => [d.pos.x, d.pos.y, d.speed.x, d.speed.y]));
  }
  const playerIds = {};
  ps.discs.forEach((d, i) => {
    if (d.playerId != null) playerIds[d.playerId] = i + 1;
  });
  cases.push({
    name,
    initial,
    frames,
    steps,
    playerIds,
    kicks,
    goalFrames,
    kickEvents,
    goalEvents,
    classic: map === "Classic",
    planes: ps.planes.map((p, i) => ({
      id: "p" + i,
      normalX: p.normal.x,
      normalY: p.normal.y,
      offset: p.dist,
      bCoef: p.bCoef,
      collisionGroup: p.cGroup,
      collisionMask: p.cMask,
    })),
    geometry: geometry(ps),
    segments: [],
  });
}
const empty = {
  name: "offline",
  bg: { type: "none" },
  width: 10000,
  height: 10000,
  vertexes: [],
  segments: [],
  planes: [],
  goals: [],
  discs: [],
  playerPhysics: {},
  ballPhysics: {},
};
const setup = (ds) => {
  for (let i = 0; i < ds.length; i++) {
    ds[i].pos.x = i * 200;
    ds[i].pos.y = 500;
    ds[i].speed.x = 0;
    ds[i].speed.y = 0;
  }
};
for (const [name, inp] of [
  ["horizontal", (t) => ({ 1: { x: t < 60 ? 1 : 0 } })],
  ["diagonal", (t) => ({ 1: { x: 1, y: 1 } })],
  ["reverse", (t) => ({ 1: { x: t < 60 ? 1 : -1 } })],
  ["heldKickMovement", (t) => ({ 1: { x: 1, kick: true } })],
])
  add(name, empty, setup, inp);
add(
  "discImpact",
  empty,
  (ds) => {
    setup(ds);
    ds[0].pos = { x: 0, y: 0 };
    ds[0].speed = { x: 8, y: 3 };
    ds[1].pos = { x: 50, y: 0 };
  },
  () => ({}),
);
for (const [name, fn] of [
  ["singleKick", (t) => t === 0],
  ["heldKick", (t) => true],
  ["repeatedKick", (t) => t % 2 === 0],
])
  add(
    name,
    empty,
    (ds) => {
      setup(ds);
      ds[0].pos = { x: 27, y: 0 };
      ds[1].pos = { x: 0, y: 0 };
    },
    (t) => ({ 1: { kick: fn(t) } }),
    30,
  );
for (const v of [1, 8, 50, 500])
  add(
    "plane_v" + v,
    {
      ...empty,
      planes: [
        {
          normal: [0, -1],
          dist: -170,
          bCoef: 1,
          cMask: ["ball"],
          cGroup: ["wall"],
        },
      ],
    },
    (ds) => {
      setup(ds);
      ds[0].pos = { x: 0, y: 150 };
      ds[0].speed = { x: 2, y: v };
    },
    () => ({}),
    60,
  );
for (const v of [
  [8, 55],
  [-30, 45],
  [40, 50],
])
  add(
    "Classic_" + v.join("_"),
    "Classic",
    (ds) => {
      ds[0].speed.x = v[0];
      ds[0].speed.y = v[1];
    },
    () => ({}),
    180,
  );
for (let i = 0; i < 24; i++)
  add(
    "seededImpact_" + i,
    empty,
    (ds) => {
      setup(ds);
      ds[0].pos = { x: 0, y: 0 };
      ds[0].speed = { x: 3 + i * 0.71, y: (i % 5) - 2 };
      ds[1].pos = { x: 25 + i, y: (i % 7) - 3 };
    },
    () => ({}),
    90,
  );
for (let seed = 0; seed < 32; seed++)
  add(
    "Classic_stress_" + seed,
    "Classic",
    (ds) => {
      ds[0].pos.x = (seed % 2 ? -1 : 1) * (350 + (seed % 7));
      ds[0].pos.y = (seed % 5) * 25 - 50;
      ds[0].speed.x = (seed % 2 ? 1 : -1) * (1 + seed * 2);
      ds[0].speed.y = (seed % 7) - 3;
    },
    (t) =>
      Object.fromEntries(
        Array.from({ length: 10 }, (_, i) => [
          i + 1,
          {
            x: ((Math.floor(t / 31) + i + seed) % 3) - 1,
            y: ((Math.floor(t / 47) + i * 2 + seed) % 3) - 1,
            kick: t % 19 < 4,
          },
        ]),
      ),
    600,
    10,
  );
for (const distance of [25, 28.999999, 29, 29.000001])
  add(
    "kick_range_" + distance,
    empty,
    (ds) => {
      setup(ds);
      ds[0].pos = { x: distance, y: 0 };
      ds[1].pos = { x: 0, y: 0 };
    },
    () => ({ 1: { kick: true } }),
    10,
  );
const code =
  moduleBundle() +
  ` local cases=${lua(cases.map(({ frames, ...c }) => c))}\n` +
  read("tests/offline/compare-runner.luau");
const results = await runLuau(code);
const report = [];
assert(Array.isArray(results));
assert.equal(results.length, cases.length, "missing scenarios");
for (let i = 0; i < cases.length; i++) {
  const c = cases[i];
  assert.equal(results[i].length, 1);
  const [frames, kicks, goals, kickEvents, goalEvents] = results[i][0];
  assert(Number.isSafeInteger(kicks) && kicks >= 0);
  assert.equal(goals.length, c.frames.length, "missing goal ticks");
  assert(goals.every((v) => v === 0 || v === 1));
  assert.deepEqual(
    kickEvents,
    c.kickEvents,
    `kick tick/player mismatch: ${c.name}`,
  );
  if (c.classic)
    assert.deepEqual(
      goalEvents,
      c.goalEvents,
      `goal tick/team mismatch: ${c.name}`,
    );
  report.push({
    name: c.name,
    ticks: c.frames.length,
    oracleKicks: c.kicks,
    reference: {
      ...compareFrames(c.frames, frames),
      kicks,
      goalMismatches: c.classic
        ? goals.filter((v, t) => v !== c.goalFrames[t]).length
        : 0,
    },
  });
}
writeReport("results.json", {
  oracle: "node-haxball@2.3.0",
  runtime: "luau-web@1.5.1",
  scope: "isolated engine, not Studio or official client",
  cases: report,
});
console.log(JSON.stringify(report, null, 2));

if (
  report.some(
    (c) =>
      c.reference.maxError > 1e-9 ||
      c.reference.kicks !== c.oracleKicks ||
      c.reference.goalMismatches !== 0,
  )
)
  process.exitCode = 1;
