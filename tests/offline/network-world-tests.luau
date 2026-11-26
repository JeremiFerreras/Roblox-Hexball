-- Ten independent clients, authoritative LocalMatch, real codecs/queues/core/prediction.
local results = {}
local function run(seed, loss)
	local rng = seed
	local function random(n)
		rng = (1664525 * rng + 1013904223) % 4294967296
		return rng % n
	end
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
	local actors, masks = {}, {}
	for i, spawn in ipairs(Profile.SpawnPoints) do
		actors[i] = Core.addDisc(w, {
			id = i,
			kind = "player",
			team = i <= 5 and "red" or "blue",
			x = spawn.x,
			y = spawn.y,
			radius = 15,
			invMass = 0.5,
			damping = 0.96,
			bCoef = 0.5,
			acceleration = 0.1,
			kickAcceleration = 0.07,
			kickDamping = 0.96,
			kickStrength = 5,
			collisionGroup = i <= 5 and 2 or 4,
			collisionMask = 39,
		})
		masks[i] = 39
	end
	local state = {
		coreWorld = w,
		ball = ball,
		players = actors,
		spawnPoints = Profile.SpawnPoints,
		playerCollisionMasks = masks,
		score = { red = 0, blue = 0 },
		tick = 0,
	}
	local match = LocalMatch.attach(state, { goalPauseTicks = 15, kickoffTicks = 10 })
	local net = NetServer.new()
	net:epoch(1, 1, 0)
	local clients = {}
	local up, down = {}, {}
	local actualMasks = {}
	local controlSeq = 0
	for slot = 1, 10 do
		clients[slot] = {
			sender = NetInputClient.new(),
			predictor = NetPrediction.new(),
			tick = -1,
			rtt = slot * 20,
			correction = 0,
			lastReliable = 0,
			accepted = 0,
		}
	end
	local function snapshot()
		local s = {
			matchId = 1,
			round = match.round,
			tick = state.tick,
			coreMode = true,
			elapsedMatchTicks = match.elapsedTicks,
			matchPhase = match.match.phase,
			pauseTicksRemaining = match.match.remainingTicks,
			kickoffTeam = match.match.kickoffTeam,
			lastTouch = match.match.lastTouch,
			lastGoal = match.match.lastGoal,
			score = table.clone(state.score),
			ball = { x = ball.x, y = ball.y, vx = ball.vx, vy = ball.vy, radius = 10 },
			players = {},
		}
		for i, p in ipairs(actors) do
			s.players[i] = {
				playerId = i,
				ownerUserId = i,
				team = p.team,
				x = p.x,
				y = p.y,
				vx = p.vx,
				vy = p.vy,
				radius = p.radius,
				collisionMask = p.collisionMask,
				kickHeld = p.kickHeld,
				kickArmed = p.kickArmed,
				kickCooldown = p.kickCooldown,
				needsKickRelease = match.needsKickRelease[i],
				inputMask = actualMasks[i] or 0,
				ack = net.queues[i].ack,
			}
		end
		return s
	end
	local function transmit(value, reliable, tick)
		for slot, c in ipairs(clients) do
			if reliable or random(100) >= loss then
				local at = tick + math.max(1, math.ceil(c.rtt * 0.03) + random(5) - 2)
				if reliable then
					at = math.max(at, c.lastReliable + 1)
					c.lastReliable = at
				end
				table.insert(down, { slot = slot, at = at, value = value, reliable = reliable })
			end
		end
	end
	for tick = 1, 1800 do
		local now = tick / 60
		for slot, c in ipairs(clients) do
			local mask = tick < 1300
					and ((math.floor(tick / (31 + slot)) % 2 == 0 and 2 or 1) + (math.floor(tick / 47 + slot) % 3 == 0 and 4 or 0) + (tick % (79 + slot) < 3 and 16 or 0))
				or 0
			c.mask = mask
			if c.base then
				c.sender:sample(mask, c.tick + math.floor((tick - c.arrival) / 1), now)
				local b, reliable = c.sender:packet(now)
				if b and (reliable or random(100) >= loss) then
					local at = tick + math.max(1, math.ceil(c.rtt * 0.03) + random(5) - 2)
					table.insert(up, { at = at, b = b, slot = slot })
					if random(8) == 0 then
						table.insert(up, { at = at + 3, b = b, slot = slot })
					end
				end
			end
		end
		for i = #up, 1, -1 do
			if up[i].at <= tick then
				net:receive(up[i].slot, up[i].b, state.tick)
				table.remove(up, i)
			end
		end
		if tick % 211 == 0 and match.match.phase == "playing" then
			ball.x, ball.y, ball.vx, ball.vy = tick % 422 == 0 and 369 or -369, 0, tick % 422 == 0 and 4 or -4, 0
		end
		local applied = net:consume(state.tick + 1)
		local result = match:step(applied)
		for i, v in ipairs(result.inputs) do
			actualMasks[i] = NetCodec.mask(v.x, v.y, v.kick)
		end
		net:epoch(1, match.round, state.tick)
		local s = snapshot()
		net:publish(s, function(full)
			transmit(full, true, tick)
		end, function(b)
			transmit(b, false, tick)
		end)
		for i = #down, 1, -1 do
			if down[i].at <= tick then
				local p = down[i]
				local c = clients[p.slot]
				local s
				if p.reliable then
					if not c.base or p.value.round >= c.base.round then
						c.base = p.value
					end
					s = p.value
				else
					s = NetCodec.decodeState(p.value, c.base)
				end
				if
					s and (not c.latest or s.round > c.latest.round or s.round == c.latest.round and s.tick >= c.tick)
				then
					if not c.latest or s.round ~= c.latest.round then
						c.sender:reset(1, s.round, s.players[p.slot].ack)
					end
					c.sender:confirm(s.players[p.slot].ack)
					c.latest = s
					c.tick = s.tick
					c.arrival = tick
					c.accepted += 1
					c.predictor:restore(s, p.slot)
					c.correction = math.max(c.correction, c.predictor.correction)
				end
				table.remove(down, i)
			end
		end
		for slot, c in ipairs(clients) do
			if c.latest then
				c.predictor:advance(c.tick + math.min(18, 1 + math.ceil(c.rtt * 0.03) + tick - c.arrival), c.mask)
				assert(c.predictor.world.tick <= c.tick + 18 and #c.sender.pending <= 32)
			end
		end
	end
	for slot, c in ipairs(clients) do
		assert(
			c.accepted > 100 and c.sender.ack == c.sender.seq and #c.sender.pending == 0,
			"client failed recovery: " .. slot
		)
		assert(net.queues[slot].mask == 0)
		for _, key in ipairs({ "x", "y", "vx", "vy" }) do
			assert(c.latest.players[slot][key] == actors[slot][key], "settled authoritative state did not converge")
		end
	end
	assert(state.score.red + state.score.blue > 0)
	return string.format(
		"seed=%d loss=%d ticks=1800 clients=10 statePackets=%d rawBytes=%d",
		seed,
		loss,
		net.stats.statePackets,
		net.stats.stateBytes
	)
end
for seed = 1, 4 do
	for _, loss in ipairs({ 0, 5, 15 }) do
		local ok, detail = pcall(function()
			return run(seed, loss)
		end)
		table.insert(results, { "world_10clients_seed" .. seed .. "_loss" .. loss, ok, tostring(detail) })
	end
end
emit(json(results))
