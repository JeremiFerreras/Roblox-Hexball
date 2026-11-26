local results = {}
local function test(name, fn)
	local ok, err = pcall(fn)
	table.insert(results, { name, ok, ok and "PASS" or tostring(err) })
end
local function state()
	local s = {
		coreMode = true,
		matchId = 1,
		round = 1,
		tick = 0,
		elapsedMatchTicks = 0,
		matchPhase = "playing",
		pauseTicksRemaining = 0,
		score = { red = 0, blue = 0 },
		ball = { x = 0, y = 0, vx = 0, vy = 0, radius = 10, speed = 0 },
		players = {},
	}
	for i, p in ipairs(Profile.SpawnPoints) do
		s.players[i] = {
			playerId = i,
			ownerUserId = i,
			team = i <= 5 and "red" or "blue",
			x = p.x,
			y = p.y,
			vx = 0,
			vy = 0,
			radius = 15,
			speed = 0,
			ack = 0,
			kickHeld = false,
			kickArmed = false,
			kickCooldown = 0,
			collisionMask = 39,
			inputMask = 0,
		}
	end
	s.player = s.players[1]
	s.player2 = s.players[6]
	return s
end
local function command(seq, mask, tick)
	return { seq = seq, mask = mask, tick = tick or 0 }
end
local function packet(cmds, round)
	return NetCodec.encodeInput(1, round or 1, cmds)
end

