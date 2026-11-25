-- Factorial temporal/order/property experiment for the three preserved Classic fixtures.
-- Execute in Roblox Studio Edit via MCP. This creates transient ModuleScript clones only.
-- Set SCENARIO_ID, LAST_TICK, FIRST_TICK before running. It never edits or saves the Place.
local SCENARIO_ID = "S3"
local FIRST_TICK = 1
local LAST_TICK = 10
local sourceCoreScript = game:GetService("ServerScriptService").HaxballLab.PhysicsCore2D
local sourceProfileScript = game:GetService("ReplicatedStorage").HaxballLab.StadiumReference2D
local sourceCore = sourceCoreScript.Source
local sourceProfile = sourceProfileScript.Source
local ServerStorage = game:GetService("ServerStorage")

local sourceProfileClone = Instance.new("ModuleScript")
sourceProfileClone.Name = "Phase3FactorialFreshProfile"
sourceProfileClone.Source = sourceProfile
sourceProfileClone.Parent = ServerStorage
local Profile = require(sourceProfileClone)

local function replaceOne(src, old, new, label)
    local first, last = src:find(old, 1, true)
    assert(first, label .. " source anchor missing")
    assert(not src:find(old, last + 1, true), label .. " anchor not unique")
    return src:sub(1, first - 1) .. new .. src:sub(last + 1)
end

local diagnosticSource = sourceCore
diagnosticSource = replaceOne(diagnosticSource,
    "world.lastSubsteps=substeps\n",
    "world.lastSubsteps=substeps\n" ..
    "    if world.config.forceSinglePass then substeps=1; world.lastSubsteps=1 end\n",
    "temporal mode selection")
diagnosticSource = replaceOne(diagnosticSource,
    "        -- Preserve declared solver order inside each microstep.\n",
    "        if world.config.temporalMode == \"fullTickBeforeContacts\" and substep == 1 then\n" ..
    "            for _,d in ipairs(world.discs) do\n" ..
    "                if d.enabled and d.invMass > 0 then\n" ..
    "                    local damping=(d.kind==\"player\" and d.kickArmed) and d.kickDamping or d.damping\n" ..
    "                    d.vx=(d.vx+d.gravityX)*damping; d.vy=(d.vy+d.gravityY)*damping\n" ..
    "                end\n            end\n        end\n" ..
    "        -- Preserve declared solver order inside each microstep.\n",
    "pre-contact full-tick velocity integration")
diagnosticSource = replaceOne(diagnosticSource,
    "    for _,disc in ipairs(world.discs) do\n        if disc.enabled and disc.invMass>0 then\n            local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping\n            disc.vx=(disc.vx+disc.gravityX)*damping\n            disc.vy=(disc.vy+disc.gravityY)*damping\n        end\n    end\n\n    world.tick += 1",
    "    if world.config.temporalMode ~= \"fullTickBeforeContacts\" then\n" ..
    "        for _,disc in ipairs(world.discs) do\n" ..
    "            if disc.enabled and disc.invMass>0 then\n" ..
    "                local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping\n" ..
    "                disc.vx=(disc.vx+disc.gravityX)*damping\n" ..
    "                disc.vy=(disc.vy+disc.gravityY)*damping\n" ..
    "            end\n        end\n    end\n\n    world.tick += 1",
    "single damping pass selection")
local DiagnosticCoreScript = Instance.new("ModuleScript")
DiagnosticCoreScript.Name = "Phase3FactorialCore"
DiagnosticCoreScript.Source = diagnosticSource
DiagnosticCoreScript.Parent = ServerStorage
local Core = require(DiagnosticCoreScript)

