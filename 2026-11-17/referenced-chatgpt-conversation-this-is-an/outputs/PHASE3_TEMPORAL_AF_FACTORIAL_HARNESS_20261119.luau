-- Preserved A-F temporal controls. Single-plane fixtures make O (plane order) neutral;
-- each case's bCoef is intentionally frozen as its independent diagnostic input.
-- Execute in Edit through MCP. No production Source is edited.
local sourceCoreScript=game:GetService("ServerScriptService").HaxballLab.PhysicsCore2D
local ServerStorage=game:GetService("ServerStorage")
local source=sourceCoreScript.Source
local function replaceOne(src,old,new,label)
 local a,b=src:find(old,1,true);assert(a,label.." anchor missing");assert(not src:find(old,b+1,true),label.." anchor not unique")
 return src:sub(1,a-1)..new..src:sub(b+1)
end
local diagnostic=replaceOne(source,"world.lastSubsteps=substeps\n","world.lastSubsteps=substeps\n    if world.config.forceSinglePass then substeps=1;world.lastSubsteps=1 end\n","select tick pass")
diagnostic=replaceOne(diagnostic,"        -- Preserve declared solver order inside each microstep.\n",
"        if world.config.temporalMode==\"fullTickBeforeContacts\" and substep==1 then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then local damp=(d.kind==\"player\" and d.kickArmed) and d.kickDamping or d.damping;d.vx=(d.vx+d.gravityX)*damp;d.vy=(d.vy+d.gravityY)*damp end end end\n        -- Preserve declared solver order inside each microstep.\n","pre-contact damping")
diagnostic=replaceOne(diagnostic,
"    for _,disc in ipairs(world.discs) do\n        if disc.enabled and disc.invMass>0 then\n            local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping\n            disc.vx=(disc.vx+disc.gravityX)*damping\n            disc.vy=(disc.vy+disc.gravityY)*damping\n        end\n    end\n\n    world.tick += 1",
"    if world.config.temporalMode~=\"fullTickBeforeContacts\" then for _,disc in ipairs(world.discs) do if disc.enabled and disc.invMass>0 then local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping;disc.vx=(disc.vx+disc.gravityX)*damping;disc.vy=(disc.vy+disc.gravityY)*damping end end end\n\n    world.tick += 1","post-contact damping")
local module=Instance.new("ModuleScript");module.Name="Phase3AFTemporalCore";module.Source=diagnostic;module.Parent=ServerStorage
local Core=require(module)
local CASES={{id="A_perpendicular",x=100,y=149,vx=0,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="B_oblique",x=100,y=149,vx=20,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="C_v10",x=100,y=150,vx=0,vy=10,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="C_v20",x=100,y=150,vx=0,vy=20,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="C_v40",x=100,y=150,vx=0,vy=40,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="C_v50",x=100,y=150,vx=0,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="D_y140",x=100,y=140,vx=0,vy=20,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="D_y148.5",x=100,y=148.5,vx=0,vy=20,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="D_y155",x=100,y=155,vx=0,vy=20,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="E_planeB0",x=100,y=149,vx=0,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=0,group=32,mask=1},
{id="E_planeB0.5",x=100,y=149,vx=0,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=0.5,group=32,mask=1},
{id="E_planeB1",x=100,y=149,vx=0,vy=50,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1},
{id="E_outerB0",x=100,y=190,vx=0,vy=20,radius=10,nx=0,ny=-1,offset=-200,b=0,group=32,mask=63},
{id="F_opposite",x=100,y=180,vx=0,vy=-20,radius=10,nx=0,ny=-1,offset=-170,b=1,group=32,mask=1}}
local output={schemaVersion=1,source="Preserved PHASE3_TEMPORAL_FIXTURE_INPUTS_A-F_20261119.json; full precision values; no inferred fixture inputs",cases={}}
for _,c in ipairs(CASES) do
 local row={id=c.id,initial={x=c.x,y=c.y,vx=c.vx,vy=c.vy,radius=c.radius},plane={normalX=c.nx,normalY=c.ny,offset=c.offset,bCoef=c.b,collisionGroup=c.group,collisionMask=c.mask},variants={}}
 for _,temporal in ipairs({"substepResolve","fullTickBeforeContacts"}) do for _,order in ipairs({"core","node"}) do
  local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=temporal=="fullTickBeforeContacts",temporalMode=temporal})
  local d=Core.addDisc(w,{id="ball",kind="ball",x=c.x,y=c.y,vx=c.vx,vy=c.vy,radius=c.radius,invMass=1,damping=.99,bCoef=.5,collisionGroup=1,collisionMask=63})
  Core.addPlane(w,{id="fixture:plane",normalX=c.nx,normalY=c.ny,offset=c.offset,bCoef=c.b,collisionGroup=c.group,collisionMask=c.mask})
  local _,events,n=Core.stepWorld(w,{})
  local contacts={}
  for _,e in ipairs(events) do if e.kind=="planeContact" or e.kind=="segmentContact" or e.kind=="discContact" then contacts[#contacts+1]={e.kind,e.geometryId,e.penetration,e.impulse,e.normalX,e.normalY} end end
  row.variants[(temporal=="substepResolve" and "T0" or "T1")..(order=="core" and "O0" or "O1")]={temporal=temporal,order=order,properties="case-defined; held fixed",state={x=d.x,y=d.y,vx=d.vx,vy=d.vy},substeps=n,contacts=contacts}
 end end
 output.cases[#output.cases+1]=row
end
module:Destroy()
return game:GetService("HttpService"):JSONEncode(output)
