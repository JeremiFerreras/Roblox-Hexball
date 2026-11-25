-- Standalone Luau convergence sweep: uses the reference PGS module and an instrumented clone.
local PGS=require("./PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119")
local TracePGS=require("./PHASE3_CONTACT_MANIFOLD_PGS_TRACE_CLONE_20261119")
local angles={90,120,150,170,175,179,179.94,180}
local velocities={{20,0},{20,-10},{0,-10}}
local restitutions={0,.5,1}
local counts={1,2,3,4}
local budgets={16,32,64,128}
local relaxations={.5,.8,1,1.2,1.5}
local total,baselineMatch=0,0
local maxError=0
local failing,converged={},{}
local selectedTraces={}

local function solveOracle(vx,vy,normals,restitution)
	if #normals==1 then
		local n=normals[1];local vn=vx*n.x+vy*n.y
		if vn<0 then local target=-(restitution or 0)*vn;return {vx=vx+(target-vn)*n.x,vy=vy+(target-vn)*n.y} end
		return {vx=vx,vy=vy}
	end
	local candidates={{vx=vx,vy=vy},{vx=0,vy=0}}
	for _,n in ipairs(normals) do
		local dot=vx*n.x+vy*n.y
		candidates[#candidates+1]={vx=vx-math.min(0,dot)*n.x,vy=vy-math.min(0,dot)*n.y}
	end
	local best,bestDistance=nil,math.huge
	for _,v in ipairs(candidates) do
		local feasible=true
		for _,n in ipairs(normals) do if v.vx*n.x+v.vy*n.y < -1e-10 then feasible=false;break end end
		if feasible then local d=(v.vx-vx)^2+(v.vy-vy)^2;if d<bestDistance then best,bestDistance=v,d end end
	end
	return best
end
local function makeNormals(angleDeg,count,swapIds)
	local spread=math.rad(angleDeg);local ns={}
	for i=0,count-1 do
		local a=count==1 and 0 or spread*(i/(count-1))
		local id=(i==0 and "a" or i==count-1 and "z" or ("m"..i))
		if swapIds and i==0 then id="z" elseif swapIds and i==count-1 then id="a" end
		ns[#ns+1]={x=math.cos(a),y=math.sin(a),surfaceId=id,angle=a}
	end
	return ns
end
local function contactRows(normals,bodyId,restitution)
	local c={};for _,n in ipairs(normals)do c[#c+1]={bodyId=bodyId,surfaceId=n.surfaceId,nx=n.x,ny=n.y,restitution=restitution}end;return c
end

print("SUMMARY|angleDeg|normalDot|vx0|vy0|restitution|count|order|iterations|omega|ok|residual|errV|impulseSum")
for _,angle in ipairs(angles) do
	for _,velocity in ipairs(velocities) do
		for _,e in ipairs(restitutions) do
			for _,count in ipairs(counts) do
				for _,swapped in ipairs({false,true}) do
					local normals=makeNormals(angle,count,swapped);local rows=contactRows(normals,"ball",e);local oracle=solveOracle(velocity[1],velocity[2],normals,e)
					local product=count==1 and 1 or (normals[1].x*normals[count].x+normals[1].y*normals[count].y)
					for _,budget in ipairs(budgets) do
						for _,omega in ipairs(relaxations) do
							local b={id="ball",vx=velocity[1],vy=velocity[2],invMass=1}
							local options={iterations=budget,maxIterations=128,residualTolerance=1e-8,velocityTolerance=1e-9,relaxation=omega,captureTrace=true}
							local r=TracePGS.solve(b,rows,options)
							local err=oracle and math.sqrt((r.post.vx-oracle.vx)^2+(r.post.vy-oracle.vy)^2) or math.huge
							maxError=math.max(maxError,err);total+=1
							if omega==1 then
								local original=PGS.solve({id="ball",vx=velocity[1],vy=velocity[2],invMass=1},rows,{iterations=budget,maxIterations=128,residualTolerance=1e-8,velocityTolerance=1e-9})
								if original.ok==r.ok and original.reason==r.reason and math.abs(original.post.vx-r.post.vx)<1e-13 and math.abs(original.post.vy-r.post.vy)<1e-13 and math.abs(original.residual-r.residual)<1e-13 then baselineMatch+=1 end
							end
							if r.ok then converged[#converged+1]={angle=angle,velocity=velocity,e=e,count=count,order=swapped and "reverseIds" or "canonical",iterations=budget,omega=omega,err=err}
							else failing[#failing+1]={angle=angle,velocity=velocity,e=e,count=count,order=swapped and "reverseIds" or "canonical",iterations=budget,omega=omega,residual=r.residual,err=err} end
							local impulseSum=0;for _,imp in ipairs(r.impulses or {})do impulseSum+=imp.lambda end
							print(string.format("ROW|%.5f|%.12g|%.9g|%.9g|%.1f|%d|%s|%d|%.1f|%s|%.12g|%.12g|%.12g",angle,product,velocity[1],velocity[2],e,count,swapped and "reverseIds" or "canonical",budget,omega,tostring(r.ok),r.residual,err,impulseSum))
							if angle>=170 and velocity[1]==20 and velocity[2]==-10 and e==.5 and count==2 and not swapped then
								for _,t in ipairs(r.trace or {})do selectedTraces[#selectedTraces+1]={angle=angle,normalDot=product,iterations=budget,omega=omega,order="canonical",iteration=t.iteration,residual=t.residual,vx=t.vx,vy=t.vy,lambdas=t.lambdas,normalVelocities=t.normalVelocities}end
							end
						end
					end
				end
			end
		end
	end
end
print(string.format("SUMMARY_END|cases=%d|baselineMatches=%d|maxOracleVelocityError=%.17g|failures=%d|converged=%d",total,baselineMatch,maxError,#failing,#converged))
print("TRACE_BEGIN")
for _,t in ipairs(selectedTraces)do
	local l={};for _,v in ipairs(t.lambdas)do l[#l+1]=string.format("%.17g",v)end
	local n={};for _,v in ipairs(t.normalVelocities)do n[#n+1]=string.format("%.17g",v)end
	print(string.format("TRACE|angle=%.5f|dot=%.17g|budget=%d|omega=%.1f|iter=%d|residual=%.17g|vx=%.17g|vy=%.17g|lambda=%s|vn=%s",t.angle,t.normalDot,t.iterations,t.omega,t.iteration,t.residual,t.vx,t.vy,table.concat(l,","),table.concat(n,",")))
end
print("TRACE_END")

-- Explicit semantic probe: opposing restitution targets would be incompatible,
-- but the reference PGS currently replaces all multi-contact targets with zero.
do
	local c={{bodyId="ball",surfaceId="left",nx=1,ny=0,restitution=1},{bodyId="ball",surfaceId="right",nx=-1,ny=0,restitution=1}}
	local b={id="ball",vx=10,vy=0,invMass=1}
	local r=PGS.solve(b,c,{iterations=16,maxIterations=128,residualTolerance=1e-8})
	print(string.format("SEMANTIC_PROBE|opposing_restitution|ok=%s|reason=%s|residual=%.17g|post=(%.17g,%.17g)|lambdas=%s|note=multi-targets-zero",tostring(r.ok),tostring(r.reason),r.residual,r.post.vx,r.post.vy,tostring(r.impulses[1].lambda)..","..tostring(r.impulses[2].lambda)))
end