test("state_codec_482_bytes_preserves_f64_and_hidden_state", function()
	local s = state()
	s.ball.x = math.pi
	s.players[1].vx = 1 / 3
	s.players[10].ack = 4294967295
	s.players[3].kickArmed = true
	s.players[3].needsKickRelease = true
	s.players[3].kickCooldown = 2
	local b = NetCodec.encodeState(s)
	assert(buffer.len(b) == 482)
	local d = assert(NetCodec.decodeState(b, s))
	assert(d.ball.x == s.ball.x and d.players[1].vx == s.players[1].vx)
	assert(
		d.players[10].ack == 4294967295
			and d.players[3].kickArmed
			and d.players[3].needsKickRelease
			and d.players[3].kickCooldown == 2
	)
end)
test("codecs_reject_truncation_version_nan_and_invalid_masks", function()
	assert(not NetCodec.decodeInput(buffer.create(1)))
	local b = packet({ command(1, 1) })
	buffer.writeu8(b, 20, 3)
	assert(not NetCodec.decodeInput(b))
	local s = state()
	local b = NetCodec.encodeState(s)
	buffer.writef64(b, 40, 0 / 0)
	assert(not NetCodec.decodeState(b, s))
	local b = NetCodec.encodeState(s)
	buffer.writeu8(b, 0, 2)
	assert(not NetCodec.decodeState(b, s))
end)
test("reordered_transitions_are_applied_once_in_sequence", function()
	local q = NetInputQueue.new(1, 1)
	assert(q:receive(packet({ command(2, 0) }), 1))
	assert(q:step(1).kick == false and q.ack == 0)
	assert(q:receive(packet({ command(1, 16), command(2, 0) }), 2))
	assert(q:step(2).kick and q.ack == 1)
	assert(q:receive(packet({ command(1, 16), command(2, 0) }), 3))
	assert(not q:step(3).kick and q.ack == 2)
	q:step(4)
	assert(q.ack == 2)
end)
test("old_epochs_duplicate_sequences_and_conflicts_are_rejected", function()
	local q = NetInputQueue.new(1, 2)
	assert(not q:receive(packet({ command(1, 1) }), 1))
	local q = NetInputQueue.new(1, 1)
	assert(not q:receive(packet({ command(1, 1), command(1, 2) }), 1))
	assert(next(q.pending) == nil)
	assert(q:receive(packet({ command(1, 1) }), 1))
	assert(not q:receive(packet({ command(1, 2) }), 1))
	assert(q:step(2).x == -1)
end)
test("input_flood_cannot_apply_extra_transitions_per_tick", function()
	local q = NetInputQueue.new(1, 1)
	local commands = {}
	for i = 1, 8 do
		commands[i] = command(i, i % 2 == 0 and 2 or 1)
	end
	for i = 1, 100 do
		q:receive(packet(commands), 0)
	end
	q:step(1)
	assert(q.ack == 1)
	assert(not q:receive(packet({ command(1000, 2) }), 1))
end)
test("lost_release_is_retransmitted_and_applied", function()
	local c = NetInputClient.new()
	c:reset(1, 1)
	local q = NetInputQueue.new(1, 1)
	c:sample(16, 0, 0)
	local b = c:packet(0)
	q:receive(b, 0)
	q:step(1)
	c:confirm(q.ack)
	c:sample(0, 2, 0.04)
	c:packet(0.04) -- dropped
	local b = c:packet(0.1)
	assert(b)
	q:receive(b, 6)
	assert(not q:step(7).kick)
	assert(q.ack == 2)
end)
test("input_timeout_stops_and_keepalive_recovers_held_direction", function()
	local q = NetInputQueue.new(1, 1)
	local b = packet({ command(1, 2) })
	q:receive(b, 0)
	assert(q:step(1).x == 1)
	assert(q:step(32).x == 0)
	assert(q:receive(b, 33))
	assert(q:step(34).x == 1 and q.ack == 1)
end)
test("round_reset_preserves_held_raw_input_until_release", function()
	local server = NetServer.new()
	server:epoch(1, 1, 0)
	server:receive(1, packet({ command(1, 16) }), 0)
	server:consume(1)
	server:epoch(1, 2, 100)
	assert(server:consume(101)[1].kick)
	assert(not server:receive(1, packet({ command(2, 0) }), 102))
end)
test("snapshot_rate_is_30hz_and_catchup_sends_only_latest", function()
	local server = NetServer.new()
	server:epoch(1, 1, 0)
	local s = state()
	local controls, packets = 0, 0
	for tick = 1, 600 do
		s.tick = tick
		server:publish(s, function()
			controls += 1
		end, function(b)
			packets += 1
			assert(buffer.len(b) == 482)
		end)
	end
	assert(packets == 300 and controls == 1 and server.stats.stateBytes == 144600)
	s.tick = 608
	server:publish(s, function()
		controls += 1
	end, function()
		packets += 1
	end)
	assert(packets == 301)
end)
test("prediction_replays_the_same_core_without_authority_side_effects", function()
	local s = state()
	local pred = NetPrediction.new()
	pred:restore(s, 1)
	local actor = pred:advance(12, 2)
	local x = actor.x
	assert(x > s.players[1].x and s.players[1].x == -80 and s.score.red == 0)
	local w = Core.newWorld({ solverMode = "haxballDiscrete", useBounds = false })
	Core.addDisc(w, {
		id = "ball",
		kind = "ball",
		radius = 10,
		invMass = 1,
		damping = 0.99,
		bCoef = 0.5,
		kickable = true,
		collisionGroup = 1,
	})
	Stadium.install(Core, w)
	local p = Profile.PhysicsBaseline.active.player
	for i, d in ipairs(s.players) do
		Core.addDisc(w, {
			id = i,
			kind = "player",
			x = d.x,
			y = d.y,
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
	end
	for tick = 1, 12 do
		Core.stepWorld(w, { [1] = { x = 1, y = 0, kick = false } })
	end
	assert(actor.x == w.discs[6].x and actor.vx == w.discs[6].vx)
	pred:restore(s, 1)
	assert(pred:advance(12, 2).x == x)
end)
test("prediction_stops_after_18_unconfirmed_ticks_and_resets_on_epoch", function()
	local s = state()
	local p = NetPrediction.new()
	p:restore(s, 1)
	p:advance(1000, 2)
	p:advance(1000, 2)
	assert(p.world.tick == 18)
	s.round = 2
	s.matchPhase = "kickoff"
	p:restore(s, 1)
	assert(p.world.tick == 0 and next(p.history) == nil and p:advance(3, 2) == nil)
end)

-- Both directions are delayed/lossy. Reliable fallbacks are delivered with the same delay.
for _, rtt in ipairs({ 20, 50, 100, 150, 200 }) do
	for _, loss in ipairs({ 0, 5, 15 }) do
		test("delivery_RTT" .. rtt .. "_loss" .. loss, function()
			local seed = rtt + loss + 1
			local function random(n)
				seed = (1664525 * seed + 1013904223) % 4294967296
				return seed % n
			end
			local c = NetInputClient.new()
			c:reset(1, 1)
			local q = NetInputQueue.new(1, 1)
			local up, down = {}, {}
			local lastState = -1
			local maxPending = 0
			for tick = 0, 1600 do
				local now = tick / 60
				local mask = tick < 1200 and ((math.floor(tick / 23) % 2 == 0 and 2 or 1) + (tick % 79 < 3 and 16 or 0))
					or 0
				c:sample(mask, tick, now)
				local b, reliable = c:packet(now)
				if b then
					local outage = tick >= 500 and tick < 540
					if reliable or not outage and random(100) >= loss then
						table.insert(up, { at = tick + math.max(1, math.ceil(rtt * 0.03) + random(5) - 2), b = b })
						if random(10) == 0 then
							table.insert(up, { at = tick + math.ceil(rtt * 0.03) + 3, b = b })
						end
					end
				end
				for i = #up, 1, -1 do
					if up[i].at <= tick then
						q:receive(up[i].b, tick)
						table.remove(up, i)
					end
				end
				q:step(tick)
				if tick % 2 == 0 and random(100) >= loss then
					table.insert(
						down,
						{ at = tick + math.max(1, math.ceil(rtt * 0.03) + random(5) - 2), ack = q.ack, tick = tick }
					)
				end
				for i = #down, 1, -1 do
					if down[i].at <= tick then
						if down[i].tick > lastState then
							c:confirm(down[i].ack)
							lastState = down[i].tick
						end
						table.remove(down, i)
					end
				end
				maxPending = math.max(maxPending, #c.pending)
				assert(#c.pending <= 32)
			end
			assert(q.ack == c.seq and #c.pending == 0 and q.mask == 0, "failed to converge")
		end)
	end
end
test("short_press_release_survives_a_single_batched_packet", function()
	local c = NetInputClient.new()
	c:reset(1, 1)
	c:sample(0, 0, 0)
	c:sample(16, 1, 0.001)
	c:sample(0, 2, 0.002)
	local q = NetInputQueue.new(1, 1)
	q:receive(c:packet(0.01), 0)
	assert(not q:step(1).kick)
	assert(q:step(2).kick)
	assert(not q:step(3).kick and q.ack == 3)
end)
test("same_tick_controls_do_not_depend_on_player_packet_arrival_order", function()
	local function run(reverse)
		local net = NetServer.new()
		net:epoch(1, 1, 0)
		if reverse then
			net:receive(2, packet({ command(1, 1) }), 0)
			net:receive(1, packet({ command(1, 2) }), 0)
		else
			net:receive(1, packet({ command(1, 2) }), 0)
			net:receive(2, packet({ command(1, 1) }), 0)
		end
		local inputs = net:consume(1)
		return json({ inputs[1].x, inputs[2].x, net.queues[1].ack, net.queues[2].ack })
	end
	assert(run(true) == run(false))
end)
test("client_rebases_to_a_trusted_newer_ack_after_resynchronization", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 5)
	c:sample(2, 0, 0)
	assert(c.seq == 6)
	assert(c:confirm(10))
	assert(c.ack == 10 and c.seq == 10 and #c.pending == 0)
	c:sample(2, 1, 0.1)
	assert(c.seq == 11)
	assert(not c:confirm(0 / 0) and not c:confirm(9))
end)
test("connection_timeout_cannot_rearm_a_held_kick", function()
	local prediction = NetPrediction.new()
	local w = prediction:_world()
	local players, masks = {}, {}
	for i = 1, 10 do
		players[i] = w.discs[5 + i]
		players[i].x = Profile.SpawnPoints[i].x
		players[i].y = Profile.SpawnPoints[i].y
		masks[i] = 39
	end
	local ball = w.discs[1]
	players[1].x, players[1].y = -27, 0
	local match = LocalMatch.attach({
		coreWorld = w,
		ball = ball,
		players = players,
		spawnPoints = Profile.SpawnPoints,
		playerCollisionMasks = masks,
		score = { red = 0, blue = 0 },
		tick = 0,
	}, { startWithKickoff = false })
	local net = NetServer.new()
	net:epoch(1, 1, 0)
	local held = packet({ command(1, 16) })
	net:receive(1, held, 0)
	local r = match:step(net:consume(1))
	local kicks = 0
	for _, e in ipairs(r.physicsEvents) do
		if e.kind == "kick" then
			kicks += 1
		end
	end
	assert(kicks == 1)
	for tick = 2, 33 do
		match:step(net:consume(tick))
	end
	assert(match.needsKickRelease[1])
	net:receive(1, held, 34)
	ball.x, ball.y, ball.vx, ball.vy = 0, 0, 0, 0
	players[1].x, players[1].y = -27, 0
	r = match:step(net:consume(34))
	for _, e in ipairs(r.physicsEvents) do
		assert(e.kind ~= "kick")
	end
	net:receive(1, packet({ command(2, 0, 35) }), 35)
	match:step(net:consume(35))
	net:receive(1, packet({ command(3, 16, 36) }), 36)
	ball.x, ball.y, ball.vx, ball.vy = 0, 0, 0, 0
	players[1].x, players[1].y = -27, 0
	r = match:step(net:consume(36))
	local found = false
	for _, e in ipairs(r.physicsEvents) do
		if e.kind == "kick" then
			found = true
		end
	end
	assert(found)
end)
test("prediction_speed_does_not_increase_with_render_fps", function()
	local reference
	for _, fps in ipairs({ 30, 60, 240 }) do
		local p = NetPrediction.new()
		p:restore(state(), 1)
		local actor
		for frame = 1, fps / 5 do
			actor = p:advance(math.floor(frame / fps * 60 + 1e-9) + 1, 2)
		end
		local value = json({ actor.x, actor.y, actor.vx, actor.vy, p.world.tick })
		if reference then
			assert(value == reference)
		else
			reference = value
		end
	end
end)
test("identical_pending_retries_use_30hz_but_new_transitions_use_60hz", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	c:sample(1, 0, 0)
	assert(c:packet(0))
	assert(not c:packet(1 / 60))
	assert(c:packet(1 / 30))
	c:sample(16, 3, 3 / 60)
	assert(c:packet(3 / 60), "new kick waited for duplicate retry interval")
	c:sample(0, 4, 4 / 60)
	assert(c:packet(4 / 60), "release waited for duplicate retry interval")
end)
test("retry_throttle_preserves_reliable_recovery_and_epoch_reset", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	c:sample(1, 0, 0)
	assert(c:packet(0))
	assert(c:packet(0.14))
	local b, reliable = c:packet(0.16 + 1e-6)
	assert(b and reliable, "reliable deadline delayed by duplicate throttle")
	c:reset(2, 1, 0)
	c:sample(1, 0, 0.17)
	assert(c:packet(0.17), "new epoch reused duplicate throttle state")
end)
test("ack_window_progress_is_not_throttled_as_duplicate", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	for i = 1, 10 do
		c:sample(i % 2 == 0 and 1 or 0, i, i / 100)
	end
	assert(c:packet(0.1))
	c:confirm(1, 0.11)
	local b = c:packet(0.1 + 1 / 60)
	assert(b)
	local packet = NetCodec.decodeInput(b)
	assert(packet.commands[#packet.commands].seq == 9)
end)
test("client_timestamps_cannot_rewind_or_accelerate_authority", function()
	local early, late = NetInputQueue.new(1, 1), NetInputQueue.new(1, 1)
	local a = NetCodec.encodeInput(
		1,
		1,
		{ { seq = 1, tick = 100, mask = 2 }, { seq = 2, tick = 100, mask = 16 }, { seq = 3, tick = 100, mask = 0 } }
	)
	local b = NetCodec.encodeInput(
		1,
		1,
		{ { seq = 1, tick = 400, mask = 2 }, { seq = 2, tick = 400, mask = 16 }, { seq = 3, tick = 400, mask = 0 } }
	)
	assert(early:receive(a, 300) and late:receive(b, 300))
	for t = 301, 305 do
		local x, y = early:step(t), late:step(t)
		assert(x.x == y.x and x.y == y.y and x.kick == y.kick and early.ack == late.ack)
		assert(early.ack == math.min(t - 300, 3), "more than one transition applied per tick")
	end
end)
emit(json(results))
