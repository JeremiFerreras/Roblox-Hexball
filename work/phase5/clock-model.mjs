
class SnapshotClock {
 constructor(){this.frames=[];this.delayTicks=2;this.jitter=0;this.underflows=0;this.rebuffers=0;}
 push(s,now) {
  if(this.latest && (s.matchId<this.matchId || s.matchId===this.matchId && (s.round<this.round || s.round===this.round && s.tick<=this.latest.tick))) return false;
  const reset=this.matchId!==s.matchId||this.round!==s.round||this.phase!==s.matchPhase;
  const offset=s.tick-now*60;
  if(reset){
   this.frames=[];this.cursor=s.tick;this.jitter=0;this.delayTicks=2;
   this.lastSample=now;this.started=false;this.starved=false;this.offset=offset;
  } else {
   const residual=Math.abs((now-this.arrivedAt)*60-(s.tick-this.latest.tick));
   this.jitter=this.jitter*.9+Math.min(residual,6)*.1;
   const gap=now-this.arrivedAt;
   // A stalled authority can resume with few ticks advanced; forget its old clock anchor.
   this.offset=gap>.5 && s.tick-this.latest.tick<gap*30 ? offset : Math.max(this.offset,offset);
  }
  this.matchId=s.matchId;this.round=s.round;this.phase=s.matchPhase;
  this.latest={tick:s.tick};this.arrivedAt=now;
  this.frames.push(this.latest);if(this.frames.length>32)this.frames.shift();
  return true;
 }
 sample(now) {
  if(!this.latest)return;
  const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
  const dt=Math.max(0,now-this.lastSample);this.lastSample=now;
  const target=clamp(2+2*this.jitter,2,6);
  this.delayTicks+=clamp(target-this.delayTicks,-dt*.5,dt*3);
  const estimated=now*60+this.offset;
  if(this.phase!=="playing")this.cursor=this.latest.tick;
  else {
   const desired=Math.min(this.latest.tick,estimated-this.delayTicks);
   if(this.cursor<this.latest.tick-8){this.cursor=Math.max(this.cursor,this.latest.tick-this.delayTicks);this.rebuffers++;}
   const delta=desired-this.cursor;
   if(delta>0){this.cursor+=Math.min(delta,dt*60*clamp(1+(delta-dt*60)*.1,.9,1.1));this.started=true;}
   const starved=this.started&&estimated-this.delayTicks>this.latest.tick+1e-6;
   if(starved&&!this.starved)this.underflows++;
   this.starved=starved;
  }
  this.cursor=clamp(this.cursor,this.frames[0].tick,this.latest.tick);
  return {tick:this.cursor,delayMs:this.delayTicks/60*1000,ageMs:Math.max(0,now-this.arrivedAt)*1000,renderLagMs:(estimated-this.cursor)/60*1000};
 }
}
export default SnapshotClock;
