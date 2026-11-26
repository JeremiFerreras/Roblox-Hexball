// Independent clock model, NOT an execution of the Luau module or Roblox.
import SnapshotClock from "./clock-model.mjs";

function runModelChecks(SnapshotClock) {
 const check=(ok,message)=>{if(!ok)throw Error(message);};
 const near=(a,b)=>check(Math.abs(a-b)<1e-7,a+" != "+b);
 const state=(tick,phase="playing",matchId=1,round=1)=>({tick,matchPhase:phase,matchId,round});
 const cases=[];
 function test(name,fn){try{cases.push({name,passed:true,observations:fn()??null});}catch(e){cases.push({name,passed:false,error:String(e)});}}
 test("regular_30hz_has_exact_33ms_margin",()=>{
  const b=new SnapshotClock();b.push(state(0),0);b.sample(0);
  for(let tick=2;tick<=60;tick+=2){b.push(state(tick),tick/60);near(b.sample(tick/60).tick,tick-2);near(b.sample((tick+1)/60).tick,tick-1);}
 });
 test("duplicate_reorder_and_old_epoch_are_rejected",()=>{
  const b=new SnapshotClock();b.push(state(10),0);
  check(!b.push(state(10),1),"duplicate");check(!b.push(state(9),1),"old tick");
  b.push(state(0,"kickoff",2),2);
  check(!b.push(state(100,"playing",1),3),"old match");
  b.push(state(0,"kickoff",2,2),4);
  check(!b.push(state(100,"playing",2,1),5),"old round");
  near(b.arrivedAt,4);
 });
 test("pause_and_epoch_snap_exactly",()=>{
  const b=new SnapshotClock();b.push(state(10),0);b.sample(0);
  b.push(state(12,"goalPause"),.1);near(b.sample(.1).tick,12);near(b.sample(.5).tick,12);
  b.push(state(0,"kickoff",2),.6);near(b.sample(.6).tick,0);check(b.frames.length===1,"epoch leaked frames");
 });
 test("blackout_freezes_then_rebuffers",()=>{
  const b=new SnapshotClock();b.push(state(0),0);b.sample(0);b.push(state(2),1/30);
  for(let t=2;t<=120;t++)check(b.sample(t/60).tick<=2,"extrapolated");
  check(b.underflows===1,"underflow must count episodes");
  check(b.sample(2).ageMs>1900,"blackout age hidden");
  b.push(state(120),2);const s=b.sample(2);
  check(b.rebuffers===1&&s.renderLagMs<=100+1e-7,"failed recovery");
 });
 test("stalled_authority_reanchors_its_clock",()=>{
  const b=new SnapshotClock();b.push(state(0),0);b.sample(0);
  b.push(state(2),1/30);b.sample(.1);b.sample(2);
  b.push(state(4),2.1);const s=b.sample(2.1);
  near(b.offset,4-2.1*60);check(s.renderLagMs<=100+1e-7,"stale server clock retained");
 });
 test("history_and_delay_are_bounded",()=>{
  const b=new SnapshotClock();b.push(state(0),0);b.sample(0);
  for(let t=2;t<=1000;t+=2){const now=t/60+(t%4===0?.02:0);b.push(state(t),now);const s=b.sample(now);check(b.frames.length<=32&&s.delayMs>=1000/30-1e-7&&s.delayMs<=100+1e-7,"unbounded");}
 });
 for(const fps of [30,60,240])for(const loss of [0,5,15]){
  test("seed_1731_"+fps+"fps_"+loss+"pct_loss",()=>{
   let seed=1731;const random=()=>{seed=seed*48271%2147483647;return seed/2147483647;};
   const q=[];for(let tick=0;tick<=1800;tick+=2){const lost=random()*100<loss;const due=tick/60+.05+random()*.07;if(!lost)q.push({tick,due});}q.sort((a,b)=>a.due-b.due);
   const b=new SnapshotClock();let index=0,oldPrevious,oldLatest,oldAt,lastX,oldX,lastCursor,steps=0,speedError=0,oldError=0,maxDelay=0,maxLag=0;
   for(let f=0;f<=Math.floor(30.2*fps);f++){
    const now=f/fps;
    while(q[index]&&q[index].due<=now){
     const it=q[index++];
     if(oldLatest===undefined||it.tick>oldLatest){
      oldPrevious=oldLatest??it.tick;oldLatest=it.tick;oldAt=now;b.push(state(it.tick),now);
     }
    }
    const s=b.sample(now);
    if(!s)continue;
    check(s.tick<=b.latest.tick+1e-6&&(lastCursor===undefined||s.tick>=lastCursor),"future or reversed clock");
    check(s.delayMs>=1000/30-1e-6&&s.delayMs<=100+1e-6&&b.frames.length<=32,"unbounded buffer");
    const interval=Math.max(1/30,(oldLatest-oldPrevious)/60);
    const x=2*(oldPrevious+(oldLatest-oldPrevious)*Math.max(0,Math.min(1,(now-oldAt)/interval)));
    if(now>2&&now<29){
     if(lastX!==undefined){speedError+=Math.abs((s.tick*2-lastX)*fps-120);oldError+=Math.abs((x-oldX)*fps-120);steps++;}
     maxDelay=Math.max(maxDelay,s.delayMs);maxLag=Math.max(maxLag,s.renderLagMs);
    }
    lastX=s.tick*2;oldX=x;lastCursor=s.tick;
   }
   check(steps>0&&speedError/steps<oldError/steps,"mean speed error did not improve");
   if(loss===0)check(b.rebuffers===0,"regular jitter caused hard rebuffer");
   return {fps,lossPct:loss,meanSpeedError:speedError/steps,oldMeanSpeedError:oldError/steps,maxDelayMs:maxDelay,maxRenderLagMs:maxLag,underflowEpisodes:b.underflows,rebuffers:b.rebuffers};
  });
 }
 return {scope:"JavaScript clock model only; Luau source, rendering, engine, wire traffic and native Roblox unexecuted",baselineCommit:"974c892b22a5a5b23736a0a50b9cc6af46dc287d",seed:1731,motionUnitsPerSecond:120,durationSeconds:30.2,arrivalDelayMs:[50,120],passes:cases.filter(c=>c.passed).length,total:cases.length,cases};
}
const report=runModelChecks(SnapshotClock);
console.log(JSON.stringify(report,null,2));
if(report.passes!==report.total) throw new Error("model checks failed");
