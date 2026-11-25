-- Instrumented clone of the PGS prototype for convergence experiments.
-- Not wired into the TOI harness or any production module.
local Manifold = {}

local function finite(x)
	return type(x) == "number" and x == x and math.abs(x) < math.huge
end

local function stableLess(a, b)
	local ab, bb = typeof(a.bodyId)..":"..tostring(a.bodyId), typeof(b.bodyId)..":"..tostring(b.bodyId)
	if ab ~= bb then return ab < bb end
	local as, bs = typeof(a.surfaceId)..":"..tostring(a.surfaceId), typeof(b.surfaceId)..":"..tostring(b.surfaceId)
	if as ~= bs then return as < bs end
	if a.nx ~= b.nx then return a.nx < b.nx end
	return a.ny < b.ny
end

-- Solves one dynamic body's 2D normal constraints against static surfaces.
-- Multi-contact manifolds use zero restitution to avoid incompatible bounce
-- targets at nearly coincident/opposed surfaces. Single contacts retain the
-- supplied restitution target. Returns failure rather than a guessed state.
function Manifold.solve(body, contacts, opts)
	opts = opts or {}
	if type(opts) ~= "table" then return {ok=false, reason="invalid-options"} end
	local iterations = opts.iterations or 16
	local maxIterations = opts.maxIterations or 64
	local residualTolerance = opts.residualTolerance or 1e-8
	local velocityTolerance = opts.velocityTolerance or 1e-9
	local relaxation = opts.relaxation or 1
	local captureTrace = opts.captureTrace == true
	if type(body) ~= "table" or not finite(body.vx) or not finite(body.vy)
		or not finite(body.invMass) or body.invMass <= 0 then
		return {ok=false, reason="invalid-body-state"}
	end
	if type(contacts) ~= "table" or not finite(iterations) or iterations < 1 or iterations % 1 ~= 0
		or not finite(maxIterations) or maxIterations < 1 or maxIterations % 1 ~= 0 or iterations > maxIterations
		or not finite(residualTolerance) or residualTolerance < 0
		or not finite(velocityTolerance) or velocityTolerance < 0
		or not finite(relaxation) or relaxation <= 0 or relaxation >= 2 then
		return {ok=false, reason="invalid-solver-input"}
	end
	local ordered = {}
	for _, original in ipairs(contacts) do
		if type(original) ~= "table" then return {ok=false, reason="invalid-contact"} end
		local c = table.clone(original)
		if c.bodyId == nil or c.surfaceId == nil or (body.id ~= nil and c.bodyId ~= body.id)
			or not finite(c.nx) or not finite(c.ny)
			or (c.restitution ~= nil and (not finite(c.restitution) or c.restitution < 0)) then
			return {ok=false, reason="invalid-contact-fields", surfaceId=c.surfaceId}
		end
		ordered[#ordered+1] = c
	end
	table.sort(ordered, stableLess)
	if #ordered == 0 then return {ok=true, impulses={}} end
	local seen, unique = {}, {}
	for _, c in ipairs(ordered) do
		local n = math.sqrt(c.nx*c.nx + c.ny*c.ny)
		if not finite(n) or n <= 1e-12 then
			return {ok=false, reason="invalid-normal-or-inverse-mass", surfaceId=c.surfaceId}
		end
		c.nx, c.ny = c.nx/n, c.ny/n
		local bodyKey = typeof(c.bodyId)..":"..tostring(c.bodyId)
		local surfaceKey = typeof(c.surfaceId)..":"..tostring(c.surfaceId)
		seen[bodyKey] = seen[bodyKey] or {}
		local prior = seen[bodyKey][surfaceKey]
		if prior then
			if prior.nx*c.nx + prior.ny*c.ny < 1-1e-12 then
				return {ok=false, reason="duplicate-surface-conflicting-normal", surfaceId=c.surfaceId}
			end
		else
			seen[bodyKey][surfaceKey]=c
			unique[#unique+1]=c
		end
	end
	local multi = #unique > 1
	local lambdas = table.create(#unique, 0)
	local vx0, vy0 = body.vx, body.vy
	local vx, vy = vx0, vy0
	local targets = table.create(#unique, 0)
	local trace = captureTrace and {} or nil
	for i,c in ipairs(unique) do
		local vn0 = vx0*c.nx + vy0*c.ny
		if not multi and vn0 < -velocityTolerance then targets[i] = -math.max(0, c.restitution or 0)*vn0 end
		if not finite(targets[i]) then return {ok=false, reason="nonfinite-target", surfaceId=c.surfaceId} end
	end
	for iterationIndex=1,iterations do
		for i,c in ipairs(unique) do
			local vn = vx*c.nx + vy*c.ny
			local delta = (targets[i]-vn)/body.invMass
			local nextLambda = math.max(0, lambdas[i]+relaxation*delta)
			delta = nextLambda-lambdas[i]
			lambdas[i] = nextLambda
			vx += c.nx*delta*body.invMass
			vy += c.ny*delta*body.invMass
			if not finite(vx) or not finite(vy) or not finite(lambdas[i]) then
				return {ok=false, reason="nonfinite-iteration-state", surfaceId=c.surfaceId,
					iterations=iterations, pre={vx=vx0,vy=vy0}, post={vx=vx,vy=vy}}
			end
		end
		if trace then
			local iterationResidual=0;local normalVelocities={}
			for j,c in ipairs(unique) do
				local gap=vx*c.nx+vy*c.ny-targets[j]
				local kkt=lambdas[j]>0 and math.abs(gap) or math.max(0,-gap)
				iterationResidual=math.max(iterationResidual,kkt)
				normalVelocities[j]=vx*c.nx+vy*c.ny
			end
			trace[#trace+1]={iteration=iterationIndex,residual=iterationResidual,vx=vx,vy=vy,lambdas=table.clone(lambdas),normalVelocities=normalVelocities}
		end
	end
	local residual = 0
	for i,c in ipairs(unique) do
		local gap = vx*c.nx + vy*c.ny-targets[i]
		local kkt = lambdas[i] > 0 and math.abs(gap) or math.max(0,-gap)
		residual = math.max(residual, kkt)
	end
	local impulses = {}
	for i,c in ipairs(unique) do impulses[#impulses+1]={bodyId=c.bodyId,surfaceId=c.surfaceId,lambda=lambdas[i]} end
	local ok = residual <= residualTolerance
	if ok then body.vx,body.vy=vx,vy end
	return {ok=ok,reason=(not ok) and "constraint-residual" or nil,iterations=iterations,residual=residual,
		multiContact=multi,pre={vx=vx0,vy=vy0},post={vx=vx,vy=vy},impulses=impulses,trace=trace}
end

return Manifold


