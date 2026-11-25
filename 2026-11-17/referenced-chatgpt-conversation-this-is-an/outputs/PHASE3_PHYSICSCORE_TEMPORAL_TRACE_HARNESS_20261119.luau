-- Scenario 3 tick 4 temporal probe.
-- Run through mcp__Roblox_Studio.execute_luau in Edit mode. Creates only transient
-- ModuleScripts under ServerStorage and fresh in-memory worlds, then destroys clones.
-- It does not edit PhysicsCore2D or StadiumReference2D.
local productCoreScript = game:GetService("ServerScriptService").HaxballLab.PhysicsCore2D
local productSource = productCoreScript.Source

local function instrument(source, substepsOverride)
    local function replaceOne(old, new, label)
        local first, last = source:find(old, 1, true)
        assert(first, label .. " anchor missing")
        assert(not source:find(old, last + 1, true), label .. " anchor not unique")
        source = source:sub(1, first - 1) .. new .. source:sub(last + 1)
    end
    replaceOne('local events,eventKeys = {},{}\n    world.motionSegments={}\n',
        'local events,eventKeys = {},{}\n    world.motionSegments={}\n' ..
        '    local function temporalRecord(phase,substep,disc,extra)\n' ..
        '        if not world.temporalTrace or not disc then return end\n' ..
        '        local row={phase=phase,tick=world.tick+1,substep=substep,x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy}\n' ..
        '        if extra then for key,value in pairs(extra) do row[key]=value end end\n' ..
        '        table.insert(world.temporalTrace,row)\n' ..
        '    end\n' ..
        '    temporalRecord("tick_start",0,world.discs[1])\n', "trace helper")
    replaceOne('applyInputAndKick(world, inputs, events)\n\n    local maxSpeed',
        'applyInputAndKick(world, inputs, events)\n    temporalRecord("after_input",0,world.discs[1])\n\n    local maxSpeed', "input")
    replaceOne('world.lastSubsteps=substeps\n',
        'world.lastSubsteps=substeps\n' ..
        (substepsOverride and ('    substeps=' .. substepsOverride .. '\n    world.lastSubsteps=substepsOverride\n') or '') ..
        '    temporalRecord("substep_count",0,world.discs[1],{substeps=substeps,dtPerSubstep=1/substeps})\n', "substep count")
    replaceOne('for substep=1,substeps do\n        for _,disc',
        'for substep=1,substeps do\n        world.currentTemporalSubstep=substep\n' ..
        '        temporalRecord("substep_start",substep,world.discs[1])\n        for _,disc', "substep start")
    replaceOne('        -- Preserve declared solver order inside each microstep.\n',
        '        temporalRecord("after_substep_motion",substep,world.discs[1])\n' ..
        '        -- Preserve declared solver order inside each microstep.\n', "post movement")
    replaceOne('for _,plane in ipairs(world.planes) do\n        local signed=disc.x*plane.normalX+disc.y*plane.normalY-plane.offset\n        local penetration=disc.radius-signed\n        if penetration>0 then collide(plane,"planeContact",plane.normalX,plane.normalY,penetration) end\n    end',
        'for planeIndex,plane in ipairs(world.planes) do\n' ..
        '        local signed=disc.x*plane.normalX+disc.y*plane.normalY-plane.offset\n' ..
        '        local penetration=disc.radius-signed\n' ..
        '        if penetration>0 and collisionAllowed(disc,plane) then\n' ..
        '            local pre={x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy}\n' ..
        '            collide(plane,"planeContact",plane.normalX,plane.normalY,penetration)\n' ..
        '            if world.temporalTrace then table.insert(world.temporalTrace,{phase="plane_contact",tick=world.tick+1,substep=world.currentTemporalSubstep,planeOrder=planeIndex,planeId=plane.id,normalX=plane.normalX,normalY=plane.normalY,offset=plane.offset,bCoef=plane.bCoef,penetration=penetration,pre=pre,post={x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy},positionCorrection={x=disc.x-pre.x,y=disc.y-pre.y},deltaVelocity={x=disc.vx-pre.vx,y=disc.vy-pre.vy}}) end\n' ..
        '        end\n    end', "plane trace")
    replaceOne('local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping\n' ..
        '            disc.vx=(disc.vx+disc.gravityX)*damping\n' ..
        '            disc.vy=(disc.vy+disc.gravityY)*damping',
        'local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping\n' ..
        '            local beforeDamping={x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy}\n' ..
        '            disc.vx=(disc.vx+disc.gravityX)*damping\n' ..
        '            disc.vy=(disc.vy+disc.gravityY)*damping\n' ..
        '            temporalRecord("after_tick_damping",substeps,disc,{damping=damping,before=beforeDamping})', "damping")
    return source
