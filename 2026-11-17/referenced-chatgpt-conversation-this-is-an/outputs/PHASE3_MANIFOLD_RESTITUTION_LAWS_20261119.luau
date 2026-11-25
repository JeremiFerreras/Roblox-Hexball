-- Independent restitution-law study; never edits or calls the production solver.
local TOL=1e-8
local function solveLinear(M,b)
 local n=#b;if n==0 then return {} end;local a={};local scale=0
 for i=1,n do a[i]={};for j=1,n do a[i][j]=M[i][j];scale=math.max(scale,math.abs(M[i][j]))end;a[i][n+1]=b[i]end
 for k=1,n do local p=k;for i=k+1,n do if math.abs(a[i][k])>math.abs(a[p][k])then p=i end end;if math.abs(a[p][k])<=math.max(1,scale)*1e-13 then return nil end;a[k],a[p]=a[p],a[k];local d=a[k][k];for j=k,n+1 do a[k][j]/=d end;for i=1,n do if i~=k then local f=a[i][k];for j=k,n+1 do a[i][j]-=f*a[k][j]end end end end
 local x={};for i=1,n do x[i]=a[i][n+1]end;return x
end
local function build(vx,vy,invMass,contacts)
 table.sort(contacts,function(a,b)local ai,bi=tostring(a.id),tostring(b.id);if ai~=bi then return ai<bi end;if a.nx~=b.nx then return a.nx<b.nx end;if a.ny~=b.ny then return a.ny<b.ny end;return (a.e or 0)<(b.e or 0)end);local n=#contacts;local A={};local g={};for i=1,n do A[i]={};g[i]=contacts[i].nx*vx+contacts[i].ny*vy end;for i=1,n do for j=1,n do A[i][j]=invMass*(contacts[i].nx*contacts[j].nx+contacts[i].ny*contacts[j].ny)end end;return A,g
end
local function energyDelta(g,A,l)
 local d=0;for i=1,#l do d+=g[i]*l[i];for j=1,#l do d+=.5*l[i]*A[i][j]*l[j]end end;return d
end
local function state(vx,vy,invMass,contacts,A,l)
 local x,y=vx,vy;for i,c in ipairs(contacts)do x+=invMass*c.nx*l[i];y+=invMass*c.ny*l[i]end;local vn={};for i,c in ipairs(contacts)do vn[i]=c.nx*x+c.ny*y end;return {vx=x,vy=y,vn=vn,energy=.5*(x*x+y*y)/invMass}
end
local function kkt(A,g,target,l)
 local maxv=0;local w={};for i=1,#l do local z=g[i]-target[i];for j=1,#l do z+=A[i][j]*l[j]end;w[i]=z;maxv=math.max(maxv,l[i]>TOL and math.abs(z) or math.max(0,-z))end;return maxv,w
