import fs from 'node:fs';
import crypto from 'node:crypto';
import readline from 'node:readline';
import {once} from 'node:events';
const dir='outputs/hbr-extractor/results';
const metaPath=dir+'/replay_metadata.json', tickPath=dir+'/replay_physics_ticks.jsonl', eventPath=dir+'/replay_events.jsonl', valPath=dir+'/replay_validation.json';
const meta=JSON.parse(fs.readFileSync(metaPath,'utf8'));
const val=JSON.parse(fs.readFileSync(valPath,'utf8'));
const ops=meta.roomData?.oG?.Pr?.OperationType??{};
const eventCounts={}; let eventRows=0;
for(const line of fs.readFileSync(eventPath,'utf8').split('\n')) if(line){JSON.parse(line);eventRows++}
const tickLines=readline.createInterface({input:fs.createReadStream(tickPath),crlfDelay:Infinity});
let count=0,first=null,last=null,prev=null,dups=0,gaps=0,parseErrors=0,playerDiskFrames=0,ballCandidateFrames=0,diskMin=Infinity,diskMax=-Infinity,firstTick;
const playersCsv=fs.createWriteStream(dir+'/replay_players.csv');const discsCsv=fs.createWriteStream(dir+'/replay_discs.csv');
playersCsv.write('frameNumber,gameTime,playerId,name,team,x,y,xspeed,yspeed,xgravity,ygravity,radius,invMass,damping,bCoef,cGroup,cMask\n');
discsCsv.write('frameNumber,gameTime,discId,isBallCandidate,playerId,x,y,xspeed,yspeed,xgravity,ygravity,radius,invMass,damping,bCoef,cGroup,cMask\n');
const esc=x=>{if(x===null||x===undefined)return '';const s=String(x);return /[",\r\n]/.test(s)?'"'+s.replaceAll('"','""')+'"':s};
for await(const line of tickLines){if(!line)continue;let row;try{row=JSON.parse(line)}catch{parseErrors++;continue}count++;if(!first){first=row.frameNumber;firstTick=row}last=row.frameNumber;if(prev!==null){if(row.frameNumber===prev)dups++;if(row.frameNumber!==prev+1)gaps++}prev=row.frameNumber;
 const st=row.state||{},pl=st.players||[],ds=st.discs||[];if(pl.some(p=>p.disc&&Number.isFinite(p.disc.x)))playerDiskFrames++;if(st.ballCandidate===0&&ds[0]?.radius===10&&ds[0]?.cGroup===193)ballCandidateFrames++;diskMin=Math.min(diskMin,ds.length);diskMax=Math.max(diskMax,ds.length);
 for(const p of pl){const d=p.disc||{};playersCsv.write([row.frameNumber,row.gameTime,p.playerId,p.name,p.team,d.x,d.y,d.xspeed,d.yspeed,d.xgravity,d.ygravity,d.radius,d.invMass,d.damping,d.bCoef,d.cGroup,d.cMask].map(esc).join(',')+'\n')}
 for(const d of ds)discsCsv.write([row.frameNumber,row.gameTime,d.discId,d.discId===st.ballCandidate,d.playerId,d.x,d.y,d.xspeed,d.yspeed,d.xgravity,d.ygravity,d.radius,d.invMass,d.damping,d.bCoef,d.cGroup,d.cMask].map(esc).join(',')+'\n')
}
await Promise.all([new Promise(resolve=>playersCsv.end(resolve)),new Promise(resolve=>discsCsv.end(resolve))]);
// Enrich API readAll metadata using the obfuscated but directly observed state layout.
const rs=meta.roomData||{}, g=rs.i||{}, stadium=g.r||{};
meta.normalized={stadium:{name:stadium.U,width:stadium.EW,height:stadium.lW},players:(rs.t||[]).map(p=>({playerId:p.M,name:p.U,team:p.rW,disc:{radius:p.n?.z,invMass:p.n?.P,damping:p.n?.m,bCoef:p.n?.b,cGroup:p.n?.f,cMask:p.n?.k}})),operationType:ops,sourceClassification:'readAll direct decode by independent Node-Haxball'};
fs.writeFileSync(metaPath,JSON.stringify(meta,null,2));
const replay=fs.readFileSync('C:/Users/User/Downloads/replay_1794954651243.hbr');
const telemetryPath='C:/Users/User/Downloads/telemetry_1794955691342.json', tb=fs.readFileSync(telemetryPath),td=JSON.parse(tb.toString('utf8')),T=td.ticks,E=td.events;
const deltas=[];for(let i=1;i<T.length;i++)deltas.push(+((T[i].gameTime-T[i-1].gameTime).toFixed(6)));
const deltaCounts={};for(const d of deltas)deltaCounts[d]=(deltaCounts[d]||0)+1;
const gapsT=[];for(let i=1;i<T.length;i++)if(T[i].tick!==T[i-1].tick+1)gapsT.push([T[i-1].tick,T[i].tick]);
const teamChanges=[];for(let i=1;i<T.length;i++){const a=T[i-1].players?.[0],b=T[i].players?.[0];if(a&&b&&a.team!==b.team)teamChanges.push({fromTick:T[i-1].tick,toTick:T[i].tick,fromTeam:a.team,toTeam:b.team})}
let eligible=0,errs=[],zeroDeltas=0,positionJumps=[],speedMax=0,fieldNulls={};
for(let i=1;i<T.length;i++){
 const a=T[i-1],b=T[i],dt=b.gameTime-a.gameTime;if(!(dt>0)){zeroDeltas++;continue}
 const pa=a.players?.[0],pb=b.players?.[0];if(!pa||!pb||pa.playerId!==pb.playerId||pa.team!==pb.team)continue;
 if(E.some(e=>e.type==='positionReset'&&e.tick>b.tick-1&&e.tick<=b.tick))continue;
 const dx=pb.x-pa.x,dy=pb.y-pa.y,dist=Math.hypot(dx,dy);if(dist>50){positionJumps.push({tick:b.tick,dt,dist});continue}
 const vx=(pa.xspeed+pb.xspeed)/2,vy=(pa.yspeed+pb.yspeed)/2;errs.push(Math.hypot(dx/dt-vx,dy/dt-vy));eligible++;
}
for(const t of T)for(const p of t.players||[])for(const k of ['x','y','xspeed','yspeed'])if(p[k]==null)fieldNulls[k]=(fieldNulls[k]||0)+1;
for(const t of T){const p=t.players?.[0];if(p)speedMax=Math.max(speedMax,Math.hypot(p.xspeed||0,p.yspeed||0))}
const telemetry={classification:'measured from user-provided JSON; semantics of tick/gameTime partly unknown',sha256:crypto.createHash('sha256').update(tb).digest('hex'),metadata:td.metadata,sampleCount:T.length,tickRange:[T[0]?.tick,T.at(-1)?.tick],tickUnique:new Set(T.map(x=>x.tick)).size,tickGaps:gapsT.length,events:E.length,eventTypes:E.reduce((o,e)=>(o[e.type]=(o[e.type]||0)+1,o),{}),gameTimeRange:[T[0]?.gameTime,T.at(-1)?.gameTime],deltaGameTime:deltaCounts,zeroDeltaCount:zeroDeltas,playerIds:[...new Set(T.flatMap(x=>(x.players||[]).map(p=>p.playerId)))],teamChanges,missingFields:fieldNulls,positionSpeedCheck:{eligiblePairs:eligible,meanVectorError:errs.reduce((a,b)=>a+b,0)/(errs.length||1),maxVectorError:Math.max(0,...errs),potentialPositionJumps:positionJumps.length,jumpSamples:positionJumps.slice(0,30),maxRecordedSpeed:speedMax,method:'compare delta-position/delta-gameTime with mean endpoint recorded velocity; exclude zero delta, identity/team changes, reset-adjacent samples and displacement >50 map units'},limitations:['producer source code absent: tick meaning, polling cadence and gameTime clock semantics unresolved','error analysis excludes candidate discontinuities; not an official physics measurement']};
fs.writeFileSync(dir+'/telemetry_analysis.json',JSON.stringify(telemetry,null,2));
const replayReport={replay:{sha256:crypto.createHash('sha256').update(replay).digest('hex'),header:meta.header,readAllVersion:meta.version,totalFrames:meta.totalFrames,stadium:meta.normalized.stadium,initialPlayers:meta.normalized.players},reconstruction:{classification:'reconstructed by independent Node-Haxball, not verified as official Haxball truth',framesCaptured:count,firstFrame:first,lastFrame:last,duplicates:dups,gaps,parseErrors,eventJsonlRecords:eventRows,callbackEvents:val.callbackEventCounts,readAllOperations:val.readAllEventCounts,operationType:ops,playerDiskFrames,ballCandidateFrames,disksPerFrameRange:[diskMin,diskMax],integrity:{ticksBytes:fs.statSync(tickPath).size,ticksSha256:crypto.createHash('sha256').update(fs.readFileSync(tickPath)).digest('hex'),eventsBytes:fs.statSync(eventPath).size,metadataSha256:crypto.createHash('sha256').update(fs.readFileSync(metaPath)).digest('hex')},note:'Rows are deep-cloned compact numeric snapshots from onGameTick; disc properties are mapped from Node-Haxball internal disc fields and are not an official-schema guarantee.'},telemetryComparison:{telemetryStadium:td.metadata?.stadium,replayStadium:meta.normalized.stadium?.name,telemetryDurationSeconds:telemetry.gameTimeRange[1],replayDurationSeconds:meta.header.frames/60,correlated:false,reason:'stadium and duration differ; separate sessions'} };
fs.writeFileSync(dir+'/analysis_report.json',JSON.stringify(replayReport,null,2));
console.log(JSON.stringify({count,first,last,dups,gaps,parseErrors,eventRows,playerDiskFrames,ballCandidateFrames,diskRange:[diskMin,diskMax],telemetry:{samples:T.length,dtCounts:deltaCounts,eligiblePairs:eligible,meanError:telemetry.positionSpeedCheck.meanVectorError,maxError:telemetry.positionSpeedCheck.maxVectorError,teamChanges},stadium:meta.normalized.stadium},null,2));