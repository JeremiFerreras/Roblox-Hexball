-- Runs the actual PGS module with the standalone official Luau CLI.
-- No Roblox APIs are used or emulated; the module depends only on Luau built-ins.
local Solver = require("./PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119")

local function body(vx, vy)
	return {id="ball", vx=vx, vy=vy, invMass=1}
end
local function contact(surfaceId, nx, ny, restitution)
	return {bodyId="ball", surfaceId=surfaceId, nx=nx, ny=ny, restitution=restitution}
end
local function near(a, b, eps)
	return math.abs(a-b) <= (eps or 1e-10)
end
local results = {}
local function record(name, status, result, b, extra)
	results[#results+1] = {name=name,status=status,result=result,body={vx=b.vx,vy=b.vy},extra=extra}
end
local function run(name, b, contacts, opts)
	local result = Solver.solve(b, contacts, opts)
	return result
end

do
	local b=body(0,10);local r=run("isolated_normal",b,{contact("floor",0,-1,.5)})
	assert(r.ok and near(b.vx,0) and near(b.vy,-5) and near(r.impulses[1].lambda,15),"isolated normal")
	record("isolated_normal","PASS",r,b)
end
do
	local b=body(20,20);local r=run("orthogonal_corner",b,{contact("right",-1,0,.5),contact("top",0,-1,.5)})
	assert(r.ok and near(b.vx,0) and near(b.vy,0) and #r.impulses==2,"orthogonal corner")
	record("orthogonal_corner","PASS",r,b)
end
do
	local b=body(20,0);local r=run("opposing_normals",b,{contact("outer",-1,0,.5),contact("net",1,0,.5)})
	assert(r.ok and near(b.vx,0) and near(r.residual,0),"opposing normals")
	record("opposing_normals","PASS",r,b)
end
do
	local b=body(20,-10);local r=run("nearly_opposing_normals",b,{contact("outer",-1,0),contact("net",.9999995,.001)})
	assert(not r.ok and r.reason=="constraint-residual" and near(b.vx,20) and near(b.vy,-10),"nearly opposing constraints must fail explicitly at iteration limit")
	record("nearly_opposing_normals","EXPECTED_FAILURE",r,b)
end
do
	local b=body(20,0);local r=run("duplicate_same_surface",b,{contact("wall",-1,0,.5),contact("wall",-1,0,.5)})
	assert(r.ok and #r.impulses==1 and near(b.vx,-10) and near(r.impulses[1].lambda,30),"duplicate surface")
	record("duplicate_same_surface","PASS",r,b)
end
do
	local b=body(20,0);local r=run("redundant_same_direction",b,{contact("a",-1,0),contact("b",-1,0)})
	assert(r.ok and #r.impulses==2 and near(b.vx,0) and near(r.impulses[1].lambda,20) and near(r.impulses[2].lambda,0),"redundant constraints")
	record("redundant_same_direction","PASS",r,b)
end
do
	local b=body(1,1);local input={contact("a",1,0),contact("b",-.5,.8660254037844386),contact("c",-.5,-.8660254037844386)}
	local r=run("nonconvergent_iteration_limit",b,input,{iterations=1,residualTolerance=1e-8})
	assert(not r.ok and r.reason=="constraint-residual" and near(r.residual,.3169872981077806) and near(b.vx,1) and near(b.vy,1),"iteration failure must preserve input")
	record("nonconvergent_iteration_limit","EXPECTED_FAILURE",r,b)
end
do
	local b=body(0/0,0);local r=run("nan_body",b,{contact("wall",1,0)})
	assert(not r.ok and r.reason=="invalid-body-state","NaN state")
	record("invalid_nan","EXPECTED_REJECTION",r,body(0,0))
end
do
	local b=body(1,0);local r=run("zero_normal",b,{contact("wall",0,0)})
	assert(not r.ok and r.reason=="invalid-normal-or-inverse-mass" and near(b.vx,1),"zero normal")
	record("invalid_zero_normal","EXPECTED_REJECTION",r,b)
end
do
	local b=body(10,0);local r=run("conflicting_duplicate_id",b,{contact("same",1,0),contact("same",-1,0)})
	assert(not r.ok and r.reason=="duplicate-surface-conflicting-normal" and near(b.vx,10),"conflicting duplicate")
	record("conflicting_duplicate_id","EXPECTED_REJECTION",r,b)
end
do
	local b=body(1,0);local r=run("iteration_cap_validation",b,{contact("wall",-1,0)}, {iterations=65,maxIterations=64})
	assert(not r.ok and r.reason=="invalid-solver-input" and near(b.vx,1),"iteration cap validation")
	record("iteration_cap_validation","EXPECTED_REJECTION",r,b)
end
do
	local b=body(math.huge,0);local r=run("infinite_body",b,{contact("wall",-1,0)})
	assert(not r.ok and r.reason=="invalid-body-state","infinite body state")
	record("invalid_infinity","EXPECTED_REJECTION",r,body(0,0))
end
do
	local b=body(1e308,0);local r=run("nonfinite_restitution_target",b,{contact("wall",-1,0,3)})
	assert(not r.ok and r.reason=="nonfinite-target" and b.vx==1e308,"nonfinite target rollback")
	record("nonfinite_target","EXPECTED_REJECTION",r,b)
end
do
	local a=run("order_a",body(20,20),{contact("top",0,-1),contact("right",-1,0)})
	local b=run("order_b",body(20,20),{contact("right",-1,0),contact("top",0,-1)})
	assert(a.ok and b.ok and near(a.post.vx,b.post.vx) and near(a.post.vy,b.post.vy)
		and #a.impulses==#b.impulses and a.impulses[1].surfaceId==b.impulses[1].surfaceId
		and a.impulses[2].surfaceId==b.impulses[2].surfaceId,"input order determinism")
	results[#results+1]={name="determinism_permutation",status="PASS",result=a,body={vx=a.post.vx,vy=a.post.vy}}
end

for _,item in ipairs(results) do
	local r=item.result or {}
	local p=r.post or item.body
	local impulses={}
	for _,imp in ipairs(r.impulses or {}) do
		impulses[#impulses+1]=tostring(imp.surfaceId)..":"..tostring(imp.lambda)
	end
	print(string.format("%s|%s|%s|%s|%s|%s|%s",item.name,item.status,
		tostring(p.vx),tostring(p.vy),tostring(r.residual or ""),tostring(r.reason or ""),table.concat(impulses,",")))
end
