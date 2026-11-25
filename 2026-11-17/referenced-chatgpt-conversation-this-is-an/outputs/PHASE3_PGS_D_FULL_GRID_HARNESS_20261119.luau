-- Full previous 11,520-entry factorial grid: iterative PGS-D vs independent D active-set oracle.
local P=require("./PHASE3_PGS_D_ISOLATED_20261119")
local TOL=1e-8
local function lin(A,b)
 local n=#b;if n==0 then return {} end;local q,scale={},0
 for i=1,n do q[i]={};for j=1,n do q[i][j]=A[i][j];scale=math.max(scale,math.abs(A[i][j]))end;q[i][n+1]=b[i]end
 for k=1,n do local p=k;for i=k+1,n do if math.abs(q[i][k])>math.abs(q[p][k])then p=i end end;if math.abs(q[p][k])<=math.max(1,scale)*1e-13 then return nil end;q[k],q[p]=q[p],q[k];local d=q[k][k];for j=k,n+1 do q[k][j]/=d end;for i=1,n do if i~=k then local f=q[i][k];for j=k,n+1 do q[i][j]-=f*q[k][j]end end end end
 local x={};for i=1,n do x[i]=q[i][n+1]end;return x
end
local function matrix(vx,vy,cs)
 local n=#cs;local A,g={},{};for i=1,n do A[i]={};g[i]=cs[i].nx*vx+cs[i].ny*vy end
 for i=1,n do for j=1,n do A[i][j]=cs[i].nx*cs[j].nx+cs[i].ny*cs[j].ny end end;return A,g
end
local function solveLcp(A,g,b,gamma)
 local n=#g;for mask=0,2^n-1 do local S={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then S[#S+1]=i end end
  local B,rhs={},{ };for ii,i in ipairs(S)do B[ii]={};rhs[ii]=-g[i]+gamma*b[i];for jj,j in ipairs(S)do B[ii][jj]=A[i][j]end end
  local z=lin(B,rhs);if z then local l=table.create(n,0);local ok=true;for k,i in ipairs(S)do if z[k]<-TOL then ok=false else l[i]=math.max(0,z[k])end end
   if ok then local w,res={},0;for i=1,n do local v=g[i]-gamma*b[i];for j=1,n do v+=A[i][j]*l[j]end;w[i]=v;res=math.max(res,l[i]>TOL and math.abs(v) or math.max(0,-v))end
    if res<=TOL then return {lambda=l,w=w,residual=res,support=S}end
   end
  end
 end;return nil
end
local function enDelta(g,A,l)
 local e=0;for i=1,#l do e+=g[i]*l[i];for j=1,#l do e+=.5*l[i]*A[i][j]*l[j]end end;return e
end
local function cLin(lo,hi,c0,c1)
 if math.abs(c1)<1e-14 then if c0 < -TOL then return nil end;return lo,hi end
 local r=(-TOL-c0)/c1;if c1>0 then lo=math.max(lo,r)else hi=math.min(hi,r)end;if lo>hi+1e-12 then return nil end;return lo,hi
end
local function cEnergy(lo,hi,a,b,c)
 if a<0 and a>-1e-12 then a=0 end
 if math.abs(a)<1e-14 then if math.abs(b)<1e-14 then if c<=TOL then return lo,hi else return nil end end;local r=-c/b;if b>0 then hi=math.min(hi,r)else lo=math.max(lo,r)end;if lo>hi then return nil end;return lo,hi end
 local d=b*b-4*a*c;if d<0 then if a*lo*lo+b*lo+c<=TOL then return lo,hi else return nil end end
 local sd=math.sqrt(math.max(0,d));lo=math.max(lo,(-b-sd)/(2*a));hi=math.min(hi,(-b+sd)/(2*a));if lo>hi then return nil end;return lo,hi
