import fs from 'node:fs';
import crypto from 'node:crypto';
const base='outputs/hbr-extractor/results/analysis';
const ref=JSON.parse(fs.readFileSync(base+'/nh_ball_trajectories.json','utf8'));
const lab=JSON.parse(fs.readFileSync(base+'/studio_classic_candidate.json','utf8'));
const sha=crypto.createHash('sha256').update(fs.readFileSync(base+'/nh_ball_trajectories.json')).digest('hex');
const cases=[];
for(const r of ref.filter(x=>x.stadium==='classic')){
 const l=lab.cases.find(x=>x.ball_vel[0]===r.ball_vel[0]&&x.ball_vel[1]===r.ball_vel[1]);
 const n=Math.min(r.ball_traj.length,l.lab.length);
 let maxX=0,maxY=0,sumX=0,sumY=0,sumE2=0,first=null,firstBeyond1e12=null;
 const rows=[];
 for(let i=0;i<n;i++){
  const rx=r.ball_traj[i][0],ry=r.ball_traj[i][1],lx=l.lab[i][0],ly=l.lab[i][1];
  const ex=Math.abs(lx-rx),ey=Math.abs(ly-ry),e=Math.hypot(lx-rx,ly-ry);
  maxX=Math.max(maxX,ex);maxY=Math.max(maxY,ey);sumX+=ex*ex;sumY+=ey*ey;sumE2+=e*e;
  if(first===null&&(ex!==0||ey!==0))first=i+1;
  if(firstBeyond1e12===null&&e>1e-12)firstBeyond1e12=i+1;
  rows.push({tick:i+1,reference:[rx,ry],lab:[lx,ly],absoluteError:[ex,ey]});
 }
 let velMax=0,velSum=0,velN=0;
 for(let i=0;i<n-1;i++){
  if(r.ball_traj[i+1][0]===0&&r.ball_traj[i+1][1]===0) continue;
  const rvx=r.ball_traj[i+1][0]-r.ball_traj[i][0],rvy=r.ball_traj[i+1][1]-r.ball_traj[i][1];
  const lvx=l.lab[i][2],lvy=l.lab[i][3];
  const d=Math.hypot(lvx-rvx,lvy-rvy);velMax=Math.max(velMax,d);velSum+=d*d;velN++;
 }
 const resets=[];
 for(let i=1;i<r.ball_traj.length;i++){
  if(Math.hypot(r.ball_traj[i][0]-r.ball_traj[i-1][0],r.ball_traj[i][1]-r.ball_traj[i-1][1])>100) resets.push({tick:i+1,from:r.ball_traj[i-1],to:r.ball_traj[i]});
 }
 cases.push({scenario:{stadium:r.stadium,initialPosition:[0,0],initialVelocity:r.ball_vel,nRed:r.n_red,nBlue:r.n_blue,tickRate:60,ticks:r.ticks},processedTicks:n,firstDifferentTick:first,firstDifferenceAbove1eMinus12:firstBeyond1e12,maxAbsoluteError:{x:maxX,y:maxY},rmsAbsoluteError:{x:Math.sqrt(sumX/n),y:Math.sqrt(sumY/n),euclidean:Math.sqrt(sumE2/n)},velocityComparison:{method:'reference velocity estimated from next position delta; compare with core post-tick velocity; reset-adjacent pairs omitted',samples:velN,rms:Math.sqrt(velSum/velN),max:velMax},largeDiscontinuities:resets,contactsObservedInCore:l.contacts,trajectory:rows});
}
const result={classification:'NODE_HAXBALL_REFERENCE',fixtureSha256:sha,referenceData:'exact fixture bytes copied from supplied HaxballGym ZIP; JSON numeric values parsed as IEEE-754 doubles without decimal rounding',labEngine:{source:'Roblox Studio PhysicsCore2D + ClassicStadium2D',profileCommit:lab.profile.commit,ball:{radius:10,invMass:1,damping:0.99,bCoef:0.5,collisionGroup:1,collisionMask:63},simHz:60,playersInComparison:false},scenarios:cases};
fs.writeFileSync('outputs/CLASSIC_ORACLE_COMPARISON.json',JSON.stringify(result));
console.log(JSON.stringify({sha,profile:lab.profile,summary:cases.map(c=>({v:c.scenario.initialVelocity,ticks:c.processedTicks,firstDifferentTick:c.firstDifferentTick,firstAbove1e12:c.firstDifferenceAbove1eMinus12,max:c.maxAbsoluteError,rms:c.rmsAbsoluteError,reset:c.largeDiscontinuities}))},null,2));