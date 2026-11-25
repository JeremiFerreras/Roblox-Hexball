import {modules} from './local-match.mjs';
import {read,runLuau} from './runtime.mjs';
import fs from 'node:fs';
let physics=read('src/ServerScriptService/HaxballLab/Physics2D/init.luau').split('\n').filter(l=>!l.includes('require(')&&!l.startsWith('local ReplicatedStorage')).join('\n').replace('local Physics2D = {}','local Physics2D = {MatchCore=Core}');
const code=modules+`\nlocal P=(function() ${physics} end)()
local function signal() return {Connect=function(self,fn) self.fn=fn end} end
local input,command,heartbeat=signal(),signal(),signal()
input.OnServerEvent=input;command.OnServerEvent=command
local debugState={}
local snapshots={count=0,FireAllClients=function(self,s) self.latest=s;self.count+=1 end}
local player={UserId=123}
local players={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function() return {player} end}
local lab={Remotes={Input=input,Snapshot=snapshots,DebugCommand=command},WaitForChild=function(self,name) return name end}
local parent={WaitForChild=function(self,name) if name=='DebugState' then return debugState end return name end}
local game={GetService=function(self,name) if name=='Players' then return players elseif name=='RunService' then return {Heartbeat=heartbeat} elseif name=='ReplicatedStorage' then return {WaitForChild=function() return lab end} end error(name) end}
local script={Parent=parent}
local map={Physics2D=P,ClassicStadium2D=Stadium,StadiumReference2D=Profile,MatchRules2D=Rules,LocalMatch2D=LocalMatch,LabRegression={}}
local function require(name) assert(map[name],name);return map[name] end
(function() ${read('src/ServerScriptService/HaxballLab/LabServer/init.server.luau')} end)()
local result={}
local function check(name,fn) local ok,err=pcall(fn);table.insert(result,{name,ok,ok and 'PASS' or tostring(err)}) end
check('real_LabServer_initializes_and_publishes_5v5_countdown',function()
 heartbeat.fn(1/60)
 assert(snapshots.latest.playerCount==10 and snapshots.latest.matchPhase=='kickoff')
 assert(snapshots.latest.redCount==5 and snapshots.latest.blueCount==5)
 assert(snapshots.latest.round==1 and snapshots.latest.pauseTicksRemaining==29)
end)
check('real_input_during_countdown_is_not_lost',function()
 input.fn(player,1,0,false)
 for i=1,29 do heartbeat.fn(1/60) end
 assert(snapshots.latest.matchPhase=='playing')
 local x=snapshots.latest.player.x
 heartbeat.fn(1/60)
 assert(snapshots.latest.player.x>x)
end)
check('real_server_goal_pause_reset_and_snapshots',function()
 command.fn(player,'setupGoalTest')
 local goal=false;local reset=false;local red,blue
 for i=1,250 do
  heartbeat.fn(1/60)
  local s=snapshots.latest
  if s.matchPhase=='goalPause' then goal=true;red=s.score.red;blue=s.score.blue end
  if goal and s.round==2 then
   reset=true;assert(s.matchPhase=='kickoff' or s.matchPhase=='playing');assert(s.score.red==red and s.score.blue==blue);assert(s.lastTouch==nil);break
  end
 end
 assert(goal and reset,'goal/reset cycle not observed')
 assert(red+blue==1)
end)
check('debug_snapshot_adapter_remains_operational',function()
 local summary=debugState.OnInvoke('summary')
 assert(summary.current.tick==snapshots.latest.tick and summary.historyCount>0)
end)
emit(json(result))`;
const result=await runLuau(code);fs.writeFileSync(new URL('server-adapter-results.json',import.meta.url),JSON.stringify(result,null,2));console.log(result);if(result.some(x=>!x[1]))process.exitCode=1;
