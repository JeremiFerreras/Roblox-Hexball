-- Independent active-set LCP oracle versus the unchanged PGS module.
local PGS=require("./PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119")
local TracePGS=require("./PHASE3_CONTACT_MANIFOLD_PGS_TRACE_CLONE_20261119")
local TOL=1e-8
local function dot(ax,ay,bx,by) return ax*bx+ay*by end
local function copyBodies(bodies)local out={};for i,b in ipairs(bodies)do out[i]={id=b.id,vx=b.vx,vy=b.vy,invMass=b.invMass}end;return out end
local function bodyById(bodies,id)for _,b in ipairs(bodies)do if b.id==id then return b end end;return nil end
local function rowVel(bodies,c)local v=0;for _,t in ipairs(c.terms)do local b=bodyById(bodies,t.bodyId);v+=dot(t.x,t.y,b.vx,b.vy)end;return v end
local function jac(c,id)local x,y=0,0;for _,t in ipairs(c.terms)do if t.bodyId==id then x+=t.x;y+=t.y end end;return x,y end
local function matrixFor(bodies,contacts)
 local n=#contacts;local A=table.create(n);local q=table.create(n)
 for i=1,n do A[i]=table.create(n,0);q[i]=rowVel(bodies,contacts[i])-contacts[i].target end
 for i=1,n do for j=1,n do local s=0;for _,b in ipairs(bodies)do local ix,iy=jac(contacts[i],b.id);local jx,jy=jac(contacts[j],b.id);s+=b.invMass*(ix*jx+iy*jy)end;A[i][j]=s end end
 return A,q
end
local function solveLinear(M,b)
 local n=#b;if n==0 then return {} end
 local a={};local scale=0;for i=1,n do a[i]={};for j=1,n do a[i][j]=M[i][j];scale=math.max(scale,math.abs(M[i][j]))end;a[i][n+1]=b[i]end
 for k=1,n do local p=k;for i=k+1,n do if math.abs(a[i][k])>math.abs(a[p][k])then p=i end end
  if math.abs(a[p][k])<=math.max(1,scale)*1e-13 then return nil end
  a[k],a[p]=a[p],a[k];local d=a[k][k];for j=k,n+1 do a[k][j]/=d end
  for i=1,n do if i~=k then local f=a[i][k];for j=k,n+1 do a[i][j]-=f*a[k][j]end end end
 end
 local x={};for i=1,n do x[i]=a[i][n+1]end;return x
end
local function rankOf(M)
 local n=#M;if n==0 then return 0 end;local a={};local scale=0
 for i=1,n do a[i]={};for j=1,n do a[i][j]=M[i][j];scale=math.max(scale,math.abs(M[i][j]))end end
 local r=0;for col=1,n do local p=nil;for i=r+1,n do if not p or math.abs(a[i][col])>math.abs(a[p][col])then p=i end end
  if p and math.abs(a[p][col])>math.max(1,scale)*1e-12 then r+=1;a[r],a[p]=a[p],a[r];local d=a[r][col];for j=col,n do a[r][j]/=d end;for i=1,n do if i~=r then local f=a[i][col];for j=col,n do a[i][j]-=f*a[r][j]end end end end
 end;return r
