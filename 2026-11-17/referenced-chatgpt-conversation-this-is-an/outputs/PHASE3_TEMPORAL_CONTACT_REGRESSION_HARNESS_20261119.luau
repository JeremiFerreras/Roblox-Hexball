-- Additional full-stadium contact regression fixtures for the temporal factorial.
-- Inputs are new explicit controls for this run; they are not historical missing fixtures.
-- Execute in Studio Edit; only temporary ModuleScript clones and in-memory worlds are used.
local sourceCoreScript=game:GetService("ServerScriptService").HaxballLab.PhysicsCore2D
local sourceProfileScript=game:GetService("ReplicatedStorage").HaxballLab.StadiumReference2D
local ServerStorage=game:GetService("ServerStorage")
local profileClone=Instance.new("ModuleScript");profileClone.Name="Phase3ExtraFreshProfile";profileClone.Source=sourceProfileScript.Source;profileClone.Parent=ServerStorage
local Profile=require(profileClone)
local src=sourceCoreScript.Source
local function rep(old,new,label)local a,b=src:find(old,1,true);assert(a,label.." anchor missing");assert(not src:find(old,b+1,true),label.." anchor duplicated");src=src:sub(1,a-1)..new..src:sub(b+1)end
rep("world.lastSubsteps=substeps\n","world.lastSubsteps=substeps\n    if world.config.forceSinglePass then substeps=1;world.lastSubsteps=1 end\n","pass selection")
rep("        -- Preserve declared solver order inside each microstep.\n","        if world.config.temporalMode==\"fullTickBeforeContacts\" and substep==1 then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then local damp=(d.kind==\"player\" and d.kickArmed) and d.kickDamping or d.damping;d.vx=(d.vx+d.gravityX)*damp;d.vy=(d.vy+d.gravityY)*damp end end end\n        -- Preserve declared solver order inside each microstep.\n","pre-contact integration")
rep("    for _,disc in ipairs(world.discs) do\n        if disc.enabled and disc.invMass>0 then\n            local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping\n            disc.vx=(disc.vx+disc.gravityX)*damping\n            disc.vy=(disc.vy+disc.gravityY)*damping\n        end\n    end\n\n    world.tick += 1","    if world.config.temporalMode~=\"fullTickBeforeContacts\" then for _,disc in ipairs(world.discs) do if disc.enabled and disc.invMass>0 then local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping;disc.vx=(disc.vx+disc.gravityX)*damping;disc.vy=(disc.vy+disc.gravityY)*damping end end end\n\n    world.tick += 1","post-contact damping")
local m=Instance.new("ModuleScript");m.Name="Phase3ExtraFactorialCore";m.Source=src;m.Parent=ServerStorage
local Core=require(m)
local NODE_ORDER={"classic:outer:bottom","classic:outer:top","classic:outer:left","classic:outer:right","classic:ballArea:bottom","classic:ballArea:top"}
local tests={
 {id="corner_stack",ball={x=415,y=195,vx=20,vy=20}},
 {id="opposite_side_outer_top",ball={x=100,y=205,vx=0,vy=-20}},
 {id="right_wall_rebound",ball={x=415,y=0,vx=20,vy=0}},
 {id="goal_net_contact",ball={x=392,y=0,vx=20,vy=0}},
 {id="ball_player_contact",ball={x=0,y=0,vx=20,vy=0},player={x=30,y=0,vx=0,vy=0,team=1}},
 {id="fast_cross_field_limit",ball={x=0,y=0,vx=3000,vy=0}},
}
local variants={}
for _,t in ipairs({"substepResolve","fullTickBeforeContacts"}) do for _,o in ipairs({"core","node"}) do for _,p in ipairs({"core","node"}) do variants[#variants+1]={id=(t=="substepResolve" and "T0" or "T1")..(o=="core" and "O0" or "O1")..(p=="core" and "P0" or "P1"),t=t,o=o,p=p} end end end
local result={schemaVersion=1,profileSourceFresh=true,profileCommit=Profile.Metadata.sourceCommit,fixtureInputs=tests,variants={}}
for _,test in ipairs(tests) do
 result.variants[test.id]={}
 for _,v in ipairs(variants) do
  local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=v.t=="fullTickBeforeContacts",temporalMode=v.t})
  Core.addDisc(w,{id="ball",kind="ball",x=test.ball.x,y=test.ball.y,vx=test.ball.vx,vy=test.ball.vy,radius=10,invMass=1,damping=.99,bCoef=.5,collisionGroup=Profile.CollisionGroups.ball,collisionMask=Profile.CollisionMasks.ball})
  for _,p in ipairs(Profile.Geometry.planes)do Core.addPlane(w,table.clone(p))end
  for _,s in ipairs(Profile.Geometry.segments)do Core.addSegment(w,table.clone(s))end
  for _,p in ipairs(Profile.Geometry.posts)do Core.addDisc(w,{id=p.id,kind="post",x=p.x,y=p.y,radius=p.radius,invMass=0,damping=1,bCoef=p.bCoef,collisionGroup=Profile.CollisionGroups.post,collisionMask=Profile.CollisionMasks.all})end
  if test.player then Core.addDisc(w,{id=1,kind="player",team=test.player.team,x=test.player.x,y=test.player.y,vx=test.player.vx,vy=test.player.vy,radius=15,invMass=.5,damping=.96,bCoef=.5,collisionGroup=Profile.CollisionGroups.red,collisionMask=Profile.CollisionMasks.player,acceleration=.1,kickAcceleration=.07,kickDamping=.96})end
  if v.o=="node"then local by={}for _,p in ipairs(w.planes)do by[p.id]=p end;local a={}for _,id in ipairs(NODE_ORDER)do a[#a+1]=by[id]end;w.planes=a end
  if v.p=="node"then for _,p in ipairs(w.planes)do if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 end end end
  local _,events,n=Core.stepWorld(w,{})
  local discs={}for _,d in ipairs(w.discs)do if d.invMass>0 and(d.kind=="ball"or d.vx~=0 or d.vy~=0)then discs[#discs+1]={d.id,d.x,d.y,d.vx,d.vy}end end
  local contacts={}for _,e in ipairs(events)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]={e.kind,e.geometryId,e.discId,e.discA,e.discB,e.penetration,e.impulse,e.normalX,e.normalY}end end
  result.variants[test.id][v.id]={temporal=v.t,order=v.o,properties=v.p,substeps=n,discs=discs,contacts=contacts,planeOrder=(function()local a={}for _,p in ipairs(w.planes)do a[#a+1]=p.id end return a end)()}
 end
end
m:Destroy();profileClone:Destroy()
return game:GetService("HttpService"):JSONEncode(result)
