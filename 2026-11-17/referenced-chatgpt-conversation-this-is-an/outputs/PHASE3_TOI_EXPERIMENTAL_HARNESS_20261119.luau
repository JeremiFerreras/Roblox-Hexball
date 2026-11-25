-- Phase 3 diagnostic continuous time-of-impact harness.
-- Runs only in Studio Edit; clones source modules to ServerStorage and destroys them.
local STUDIO_ID = "3e731d6a-4da2-40c5-a4e1-74d65208d2b0"
local MODE = "controls" -- scenarios | controls | micro
local SCENARIO_ID = "S3"
local FIRST_TICK, LAST_TICK = 1, 8
local CONTROL_ID = "goal_net_contact"
local MICRO_ID = "A_perpendicular"
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sourceCoreScript = game:GetService("ServerScriptService").HaxballLab.PhysicsCore2D
local sourceProfileScript = ReplicatedStorage.HaxballLab.StadiumReference2D
local profileClone = Instance.new("ModuleScript")
profileClone.Name = "Phase3TOIFreshProfile"
profileClone.Source = sourceProfileScript.Source
profileClone.Parent = ServerStorage
local Profile = require(profileClone)
local source = sourceCoreScript.Source
local function replaceOne(src, old, new, label)
    local a,b=src:find(old,1,true); assert(a,label.." anchor missing")
    assert(not src:find(old,b+1,true),label.." anchor duplicated")
    return src:sub(1,a-1)..new..src:sub(b+1)
end

-- T1 reference clone: full displacement, one discrete pass, velocity update before contacts.
local t1Source=source
t1Source=replaceOne(t1Source,"world.lastSubsteps=substeps\n","world.lastSubsteps=substeps\n    if world.config.forceSinglePass then substeps=1;world.lastSubsteps=1 end\n","T1 pass")
t1Source=replaceOne(t1Source,"        -- Preserve declared solver order inside each microstep.\n",
"        if world.config.temporalMode==\"fullTickBeforeContacts\" and substep==1 then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then local damp=(d.kind==\"player\" and d.kickArmed) and d.kickDamping or d.damping;d.vx=(d.vx+d.gravityX)*damp;d.vy=(d.vy+d.gravityY)*damp end end end\n        -- Preserve declared solver order inside each microstep.\n","T1 pre-update")
t1Source=replaceOne(t1Source,
"    for _,disc in ipairs(world.discs) do\n        if disc.enabled and disc.invMass>0 then\n            local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping\n            disc.vx=(disc.vx+disc.gravityX)*damping\n            disc.vy=(disc.vy+disc.gravityY)*damping\n        end\n    end\n\n    world.tick += 1",
"    if world.config.temporalMode~=\"fullTickBeforeContacts\" then for _,disc in ipairs(world.discs) do if disc.enabled and disc.invMass>0 then local damping=(disc.kind==\"player\" and disc.kickArmed) and disc.kickDamping or disc.damping;disc.vx=(disc.vx+disc.gravityX)*damping;disc.vy=(disc.vy+disc.gravityY)*damping end end end\n\n    world.tick += 1","T1 post-update")
local t1Module=Instance.new("ModuleScript");t1Module.Name="Phase3TOIT1Core";t1Module.Source=t1Source;t1Module.Parent=ServerStorage
local T1=require(t1Module)