local SCENARIOS = {
    S1={red=1,blue=1,ballVx=8,ballVy=55,ticks=180},
    S2={red=1,blue=1,ballVx=-30,ballVy=45,ticks=13},
    S3={red=3,blue=3,ballVx=40,ballVy=50,ticks=180},
}
local scenario=assert(SCENARIOS[SCENARIO_ID],"unknown scenario")
assert(FIRST_TICK>=1 and LAST_TICK>=FIRST_TICK and LAST_TICK<=scenario.ticks,"invalid tick range")
local NODE_ORDER={
    "classic:outer:bottom","classic:outer:top","classic:outer:left","classic:outer:right",
    "classic:ballArea:bottom","classic:ballArea:top",
}
local variants={}
for _,temporal in ipairs({"substepResolve","fullTickBeforeContacts"}) do
    for _,order in ipairs({"core","node"}) do
        for _,properties in ipairs({"core","node"}) do
            variants[#variants+1]={id=(temporal=="substepResolve" and "T0" or "T1")..(order=="core" and "O0" or "O1")..(properties=="core" and "P0" or "P1"),temporal=temporal,order=order,properties=properties}
        end
    end
end
local function buildWorld(v)
    local world=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=v.temporal=="fullTickBeforeContacts",temporalMode=v.temporal})
    local ball=Core.addDisc(world,{id="ball",kind="ball",x=0,y=0,vx=scenario.ballVx,vy=scenario.ballVy,radius=10,invMass=1,damping=.99,bCoef=.5,collisionGroup=Profile.CollisionGroups.ball,collisionMask=Profile.CollisionMasks.ball})
    for _,p in ipairs(Profile.Geometry.planes) do Core.addPlane(world,table.clone(p)) end
    for _,s in ipairs(Profile.Geometry.segments) do Core.addSegment(world,table.clone(s)) end
    for _,p in ipairs(Profile.Geometry.posts) do
        Core.addDisc(world,{id=p.id,kind="post",x=p.x,y=p.y,radius=p.radius,invMass=0,damping=1,bCoef=p.bCoef,collisionGroup=Profile.CollisionGroups.post,collisionMask=Profile.CollisionMasks.all})
    end
    for team=1,2 do
        local count=team==1 and scenario.red or scenario.blue
        local teamFlag=team==1 and Profile.CollisionGroups.red or Profile.CollisionGroups.blue
        for n=1,count do
            local playerId=(team==1 and n or scenario.red+n)
            local y=0
            if n==2 then y=55 elseif n==3 then y=-55 end
            local x=team==1 and -277.5 or 277.5
            Core.addDisc(world,{id=playerId,kind="player",team=team,x=x,y=y,radius=15,invMass=.5,damping=.96,bCoef=.5,collisionGroup=teamFlag,collisionMask=Profile.CollisionMasks.player,acceleration=.1,kickAcceleration=.07,kickDamping=.96})
        end
    end
    if v.order=="node" then
        local byId={}
        for _,p in ipairs(world.planes) do byId[p.id]=p end
        local arranged={}
        for _,id in ipairs(NODE_ORDER) do assert(byId[id],"Node plane absent from freshly loaded Source profile: "..id);arranged[#arranged+1]=byId[id] end
        world.planes=arranged
    end
    if v.properties=="node" then
        for _,p in ipairs(world.planes) do
            if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 end
        end
    end
    return world,ball
end
local result={
    schemaVersion=1,scenario=SCENARIO_ID,range={first=FIRST_TICK,last=LAST_TICK,totalTicks=scenario.ticks},
    profile={sourceModulePath=sourceProfileScript:GetFullName(),sourceFreshClone=true,profileId=Profile.Metadata.id,sourceCommit=Profile.Metadata.sourceCommit,groups=Profile.CollisionGroups,masks=Profile.CollisionMasks},
    fixture={initialBall={x=0,y=0,vx=scenario.ballVx,vy=scenario.ballVy,radius=10,invMass=1,bCoef=.5,damping=.99,cGroup=Profile.CollisionGroups.ball,cMask=Profile.CollisionMasks.ball},playerTemplate={radius=15,invMass=.5,bCoef=.5,damping=.96,mask=Profile.CollisionMasks.player,redGroup=Profile.CollisionGroups.red,blueGroup=Profile.CollisionGroups.blue},zeroInputs=true,geometryCounts={planes=#Profile.Geometry.planes,segments=#Profile.Geometry.segments,posts=#Profile.Geometry.posts}},
    variants={}
}
for _,v in ipairs(variants) do
    local world,ball=buildWorld(v)
    local planeOrder,planeProps={},{}
    for i,p in ipairs(world.planes) do planeOrder[i]=p.id;planeProps[i]={id=p.id,bCoef=p.bCoef,normalX=p.normalX,normalY=p.normalY,offset=p.offset,collisionGroup=p.collisionGroup,collisionMask=p.collisionMask} end
    local rows={}
    for tick=1,LAST_TICK do
        local _,events,substeps=Core.stepWorld(world,{})
        if tick>=FIRST_TICK then
            local discs={}
            for _,d in ipairs(world.discs) do
                if d.invMass>0 and (d.kind=="ball" or d.vx~=0 or d.vy~=0) then discs[#discs+1]={d.id,d.x,d.y,d.vx,d.vy} end
            end
            local contacts={}
            for _,e in ipairs(events) do if e.kind=="planeContact" or e.kind=="segmentContact" or e.kind=="discContact" or e.kind=="boundaryContact" then contacts[#contacts+1]={e.kind,e.geometryId,e.discId,e.discA,e.discB,e.penetration,e.impulse,e.normalX,e.normalY} end end
            rows[#rows+1]={tick=tick,substeps=substeps,discs=discs,contacts=contacts}
        end
    end
    result.variants[v.id]={temporal=v.temporal,order=v.order,properties=v.properties,planeOrder=planeOrder,planeProperties=planeProps,rows=rows}
end
DiagnosticCoreScript:Destroy()
sourceProfileClone:Destroy()
return game:GetService("HttpService"):JSONEncode(result)