end
-- Independent active-set enumeration of the D ray projection, not using PGS output.
local function oracleD(vx,vy,cs,b)
 local A,g=matrix(vx,vy,cs);local n=#g;local best
 for mask=0,2^n-1 do local S={};for i=1,n do if math.floor(mask/2^(i-1))%2==1 then S[#S+1]=i end end
  local B,r0,r1={},{},{};for ii,i in ipairs(S)do B[ii]={};r0[ii]=-g[i];r1[ii]=b[i];for jj,j in ipairs(S)do B[ii][jj]=A[i][j]end end
  local x0,x1=lin(B,r0),lin(B,r1)
  if x0 and x1 then local lo,hi=0,1;local good=true;local slot={}
   for k,i in ipairs(S)do slot[i]=k;lo,hi=cLin(lo,hi,x0[k],x1[k]);if not lo then good=false;break end end
   if good then for i=1,n do if not slot[i]then local z0,z1=g[i],-b[i];for k,j in ipairs(S)do z0+=A[i][j]*x0[k];z1+=A[i][j]*x1[k]end;lo,hi=cLin(lo,hi,z0,z1);if not lo then good=false;break end end end end
   if good then local e0,e1,e2=0,0,0;for k,i in ipairs(S)do e0+=g[i]*x0[k];e1+=g[i]*x1[k];for j,jj in ipairs(S)do e0+=.5*x0[k]*A[i][jj]*x0[j];e1+=x0[k]*A[i][jj]*x1[j];e2+=.5*x1[k]*A[i][jj]*x1[j]end end;lo,hi=cEnergy(lo,hi,e2,e1,e0)
    if lo and hi>=-TOL and (not best or hi>best.gamma+1e-12)then local gamma=math.clamp(hi,0,1);local l=table.create(n,0);for k,i in ipairs(S)do l[i]=math.max(0,x0[k]+gamma*x1[k])end;local inc=solveLcp(A,g,table.create(n,0),0);if gamma<=1e-8 and inc then gamma=0;l=inc.lambda end;local d=enDelta(g,A,l);local vx1,vy1=vx,vy;local r=0;for i,c in ipairs(cs)do vx1+=c.nx*l[i];vy1+=c.ny*l[i]end;for i=1,n do local w=g[i]-gamma*b[i];for j=1,n do w+=A[i][j]*l[j]end;r=math.max(r,l[i]>TOL and math.abs(w) or math.max(0,-w))end;best={gamma=gamma,lambda=l,energyDelta=d,residual=r,vx=vx1,vy=vy1,A=A,g=g,support=S}end
   end
  end
 end
 if best and best.energyDelta>0 then
  local gammaSafe=best.gamma*(1-1e-9);local safe=solveLcp(best.A,best.g,b,gammaSafe)
  if safe then local l=safe.lambda;local vxSafe,vySafe=vx,vy;for i,c in ipairs(cs)do vxSafe+=c.nx*l[i];vySafe+=c.ny*l[i]end
   local energy=.5*(vxSafe*vxSafe+vySafe*vySafe)-.5*(vx*vx+vy*vy)
   if energy<=1e-8 then best={gamma=gammaSafe,lambda=l,energyDelta=energy,residual=safe.residual,vx=vxSafe,vy=vySafe,A=best.A,g=best.g,support=safe.support}end
  end
 end
 return best
end
local function fmt(xs)local t={};for _,x in ipairs(xs or {})do t[#t+1]=string.format("%.17g",x)end;return table.concat(t,",")end
local total={cases=0,oracleMissing=0,pgsConverged=0,pgsFailed=0,falseSuccessOriginal=0,pgsVsOracleMismatch=0,energyPositive=0,gammaReduced=0,gammaZero=0,maxResidual=0,maxVelocityError=0,maxGammaError=0,maxOriginalResidual=0}
print("schema|PGS-D-v1|grid=11520|tol=1e-8")
local idx=0
for _,ang in ipairs({90,120,150,170,175,179,179.94,180})do
 for _,v0 in ipairs({{20,0},{20,-10},{0,-10}})do for _,e in ipairs({0,.5,1})do for _,count in ipairs({1,2,3,4})do for _,rev in ipairs({false,true})do
  local cs={};for i=0,count-1 do local a=count==1 and 0 or math.rad(ang)*(i/(count-1));local id=i==0 and "a" or i==count-1 and "z" or ("m"..i);if rev and i==0 then id="z"elseif rev and i==count-1 then id="a"end;cs[#cs+1]={surfaceId=id,nx=math.cos(a),ny=math.sin(a),restitution=e}end
  table.sort(cs,function(a,b)return a.surfaceId<b.surfaceId end)
  local g,b={},{};for i,c in ipairs(cs)do g[i]=c.nx*v0[1]+c.ny*v0[2];b[i]=math.max(0,-g[i])*e end
  local oracle=oracleD(v0[1],v0[2],cs,b)
  for _,budget in ipairs({16,32,64,128})do for _,omega in ipairs({.5,.8,1,1.2,1.5})do
   idx+=1;total.cases+=1
   local rr=P.solve({vx=v0[1],vy=v0[2],invMass=1},cs,{iterations=budget,relaxation=omega,tolerance=TOL})
   local dv=oracle and math.sqrt((rr.post.vx-oracle.vx)^2+(rr.post.vy-oracle.vy)^2)or math.huge
   local dg=oracle and math.abs(rr.gamma-oracle.gamma)or math.huge
   local targetMismatch=rr.originalTargetResidual>TOL and rr.ok
   if not oracle then total.oracleMissing+=1 end
   if rr.ok then total.pgsConverged+=1 else total.pgsFailed+=1 end
   if targetMismatch then total.falseSuccessOriginal+=1 end
   if oracle and (dv>1e-6 or dg>1e-8)then total.pgsVsOracleMismatch+=1 end
   if rr.energyDelta>1e-7 then total.energyPositive+=1 end
   if rr.gamma<1-1e-8 then total.gammaReduced+=1 end;if rr.gamma<=1e-8 then total.gammaZero+=1 end
   total.maxResidual=math.max(total.maxResidual,rr.residualKKT);total.maxOriginalResidual=math.max(total.maxOriginalResidual,rr.originalTargetResidual);total.maxVelocityError=math.max(total.maxVelocityError,dv);total.maxGammaError=math.max(total.maxGammaError,dg)
   print(table.concat({"row",idx,ang,v0[1],v0[2],e,count,rev and "reverseIds" or "canonical",budget,omega,
    string.format("%.17g",rr.gamma),fmt(rr.originalTargets),fmt(rr.projectedTargets),fmt(rr.lambda),
    string.format("%.17g",rr.post.vx),string.format("%.17g",rr.post.vy),fmt(rr.post.normalVelocities),
    string.format("%.17g",rr.residualKKT),string.format("%.17g",rr.originalTargetResidual),
    string.format("%.17g",rr.energyDelta),tostring(rr.ok),tostring(targetMismatch),
    oracle and string.format("%.17g",oracle.gamma)or "nan",oracle and fmt(oracle.lambda)or "",
    oracle and string.format("%.17g",oracle.vx)or "nan",oracle and string.format("%.17g",oracle.vy)or "nan",
    oracle and string.format("%.17g",oracle.residual)or "nan",oracle and string.format("%.17g",oracle.energyDelta)or "nan",
    string.format("%.17g",dg),string.format("%.17g",dv),budget},"|"))
  end end
  end end end end
end
print(string.format("TOTAL|cases=%d|oracleMissing=%d|converged=%d|failed=%d|falseSuccessOriginal=%d|oracleMismatch=%d|energyPositive=%d|gammaReduced=%d|gammaZero=%d|maxResidual=%.17g|maxOriginalResidual=%.17g|maxVelocityError=%.17g|maxGammaError=%.17g",total.cases,total.oracleMissing,total.pgsConverged,total.pgsFailed,total.falseSuccessOriginal,total.pgsVsOracleMismatch,total.energyPositive,total.gammaReduced,total.gammaZero,total.maxResidual,total.maxOriginalResidual,total.maxVelocityError,total.maxGammaError))
print("END")
