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