end
-- Exhaustive independent active-set oracle for a contact LCP.
local function lcp(vx,vy,invMass,contacts,target)
 local A,g=build(vx,vy,invMass,contacts);local n=#contacts;local q={};for i=1,n do q[i]=g[i]-target[i]end
 for mask=0,2^n-1 do local active={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then active[#active+1]=i end end;local block,rhs={},{};for ii,i in ipairs(active)do block[ii]={};rhs[ii]=-q[i];for jj,j in ipairs(active)do block[ii][jj]=A[i][j]end end;local sol=solveLinear(block,rhs);if sol then local lam={};for i=1,n do lam[i]=0 end;local ok=true;for k,i in ipairs(active)do if sol[k]<-TOL then ok=false else lam[i]=math.max(0,sol[k])end end;if ok then local residual,w=kkt(A,g,target,lam);if residual<=TOL then local s=state(vx,vy,invMass,contacts,A,lam);return {ok=true,A=A,g=g,q=q,lambda=lam,w=w,residual=residual,state=s,energyDelta=energyDelta(g,A,lam),active=active,mask=mask}end end end end
 return {ok=false,A=A,g=g,q=q,reason="no complementary active set",energyDelta=nil}
end
local function desiredTargets(g,eByContact)local b={};for i,vn in ipairs(g)do b[i]=math.max(0,-vn)*eByContact[i]end;return b end
-- Candidate C: inelastic projection, then scale its impulse response. Cap eM so every row remains feasible.
local function scaledInelastic(vx,vy,invMass,contacts,eM)
 local A,g=build(vx,vy,invMass,contacts);local zero=table.create(#g,0);local base=lcp(vx,vy,invMass,contacts,zero);if not base.ok then return {ok=false,reason="inelastic-base-incompatible"}end
 local eEff=math.min(1,math.max(0,eM));for i=1,#g do local d=0;for j=1,#g do d+=A[i][j]*base.lambda[j]end;local gi=g[i]+d;if d < -TOL then eEff=math.min(eEff,math.max(0,gi/(-d)))end end
 local lam={};for i=1,#g do lam[i]=(1+eEff)*base.lambda[i]end;local s=state(vx,vy,invMass,contacts,A,lam);local targets={};for i=1,#g do targets[i]=base.lambda[i]>TOL and s.vn[i] or 0 end;local residual,w=kkt(A,g,targets,lam);local minVn=math.huge;for _,v in ipairs(s.vn)do minVn=math.min(minVn,v)end
 return {ok=residual<=TOL and minVn>=-TOL,eEffective=eEff,base=base,lambda=lam,state=s,targets=targets,w=w,residual=residual,energyDelta=energyDelta(g,A,lam),minPostVn=minVn}
end
local function constrainLinear(lo,hi,c0,c1)
 if math.abs(c1)<=1e-14 then if c0 < -TOL then return nil end;return lo,hi end
 local root=(-TOL-c0)/c1;if c1>0 then lo=math.max(lo,root)else hi=math.min(hi,root)end;if lo>hi+1e-12 then return nil end;return lo,hi
end
local function intersectEnergy(lo,hi,a,b,c)
 if a<0 and a>-1e-12 then a=0 end
 if math.abs(a)<=1e-14 then if math.abs(b)<=1e-14 then if c<=TOL then return lo,hi else return nil end end;local r=(-c)/b;if b>0 then hi=math.min(hi,r)else lo=math.max(lo,r)end;if lo>hi then return nil end;return lo,hi end
 local disc=b*b-4*a*c;if disc<0 then if a*lo*lo+b*lo+c<=TOL then return lo,hi else return nil end end;local root=math.sqrt(math.max(0,disc));local r1=(-b-root)/(2*a);local r2=(-b+root)/(2*a);lo=math.max(lo,r1);hi=math.min(hi,r2);if lo>hi then return nil end;return lo,hi
end
-- Candidate D: project the individual target vector along its ray b(gamma)=gamma*bIndividual.
-- Enumerate active sets; on each support impulses are affine in gamma and the energy bound is quadratic.
local function projectTargets(vx,vy,invMass,contacts,bDesired)
 local A,g=build(vx,vy,invMass,contacts);local n=#g;local best=nil
 for mask=0,2^n-1 do local S={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then S[#S+1]=i end end;local block={};local rhs0,rhs1={},{};for ii,i in ipairs(S)do block[ii]={};rhs0[ii]=-g[i];rhs1[ii]=bDesired[i];for jj,j in ipairs(S)do block[ii][jj]=A[i][j]end end;local l0=solveLinear(block,rhs0);local l1=solveLinear(block,rhs1)
  if l0 and l1 then local lo,hi=0,1;local valid=true;local pos={};for k,i in ipairs(S)do pos[i]=k;lo,hi=constrainLinear(lo,hi,l0[k],l1[k]);if not lo then valid=false;break end end
   if valid then for j=1,n do if not pos[j]then local c0=g[j];local c1=-bDesired[j];for k,i in ipairs(S)do c0+=A[j][i]*l0[k];c1+=A[j][i]*l1[k]end;lo,hi=constrainLinear(lo,hi,c0,c1);if not lo then valid=false;break end end end end
   if valid then local c0,c1,c2=0,0,0;for k,i in ipairs(S)do c0+=g[i]*l0[k];c1+=g[i]*l1[k];for j,jj in ipairs(S)do c0+=.5*l0[k]*A[i][jj]*l0[j];c1+=l0[k]*A[i][jj]*l1[j];c2+=.5*l1[k]*A[i][jj]*l1[j]end end;lo,hi=intersectEnergy(lo,hi,c2,c1,c0);if lo and hi>=-TOL then local gamma=math.clamp(hi,0,1);if not best or gamma>best.gamma+1e-12 then local lam=table.create(n,0);for k,i in ipairs(S)do lam[i]=math.max(0,l0[k]+gamma*l1[k])end;local targets={};for i=1,n do targets[i]=gamma*bDesired[i]end;local residual,w=kkt(A,g,targets,lam);local s=state(vx,vy,invMass,contacts,A,lam);best={ok=residual<=2*TOL and energyDelta(g,A,lam)<=2*TOL,gamma=gamma,A=A,g=g,lambda=lam,targets=targets,w=w,residual=residual,state=s,energyDelta=energyDelta(g,A,lam),support=S,mask=mask}end end end
  end
 end
 if not best then return {ok=false,reason="no passive feasible active set"} end;if best.gamma<=1e-8 then local z=table.create(n,0);local inelastic=lcp(vx,vy,invMass,contacts,z);if not inelastic.ok then return {ok=false,reason="inelastic-fallback-infeasible",gamma=0} end;inelastic.gamma=0;inelastic.targets=z;inelastic.energyDelta=energyDelta(inelastic.g,inelastic.A,inelastic.lambda);return inelastic end;if best.energyDelta>0 then local gammaSafe=best.gamma*(1-1e-9);local safeTargets={};for i=1,n do safeTargets[i]=gammaSafe*bDesired[i]end;local safe=lcp(vx,vy,invMass,contacts,safeTargets);if safe.ok and safe.energyDelta<=1e-8 then safe.gamma=gammaSafe;safe.targets=safeTargets;return safe end end;return best
end
local function summarizeLaw(law,preEnergy)
 if not law or not law.ok then return "FAIL",math.huge,math.huge,math.huge end;local e=law.energyDelta or (law.state.energy-preEnergy);local min=math.huge;for _,v in ipairs(law.state.vn)do min=math.min(min,v)end;return "OK",law.residual,e,min
end
local grid={cases=0,Afeasible=0,Aincompatible=0,Anonpassive=0,AmaxEnergyRise=0,Bfeasible=0,Bincompatible=0,Bnonpassive=0,BmaxEnergyRise=0,Cvalid=0,Creduced=0,CzeroFallback=0,CmaxEnergyRise=0,Dvalid=0,Dreduced=0,DzeroFallback=0,DmaxEnergyRise=0,isolatedExact=0,determinismErrors=0}
local byAngle={}
for _,angle in ipairs({90,120,150,170,175,179,179.94,180})do for _,v0 in ipairs({{20,0},{20,-10},{0,-10}})do for _,e in ipairs({0,.5,1})do for _,count in ipairs({1,2,3,4})do for _,reverse in ipairs({false,true})do
 local contacts={};local spread=math.rad(angle);for i=0,count-1 do local a=count==1 and 0 or spread*(i/(count-1));local id=i==0 and "a" or i==count-1 and "z" or ("m"..i);if reverse and i==0 then id="z"elseif reverse and i==count-1 then id="a"end;contacts[#contacts+1]={id=id,nx=math.cos(a),ny=math.sin(a),e=e}end;table.sort(contacts,function(a,b)return a.id<b.id end)
 for _,budget in ipairs({16,32,64,128})do for _,omega in ipairs({.5,.8,1,1.2,1.5})do local _,g=build(v0[1],v0[2],1,contacts);local eBy={};for i=1,count do eBy[i]=contacts[i].e end;local bInd=desiredTargets(g,eBy);local aLaw=lcp(v0[1],v0[2],1,contacts,bInd);local bLaw=aLaw -- common eM equals e on this uniform-material factorial grid.
 local cLaw=scaledInelastic(v0[1],v0[2],1,contacts,e);local dLaw=projectTargets(v0[1],v0[2],1,contacts,bInd)
 local preE=.5*(v0[1]^2+v0[2]^2);grid.cases+=1;local ag=byAngle[angle]or{angle=angle,total=0,Aincompatible=0,A_nonpassive=0,C_reduced=0,D_reduced=0};byAngle[angle]=ag;ag.total+=1
 if aLaw.ok then grid.Afeasible+=1;grid.AmaxEnergyRise=math.max(grid.AmaxEnergyRise,aLaw.energyDelta);if aLaw.energyDelta>1e-7 then grid.Anonpassive+=1;ag.A_nonpassive+=1 end else grid.Aincompatible+=1;ag.Aincompatible+=1 end
 if bLaw.ok then grid.Bfeasible+=1;grid.BmaxEnergyRise=math.max(grid.BmaxEnergyRise,bLaw.energyDelta);if bLaw.energyDelta>1e-7 then grid.Bnonpassive+=1 end else grid.Bincompatible+=1 end
 if cLaw.ok then grid.Cvalid+=1;if cLaw.eEffective<e-1e-8 then grid.Creduced+=1;ag.C_reduced+=1 end;if cLaw.eEffective<=1e-10 and e>0 then grid.CzeroFallback+=1 end;grid.CmaxEnergyRise=math.max(grid.CmaxEnergyRise,cLaw.energyDelta)else grid.Cvalid+=0 end
 if dLaw.ok then grid.Dvalid+=1;if dLaw.gamma<1-1e-8 then grid.Dreduced+=1;ag.D_reduced+=1 end;if dLaw.gamma<=1e-10 and e>0 then grid.DzeroFallback+=1 end;grid.DmaxEnergyRise=math.max(grid.DmaxEnergyRise,dLaw.energyDelta)end
 if count==1 and aLaw.ok and math.abs(aLaw.state.vn[1]-bInd[1])<1e-7 then grid.isolatedExact+=1 end
 if angle==179.94 and v0[1]==20 and v0[2]==-10 and e==.5 and count==2 and not reverse and budget==16 and omega==.5 then local ast,ar,ae,amin=summarizeLaw(aLaw,preE);local cst,cr,ce,cmin=summarizeLaw(cLaw,preE);local dst=summarizeLaw(dLaw,preE);print(string.format("FOCUS17994|A=%s,%.17g,%.17g,%.17g|C=%s,eEff=%.17g,res=%.17g,dE=%.17g,v=%.17g,%.17g|minVn=%.17g|D=%s,ok=%s,gamma=%.17g,resActual=%.17g,dEActual=%.17g,v=%.17g,%.17g|minVn=%.17g",ast,ar,ae,amin,cst,cLaw.eEffective or -1,cr,ce,cLaw.state and cLaw.state.vx or 0,cLaw.state and cLaw.state.vy or 0,cmin,dst,tostring(dLaw.ok),dLaw.gamma or -1,dLaw.residual or math.huge,dLaw.energyDelta or math.huge,dLaw.state and dLaw.state.vx or 0,dLaw.state and dLaw.state.vy or 0,dLaw.state and math.min(table.unpack(dLaw.state.vn)) or math.huge))end
 if angle==179.94 and v0[1]==20 and v0[2]==-10 and e==1 and count==2 and not reverse and budget==16 and omega==.5 then print(string.format("FOCUS17994E1|Aok=%s|A_dE=%.17g|Av=%.17g,%.17g|C_eEff=%.17g|Cv=%.17g,%.17g|D_gamma=%.17g|D_dE=%.17g|Dv=%.17g,%.17g",tostring(aLaw.ok),aLaw.energyDelta,aLaw.state and aLaw.state.vx or 0,aLaw.state and aLaw.state.vy or 0,cLaw.eEffective or -1,cLaw.state and cLaw.state.vx or 0,cLaw.state and cLaw.state.vy or 0,dLaw.gamma or -1,dLaw.energyDelta or math.huge,dLaw.state and dLaw.state.vx or 0,dLaw.state and dLaw.state.vy or 0))end
 if angle==180 and v0[1]==10 and v0[2]==0 and e==1 and count==2 and not reverse and budget==16 and omega==.5 then print(string.format("FOCUS180|A=%s|C=%s,eEff=%.17g,res=%.17g,dE=%.17g|D=%s,gamma=%.17g,res=%.17g,dE=%.17g",aLaw.ok and "FEASIBLE" or "INCOMPATIBLE",cLaw.ok and "OK" or "FAIL",cLaw.eEffective or -1,cLaw.residual or math.huge,cLaw.energyDelta or math.huge,dLaw.ok and "OK" or "FAIL",dLaw.gamma or -1,dLaw.residual or math.huge,dLaw.energyDelta or math.huge))end
end end end end end
end end
print(string.format("GRID_TOTAL|cases=%d|Afeasible=%d|Aincompatible=%d|Anonpassive=%d|AmaxEnergyRise=%.17g|Bfeasible=%d|Bincompatible=%d|Bnonpassive=%d|BmaxEnergyRise=%.17g|Cvalid=%d|Creduced=%d|CzeroFallback=%d|CmaxEnergyRise=%.17g|Dvalid=%d|Dreduced=%d|DzeroFallback=%d|DmaxEnergyRise=%.17g|isolatedExact=%d",grid.cases,grid.Afeasible,grid.Aincompatible,grid.Anonpassive,grid.AmaxEnergyRise,grid.Bfeasible,grid.Bincompatible,grid.Bnonpassive,grid.BmaxEnergyRise,grid.Cvalid,grid.Creduced,grid.CzeroFallback,grid.CmaxEnergyRise,grid.Dvalid,grid.Dreduced,grid.DzeroFallback,grid.DmaxEnergyRise,grid.isolatedExact))
for _,a in ipairs({90,120,150,170,175,179,179.94,180})do local g=byAngle[a];print(string.format("GRID_ANGLE|angle=%.5f|total=%d|Aincompatible=%d|Anonpassive=%d|Creduced=%d|Dreduced=%d",a,g.total,g.Aincompatible,g.A_nonpassive,g.C_reduced,g.D_reduced))end
-- Mixed contact materials, effective e_M is an explicit input, not inferred from surface bCoef.
do local vx,vy,inv=10,10,1;local cs={{id="mat-low",nx=-1,ny=0,e=.2},{id="mat-high",nx=0,ny=-1,e=.8}};local _,g=build(vx,vy,inv,cs);local emix={};for i,c in ipairs(cs)do emix[i]=c.e end;local bi=desiredTargets(g,emix);local a=lcp(vx,vy,inv,cs,bi);local d=projectTargets(vx,vy,inv,cs,bi);print(string.format("MIXED|individual=0.2,0.8|A=%s,v=%.17g,%.17g,dE=%.17g|D=%s,gamma=%.17g,eEff=%.17g,%.17g,v=%.17g,%.17g,dE=%.17g",a.ok and "OK" or "FAIL",a.state.vx,a.state.vy,a.energyDelta,d.ok and "OK" or "FAIL",d.gamma,d.gamma*.2,d.gamma*.8,d.state.vx,d.state.vy,d.energyDelta));for _,em in ipairs({.2,.5,.8})do local common={em,em};local bt=desiredTargets(g,common);local b=lcp(vx,vy,inv,cs,bt);local c=scaledInelastic(vx,vy,inv,cs,em);print(string.format("MIXED_COMMON|eM=%.1f|B=%s,v=%.17g,%.17g,dE=%.17g|C=%s,eEff=%.17g,v=%.17g,%.17g,dE=%.17g",em,b.ok and "OK" or "FAIL",b.state and b.state.vx or 0,b.state and b.state.vy or 0,b.energyDelta or math.huge,c.ok and "OK" or "FAIL",c.eEffective or -1,c.state and c.state.vx or 0,c.state and c.state.vy or 0,c.energyDelta or math.huge))end end
-- Input permutation control: reorder same surfaces; stable sorting must yield identical D/C velocities.
do local c1={{id="a",nx=math.cos(0),ny=math.sin(0),e=.5},{id="z",nx=math.cos(math.rad(179.94)),ny=math.sin(math.rad(179.94)),e=.5}};local c2={c1[2],c1[1]};local _,g1=build(20,-10,1,c1);local _,g2=build(20,-10,1,c2);local d1=projectTargets(20,-10,1,c1,desiredTargets(g1,{.5,.5}));local d2=projectTargets(20,-10,1,c2,desiredTargets(g2,{.5,.5}));print(string.format("PERMUTATION|sameIdsReversedInput|gamma1=%.17g|gamma2=%.17g|v1=%.17g,%.17g|v2=%.17g,%.17g|equal=%s",d1.gamma,d2.gamma,d1.state.vx,d1.state.vy,d2.state.vx,d2.state.vy,tostring(math.abs(d1.gamma-d2.gamma)<1e-12 and math.abs(d1.state.vx-d2.state.vx)<1e-9 and math.abs(d1.state.vy-d2.state.vy)<1e-9)))end

-- Direct isolated approach: exact legacy restitution for 0<=e<=1.
for _,e in ipairs({0,.5,1,1.2})do local vx,vy,inv=0,10,1;local cs={{id="floor",nx=0,ny=-1,e=e}};local _,g=build(vx,vy,inv,cs);local bi=desiredTargets(g,{e});local a=lcp(vx,vy,inv,cs,bi);local b=a;local c=scaledInelastic(vx,vy,inv,cs,e);local d=projectTargets(vx,vy,inv,cs,bi);print(string.format("ISOLATED|e=%.1f|A=%.17g,%.17g,dE=%.17g|B=%.17g,%.17g|C=eEff=%.17g,v=%.17g,%.17g,dE=%.17g|D=gamma=%.17g,eEff=%.17g,v=%.17g,%.17g,dE=%.17g",e,a.state.vx,a.state.vy,a.energyDelta,b.state.vx,b.state.vy,c.eEffective,c.state.vx,c.state.vy,c.energyDelta,d.gamma,d.gamma*e,d.state.vx,d.state.vy,d.energyDelta))end
-- Exact opposite constraints with per-contact restitution: C/D must report explicit inelastic fallback, never success at e>0.
do local vx,vy,inv=10,0,1;local cs={{id="plus",nx=1,ny=0,e=1},{id="minus",nx=-1,ny=0,e=1}};local _,g=build(vx,vy,inv,cs);local bi=desiredTargets(g,{1,1});local a=lcp(vx,vy,inv,cs,bi);local b=a;local c=scaledInelastic(vx,vy,inv,cs,1);local d=projectTargets(vx,vy,inv,cs,bi);print(string.format("OPPOSED180|A=%s|B=%s|C=eEff=%.17g,v=%.17g,%.17g,res=%.17g|D=gamma=%.17g,v=%.17g,%.17g,res=%.17g",a.ok and "FEASIBLE" or "INCOMPATIBLE",b.ok and "FEASIBLE" or "INCOMPATIBLE",c.eEffective,c.state.vx,c.state.vy,c.residual,d.gamma,d.state.vx,d.state.vy,d.residual))end
-- Two dynamic bodies, analytic one-contact control with unequal inverse masses.
do local invA,invB=1,.25;local vA,vB=10,-2;local nx=-1;local g=nx*(vA-vB);local e=.5;local target=-e*g;local A=invA+invB;local lambda=(target-g)/A;local postA=vA+invA*nx*lambda;local postB=vB-invB*nx*lambda;local momentumBefore=vA/invA+vB/invB;local momentumAfter=postA/invA+postB/invB;local energyBefore=.5*vA*vA/invA+.5*vB*vB/invB;local energyAfter=.5*postA*postA/invA+.5*postB*postB/invB;print(string.format("TWO_BODY_SINGLE|target=%.17g|lambda=%.17g|postA=%.17g|postB=%.17g|momentum=%.17g,%.17g|energy=%.17g,%.17g|A_B_C_D_same=true",target,lambda,postA,postB,momentumBefore,momentumAfter,energyBefore,energyAfter))end