end

local function loadTemporary(name, substepsOverride)
    local module = Instance.new("ModuleScript")
    module.Name = name
    module.Source = instrument(productSource, substepsOverride)
    module.Parent = game:GetService("ServerStorage")
    return module, require(module)
end

local function run(Core, substepsOverride, nodeObservedContactOrder, collectTrace)
    local world = Core.newWorld({useBounds=false,maxSubsteps=64})
    -- Only the two contacts relevant at tick 4 are retained from the exact
    -- source stadium geometry. In the full Core plane list these are positions 2 and 4.
    local inner = Core.addPlane(world, {id="classic:ballArea:top",normalX=0,normalY=-1,offset=-170,bCoef=1,collisionGroup=32,collisionMask=1})
    local outer = Core.addPlane(world, {id="classic:outer:top",normalX=0,normalY=-1,offset=-200,bCoef=0.1,collisionGroup=32,collisionMask=63})
    local ball = Core.addDisc(world, {id="ball",kind="ball",x=118.80399999999997,y=148.5049999999999,vx=38.81196,vy=48.51495,radius=10,invMass=1,damping=0.99,bCoef=0.5,collisionGroup=1,collisionMask=63})
    if nodeObservedContactOrder then world.planes={outer,inner} end
    world.tick=3 -- seed with the verified state immediately before logical tick 4
    if collectTrace then world.temporalTrace={} end
    local _,events,substeps=Core.stepWorld(world,{})
    local rows=world.temporalTrace or {}
    table.sort(rows,function(a,b)
        if a.substep~=b.substep then return a.substep<b.substep end
        local rank={tick_start=1,after_input=2,substep_count=3,substep_start=4,after_substep_motion=5,plane_contact=6,after_tick_damping=7}
        local ar,br=rank[a.phase] or 9,rank[b.phase] or 9
        if ar~=br then return ar<br end
        if a.phase=="plane_contact" and b.phase=="plane_contact" then return a.planeOrder<b.planeOrder end
        return false
    end)
    return {state={x=ball.x,y=ball.y,vx=ball.vx,vy=ball.vy},requestedSubsteps=substepsOverride,substeps=substeps,events=events,planeOrder=(function() local a={} for i,p in ipairs(world.planes) do a[i]=p.id end return a end)(),properties={ballBCoef=ball.bCoef,damping=ball.damping,innerTopBCoef=inner.bCoef,outerTopBCoef=outer.bCoef},timeline=rows}
end

local productCore=require(productCoreScript)
local baseline=run(productCore,false,false,false)
local passiveModule,passiveCore=loadTemporary("Phase3TemporalPassiveProbe",false)
local passive=run(passiveCore,false,false,true)
local oneModule,oneCore=loadTemporary("Phase3TemporalSingleStepProbe",1)
local singleCurrentOrder=run(oneCore,1,false,true)
local singleNodeObservedOrder=run(oneCore,1,true,true)
local substepSweep={}
for _,count in ipairs({13,8,4,2,1}) do
    local sweepModule,sweepCore=loadTemporary("Phase3TemporalSubstepSweep"..count,count)
    substepSweep[tostring(count)]=run(sweepCore,count,false,true)
    sweepModule:Destroy()
end
passiveModule:Destroy()
oneModule:Destroy()
return {
    seed={tick=3,x=118.80399999999997,y=148.5049999999999,vx=38.81196,vy=48.51495,radius=10},
    baseline=baseline,
    passiveInstrumentation=passive,
    singleStepCurrentOrder=singleCurrentOrder,
    singleStepNodeObservedContactOrderCurrentProperties=singleNodeObservedOrder,
    substepSweep=substepSweep,
    passiveEquivalent=baseline.state.x==passive.state.x and baseline.state.y==passive.state.y and baseline.state.vx==passive.state.vx and baseline.state.vy==passive.state.vy and baseline.substeps==passive.substeps
}
