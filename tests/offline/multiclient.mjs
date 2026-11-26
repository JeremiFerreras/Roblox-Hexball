import { serverSetup } from "./server-adapter.mjs";
import { read, moduleSource, runLuau, writeReport, lua } from "./runtime.mjs";
const baseline = process.argv.includes("--retry-baseline");
if (
  baseline &&
  process.env.HEX_MUTATION !== "duplicate_pending_throttle_removed"
) {
  throw new Error(
    "Baseline requires HEX_MUTATION=duplicate_pending_throttle_removed",
  );
}
const factory = `
local Prediction=${moduleSource("src/ReplicatedStorage/HaxballLab/PredictionLab2D/init.luau")}
local function makeClient(player, transport, clockBias)
${read("tests/offline/client-ui-adapter.luau")}
${read("tests/offline/multiclient-client.luau")}
(function() ${read("src/ReplicatedStorage/HaxballLab/LabClient/init.server.luau")} end)()
return {
 receive=function(kind,args,t)
  now=t+clockBias
  if kind=="snapshot" then snapshotSignal.fn(args[1])
  elseif kind=="state" then stateSignal.fn(args[1])
  elseif kind=="control" then controlSignal.fn(table.unpack(args))
  else error(kind) end
 end,
 frame=function(t,dt,mask)
  now=t+clockBias
  local value=NetCodec.input(mask)
  moveState=vector(value.x,value.y,nil,"Vector2");kickState=value.kick
  render.fn(dt)
 end,
 report=function(t)
  now=t+clockBias
  return guiRoot.children.HaxballLabDebug.children.NetworkDiagnostics.OnInvoke()
 end,
 pose=function(slot)
  local part=field.children[slot==1 and "PlayerDisc" or "PlayerDisc"..slot]
  return part.Position.X/.5,-part.Position.Z/.5
 end,
}
end
`;
const configurations = [
  { name: "mixed_fps_loss0", seed: 1731, loss: 0 },
  { name: "mixed_fps_loss5", seed: 8217, loss: 5 },
  { name: "mixed_fps_loss15_blackout", seed: 9173, loss: 15, blackout: true },
  {
    name: "asymmetric_reversed_connections",
    seed: 1731,
    loss: 5,
    reverse: true,
    asymmetric: true,
  },
];
const results = [];
for (const config of configurations) {
  const code =
    serverSetup +
    factory +
    `\nlocal CONFIG=${lua(config)}\n` +
    read("tests/offline/multiclient-tests.luau");
  const rows = await runLuau(code);
  results.push(...rows);
  console.log(
    config.name,
    rows.filter((row) => !row[1]),
  );
}
writeReport(
  baseline ? "multiclient-baseline-results.json" : "multiclient-results.json",
  results,
);
console.log(
  `${results.filter((row) => row[1]).length}/${results.length} actual-client adapter checks`,
);
if (results.some((row) => !row[1])) process.exitCode = 1;
