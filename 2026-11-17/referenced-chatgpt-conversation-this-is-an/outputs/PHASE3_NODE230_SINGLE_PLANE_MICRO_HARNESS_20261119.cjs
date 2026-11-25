const fs=require('fs');const {Room,Utils}=require('node-haxball')();
const cases=[
 {id:'A_perpendicular',planeIndex:5,x:100,y:149,vx:0,vy:50},
 {id:'B_oblique',planeIndex:5,x:100,y:149,vx:20,vy:50},
 ...[10,20,40,50].map(v=>({id:'C_v'+v,planeIndex:5,x:100,y:150,vx:0,vy:v})),
 ...[140,148.5,155].map(y=>({id:'D_y'+y,planeIndex:5,x:100,y,vx:0,vy:20})),
 ...[0,.5,1].map(b=>({id:'E_planeB'+b,planeIndex:5,x:100,y:149,vx:0,vy:50,planeB:b})),
 {id:'E_outerB0',planeIndex:1,x:100,y:190,vx:0,vy:20},
 {id:'F_opposite',planeIndex:5,x:100,y:180,vx:0,vy:-20}
];
const results=[];for(const c of cases){const events=[];const cb={onCollisionDiscVsPlane:(...args)=>events.push(args.map(x=>typeof x==='object'&&x?Object.keys(x):x))};const room=Room.sandbox(cb,{});room.setCurrentStadium(Utils.getDefaultStadiums().find(s=>s.name==='Classic'),0);room.playerJoin(1,'r','tr','','','');room.setPlayerTeam(1,1,0);room.startGame(0);const gs=room.gameState.copy(),ps=gs.physicsState,ball=ps.discs[0],plane=ps.m[c.planeIndex];ps.m=[plane];ps.k=[];ps.O=[];if(c.planeB!==undefined)plane.a=c.planeB;ball.pos.x=c.x;ball.pos.y=c.y;ball.speed.x=c.vx;ball.speed.y=c.vy;const before={x:ball.pos.x,y:ball.pos.y,vx:ball.speed.x,vy:ball.speed.y,radius:ball.radius,discB:ball.a,planeIndex:c.planeIndex,plane:{normal:plane.z$,offset:plane.c$,bCoef:plane.a}};gs.runSteps(1);results.push({id:c.id,before,after:{x:ball.pos.x,y:ball.pos.y,vx:ball.speed.x,vy:ball.speed.y},events,planeCount:ps.m.length});}
fs.writeFileSync(process.argv[2],JSON.stringify({version:require('node-haxball/package.json').version,cases:results}));console.log(JSON.stringify({version:require('node-haxball/package.json').version,cases:results.length,out:process.argv[2]}));