-- Insert a diagnostic TOI cycle in a separate Core clone, reusing source resolver math
-- and adding continuous candidate generation and per-impact re-detection.
local toiStep=[=[
function Core.stepWorld(world, inputs)
    assert(type(world)=="table" and type(world.discs)=="table","invalid world")
    inputs=inputs or {}
    local started=os.clock()
    local events,eventKeys={},{}
    local trace={}
    world.motionSegments={}
    applyInputAndKick(world,inputs,events)
    -- Preserve the Core's velocity update semantics: use pre-damping velocity
    -- for motion and impacts, then apply gravity/damping once at tick end.
    local remaining=1
    local maxEvents=32
    local timeEps=1e-9
    local posSlop=1e-7
    local velEps=1e-9
    local stats={candidateTests=0,validCandidates=0,discardedMask=0,discardedSeparating=0,discardedOutOfRange=0,iterations=0,eventLimit=false,zeroTimeEvents=0,curvedArcTests=0}
    local function keyOf(x) return typeof(x)..":"..tostring(x) end
    local function better(c,best)
        if not best then return true end
        if c.t < best.t-timeEps then return true end
        if math.abs(c.t-best.t)>timeEps then return false end
        local function rank(v)
            if world.config.toiOrder=="node" then
                if v.kind=="plane" then return 1 elseif v.kind=="segment" then return 2 elseif v.kind=="pair" then return 3 else return 4 end
            else
                if v.kind=="pair" then return 1 elseif v.kind=="bounds" then return 2 elseif v.kind=="plane" then return 3 else return 4 end
            end
        end
        local ra,rb=rank(c),rank(best)
        if ra~=rb then return ra<rb end
        if (c.geometryIndex or c.discIndex or 0)~=(best.geometryIndex or best.discIndex or 0) then return (c.geometryIndex or c.discIndex or 0)<(best.geometryIndex or best.discIndex or 0) end
        return tostring(c.geometry and c.geometry.id or c.a and c.a.id or "") < tostring(best.geometry and best.geometry.id or best.a and best.a.id or "")
    end
    local function addCandidate(candidates,c)
        if c.t < -timeEps or c.t > remaining+timeEps then stats.discardedOutOfRange+=1;return end
        c.t=math.max(0,math.min(remaining,c.t))
        candidates[#candidates+1]=c;stats.validCandidates+=1
    end
    local function closestOnSegment(seg,x,y)
        local qx,qy
        if seg.arc then
            local arc=seg.arc
            local angle=math.atan2(y-arc.centerY,x-arc.centerX)
            local delta=arc.sweep>=0 and ((angle-arc.startAngle)%(2*math.pi)) or ((arc.startAngle-angle)%(2*math.pi))
            if delta<=math.abs(arc.sweep)+1e-9 then qx=arc.centerX+arc.radius*math.cos(angle);qy=arc.centerY+arc.radius*math.sin(angle)
            else
                local ds=(x-seg.x1)^2+(y-seg.y1)^2;local de=(x-seg.x2)^2+(y-seg.y2)^2
                if ds<=de then qx,qy=seg.x1,seg.y1 else qx,qy=seg.x2,seg.y2 end
            end
        else
            local sx,sy=seg.x2-seg.x1,seg.y2-seg.y1
            local len2=sx*sx+sy*sy
            local t=math.clamp(((x-seg.x1)*sx+(y-seg.y1)*sy)/len2,0,1)
            qx,qy=seg.x1+t*sx,seg.y1+t*sy
        end
        local dx,dy=x-qx,y-qy;local d=math.sqrt(dx*dx+dy*dy)
        local nx,ny
        if d>1e-14 then nx,ny=dx/d,dy/d
        elseif seg.arc then local a=seg.arc.startAngle+seg.arc.sweep*.5;nx,ny=math.cos(a),math.sin(a)
        else local sx,sy=seg.x2-seg.x1,seg.y2-seg.y1;local len=math.sqrt(sx*sx+sy*sy);nx,ny=-sy/len,sx/len end
        if not seg.twoSided and not seg.arc then
            local sx,sy=seg.x2-seg.x1,seg.y2-seg.y1;local len=math.sqrt(sx*sx+sy*sy)
            if (x-seg.x1)*(-sy/len)+(y-seg.y1)*(sx/len)<0 then nx,ny=-nx,-ny end
        end
        return qx,qy,d,nx,ny
    end
    local function sweepCircle(x,y,vx,vy,cx,cy,radius,maxT)
        local rx,ry=x-cx,y-cy;local c=rx*rx+ry*ry-radius*radius
        local aa=vx*vx+vy*vy
        local rv=rx*vx+ry*vy
        if c<=posSlop then
            if rv < -velEps or c < -posSlop then return 0 end
            return nil
        end
        if aa<=1e-24 then return nil end
        local disc=rv*rv-aa*c
        if disc<0 then return nil end
        local t=(-rv-math.sqrt(disc))/aa
        if t>=-timeEps and t<=maxT+timeEps and rv+aa*t< -velEps then return math.max(0,t) end
        return nil
    end
    local function gather()
        local candidates={}
        -- Planes and segments in the configured arrays.
        for di,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then
            for gi,p in ipairs(world.planes) do
                stats.candidateTests+=1
                if collisionAllowed(d,p) then
                    local signed=d.x*p.normalX+d.y*p.normalY-p.offset
                    local gap=signed-d.radius;local vn=d.vx*p.normalX+d.vy*p.normalY
                    if gap<=posSlop then
                        if gap < -posSlop or vn < -velEps then addCandidate(candidates,{t=0,kind="plane",disc=d,geometry=p,nx=p.normalX,ny=p.normalY,geometryIndex=gi,penetration=math.max(0,-gap)})
                        else stats.discardedSeparating+=1 end
                    elseif vn < -velEps then addCandidate(candidates,{t=-gap/vn,kind="plane",disc=d,geometry=p,nx=p.normalX,ny=p.normalY,geometryIndex=gi})
                    else stats.discardedSeparating+=1 end
                else stats.discardedMask+=1 end
            end
            for gi,s in ipairs(world.segments) do
                stats.candidateTests+=1
                if collisionAllowed(d,s) then
                    local qx,qy,dist,nx,ny=closestOnSegment(s,d.x,d.y)
                    local vn=d.vx*nx+d.vy*ny
                    local initialGap=dist-d.radius
                    local hitT=nil
                    if initialGap<=posSlop then
                        if initialGap < -posSlop or vn < -velEps then hitT=0 else stats.discardedSeparating+=1 end
                    elseif s.arc then
                        stats.curvedArcTests+=1
                        local arc=s.arc;local rx,ry=d.x-arc.centerX,d.y-arc.centerY;local aa=d.vx*d.vx+d.vy*d.vy
                        local earliest=nil
                        local function onArc(t)
                            if t< -timeEps or t>remaining+timeEps then return end
                            local hx,hy=d.x+d.vx*t,d.y+d.vy*t
                            local angle=math.atan2(hy-arc.centerY,hx-arc.centerX)
                            local delta=arc.sweep>=0 and ((angle-arc.startAngle)%(2*math.pi)) or ((arc.startAngle-angle)%(2*math.pi))
                            if delta>math.abs(arc.sweep)+1e-8 then return end
                            local _,_,dd,hnx,hny=closestOnSegment(s,hx,hy)
                            if math.abs(dd-d.radius)<=1e-5 and d.vx*hnx+d.vy*hny< -velEps then
                                if not earliest or t<earliest then earliest=math.max(0,t) end
                            end
                        end
                        if aa>1e-24 then
                            local targets={arc.radius+d.radius,arc.radius-d.radius}
                            for _,target in ipairs(targets)do if target>0 then
                                local bb=2*(rx*d.vx+ry*d.vy);local cc=rx*rx+ry*ry-target*target
                                local disc=bb*bb-4*aa*cc
                                if disc>=0 then local root=math.sqrt(disc);onArc((-bb-root)/(2*aa));onArc((-bb+root)/(2*aa))end
                            end end
                        end
                        for _,ep in ipairs({{s.x1,s.y1},{s.x2,s.y2}})do
                            local t=sweepCircle(d.x,d.y,d.vx,d.vy,ep[1],ep[2],d.radius,remaining)
                            if t then local hx,hy=d.x+d.vx*t,d.y+d.vy*t;local nx,ny=hx-ep[1],hy-ep[2];local nl=math.sqrt(nx*nx+ny*ny);if nl>1e-12 and d.vx*(nx/nl)+d.vy*(ny/nl)< -velEps and (not earliest or t<earliest)then earliest=t end end
                        end
                        hitT=earliest
                    else
                        local sx,sy=s.x2-s.x1,s.y2-s.y1;local length=math.sqrt(sx*sx+sy*sy)
                        local ux,uy=sx/length,sy/length;local lnX,lnY=-uy,ux
                        local earliest=nil
                        local sides=s.twoSided and {-1,1} or {1}
                        for _,side in ipairs(sides)do
                            local snx,sny=lnX*side,lnY*side
                            local gap=(d.x-s.x1)*snx+(d.y-s.y1)*sny-d.radius
                            local closing=d.vx*snx+d.vy*sny
                            if closing < -velEps then
                                local t=-gap/closing
                                if t>=-timeEps and t<=remaining+timeEps then
                                    local hx=d.x+d.vx*t;local hy=d.y+d.vy*t
                                    local along=(hx-s.x1)*ux+(hy-s.y1)*uy
                                    if along>=-posSlop and along<=length+posSlop and (not earliest or t<earliest) then earliest=math.max(0,t) end
                                end
                            end
                        end
                        for _,ep in ipairs({{s.x1,s.y1},{s.x2,s.y2}})do
                            local t=sweepCircle(d.x,d.y,d.vx,d.vy,ep[1],ep[2],d.radius,remaining)
                            if t and (not earliest or t<earliest)then
                                local hx=d.x+d.vx*t;local hy=d.y+d.vy*t
                                local rx,ry=hx-ep[1],hy-ep[2];local rl=math.sqrt(rx*rx+ry*ry)
                                if rl>1e-12 then local snx,sny=rx/rl,ry/rl;local closing=d.vx*snx+d.vy*sny;if closing< -velEps then earliest=t end end
                            end
                        end
                        hitT=earliest
                    end
                    if hitT then
                        local x=d.x+d.vx*hitT;local y=d.y+d.vy*hitT
                        local _,_,_,hnx,hny=closestOnSegment(s,x,y)
                        addCandidate(candidates,{t=hitT,kind="segment",disc=d,geometry=s,nx=hnx,ny=hny,geometryIndex=gi,penetration=hitT==0 and math.max(0,-initialGap) or 0})
                    end
                else stats.discardedMask+=1 end
            end
            if world.useBounds then
                local minX,maxX=-world.config.fieldHalfWidth+d.radius,world.config.fieldHalfWidth-d.radius
                local minY,maxY=-world.config.fieldHalfHeight+d.radius,world.config.fieldHalfHeight-d.radius
                local bcs={{value=minX,pos=d.x,v=d.vx,nx=1,ny=0,side="left"},{value=maxX,pos=d.x,v=d.vx,nx=-1,ny=0,side="right"},{value=minY,pos=d.y,v=d.vy,nx=0,ny=1,side="bottom"},{value=maxY,pos=d.y,v=d.vy,nx=0,ny=-1,side="top"}}
                for bi,b in ipairs(bcs) do stats.candidateTests+=1;local gap=(b.pos-b.value)*-((b.side=="left" or b.side=="bottom") and 1 or -1);local vn=d.vx*b.nx+d.vy*b.ny
                    local penetrated=(b.side=="left" and d.x<minX-posSlop)or(b.side=="right" and d.x>maxX+posSlop)or(b.side=="bottom" and d.y<minY-posSlop)or(b.side=="top" and d.y>maxY+posSlop)
                    if penetrated or (math.abs(b.pos-b.value)<=posSlop and vn< -velEps) then addCandidate(candidates,{t=0,kind="bounds",disc=d,nx=b.nx,ny=b.ny,side=b.side,value=b.value,geometryIndex=bi})
                    elseif vn< -velEps then local axis=(b.nx~=0) and d.vx or d.vy;local t=(b.value-b.pos)/axis
                        addCandidate(candidates,{t=t,kind="bounds",disc=d,nx=b.nx,ny=b.ny,side=b.side,value=b.value,geometryIndex=bi})
                    else stats.discardedSeparating+=1 end
                end
            end
        end end
        -- Dynamic pairs (including ball/player) with exact swept-circle TOI.
        for i=1,#world.discs do local a=world.discs[i];if a.enabled then
            for j=i+1,#world.discs do local b=world.discs[j];if b.enabled and (a.invMass>0 or b.invMass>0) then
                stats.candidateTests+=1
                if collisionAllowed(a,b) then
                    local rx,ry=a.x-b.x,a.y-b.y;local vx,vy=a.vx-b.vx,a.vy-b.vy
                    local radius=a.radius+b.radius;local dist2=rx*rx+ry*ry;local radial=rx*vx+ry*vy
                    local hit
                    if dist2<=radius*radius+posSlop then
                        if dist2<radius*radius-posSlop or radial < -velEps then hit=0 else stats.discardedSeparating+=1 end
                    else
                        local aa=vx*vx+vy*vy;local disc=radial*radial-aa*(dist2-radius*radius)
                        if aa>1e-24 and disc>=0 then local t=(-radial-math.sqrt(disc))/aa;if t>=-timeEps and t<=remaining+timeEps and radial+aa*t< -velEps then hit=math.max(0,t) end end
                    end
                    if hit then local hx,hy=rx+vx*hit,ry+vy*hit;local hl=math.sqrt(hx*hx+hy*hy);local nx,ny=hl>1e-12 and hx/hl or -1,hl>1e-12 and hy/hl or 0;addCandidate(candidates,{t=hit,kind="pair",a=a,b=b,nx=nx,ny=ny,discIndex=i,pairIndex=j})
                    else stats.discardedSeparating+=1 end
                else stats.discardedMask+=1 end
            end end
        end end
        local best=nil
        for _,c in ipairs(candidates) do if better(c,best) then best=c end end
        return best,candidates
    end
    while remaining>timeEps and stats.iterations<maxEvents do
        stats.iterations+=1
        local best,candidates=gather()
        if not best then
            for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*remaining;d.y+=d.vy*remaining end end
            remaining=0
            break
        end
        local beforeRemaining=remaining
        local pre={}
        for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then pre[keyOf(d.id)]={x=d.x,y=d.y,vx=d.vx,vy=d.vy} end end
        for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*best.t;d.y+=d.vy*best.t end end
        remaining=math.max(0,remaining-best.t)
        local disc=best.disc
        local candidateList={};for _,c in ipairs(candidates)do candidateList[#candidateList+1]={toi=c.t,kind=c.kind,geometryId=c.geometry and c.geometry.id or nil,discId=c.disc and c.disc.id or nil,discA=c.a and c.a.id or nil,discB=c.b and c.b.id or nil,normalX=c.nx,normalY=c.ny}end
        local hitRecord={toi=best.t,timeRemainingBefore=beforeRemaining,timeRemainingAfter=remaining,kind=best.kind,geometryId=best.geometry and best.geometry.id or nil,discId=disc and disc.id or nil,discA=best.a and best.a.id or nil,discB=best.b and best.b.id or nil,normalX=best.nx,normalY=best.ny,candidateCount=#candidates,candidates=candidateList,pre=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil,orderMode=world.config.toiOrder}
        if best.kind=="pair" then
            hitRecord.pairPre={a=pre[keyOf(best.a.id)],b=pre[keyOf(best.b.id)]}
            local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            best.a.x-=best.nx*posSlop*.5;best.a.y-=best.ny*posSlop*.5;best.b.x+=best.nx*posSlop*.5;best.b.y+=best.ny*posSlop*.5
            local con=resolveDiscPair(best.a,best.b)
            if con then
                con.kind="discContact";con.tick=world.tick+1;con.discA=best.a.id;con.discB=best.b.id
                local key="pair:"..keyOf(best.a.id)..":"..keyOf(best.b.id);eventKeys[key]=con;table.insert(events,con)
                hitRecord.penetration=con.penetration;hitRecord.impulse=con.impulse
            end
            hitRecord.pairPost={a={x=best.a.x,y=best.a.y,vx=best.a.vx,vy=best.a.vy},b={x=best.b.x,y=best.b.y,vx=best.b.vx,vy=best.b.vy}}
        elseif best.kind=="plane" or best.kind=="segment" then
            local correction=math.max(best.penetration or 0,posSlop)
            local g=best.geometry
            local normalVelocity=disc.vx*best.nx+disc.vy*best.ny
            local impulse=0
            if normalVelocity<0 then local change=-(1+disc.bCoef*g.bCoef)*normalVelocity;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            disc.x+=best.nx*correction;disc.y+=best.ny*correction
            local kind=best.kind=="plane" and "planeContact" or "segmentContact"
            local ev={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=g.id,normalX=best.nx,normalY=best.ny,penetration=0,impulse=impulse}
            table.insert(events,ev);hitRecord.impulse=impulse;hitRecord.penetration=0
        else
            disc.x=disc.x+best.nx*posSlop;disc.y=disc.y+best.ny*posSlop
            local vn=disc.vx*best.nx+disc.vy*best.ny
            local impulse=0;if vn<0 then local change=-(1+disc.bCoef)*vn;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            hitRecord.impulse=impulse;hitRecord.penetration=0
            local ev={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=1,side=best.side,impulse=impulse};table.insert(events,ev)
        end
        hitRecord.post=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil
        table.insert(trace,hitRecord)
        if best.t<=timeEps then stats.zeroTimeEvents+=1 end
        if best.t<=timeEps and (not hitRecord.impulse or hitRecord.impulse==0) then
            -- Avoid a t=0 repeat loop for resting/tangent or unresolved initial overlap.
            if stats.zeroTimeEvents>=4 then stats.eventLimit=true;break end
        end
    end
    if remaining>timeEps then
        if stats.iterations>=maxEvents then stats.eventLimit=true end
        for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*remaining;d.y+=d.vy*remaining end end
        remaining=0
    end
    for _,d in ipairs(world.discs) do
        if d.enabled and d.invMass>0 then
            local damp=(d.kind=="player" and d.kickArmed) and d.kickDamping or d.damping
            d.vx=(d.vx+d.gravityX)*damp; d.vy=(d.vy+d.gravityY)*damp
        end
    end
    world.tick+=1;world.events=events;world.lastSubsteps=stats.iterations
    world.toiTrace=trace;world.toiStats=stats;world.toiCostSeconds=os.clock()-started
    return world,events,stats.iterations
end
]=]
local startAt=source:find("function Core.stepWorld(world, inputs)",1,true)
local endAt=source:find("function Core.snapshot(world)",startAt,true)
assert(startAt and endAt,"stepWorld anchors absent")
local toiSource=source:sub(1,startAt-1)..toiStep.."\n"..source:sub(endAt)
local toiModule=Instance.new("ModuleScript");toiModule.Name="Phase3TOICore";toiModule.Source=toiSource;toiModule.Parent=ServerStorage
local TOI=require(toiModule)

local NODE_ORDER={"classic:outer:bottom","classic:outer:top","classic:outer:left","classic:outer:right","classic:ballArea:bottom","classic:ballArea:top"}
local VARIANTS={
 {id="A_core",engine="core",order="core",props="core"},
 {id="B_T1_node",engine="t1",order="node",props="node"},
 {id="C_TOI_core",engine="toi",order="core",props="core"},
 {id="D_TOI_coreOrder_nodeProps",engine="toi",order="core",props="node"},
 {id="E_TOI_nodeOrder_coreProps",engine="toi",order="node",props="core"},
 {id="F_TOI_node",engine="toi",order="node",props="node"},
}
local SCENARIOS={S1={red=1,blue=1,ballVx=8,ballVy=55,ticks=180},S2={red=1,blue=1,ballVx=-30,ballVy=45,ticks=13},S3={red=3,blue=3,ballVx=40,ballVy=50,ticks=180}}
local CONTROLS={
 {id="corner_stack",ball={x=415,y=195,vx=20,vy=20}},
 {id="opposite_side_outer_top",ball={x=100,y=205,vx=0,vy=-20}},
 {id="right_wall_rebound",ball={x=415,y=0,vx=20,vy=0}},
 {id="goal_net_contact",ball={x=392,y=0,vx=20,vy=0}},
 {id="ball_player_contact",ball={x=0,y=0,vx=20,vy=0},player={x=30,y=0,vx=0,vy=0,team=1}},
 {id="fast_cross_field_limit",ball={x=0,y=0,vx=3000,vy=0}},
}
local MICRO={
 {id="A_perpendicular",x=100,y=149,vx=0,vy=50,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="B_oblique",x=100,y=149,vx=20,vy=50,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="C_v10",x=100,y=150,vx=0,vy=10,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="C_v20",x=100,y=150,vx=0,vy=20,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="C_v40",x=100,y=150,vx=0,vy=40,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="C_v50",x=100,y=150,vx=0,vy=50,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="D_y140",x=100,y=140,vx=0,vy=20,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="D_y148.5",x=100,y=148.5,vx=0,vy=20,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="D_y155",x=100,y=155,vx=0,vy=20,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="E_planeB0",x=100,y=149,vx=0,vy=50,r=10,ny=-1,offset=-170,b=0,group=32,mask=1},
 {id="E_planeB0.5",x=100,y=149,vx=0,vy=50,r=10,ny=-1,offset=-170,b=.5,group=32,mask=1},
 {id="E_planeB1",x=100,y=149,vx=0,vy=50,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
 {id="E_outerB0",x=100,y=190,vx=0,vy=20,r=10,ny=-1,offset=-200,b=0,group=32,mask=63},
 {id="F_opposite",x=100,y=180,vx=0,vy=-20,r=10,ny=-1,offset=-170,b=1,group=32,mask=1},
}
local function configurePlanes(w,v)
 if v.order=="node" then local by={};for _,p in ipairs(w.planes)do by[p.id]=p end;local ordered={};for _,id in ipairs(NODE_ORDER)do if by[id]then ordered[#ordered+1]=by[id]end end;for _,p in ipairs(w.planes)do if not table.find(ordered,p)then ordered[#ordered+1]=p end end;w.planes=ordered end
 if v.props=="node" then for _,p in ipairs(w.planes)do if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 end end end
end
local function fullState(w)
 local a={};for _,d in ipairs(w.discs)do if d.enabled and d.invMass>0 then a[#a+1]={id=d.id,x=d.x,y=d.y,vx=d.vx,vy=d.vy}end end;return a
end
local function makeWorld(sc,v)
 local Core=v.engine=="core" and require((function() return sourceCoreScript end)()) or nil
 if v.engine=="t1" then Core=T1 elseif v.engine=="toi" then Core=TOI end
 local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order})
 local b=Core.addDisc(w,{id="ball",kind="ball",x=0,y=0,vx=sc.ballVx,vy=sc.ballVy,radius=10,invMass=1,damping=.99,bCoef=.5,collisionGroup=Profile.CollisionGroups.ball,collisionMask=Profile.CollisionMasks.ball})
 for _,p in ipairs(Profile.Geometry.planes)do Core.addPlane(w,table.clone(p))end
 for _,s in ipairs(Profile.Geometry.segments)do Core.addSegment(w,table.clone(s))end
 for _,p in ipairs(Profile.Geometry.posts)do Core.addDisc(w,{id=p.id,kind="post",x=p.x,y=p.y,radius=p.radius,invMass=0,damping=1,bCoef=p.bCoef,collisionGroup=Profile.CollisionGroups.post,collisionMask=Profile.CollisionMasks.all})end
 for _,team in ipairs({1,2})do local count=team==1 and sc.red or sc.blue;local group=team==1 and Profile.CollisionGroups.red or Profile.CollisionGroups.blue
  for n=1,count do local id=team==1 and n or sc.red+n;local y=n==2 and 55 or n==3 and -55 or 0;local x=team==1 and -277.5 or 277.5
   Core.addDisc(w,{id=id,kind="player",team=team,x=x,y=y,radius=15,invMass=.5,damping=.96,bCoef=.5,collisionGroup=group,collisionMask=Profile.CollisionMasks.player,acceleration=.1,kickAcceleration=.07,kickDamping=.96})
  end
 end
 configurePlanes(w,v)
 return Core,w,b
end
local function runScenario()
 local sc=assert(SCENARIOS[SCENARIO_ID])
 assert(FIRST_TICK>=1 and LAST_TICK>=FIRST_TICK and LAST_TICK<=sc.ticks)
 local out={schemaVersion=1,mode=MODE,scenario=SCENARIO_ID,profileSourceCommit=Profile.Metadata.sourceCommit,range={first=FIRST_TICK,last=LAST_TICK,totalTicks=sc.ticks},variantDefinitions=VARIANTS,rows={}}
 for _,v in ipairs(VARIANTS)do
 local Core,w,b=makeWorld(sc,v);local rows={};local costTotal,costMax=0,0
  for tick=1,LAST_TICK do
   local before=fullState(w);local stepStart=os.clock();local _,ev,iterations=Core.stepWorld(w,{});local stepCost=os.clock()-stepStart;costTotal+=stepCost;costMax=math.max(costMax,stepCost)
   if tick>=FIRST_TICK then
    local contacts={};for _,e in ipairs(ev)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]=e end end
    rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or {},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,stepCostSeconds=stepCost,iterations=iterations,before=before}
   end
  end
  out.rows[v.id]=rows;out.performance=out.performance or {};out.performance[v.id]={totalSeconds=costTotal,meanMs=costTotal/sc.ticks*1000,maxMs=costMax*1000}
 end
 return game:GetService("HttpService"):JSONEncode(out)
end
local function runControls()
 local out={schemaVersion=1,mode=MODE,profileSourceCommit=Profile.Metadata.sourceCommit,cases={}}
 for _,test in ipairs(CONTROLS)do
  if test.id==CONTROL_ID or CONTROL_ID=="all" then
   out.cases[test.id]={input=test,variants={}}
   for _,v in ipairs(VARIANTS)do
    local sc={red=0,blue=0,ballVx=test.ball.vx,ballVy=test.ball.vy}
    local Core,w,b=makeWorld(sc,v);b.x=test.ball.x;b.y=test.ball.y
    if test.player then Core.addDisc(w,{id=1,kind="player",team=test.player.team,x=test.player.x,y=test.player.y,vx=test.player.vx,vy=test.player.vy,radius=15,invMass=.5,damping=.96,bCoef=.5,collisionGroup=Profile.CollisionGroups.red,collisionMask=Profile.CollisionMasks.player,acceleration=.1,kickAcceleration=.07,kickDamping=.96})end
    local rows={};for tick=1,20 do local before=fullState(w);local _,ev,n=Core.stepWorld(w,{});local contacts={};for _,e in ipairs(ev)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]=e end end;rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before}end
    out.cases[test.id].variants[v.id]=rows
   end
  end
 end
 return game:GetService("HttpService"):JSONEncode(out)
