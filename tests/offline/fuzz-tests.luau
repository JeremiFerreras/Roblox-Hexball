local results = {}
local function make(seed)
	local w = Core.newWorld({ solverMode = "haxballDiscrete", useBounds = false })
	local ball = Core.addDisc(w, {
		id = "ball",
		kind = "ball",
		radius = 10,
		invMass = 1,
		damping = 0.99,
		bCoef = 0.5,
		kickable = true,
		traceMotion = true,
		collisionGroup = 1,
	})
	Stadium.install(Core, w)
	local players, masks = {}, {}
	for slot, spawn in ipairs(Profile.SpawnPoints) do
		players[slot] = Core.addDisc(w, {
			id = slot,
			kind = "player",
			team = slot <= 5 and "red" or "blue",
			x = spawn.x,
			y = spawn.y,
			radius = 15,
			invMass = 0.5,
			damping = 0.96,
			bCoef = 0.5,
			acceleration = 0.1,
			kickAcceleration = 0.07,
			kickStrength = 5,
			collisionGroup = slot <= 5 and 2 or 4,
			collisionMask = 39,
		})
		masks[slot] = 39
	end
	return LocalMatch.attach({
		coreWorld = w,
		ball = ball,
		players = players,
		playerCollisionMasks = masks,
		spawnPoints = Profile.SpawnPoints,
		score = { red = 0, blue = 0 },
		tick = 0,
	}, { startingTeam = seed % 2 == 0 and "red" or "blue", scoreLimit = seed % 7 == 0 and 3 or 0 })
end
for seed = 1, 64 do
	local ok, detail = pcall(function()
		local rng = seed
		local function random(n)
			rng = (1664525 * rng + 1013904223) % 4294967296
			return rng % n
		end
		local m = make(seed)
		local goals, restarts = 0, 0
		for tick = 1, 1800 do
			if tick % 601 == 0 then
				m:restart(random(2) == 0 and "red" or "blue")
				restarts += 1
			end
			if tick % 173 == 0 and m.match.phase == "playing" then
				local sign = random(2) == 0 and -1 or 1
				m.state.ball.x, m.state.ball.y, m.state.ball.vx, m.state.ball.vy = sign * 369, 0, sign * 4, 0
			end
			local oldScore = m.state.score.red + m.state.score.blue
			local oldTick = m.state.tick
			local oldPositions = {}
			local oldPhase = m.match.phase
			for i, d in ipairs(m.state.coreWorld.discs) do
				oldPositions[i] = { d.x, d.y }
			end
			local input = {}
			for slot = 1, 10 do
				input[slot] = { x = random(3) - 1, y = random(3) - 1, kick = random(11) < 3 }
			end
			local r = m:step(input)
			local tickGoals = 0
			for _, e in ipairs(r.ruleEvents) do
				assert(e.tick == m.state.tick)
				if e.kind == "goalScored" then
					tickGoals += 1
					goals += 1
				end
			end
			assert(m.state.tick == oldTick + 1)
			assert(m.state.score.red + m.state.score.blue == oldScore + tickGoals)
			assert(tickGoals <= 1)
			assert(
				m.match.phase == "kickoff"
					or m.match.phase == "playing"
					or m.match.phase == "goalPause"
					or m.match.phase == "finished"
			)
			for i, d in ipairs(m.state.coreWorld.discs) do
				for _, v in ipairs({ d.x, d.y, d.vx, d.vy }) do
					assert(v == v and math.abs(v) < 1e6)
				end
				if oldPhase ~= "playing" and not r.roundChanged then
					assert(d.x == oldPositions[i][1] and d.y == oldPositions[i][2], "locked position changed")
				end
			end
			if m.match.kickoffTeam == nil then
				for _, p in ipairs(m.state.players) do
					assert(p.collisionMask == 39)
				end
			end
			if r.roundChanged then
				assert(m.match.lastTouch == nil and m.state.ball.x == 0 and m.state.ball.y == 0)
			end
		end
		assert(goals > 0 and restarts == 2)
		return string.format("seed=%d ticks=1800 goals=%d restarts=%d", seed, goals, restarts)
	end)
	table.insert(results, { "random_match_seed_" .. seed, ok, tostring(detail) })
end
emit(json(results))