end
local function oracle(bodies,contacts)
 for _,b in ipairs(bodies)do if b.invMass<0 or b.vx~=b.vx or b.vy~=b.vy or b.invMass~=b.invMass or math.abs(b.vx)==math.huge or math.abs(b.vy)==math.huge or math.abs(b.invMass)==math.huge then return {class="invalid",reason="nonfinite-or-negative-mass"}end end
 for _,c in ipairs(contacts)do if c.target~=c.target or math.abs(c.target)==math.huge or math.abs(c.nx*c.nx+c.ny*c.ny-1)>1e-8 then return {class="invalid",reason="invalid-target-or-normal"}end end
 local A,q=matrixFor(bodies,contacts);local rank=rankOf(A);local m=#contacts;local best=nil
 for mask=0,2^m-1 do
  local idx={};for i=1,m do if math.floor(mask/2^(i-1))%2==1 then idx[#idx+1]=i end end
  local lam={};for i=1,m do lam[i]=0 end
  local block={};local rhs={};for ii,i in ipairs(idx)do block[ii]={};rhs[ii]=-q[i];for jj,j in ipairs(idx)do block[ii][jj]=A[i][j]end end
  local active=solveLinear(block,rhs)
  if active then
   local okay=true;for k,i in ipairs(idx)do if active[k]<-TOL then okay=false else lam[i]=math.max(0,active[k])end end
   if okay then local w={};local pres=0;for i=1,m do local z=q[i];for j=1,m do z+=A[i][j]*lam[j]end;w[i]=z;if z < -TOL then okay=false end;if lam[i]>TOL and math.abs(z)>TOL then okay=false end;pres=math.max(pres,math.max(0,-z))end
    if okay then best={lambda=lam,w=w,primalResidual=pres,dualResidual=0,complementarity=0,support=idx};for i=1,m do best.dualResidual=math.max(best.dualResidual,math.max(0,-lam[i]));best.complementarity=math.max(best.complementarity,math.abs(lam[i]*w[i]))end;break end
   end
  end
 end
 if not best then return {class="incompatible",rank=rank,A=A,q=q,method="exhaustive-nonsingular-active-set-enumeration",tol=TOL}end
 local post=copyBodies(bodies);for _,b in ipairs(post)do local ix,iy=0,0;for i,c in ipairs(contacts)do local x,y=jac(c,b.id);ix+=x*best.lambda[i];iy+=y*best.lambda[i]end;b.vx+=b.invMass*ix;b.vy+=b.invMass*iy end
 best.class=rank<m and "feasible-singular-redundant" or "feasible";best.rank=rank;best.A=A;best.q=q;best.post=post;best.tol=TOL;return best
end
local function makePlaneContact(bodyId,surfaceId,nx,ny,e,bodies)
 local b=bodyById(bodies,bodyId);local vn=nx*b.vx+ny*b.vy;local target=vn < -1e-9 and -(e or 0)*vn or 0
 return {surfaceId=surfaceId,nx=nx,ny=ny,target=target,terms={{bodyId=bodyId,x=nx,y=ny}}}
end
local function pgscall(bodies,contacts,budget,omega)
 if #bodies~=1 then return {applicable=false,reason="reference PGS accepts one dynamic body against static surfaces only"}end
 local b=bodies[1];local rows={};for _,c in ipairs(contacts)do if #c.terms~=1 or c.terms[1].bodyId~=b.id then return {applicable=false,reason="not a one-body static-surface manifold"}end;rows[#rows+1]={bodyId=b.id,surfaceId=c.surfaceId,nx=c.nx,ny=c.ny,restitution=c.restitution or 0}end
 local solver=omega and TracePGS or PGS;local out=solver.solve({id=b.id,vx=b.vx,vy=b.vy,invMass=b.invMass},rows,{iterations=budget,maxIterations=128,residualTolerance=1e-8,velocityTolerance=1e-9,relaxation=omega or 1});return {applicable=true,ok=out.ok,reason=out.reason,residual=out.residual,pre=out.pre,post=out.post,impulses=out.impulses}
end
local function kinetic(bodies)local e=0;for _,b in ipairs(bodies)do if b.invMass>0 then e+=0.5*(b.vx*b.vx+b.vy*b.vy)/b.invMass end end;return e end
local function runCase(name,bodies,contacts,budgets,pgsContacts,permutation,omega)
 local o=oracle(bodies,contacts);local pgs={};if pgsContacts then for _,it in ipairs(budgets or {16,32,64,128})do pgs[#pgs+1]={budget=it,result=pgscall(bodies,pgsContacts,it,omega)}end end
 local post=o.post;local em={pre=kinetic(bodies),post=post and kinetic(post) or nil};local vn={};if post then for _,c in ipairs(contacts)do vn[#vn+1]=rowVel(post,c)end end
 print(string.format("CASE|%s|class=%s|rank=%s|m=%d|A=%s|q=%s|lambda=%s|w=%s|post=%s|vn=%s|energy=%s|support=%s|pgs=%s|permutation=%s",name,o.class,tostring(o.rank or ""),#contacts,table.concat((function()local t={};for _,row in ipairs(o.A or {})do t[#t+1]=table.concat(row,",")end;return t end)(),";"),table.concat(o.q or {},","),table.concat(o.lambda or {},","),table.concat(o.w or {},","),post and table.concat((function()local t={};for _,b in ipairs(post)do t[#t+1]=b.id..":"..b.vx..","..b.vy end;return t end)(),";") or "",table.concat(vn,","),tostring(em.pre)..","..tostring(em.post),o.support and table.concat(o.support,",") or "",table.concat((function()local t={};for _,x in ipairs(pgs)do local r=x.result;t[#t+1]=tostring(x.budget).."@"..tostring(omega or 1)..":"..tostring(r.ok)..":"..tostring(r.residual)..":"..tostring(r.post and (r.post.vx..","..r.post.vy) or "") end;return t end)(),";"),permutation or ""))
 return {name=name,oracle=o,pgs=pgs,energy=em,postNormalVelocities=vn}
end
local out={}
-- Isolated restitutive contact: n points into the admissible region.
do local b={{id="ball",vx=0,vy=10,invMass=1}};local c=makePlaneContact("ball","floor",0,-1,.5,b);c.restitution=.5;out[#out+1]=runCase("isolated_e05",b,{c},{16,32,64,128},{c})end
-- Orthogonal corner, inelastic.
do local b={{id="ball",vx=20,vy=20,invMass=1}};local c1=makePlaneContact("ball","right",-1,0,0,b);local c2=makePlaneContact("ball","top",0,-1,0,b);c1.restitution=0;c2.restitution=0;out[#out+1]=runCase("orthogonal_corner",b,{c1,c2},{16,32,64,128},{c1,c2})end
-- Oblique feasible inelastic contacts.
do local b={{id="ball",vx=20,vy=-10,invMass=1}};local cs={};for i,a in ipairs({0,120})do local r=math.rad(a);local c=makePlaneContact("ball","oblique"..i,math.cos(r),math.sin(r),0,b);c.restitution=0;cs[#cs+1]=c end;out[#out+1]=runCase("oblique_120_e0",b,cs,{16,32,64,128},cs)end
-- Near-opposite 179.94 degrees: compare zero-target feasibility and independent per-contact restitution targets.
for _,e in ipairs({0,.5})do local b={{id="ball",vx=20,vy=-10,invMass=1}};local cs={};for i,a in ipairs({0,179.94})do local r=math.rad(a);local c=makePlaneContact("ball","near"..i,math.cos(r),math.sin(r),e,b);c.restitution=e;cs[#cs+1]=c end;out[#out+1]=runCase("near_179_94_e"..tostring(e),b,cs,{16,32,64,128},cs)end
-- Exact opposed, inelastic: singular but feasible, nonunique impulse decomposition.
do local b={{id="ball",vx=10,vy=0,invMass=1}};local cs={makePlaneContact("ball","plus",1,0,0,b),makePlaneContact("ball","minus",-1,0,0,b)};for _,c in ipairs(cs)do c.restitution=0 end;out[#out+1]=runCase("opposed_180_e0",b,cs,{16,32,64,128},cs)end
-- Exact opposed with incoming restitution target: mathematically incompatible.
do local b={{id="ball",vx=10,vy=0,invMass=1}};local cs={makePlaneContact("ball","plus",1,0,1,b),makePlaneContact("ball","minus",-1,0,1,b)};for _,c in ipairs(cs)do c.restitution=1 end;out[#out+1]=runCase("opposed_180_incompatible_restitution",b,cs,{16,32,64,128},cs)end
-- Duplicate same surface: PGS deduplicates; independent oracle finds singular/redundant LCP.
do local b={{id="ball",vx=10,vy=0,invMass=1}};local c1=makePlaneContact("ball","dup",-1,0,0,b);local c2=table.clone(c1);for _,c in ipairs({c1,c2})do c.restitution=0 end;out[#out+1]=runCase("duplicate_same_surface",b,{c1,c2},{16,32,64,128},{c1,c2})end
-- Redundant same-direction different surfaces.
do local b={{id="ball",vx=10,vy=0,invMass=1}};local c1=makePlaneContact("ball","a",-1,0,0,b);local c2=makePlaneContact("ball","b",-1,0,0,b);for _,c in ipairs({c1,c2})do c.restitution=0 end;out[#out+1]=runCase("redundant_same_normal",b,{c1,c2},{16,32,64,128},{c1,c2})end
-- Previous order-sensitive case from the saved sweep: four normals at 0,40,80,120 degrees; e=0.
for _,reverse in ipairs({false,true})do local b={{id="ball",vx=0,vy=-10,invMass=1}};local cs={};local angles={0,40,80,120};for i,a in ipairs(angles)do local r=math.rad(a);local id="s"..string.format("%02d",i);if reverse and i==1 then id="s04" elseif reverse and i==4 then id="s01" end;local c=makePlaneContact("ball",id,math.cos(r),math.sin(r),0,b);c.restitution=0;cs[#cs+1]=c end;out[#out+1]=runCase(reverse and "order_case_reverse_ids" or "order_case_canonical",b,cs,{16,32,64,128},cs,reverse and "reverseIds" or "canonical",.8)end
do local b={{id="ball",vx=0,vy=-10,invMass=1}};local cs={};for i,a in ipairs({0,40,80,120})do local r=math.rad(a);local c=makePlaneContact("ball","s"..string.format("%02d",i),math.cos(r),math.sin(r),0,b);c.restitution=0;cs[#cs+1]=c end;local rev={};for i=#cs,1,-1 do rev[#rev+1]=cs[i]end;out[#out+1]=runCase("order_case_input_permutation",b,rev,{16,32,64,128},rev,"sameIds-reversedArray",.8)end
-- Two dynamic bodies with different masses and velocities, one internal contact.
do local bodies={{id="A",vx=10,vy=0,invMass=1},{id="B",vx=-2,vy=0,invMass=.25}};local c={surfaceId="A_B",nx=-1,ny=0,target=6,restitution=.5,terms={{bodyId="A",x=-1,y=0},{bodyId="B",x=1,y=0}}};out[#out+1]=runCase("two_dynamic_different_mass",bodies,{c},{16,32,64,128},nil)end
-- Input validation.
do local b={{id="ball",vx=0,vy=0,invMass=1}};local c={surfaceId="invalid",nx=0,ny=0,target=0,terms={{bodyId="ball",x=0,y=0}}};out[#out+1]=runCase("invalid_zero_normal",b,{c},{16},{c})end
-- Re-run the exact previous 11,520-case input grid through two independent LCPs:
-- the targets actually used by PGS (zero for multi-contact), and restitution per row.
local totals={cases=0,pgsSuccess=0,pgsFailure=0,effectiveFeasible=0,desiredFeasible=0,desiredIncompatible=0,pgsFailureButEffectiveFeasible=0,pgsSuccessButDesiredIncompatible=0,pgsSuccessButDesiredKktFailure=0,pgsSuccessDesiredKktPass=0,maxSuccessfulEffectiveVelocityError=0}
local byAngleCount={};local orderPairs={}
for _,angle in ipairs({90,120,150,170,175,179,179.94,180})do for _,v0 in ipairs({{20,0},{20,-10},{0,-10}})do for _,e in ipairs({0,.5,1})do for _,count in ipairs({1,2,3,4})do for _,reverse in ipairs({false,true})do
 local b={{id="ball",vx=v0[1],vy=v0[2],invMass=1}};local cs={};local spread=math.rad(angle)
 for i=0,count-1 do local a=count==1 and 0 or spread*(i/(count-1));local id=(i==0 and "a" or i==count-1 and "z" or ("m"..i));if reverse and i==0 then id="z" elseif reverse and i==count-1 then id="a" end;local n={x=math.cos(a),y=math.sin(a)};local vn=n.x*v0[1]+n.y*v0[2];local target=vn < -1e-9 and e*(-vn) or 0;cs[#cs+1]={bodyId="ball",surfaceId=id,nx=n.x,ny=n.y,restitution=e,target=target,terms={{bodyId="ball",x=n.x,y=n.y}}}end
 local desired=oracle(b,cs);local actualTargets={};for i,c in ipairs(cs)do local z=table.clone(c);if count>1 then z.target=0 end;actualTargets[i]=z end;local effective=oracle(b,actualTargets)
 local key=string.format("%.5f|%.9g|%.9g|%.1f|%d",angle,v0[1],v0[2],e,count);byAngleCount[key]=byAngleCount[key] or {angle=angle,count=count,total=0,desiredIncompatible=0,pgsFailures=0,pgsSuccess=0,pgsFalseSuccess=0}
 for _,budget in ipairs({16,32,64,128})do for _,omega in ipairs({.5,.8,1,1.2,1.5})do
  local rows={};for _,c in ipairs(cs)do rows[#rows+1]={bodyId="ball",surfaceId=c.surfaceId,nx=c.nx,ny=c.ny,restitution=e}end
  local rr=TracePGS.solve({id="ball",vx=v0[1],vy=v0[2],invMass=1},rows,{iterations=budget,maxIterations=128,residualTolerance=1e-8,velocityTolerance=1e-9,relaxation=omega})
  totals.cases+=1;local ag=byAngleCount[key];ag.total+=1
  local desiredOk=desired.class~="incompatible" and desired.class~="invalid";local effectiveOk=effective.class~="incompatible" and effective.class~="invalid"
  if desiredOk then totals.desiredFeasible+=1 else totals.desiredIncompatible+=1;ag.desiredIncompatible+=1 end;if effectiveOk then totals.effectiveFeasible+=1 end
  if rr.ok then totals.pgsSuccess+=1;ag.pgsSuccess+=1 else totals.pgsFailure+=1;ag.pgsFailures+=1;if effectiveOk then totals.pgsFailureButEffectiveFeasible+=1 end end
  if rr.ok and not desiredOk then totals.pgsSuccessButDesiredIncompatible+=1;ag.pgsFalseSuccess+=1 end
  local desiredKkt=math.huge
  if rr.post then desiredKkt=0;local lambdaById={};for _,imp in ipairs(rr.impulses or {})do lambdaById[imp.surfaceId]=imp.lambda end;for _,c in ipairs(cs)do local w=rr.post.vx*c.nx+rr.post.vy*c.ny-c.target;local l=lambdaById[c.surfaceId] or 0;local violation=l>0 and math.abs(w) or math.max(0,-w);desiredKkt=math.max(desiredKkt,violation)end end
  if rr.ok and desiredKkt>1e-8 then totals.pgsSuccessButDesiredKktFailure+=1 end;if rr.ok and desiredKkt<=1e-8 then totals.pgsSuccessDesiredKktPass+=1 end
  if rr.ok and effective.post then local dx=rr.post.vx-effective.post[1].vx;local dy=rr.post.vy-effective.post[1].vy;local dv=math.sqrt(dx*dx+dy*dy);totals.maxSuccessfulEffectiveVelocityError=math.max(totals.maxSuccessfulEffectiveVelocityError,dv)end
  if count==2 and angle==179.94 and v0[1]==20 and v0[2]==-10 and e==.5 and budget==128 and omega==1 then print(string.format("GRID_FOCUS|angle=%.5f|dot=%.17g|count=%d|e=%.1f|desired=%s|desiredQ=%s|effective=%s|pgs=%s|res=%.17g|post=%.17g,%.17g|desiredKkt=%.17g",angle,cs[1].nx*cs[2].nx+cs[1].ny*cs[2].ny,count,e,desired.class,table.concat(desired.q or {},","),effective.class,tostring(rr.ok),rr.residual,rr.post.vx,rr.post.vy,desiredKkt))end
  if count==4 and angle==120 and v0[1]==0 and v0[2]==-10 and e==0 and budget==16 and omega==.8 then local pairKey=key.."|"..budget.."|"..omega;orderPairs[pairKey]=orderPairs[pairKey] or {};orderPairs[pairKey][reverse and "reverse" or "canonical"]={ok=rr.ok,res=rr.residual,vx=rr.post.vx,vy=rr.post.vy}end
 end end
end end end end end
local changed=0;for _,p in pairs(orderPairs)do if p.canonical and p.reverse and (p.canonical.ok~=p.reverse.ok or math.abs(p.canonical.res-p.reverse.res)>1e-12 or math.abs(p.canonical.vx-p.reverse.vx)>1e-12 or math.abs(p.canonical.vy-p.reverse.vy)>1e-12)then changed+=1 end end
print(string.format("GRID_TOTAL|cases=%d|pgsSuccess=%d|pgsFailure=%d|effectiveFeasible=%d|desiredFeasible=%d|desiredIncompatible=%d|failureButEffectiveFeasible=%d|successButDesiredIncompatible=%d|successButDesiredKktFailure=%d|successDesiredKktPass=%d|maxSuccessfulEffectiveVelocityError=%.17g|orderPairs=%d|orderStatusOrOutputDiffs=%d",totals.cases,totals.pgsSuccess,totals.pgsFailure,totals.effectiveFeasible,totals.desiredFeasible,totals.desiredIncompatible,totals.pgsFailureButEffectiveFeasible,totals.pgsSuccessButDesiredIncompatible,totals.pgsSuccessButDesiredKktFailure,totals.pgsSuccessDesiredKktPass,totals.maxSuccessfulEffectiveVelocityError,changed>0 and 1 or 0,changed))
for _,a in ipairs({90,120,150,170,175,179,179.94,180})do for _,n in ipairs({1,2,3,4})do local total=0;local inc=0;local failed=0;local ok=0;local falseSuccess=0;for _,g in pairs(byAngleCount)do if g.angle==a and g.count==n then total+=g.total;inc+=g.desiredIncompatible;failed+=g.pgsFailures;ok+=g.pgsSuccess;falseSuccess+=g.pgsFalseSuccess end end;print(string.format("GRID_ANGLE|angle=%.5f|count=%d|total=%d|desiredIncompatible=%d|pgsFailed=%d|pgsSuccess=%d|falseSuccess=%d",a,n,total,inc,failed,ok,falseSuccess))end end
print("END|cases="..#out)