end
local function runMicro()
 local out={schemaVersion=1,mode=MODE,cases={}}
 for _,c in ipairs(MICRO)do if c.id==MICRO_ID or MICRO_ID=="all"then out.cases[c.id]={input=c,variants={}}
  for _,v in ipairs(VARIANTS)do
   local Core=v.engine=="core" and require(sourceCoreScript) or v.engine=="t1" and T1 or TOI
   local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order})
   local b=Core.addDisc(w,{id="ball",kind="ball",x=c.x,y=c.y,vx=c.vx,vy=c.vy,radius=c.r,invMass=1,damping=.99,bCoef=.5,collisionGroup=1,collisionMask=63})
   Core.addPlane(w,{id="fixture:plane",normalX=0,normalY=c.ny,offset=c.offset,bCoef=c.b,collisionGroup=c.group,collisionMask=c.mask})
   local rows={};for tick=1,20 do local before=fullState(w);local _,ev,n=Core.stepWorld(w,{});local contacts={};for _,e in ipairs(ev)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]=e end end;rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before}end
   out.cases[c.id].variants[v.id]=rows
  end
 end end
 return game:GetService("HttpService"):JSONEncode(out)
end
local result=MODE=="scenarios" and runScenario() or MODE=="controls" and runControls() or runMicro()
toiModule:Destroy();t1Module:Destroy();profileClone:Destroy()
return result

