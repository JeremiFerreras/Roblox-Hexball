import { writeReport } from "./runtime.mjs";
import { modules } from "./local-match.mjs";
import { read, runLuau } from "./runtime.mjs";
import { fileURLToPath } from "node:url";
export const serverSetup =
  modules +
  `\nlocal function signal() return {Connect=function(self,fn) self.fn=fn end} end
local input,command,heartbeat=signal(),signal(),signal()
input.OnServerEvent=input;command.OnServerEvent=command
local debugState={}
local snapshots={count=0,FireAllClients=function(self,s) self.latest=s;self.count+=1 end}
local player={UserId=123}
local roster={player}
local players={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function() return roster end}
local lab={Remotes={Input=input,Snapshot=snapshots,DebugCommand=command},WaitForChild=function(self,name) return name end}
local parent={WaitForChild=function(self,name) if name=='DebugState' then return debugState end return name end}
local game={GetService=function(self,name) if name=='Players' then return players elseif name=='RunService' then return {Heartbeat=heartbeat} elseif name=='ReplicatedStorage' then return {WaitForChild=function() return lab end} end error(name) end}
local script={Parent=parent}
local map={Physics2D=P,ClassicStadium2D=Stadium,StadiumReference2D=Profile,MatchRules2D=Rules,LocalMatch2D=LocalMatch,LabRegression=Suite}
local function require(name) assert(map[name],name);return map[name] end
(function() ${read("src/ServerScriptService/HaxballLab/LabServer/init.server.luau")} end)()
`;
export const serverTests = `local result={}
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
check('invalid_inputs_and_unauthorized_commands_do_not_change_match',function()
 local before=debugState.OnInvoke('summary').current
 input.fn(player,0/0,1,true);input.fn(player,math.huge,0,true);input.fn(player,nil,0,true)
 local outsider={UserId=9999}
 input.fn(outsider,1,0,true);command.fn(outsider,'reset')
 local after=debugState.OnInvoke('summary').current
 assert(before.matchId==after.matchId and before.tick==after.tick)
end)
check('ten_control_slots_and_extra_spectator_are_assigned_consistently',function()
 for i=2,11 do local p={UserId=1000+i};table.insert(roster,p);players.PlayerAdded.fn(p) end
 heartbeat.fn(1/60)
 local count=0
 for _,disc in ipairs(snapshots.latest.players)do if disc.ownerUserId then count+=1 end assert(disc.ownerUserId~=1011)end
 assert(count==10)
 input.fn(roster[11],1,0,true)
 command.fn(roster[11],'reset')
 assert(debugState.OnInvoke('summary').current.matchId==snapshots.latest.matchId)
end)
check('leaving_player_cannot_keep_controlling_reused_slot',function()
 local departing=roster[1]
 table.remove(roster,1);players.PlayerRemoving.fn(departing)
 local replacement={UserId=2000};table.insert(roster,replacement);players.PlayerAdded.fn(replacement)
 input.fn(replacement,1,0,false)
 input.fn(departing,-1,0,true)
 heartbeat.fn(1/60)
 assert(snapshots.latest.players[1].ownerUserId==2000)
 assert(snapshots.latest.input.x==1 and snapshots.latest.input.kick==false)
end)
check('one_contact_episode_is_counted_once',function()
 local active=roster[1]
 -- The current controller is the first remaining player after the original left.
 command.fn(active,'setupKick')
 input.fn(roster[#roster],1,0,false)
 for i=1,40 do heartbeat.fn(1/60) end
 local detail=debugState.OnInvoke({limit=100})
 local ticks={} local contacts=0
 for _,e in ipairs(detail.events) do
  if e.kind=='playerBallContact' then
   local key=tostring(e.tick)..':'..tostring(e.playerId or 1)
   assert(not ticks[key],'duplicate player-ball contact at '..key)
   ticks[key]=true;contacts+=1
  end
 end
 assert(contacts>0,'fixture did not generate a contact')
 assert(detail.metrics.ballContacts==contacts,'contact metric does not match contact events')
end)
check('departing_controller_does_not_clear_another_players_held_input',function()
 local active=roster[1]
 local slotOne=roster[#roster]
 input.fn(slotOne,1,0,false)
 table.remove(roster,1);players.PlayerRemoving.fn(active)
 local state=debugState.OnInvoke('summary').current
 assert(state.players[1].ownerUserId==slotOne.UserId)
 assert(state.input.x==1,'leaving controller erased slot one input')
end)
check('player_kick_damping_uses_its_own_configuration',function()
 local value=P.Config.playerKickDamping
 P.Config.playerKickDamping=.8
 command.fn(roster[1],'setupKick')
 local snapshot=debugState.OnInvoke('summary').current
 assert(snapshot.predictionParams.kickDamping==.8,'kick damping incorrectly coupled to ordinary damping')
 P.Config.playerKickDamping=value
 command.fn(roster[1],'reset')
end)
emit(json(result))`;
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const result = await runLuau(serverSetup + serverTests);
  writeReport("server-adapter-results.json", result);
  console.log(result);
  if (result.some((x) => !x[1])) process.exitCode = 1;
}
