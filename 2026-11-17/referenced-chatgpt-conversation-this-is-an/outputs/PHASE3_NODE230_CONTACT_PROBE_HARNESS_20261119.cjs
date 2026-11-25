const fs=require('node:fs');
const crypto=require('node:crypto');
globalThis.__E_CONTACT_ROWS=[]; globalThis.__E_CONTACT_TRACE=(row)=>globalThis.__E_CONTACT_ROWS.push(row); globalThis.__E_TRACE_CTX={};
const {Room,Utils,GamePlayState}=require('./src/index.js')();
const SCENARIOS=[
 {stadium:'classic',n_red:1,n_blue:1,ball_vel:[8,55],ticks:180},
 {stadium:'classic',n_red:1,n_blue:1,ball_vel:[-30,45],ticks:180},
 {stadium:'classic',n_red:3,n_blue:3,ball_vel:[40,50],ticks:180}
];
const callbackNames=['onPlayerInputChange','onPlayerBallKick','onTeamGoal','onPositionsReset','onGameStart','onGameStop','onGameTick','onPlayerJoin','onPlayerLeave','onPlayerTeamChange','onCollisionDiscVsDisc','onCollisionDiscVsSegment','onCollisionDiscVsPlane','onCollisionDiscVsVertex','onKickOff'];
function cloneArg(v,depth=0,seen=new WeakSet()){
 if(v===null||v===undefined||typeof v==='string'||typeof v==='number'||typeof v==='boolean')return v??null;
 if(typeof v==='function')return '[function]';
 if(depth>3)return '[depth-limit]';
 if(typeof v==='object'){if(seen.has(v))return '[circular]';seen.add(v);
  if(Array.isArray(v))return v.slice(0,200).map(x=>cloneArg(x,depth+1,seen));
  const out={}; const keys=new Set([...Object.keys(v),...['id','name','team','teamId','playerId','discId','segmentId','planeId','goalId','x','y','pos','speed','gravity','radius','invMass','damping','bCoef','cGroup','cMask','p0','p1','team','color','normal','dist','curve']]);
  for(const k of keys){try{const x=v[k];if(x!==undefined && typeof x!=='function')out[k]=cloneArg(x,depth+1,seen)}catch{}}
  return out;
 }
 return String(v);
}
function snapDisc(d,index){
 const pos=d.pos,speed=d.speed,gravity=d.gravity;
 return {discIndex:index,playerId:d.playerId??null,x:pos.x,y:pos.y,vx:speed.x,vy:speed.y,gravityX:gravity.x,gravityY:gravity.y,radius:d.radius,invMass:d.invMass,damping:d.damping,bCoef:d.bCoef,cGroup:d.cGroup,cMask:d.cMask};
}
function snapState(gs,players){
 const discs=gs.physicsState.discs.map((d,i)=>snapDisc(d,i));
 const playerRows=players.map(p=>{const d=discs.find(x=>x.playerId===p.id)||null;return {playerId:p.id,name:p.name,teamId:p.team?.id??null,input:p.input,isKicking:p.isKicking,active:!!p.disc,disc:d};});
 return {gameState:{timeElapsedMs:gs.timeElapsed,state:gs.state,redScore:gs.redScore,blueScore:gs.blueScore,goalTickCounter:gs.goalTickCounter,pauseGameTickCounter:gs.pauseGameTickCounter,goalConcedingTeamId:gs.goalConcedingTeam?.id??null,paused:gs.paused,timeLimit:gs.timeLimit,scoreLimit:gs.scoreLimit},ball:discs.find(d=>d.discIndex===0)||null,players:playerRows,discs};
}
const apiVersion=require('node-haxball/package.json').version;
if(apiVersion!=='2.3.0')throw new Error('Expected Node-Haxball 2.3.0, loaded '+apiVersion);
const output={schemaVersion:1,provenance:{package:'node-haxball',version:apiVersion,node:process.version,oracleScript:'HaxballGym headless-bot/nh_oracle.js method, separately instrumented with passive Room.sandbox callbacks',evidenceClass:'RECONSTRUCTED_NODE_HAXBALL',officialEngineMeasurement:false,tickRateAssumptionHz:60},scenarios:[]};
for(let si=0;si<SCENARIOS.length;si++){
 const sc=SCENARIOS[si],events=[],callbackCounts={},ticks=[];let captureFrame=0; globalThis.__E_TRACE_CTX.scenario=si+1;
 const callbacks={};
 for(const name of callbackNames){callbackCounts[name]=0;callbacks[name]=(...args)=>{callbackCounts[name]++;events.push({eventType:name,frameNumber:captureFrame,logicalTimeSeconds:captureFrame/60,args:args.map(v=>cloneArg(v))});};}
 const stadium=Utils.getDefaultStadiums().find(s=>s.name==='Classic');
 const stadiumHbs=JSON.parse(Utils.exportStadium(stadium));
 const room=Room.sandbox(callbacks,{});
 room.setCurrentStadium(stadium,0);
 let id=1;
 for(let i=0;i<sc.n_red;i++){room.playerJoin(id,'r'+id,'tr','','','');room.setPlayerTeam(id,1,0);id++;}
 for(let i=0;i<sc.n_blue;i++){room.playerJoin(id,'b'+id,'tr','','','');room.setPlayerTeam(id,2,0);id++;}
 room.startGame(0);
 const players=room.state.players.map(p=>({id:p.id,name:p.name,team:p.team,input:p.input,isKicking:p.isKicking,disc:p.disc}));
 const gs=room.gameState.copy();
 const ballIndex=Number(String(stadiumHbs.ballPhysics||'disc0').match(/disc(\d+)/)?.[1]||0);
 const ball=gs.physicsState.discs[ballIndex];
 const beforeVelocity=snapState(gs,players);
 ball.speed.x=sc.ball_vel[0];ball.speed.y=sc.ball_vel[1];
 const initialState=snapState(gs,players);
 for(let frame=1;frame<=sc.ticks;frame++){
  captureFrame=frame; globalThis.__E_TRACE_CTX.tick=frame;
  const preStep=snapState(gs,players);
  gs.runSteps(1);
  const postStep=snapState(gs,players);
  ticks.push({frameNumber:frame,logicalTimeSeconds:frame/60,preStep,postStep});
 }
 fs.writeFileSync(process.argv[3],JSON.stringify(globalThis.__E_CONTACT_ROWS));
 const states= ticks.map(t=>t.postStep);
 output.scenarios.push({scenarioIndex:si+1,stadium:'Classic',stadiumHbs,stadiumSha256:crypto.createHash('sha256').update(JSON.stringify(stadiumHbs)).digest('hex'),initialBallVelocity:sc.ball_vel,playersCreated:players.map(p=>({playerId:p.id,name:p.name,teamId:p.team?.id??null,input:p.input,spawnPosition:p.disc?.pos?{x:p.disc.pos.x,y:p.disc.pos.y}:null})),disc0BallVerified:ballIndex===0&&ball.radius===10&&(ball.cGroup&1)!==0,ballDiscIndex:ballIndex,preVelocityState:beforeVelocity,initialState,tickCount:ticks.length,ticks,events,callbackCounts});
}
const outPath=process.argv[2];fs.writeFileSync(outPath,JSON.stringify(output));
console.log(JSON.stringify({version:apiVersion,scenarioCount:output.scenarios.length,ticks:output.scenarios.map(s=>s.tickCount),totalTicks:output.scenarios.reduce((n,s)=>n+s.tickCount,0),events:output.scenarios.map(s=>s.events.length),onGameTick:output.scenarios.map(s=>s.callbackCounts.onGameTick),outPath,bytes:fs.statSync(outPath).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(outPath)).digest('hex')}));



