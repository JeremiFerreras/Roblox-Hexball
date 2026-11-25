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
local PGSD_SOURCE=[====[
-- Isolated PGS-D diagnostic clone. Does not import or mutate the reference PGS.
-- Scope: one dynamic 2D body against static normal constraints, same as reference.
local M = {}
local TOL=1e-8
local function solveLinear(A,b)
 local n=#b;if n==0 then return {} end
 local a,scale={},0
 for i=1,n do a[i]={};for j=1,n do a[i][j]=A[i][j];scale=math.max(scale,math.abs(A[i][j]))end;a[i][n+1]=b[i]end
 for k=1,n do local p=k;for i=k+1,n do if math.abs(a[i][k])>math.abs(a[p][k])then p=i end end
  if math.abs(a[p][k])<=math.max(1,scale)*1e-13 then return nil end
  a[k],a[p]=a[p],a[k];local d=a[k][k];for j=k,n+1 do a[k][j]/=d end
  for i=1,n do if i~=k then local f=a[i][k];for j=k,n+1 do a[i][j]-=f*a[k][j]end end end
 end
 local x={};for i=1,n do x[i]=a[i][n+1]end;return x
end
local function matrix(vx,vy,invMass,cs)
 local n=#cs;local A,g={},{}
 for i=1,n do A[i]={};g[i]=cs[i].nx*vx+cs[i].ny*vy end
 for i=1,n do for j=1,n do A[i][j]=invMass*(cs[i].nx*cs[j].nx+cs[i].ny*cs[j].ny)end end
 return A,g
end
local function workDelta(g,A,l)
 local d=0;for i=1,#l do d+=g[i]*l[i];for j=1,#l do d+=.5*l[i]*A[i][j]*l[j]end end;return d
end
local function calcKKT(A,g,b,l)
 local w,res={},0
 for i=1,#l do local z=g[i]-b[i];for j=1,#l do z+=A[i][j]*l[j]end;w[i]=z
  res=math.max(res,l[i]>TOL and math.abs(z) or math.max(0,-z))
 end
 return res,w
end
local function eval(vx,vy,invMass,cs,A,g,l,b)
 local x,y=vx,vy;for i,c in ipairs(cs)do x+=invMass*c.nx*l[i];y+=invMass*c.ny*l[i]end
 local vn={};for i,c in ipairs(cs)do vn[i]=c.nx*x+c.ny*y end
 local pre=.5*(vx*vx+vy*vy)/invMass;local post=.5*(x*x+y*y)/invMass
 return {vx=x,vy=y,normalVelocities=vn,energyBefore=pre,energyAfter=post,energyDelta=post-pre}
end
local function constrain(lo,hi,c0,c1)
 if math.abs(c1)<=1e-14 then if c0 < -TOL then return nil end;return lo,hi end
 local r=(-TOL-c0)/c1;if c1>0 then lo=math.max(lo,r)else hi=math.min(hi,r)end
 if lo>hi+1e-12 then return nil end;return lo,hi
end
local function energyInterval(lo,hi,a,b,c)
 if a<0 and a>-1e-12 then a=0 end
 if math.abs(a)<=1e-14 then
  if math.abs(b)<=1e-14 then if c<=TOL then return lo,hi else return nil end end
  local r=-c/b;if b>0 then hi=math.min(hi,r)else lo=math.max(lo,r)end
  if lo>hi then return nil end;return lo,hi
 end
 local disc=b*b-4*a*c
 if disc<0 then if a*lo*lo+b*lo+c<=TOL then return lo,hi else return nil end end
 local root=math.sqrt(math.max(0,disc));local r1=(-b-root)/(2*a);local r2=(-b+root)/(2*a)
 lo=math.max(lo,r1);hi=math.min(hi,r2);if lo>hi then return nil end;return lo,hi
end

-- Exact D target selection from the audit: maximize gamma on [0,1] along
-- b(gamma)=gamma*bIndividual, subject to LCP and delta-energy <= 0.
-- This small-manifold active-set phase is diagnostic target selection; PGS
-- below is still the iterative impulse solver being evaluated.
local function project(vx,vy,invMass,cs,bDesired)
 local A,g=matrix(vx,vy,invMass,cs);local n=#g;local best=nil
 for mask=0,2^n-1 do
  local S={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then S[#S+1]=i end end
  local block,r0,r1={},{},{}
  for ii,i in ipairs(S)do block[ii]={};r0[ii]=-g[i];r1[ii]=bDesired[i];for jj,j in ipairs(S)do block[ii][jj]=A[i][j]end end
  local l0,l1=solveLinear(block,r0),solveLinear(block,r1)
  if l0 and l1 then
   local lo,hi,valid=0,1,true;local pos={}
   for k,i in ipairs(S)do pos[i]=k;lo,hi=constrain(lo,hi,l0[k],l1[k]);if not lo then valid=false;break end end
   if valid then for j=1,n do if not pos[j]then local c0,c1=g[j],-bDesired[j];for k,i in ipairs(S)do c0+=A[j][i]*l0[k];c1+=A[j][i]*l1[k]end;lo,hi=constrain(lo,hi,c0,c1);if not lo then valid=false;break end end end end
   if valid then
    local c0,c1,c2=0,0,0
    for k,i in ipairs(S)do c0+=g[i]*l0[k];c1+=g[i]*l1[k];for j,jj in ipairs(S)do c1+=l0[k]*A[i][jj]*l1[j];c2+=.5*l1[k]*A[i][jj]*l1[j];c0+=.5*l0[k]*A[i][jj]*l0[j]end end
    lo,hi=energyInterval(lo,hi,c2,c1,c0)
    if lo and hi>=-TOL then local gamma=math.clamp(hi,0,1);if not best or gamma>best.gamma+1e-12 then
     local l=table.create(n,0);for k,i in ipairs(S)do l[i]=math.max(0,l0[k]+gamma*l1[k])end
     local b={};for i=1,n do b[i]=gamma*bDesired[i]end
     local res,w=calcKKT(A,g,b,l);local st=eval(vx,vy,invMass,cs,A,g,l,b)
     best={gamma=gamma,lambda=l,targets=b,A=A,g=g,w=w,residual=res,state=st,support=S}
    end end
   end
  end
 end
 if not best then return nil,"D-projection-no-feasible-active-set" end
 if best.gamma<=1e-8 then
  local z=table.create(n,0);local lcp=M.activeSetLcp(vx,vy,invMass,cs,z)
  if not lcp.ok then return nil,"D-inelastic-fallback-unavailable" end
  best.gamma=0;best.targets=z;best.lambda=lcp.lambda;best.support=lcp.support
  best.residual=lcp.residual;best.w=lcp.w;best.state=lcp.state
 end
 -- Match the documented D numerical-safety branch exactly: if floating-point
 -- evaluation puts the selected boundary a little above zero energy, retreat
 -- gamma by 1e-9 relatively and independently solve/verify the safer LCP.
 if workDelta(best.g,best.A,best.lambda)>0 then
  local gammaSafe=best.gamma*(1-1e-9);local bSafe={};for i=1,n do bSafe[i]=gammaSafe*bDesired[i]end
  local safe=M.activeSetLcp(vx,vy,invMass,cs,bSafe)
  if safe.ok and workDelta(best.g,best.A,safe.lambda)<=1e-8 then
   best.gamma=gammaSafe;best.targets=bSafe;best.lambda=safe.lambda;best.support=safe.support
   best.residual=safe.residual;best.w=safe.w;best.state=safe.state
  else return nil,"D-roundoff-passivity-retreat-failed" end
 end
 return best
end

-- Separate active-set oracle exported only for the harness comparison.
function M.activeSetLcp(vx,vy,invMass,cs,b)
 local A,g=matrix(vx,vy,invMass,cs);local n=#g
 for mask=0,2^n-1 do local S={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then S[#S+1]=i end end
  local block,rhs={},{ };for ii,i in ipairs(S)do block[ii]={};rhs[ii]=-g[i]+b[i];for jj,j in ipairs(S)do block[ii][jj]=A[i][j]end end
  local sol=solveLinear(block,rhs);if sol then local l=table.create(n,0);local ok=true
   for k,i in ipairs(S)do if sol[k]<-TOL then ok=false else l[i]=math.max(0,sol[k])end end
   if ok then local res,w=calcKKT(A,g,b,l);if res<=TOL then return {ok=true,lambda=l,w=w,residual=res,state=eval(vx,vy,invMass,cs,A,g,l,b),support=S,rank=n}end end
  end
 end
 return {ok=false,reason="active-set-no-solution",A=A,g=g}
end

function M.solve(body,contacts,opts)
 opts=opts or {};local it=opts.iterations or 64;local omega=opts.relaxation or 1;local tol=opts.tolerance or 1e-8
 if type(body)~="table" or not (body.vx==body.vx and body.vy==body.vy and body.invMass>0) then return {ok=false,reason="invalid-body"}end
 if it<1 or it%1~=0 or omega<=0 or omega>=2 then return {ok=false,reason="invalid-options"}end
 local cs={};for _,c in ipairs(contacts)do local n=math.sqrt(c.nx*c.nx+c.ny*c.ny);if not (n>1e-12 and c.restitution>=0) then return {ok=false,reason="invalid-contact"}end
  local x=table.clone(c);x.nx/=n;x.ny/=n;cs[#cs+1]=x
 end
 table.sort(cs,function(a,b)if tostring(a.surfaceId)~=tostring(b.surfaceId)then return tostring(a.surfaceId)<tostring(b.surfaceId)end;if a.nx~=b.nx then return a.nx<b.nx end;return a.ny<b.ny end)
 local g={};local bI={};for i,c in ipairs(cs)do g[i]=c.nx*body.vx+c.ny*body.vy;bI[i]=math.max(0,-g[i])*c.restitution end
 local d,why=project(body.vx,body.vy,body.invMass,cs,bI);if not d then return {ok=false,reason=why}end
 local A=d.A;local lam=table.create(#cs,0);local vx,vy=body.vx,body.vy;local trace={}
 for k=1,it do
  for i,c in ipairs(cs)do local vn=c.nx*vx+c.ny*vy;local dl=(d.targets[i]-vn)/body.invMass;local nl=math.max(0,lam[i]+omega*dl);dl=nl-lam[i];lam[i]=nl;vx+=c.nx*dl*body.invMass;vy+=c.ny*dl*body.invMass end
  local r=0;local nv={};for i,c in ipairs(cs)do local gap=c.nx*vx+c.ny*vy-d.targets[i];nv[i]=c.nx*vx+c.ny*vy;r=math.max(r,lam[i]>0 and math.abs(gap) or math.max(0,-gap))end
  trace[k]={iteration=k,residual=r,vx=vx,vy=vy,lambda=table.clone(lam),normalVelocities=nv}
 end
 local res=calcKKT(A,g,d.targets,lam);local st=eval(body.vx,body.vy,body.invMass,cs,A,g,lam,d.targets)
 local origRes=calcKKT(A,g,bI,lam)
 local impulses={};for i,c in ipairs(cs)do impulses[i]={surfaceId=c.surfaceId,lambda=lam[i]}end
 return {ok=res<=tol,reason=res>tol and "pgs-kkt-residual" or nil,gamma=d.gamma,
  originalTargets=bI,projectedTargets=d.targets,lambda=lam,impulses=impulses,
  post=st,iterations=it,residualKKT=res,originalTargetResidual=origRes,
  energyDelta=st.energyDelta,projectionOracle={lambda=d.lambda,post=d.state,
   residual=d.residual,support=d.support},trace=trace}
end
return M
]====]
local pgsdModule=Instance.new("ModuleScript");pgsdModule.Name="Phase3PGSD";pgsdModule.Source=PGSD_SOURCE;pgsdModule.Parent=ServerStorage
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
    local PGSD=require(game:GetService("ServerStorage"):WaitForChild("Phase3PGSD"))
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
    local stats={candidateTests=0,validCandidates=0,discardedMask=0,discardedSeparating=0,discardedOutOfRange=0,iterations=0,eventLimit=false,zeroTimeEvents=0,curvedArcTests=0,incomplete=false,strategies={pgsD=0,cInelastic=0,sequentialInelastic=0,pairResolver=0,pairPGSD=0,pairInelastic=0,failed=0},manifoldEvents=0}
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
                        if gap < -(world.config.experimentalPGSD and 2*posSlop or posSlop) or vn < -velEps then addCandidate(candidates,{t=0,kind="plane",disc=d,geometry=p,nx=p.normalX,ny=p.normalY,geometryIndex=gi,penetration=math.max(0,-gap)})
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
                        if initialGap < -(world.config.experimentalPGSD and 2*posSlop or posSlop) or vn < -velEps then hitT=0 else stats.discardedSeparating+=1 end
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
    while remaining>timeEps and stats.iterations<maxEvents and not stats.incomplete do
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
        if best.kind=="pair" and world.config.experimentalPGSD then
            local a,b=best.a,best.b;local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            local nx,ny=best.nx,best.ny;local invTotal=a.invMass+b.invMass;local rvx,rvy=a.vx-b.vx,a.vy-b.vy
            local surfaceA=a.bCoef==nil and 1 or a.bCoef;local surfaceB=b.bCoef==nil and 1 or b.bCoef;local pairRest=surfaceA*surfaceB
            local rows={{surfaceId="pair:"..keyOf(a.id)..":"..keyOf(b.id),nx=nx,ny=ny,restitution=pairRest}}
            local e0=.5*(rvx*rvx+rvy*rvy)/math.max(invTotal,1e-30);local solve=PGSD.solve({id="pair",vx=rvx,vy=rvy,invMass=invTotal},rows,{iterations=128,relaxation=1,tolerance=1e-8})
            local chosen,strategy,gamma=nil,nil,nil;local attempts={{strategy="PGS-D-pair",ok=solve.ok,residual=solve.residualKKT,gamma=solve.gamma,reason=solve.reason}};local energyTol=math.max(1e-8,e0*1e-10)
            if solve.ok and solve.energyDelta<=energyTol then chosen={lambda=solve.lambda,post=solve.post,residual=solve.residualKKT,energyDelta=solve.energyDelta};strategy="PGS-D-pair";gamma=solve.gamma;stats.strategies.pairPGSD+=1 end
            if not chosen then local zero={0};local c=PGSD.activeSetLcp(rvx,rvy,invTotal,rows,zero);local good=c.ok and c.state.energyDelta<=energyTol;attempts[#attempts+1]={strategy="C-inelastic-pair",ok=good,residual=c.residual,reason=c.reason};if good then chosen={lambda=c.lambda,post=c.state,residual=c.residual,energyDelta=c.state.energyDelta};strategy="C-inelastic-pair";gamma=0;stats.strategies.pairInelastic+=1 end end
            if not chosen then local vn=rvx*nx+rvy*ny;local j=vn<0 and -vn/math.max(invTotal,1e-30) or 0;local px,py=rvx+nx*j*invTotal,rvy+ny*j*invTotal;local de=.5*(px*px+py*py)/math.max(invTotal,1e-30)-e0;local good=de<=energyTol and px==px and py==py and math.abs(px)<math.huge and math.abs(py)<math.huge;attempts[#attempts+1]={strategy="bounded-sequential-inelastic-pair",ok=good,energyDelta=de};if good then chosen={lambda={j},post={vx=px,vy=py},residual=math.max(0,-(px*nx+py*ny)),energyDelta=de};strategy="bounded-sequential-inelastic-pair";gamma=0;stats.strategies.pairInelastic+=1 end end
            if not chosen then stats.incomplete=true;stats.incompleteReason="pair-manifold-strategies-failed";stats.unconsumedTime=remaining;stats.strategies.failed+=1;hitRecord.solver={attempts=attempts,chosen="failed",timeUnconsumed=remaining}
            else
                local j=chosen.lambda[1]or 0;a.vx+=nx*j*a.invMass;a.vy+=ny*j*a.invMass;b.vx-=nx*j*b.invMass;b.vy-=ny*j*b.invMass
                local dx,dy=b.x-a.x,b.y-a.y;local dist=math.sqrt(dx*dx+dy*dy);local penetration=math.max(0,a.radius+b.radius-dist);local correction=math.max(posSlop,penetration)
                if invTotal>0 then a.x+=nx*correction*a.invMass/invTotal;a.y+=ny*correction*a.invMass/invTotal;b.x-=nx*correction*b.invMass/invTotal;b.y-=ny*correction*b.invMass/invTotal end
                local vn0=rvx*nx+rvy*ny;local vn1=(a.vx-b.vx)*nx+(a.vy-b.vy)*ny;local restOk=strategy=="PGS-D-pair" and solve.originalTargetResidual<=1e-8
                local ev={kind="discContact",tick=world.tick+1,discA=a.id,discB=b.id,normalX=nx,normalY=ny,penetration=penetration,impulse=j,solverStrategy=strategy,gamma=gamma,relativeVelocityBefore=vn0,relativeVelocityAfter=vn1,originalRestitutionSatisfied=restOk};table.insert(events,ev)
                hitRecord.impulse=j;hitRecord.penetration=penetration;hitRecord.pairPre={a=pre[keyOf(a.id)],b=pre[keyOf(b.id)]};hitRecord.pairPost={a={x=a.x,y=a.y,vx=a.vx,vy=a.vy},b={x=b.x,y=b.y,vx=b.vx,vy=b.vy}}
                hitRecord.solver={chosen=strategy,gamma=gamma,energyBefore=e0,energyAfter=e0+chosen.energyDelta,energyDelta=chosen.energyDelta,projectedKktResidual=chosen.residual,originalTargetResidual=solve.originalTargetResidual,originalRestitutionSatisfied=restOk,attempts=attempts,contacts={{surfaceId=rows[1].surfaceId,nx=nx,ny=ny,ePair=pairRest,impulse=j,normalVelocityBefore=vn0,normalVelocityAfter=vn1,solverStrategy=strategy}}}
            end
        elseif best.kind=="pair" then
            hitRecord.pairPre={a=pre[keyOf(best.a.id)],b=pre[keyOf(best.b.id)]}
            local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            best.a.x-=best.nx*posSlop*.5;best.a.y-=best.ny*posSlop*.5;best.b.x+=best.nx*posSlop*.5;best.b.y+=best.ny*posSlop*.5
            local con=resolveDiscPair(best.a,best.b)
            if con then
                con.kind="discContact";con.tick=world.tick+1;con.discA=best.a.id;con.discB=best.b.id;con.solverStrategy="existing-pair-resolver"
                local key="pair:"..keyOf(best.a.id)..":"..keyOf(best.b.id);eventKeys[key]=con;table.insert(events,con)
                hitRecord.penetration=con.penetration;hitRecord.impulse=con.impulse;stats.strategies.pairResolver+=1
            end
            hitRecord.pairPost={a={x=best.a.x,y=best.a.y,vx=best.a.vx,vy=best.a.vy},b={x=best.b.x,y=best.b.y,vx=best.b.vx,vy=best.b.vy}}
        elseif world.config.experimentalPGSD and (best.kind=="plane" or best.kind=="segment") then
            local maxSpeed=math.sqrt(disc.vx*disc.vx+disc.vy*disc.vy)
            local spatialTol=disc.radius*1e-5
            local simultaneousTol=math.max(timeEps,spatialTol/math.max(1,maxSpeed))
            local rows,seen={},{}
            local function addManifoldRow(kind,g,nx,ny,penetration)
                local sid=tostring(g.id);if seen[sid]then return end
                local n=math.sqrt(nx*nx+ny*ny);if n<=1e-12 then return end
                seen[sid]=true;local surfaceB=g.bCoef==nil and 1 or g.bCoef
                rows[#rows+1]={surfaceId=sid,nx=nx/n,ny=ny/n,restitution=disc.bCoef*surfaceB,geometry=g,kind=kind,penetration=penetration or 0}
            end
            -- Include geometrically touching surfaces even when their incoming normal
            -- velocity was separating: resolving one contact may make an adjacent one closing.
            for _,c in ipairs(candidates)do if c.disc==disc and (c.kind=="plane" or c.kind=="segment") and math.abs(c.t-best.t)<=simultaneousTol then addManifoldRow(c.kind,c.geometry,c.nx,c.ny,c.penetration) end end
            for _,g in ipairs(world.planes)do if collisionAllowed(disc,g)then local gap=disc.x*g.normalX+disc.y*g.normalY-g.offset-disc.radius;if gap<=spatialTol then addManifoldRow("plane",g,g.normalX,g.normalY,math.max(0,-gap))end end end
            for _,g in ipairs(world.segments)do if collisionAllowed(disc,g)then local _,_,dist,nx,ny=closestOnSegment(g,disc.x,disc.y);local gap=dist-disc.radius;if gap<=spatialTol then addManifoldRow("segment",g,nx,ny,math.max(0,-gap))end end end
            table.sort(rows,function(a,b)return a.surfaceId<b.surfaceId end)
            stats.manifoldEvents+=1
            local vx0,vy0=disc.vx,disc.vy;local energy0=.5*(vx0*vx0+vy0*vy0)/disc.invMass
            local solve=PGSD.solve({id=disc.id,vx=vx0,vy=vy0,invMass=disc.invMass},rows,{iterations=128,relaxation=1,tolerance=1e-8})
            local chosen,solverStrategy,usedGamma,attempts=nil,nil,nil,{{strategy="PGS-D",ok=solve.ok,residual=solve.residualKKT,gamma=solve.gamma,reason=solve.reason}}
            local energyTol=math.max(1e-8,energy0*1e-10)
            if solve.ok and solve.energyDelta<=energyTol then chosen={lambda=solve.lambda,state=solve.post,residual=solve.residualKKT,energyDelta=solve.energyDelta,targets=solve.projectedTargets,originalTargets=solve.originalTargets};solverStrategy="PGS-D";usedGamma=solve.gamma;stats.strategies.pgsD+=1 end
            if not chosen then
                local zero=table.create(#rows,0);local c=PGSD.activeSetLcp(vx0,vy0,disc.invMass,rows,zero)
                local cOk=c.ok and c.state.energyDelta<=energyTol
                attempts[#attempts+1]={strategy="C-inelastic",ok=cOk,residual=c.residual,energyDelta=c.state and c.state.energyDelta or nil,reason=c.reason}
                if cOk then chosen={lambda=c.lambda,state=c.state,residual=c.residual,energyDelta=c.state.energyDelta,targets=zero,originalTargets=solve.originalTargets};solverStrategy="C-inelastic";usedGamma=0;stats.strategies.cInelastic+=1 end
            end
            if not chosen then
                local svx,svy=vx0,vy0;local sums=table.create(#rows,0);local passRes=math.huge
                for sweep=1,8 do for i,c in ipairs(rows)do local vn=svx*c.nx+svy*c.ny;if vn<0 then local impulse=-vn/disc.invMass;sums[i]+=impulse;svx+=c.nx*impulse*disc.invMass;svy+=c.ny*impulse*disc.invMass end end
                    passRes=0;for _,c in ipairs(rows)do passRes=math.max(passRes,math.max(0,-(svx*c.nx+svy*c.ny)))end
                end
                local energy=.5*(svx*svx+svy*svy)/disc.invMass-energy0
                local seqOk=passRes<=1e-6 and energy<=energyTol and svx==svx and svy==svy and math.abs(svx)<math.huge and math.abs(svy)<math.huge
                attempts[#attempts+1]={strategy="bounded-sequential-inelastic",ok=seqOk,residual=passRes,energyDelta=energy,sweeps=8}
                if seqOk then chosen={lambda=sums,state={vx=svx,vy=svy},residual=passRes,energyDelta=energy,targets=zero,originalTargets=solve.originalTargets};solverStrategy="bounded-sequential-inelastic";usedGamma=0;stats.strategies.sequentialInelastic+=1 end
            end
            if not chosen then
                stats.incomplete=true;stats.strategies.failed+=1;stats.incompleteReason="all-manifold-strategies-failed";stats.unconsumedTime=remaining
                hitRecord.solver={attempts=attempts,chosen="failed",timeUnconsumed=remaining,spatialTolerance=spatialTol,simultaneousTolerance=simultaneousTol}
            else
                disc.vx=chosen.state.vx;disc.vy=chosen.state.vy
                local maxPen=0
                for pass=1,8 do
                    for _,c in ipairs(rows)do local nx,ny=c.nx,c.ny;local gap
                        if c.kind=="plane"then gap=disc.x*nx+disc.y*ny-c.geometry.offset-disc.radius
                        else local qx,qy,dist,nnx,nny=closestOnSegment(c.geometry,disc.x,disc.y);nx,ny=nnx,nny;gap=dist-disc.radius end
                        if gap < -posSlop then local correction=-gap+posSlop;disc.x+=nx*correction;disc.y+=ny*correction end
                    end
                end
                for _,c in ipairs(rows)do local gap;if c.kind=="plane"then gap=disc.x*c.nx+disc.y*c.ny-c.geometry.offset-disc.radius else local _,_,dist=closestOnSegment(c.geometry,disc.x,disc.y);gap=dist-disc.radius end;maxPen=math.max(maxPen,math.max(0,-gap))end
                if maxPen>math.max(5*posSlop,spatialTol)then
                    stats.incomplete=true;stats.strategies.failed+=1;stats.incompleteReason="positional-residual-after-manifold";stats.unconsumedTime=remaining
                end
                local impulseTotal=0;local contactRecords={}
                for i,c in ipairs(rows)do local vn0=vx0*c.nx+vy0*c.ny;local vn1=disc.vx*c.nx+disc.vy*c.ny;local lambda=chosen.lambda[i] or 0;impulseTotal+=lambda
                    local surfaceB=c.geometry.bCoef==nil and 1 or c.geometry.bCoef
                    local rec={surfaceId=c.surfaceId,geometryKind=c.kind,normalX=c.nx,normalY=c.ny,bCoefBody=disc.bCoef,bCoefSurface=surfaceB,ePair=c.restitution,originalTarget=solve.originalTargets[i],projectedTarget=solve.projectedTargets[i],gamma=usedGamma,impulse=lambda,normalVelocityBefore=vn0,normalVelocityAfter=vn1,kktResidual=chosen.residual,solverStrategy=solverStrategy,originalRestitutionSatisfied=solverStrategy=="PGS-D" and solve.originalTargetResidual<=1e-8,penetrationAfter=maxPen}
                    contactRecords[#contactRecords+1]=rec
                    local ev={kind=c.kind=="plane" and "planeContact" or "segmentContact",tick=world.tick+1,discId=disc.id,geometryId=c.geometry.id,normalX=c.nx,normalY=c.ny,penetration=maxPen,impulse=lambda,solverStrategy=solverStrategy,gamma=usedGamma,originalRestitutionSatisfied=rec.originalRestitutionSatisfied,normalVelocityBefore=vn0,normalVelocityAfter=vn1}
                    table.insert(events,ev)
                end
                hitRecord.impulse=impulseTotal;hitRecord.penetration=maxPen;hitRecord.solver={attempts=attempts,chosen=solverStrategy,gamma=usedGamma,energyBefore=energy0,energyAfter=.5*(disc.vx*disc.vx+disc.vy*disc.vy)/disc.invMass,energyDelta=.5*(disc.vx*disc.vx+disc.vy*disc.vy)/disc.invMass-energy0,projectedKktResidual=chosen.residual,originalTargetResidual=solve.originalTargetResidual,originalRestitutionSatisfied=solverStrategy=="PGS-D" and solve.originalTargetResidual<=1e-8,contacts=contactRecords,spatialTolerance=spatialTol,simultaneousTolerance=simultaneousTol,positionCorrectionSweeps=8}
            end
        elseif best.kind=="plane" or best.kind=="segment" then
            local correction=math.max(best.penetration or 0,posSlop);local g=best.geometry;local normalVelocity=disc.vx*best.nx+disc.vy*best.ny;local impulse=0
            if normalVelocity<0 then local change=-(1+disc.bCoef*g.bCoef)*normalVelocity;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            disc.x+=best.nx*correction;disc.y+=best.ny*correction;local kind=best.kind=="plane" and "planeContact" or "segmentContact"
            local ev={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=g.id,normalX=best.nx,normalY=best.ny,penetration=0,impulse=impulse};table.insert(events,ev);hitRecord.impulse=impulse;hitRecord.penetration=0
        else
            disc.x=disc.x+best.nx*posSlop;disc.y=disc.y+best.ny*posSlop;local vn=disc.vx*best.nx+disc.vy*best.ny;local impulse=0
            if vn<0 then local change=-(1+disc.bCoef)*vn;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            hitRecord.impulse=impulse;hitRecord.penetration=0;local ev={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=1,side=best.side,impulse=impulse};table.insert(events,ev)
        end
        hitRecord.post=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil
        table.insert(trace,hitRecord)
        if best.t<=timeEps then stats.zeroTimeEvents+=1 end
        if best.t<=timeEps and (not hitRecord.impulse or hitRecord.impulse==0) then
            -- Avoid a t=0 repeat loop for resting/tangent or unresolved initial overlap.
            if stats.zeroTimeEvents>=4 then stats.eventLimit=true;break end
        end
    end
    if stats.eventLimit and not stats.incomplete then stats.incomplete=true;stats.incompleteReason=stats.iterations>=maxEvents and "event-limit" or "zero-time-event-limit";stats.unconsumedTime=remaining end
if remaining>timeEps and not stats.incomplete then
        if stats.iterations>=maxEvents then stats.eventLimit=true;stats.incomplete=true;stats.incompleteReason="event-limit";stats.unconsumedTime=remaining end
        if not stats.incomplete then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*remaining;d.y+=d.vy*remaining end end;remaining=0 end
    end
    if not stats.incomplete then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then local damp=(d.kind=="player" and d.kickArmed) and d.kickDamping or d.damping;d.vx=(d.vx+d.gravityX)*damp;d.vy=(d.vy+d.gravityY)*damp end end end
    if not stats.incomplete then world.tick+=1 end;world.events=events;world.lastSubsteps=stats.iterations
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
 {id="G_TOI_PGSD_core",engine="toiPGSD",order="core",props="core"},
 {id="H_TOI_PGSD_hbs",engine="toiPGSD",order="core",props="node"},
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
 if v.props=="node" then for _,p in ipairs(w.planes)do if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 elseif string.find(p.id,"classic:ballArea:",1,true)==1 then p.bCoef=1 end end end
end
local function fullState(w)
 local a={};for _,d in ipairs(w.discs)do if d.enabled and d.invMass>0 then a[#a+1]={id=d.id,x=d.x,y=d.y,vx=d.vx,vy=d.vy}end end;return a
end
local function makeWorld(sc,v)
 local Core=v.engine=="core" and require((function() return sourceCoreScript end)()) or nil
 if v.engine=="t1" then Core=T1 elseif v.engine=="toi" or v.engine=="toiPGSD" then Core=TOI end
 local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order,experimentalPGSD=v.engine=="toiPGSD"})
 if v.engine=="toiPGSD" then w.config.experimentalPGSD=true end
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
    rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or {},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,stepCostSeconds=stepCost,iterations=iterations,before=before};if w.toiStats and w.toiStats.incomplete then break end
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
    local rows={};for tick=1,20 do local before=fullState(w);local _,ev,n=Core.stepWorld(w,{});local contacts={};for _,e in ipairs(ev)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]=e end end;rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before};if w.toiStats and w.toiStats.incomplete then break end end
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
   local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order,experimentalPGSD=v.engine=="toiPGSD"})
 if v.engine=="toiPGSD" then w.config.experimentalPGSD=true end
   local b=Core.addDisc(w,{id="ball",kind="ball",x=c.x,y=c.y,vx=c.vx,vy=c.vy,radius=c.r,invMass=1,damping=.99,bCoef=.5,collisionGroup=1,collisionMask=63})
   Core.addPlane(w,{id="fixture:plane",normalX=0,normalY=c.ny,offset=c.offset,bCoef=c.b,collisionGroup=c.group,collisionMask=c.mask})
   local rows={};for tick=1,20 do local before=fullState(w);local _,ev,n=Core.stepWorld(w,{});local contacts={};for _,e in ipairs(ev)do if e.kind=="planeContact"or e.kind=="segmentContact"or e.kind=="discContact"or e.kind=="boundaryContact"then contacts[#contacts+1]=e end end;rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before};if w.toiStats and w.toiStats.incomplete then break end end
   out.cases[c.id].variants[v.id]=rows
  end
 end end
 return game:GetService("HttpService"):JSONEncode(out)
end
local result=MODE=="scenarios" and runScenario() or MODE=="controls" and runControls() or runMicro()
toiModule:Destroy();t1Module:Destroy();profileClone:Destroy();pgsdModule:Destroy()
return result

