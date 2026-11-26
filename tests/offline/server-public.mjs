import { serverSetup } from "./server-adapter.mjs";
import { runLuau, writeReport } from "./runtime.mjs";
if (!serverSetup.includes("local studioMode=true"))
  throw new Error("fixture mode missing");
const code =
  serverSetup.replace("local studioMode=true", "local studioMode=false") +
  `
local result={}
local function check(name,fn)local ok,e=pcall(fn);table.insert(result,{name,ok,ok and 'PASS' or tostring(e)})end
check('public_match_disables_debug_commands_and_recording',function()
 local before=debugState.OnInvoke('summary').current
 command.fn(player,'setupGoalTest');command.fn(player,'runRegressionSuite');command.fn(player,'toggleRecording')
 local after=debugState.OnInvoke('summary').current
 assert(before.matchId==after.matchId and after.recording==false)
end)
check('public_match_has_no_history_or_periodic_debug_snapshots',function()
 for i=1,120 do heartbeat.fn(1/60)end
 local s=debugState.OnInvoke('summary')
 assert(s.historyCount==0 and s.current.recording==false)
 assert(stateStream.count==60 and snapshots.count==2)
end)
emit(json(result))`;
const result = await runLuau(code);
writeReport("server-public-results.json", result);
console.log(result);
if (result.some((r) => !r[1])) process.exitCode = 1;
