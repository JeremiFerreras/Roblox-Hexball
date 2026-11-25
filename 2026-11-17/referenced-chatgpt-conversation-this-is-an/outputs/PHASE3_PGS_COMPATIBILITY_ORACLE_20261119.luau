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
print("END|cases="..#out)