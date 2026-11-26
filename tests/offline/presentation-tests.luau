local results = {}
local function test(name, fn)
	local ok, err = pcall(fn)
	table.insert(results, { name, ok, ok and "PASS" or tostring(err) })
end
local function near(a, b)
	assert(math.abs(a - b) < 1e-7, tostring(a) .. " ~= " .. tostring(b))
end
local function state(tick, phase, matchId, round)
	local p = { x = tick * 2, y = -tick }
	return {
		tick = tick, matchId = matchId or 1, round = round or 1,
		matchPhase = phase or "playing", coreMode = true,
		ball = p, player = p, player2 = p, players = { p, p },
	}
end

test("no_pose_before_bootstrap", function()
	assert(SnapshotBuffer.new():sample(0) == nil)
end)
test("linear_remote_pose_is_exact_at_30hz", function()
	local b = SnapshotBuffer.new()
	b:push(state(0), 0)
	b:sample(0)
	for tick = 2, 60, 2 do
		b:push(state(tick), tick / 60)
		local p, status = b:sample(tick / 60)
		near(p.players[2].x, 2 * (tick - 2))
		near(status.delayMs, 1000 / 30)
		p, status = b:sample((tick + 1) / 60)
		near(p.players[2].x, 2 * (tick - 1))
		near(status.renderLagMs, 1000 / 30)
	end
end)
test("copies_input_poses_and_bounds_history", function()
	local b = SnapshotBuffer.new()
	local s = state(0)
	b:push(s, 0)
	s.ball.x = 999
	near(b:sample(0).ball.x, 0)
	for tick = 2, 200, 2 do
		b:push(state(tick), tick / 60)
		b:sample(tick / 60)
	end
	assert(#b.frames == 32)
end)
test("rejects_reordered_ticks_duplicate_ticks_and_old_epochs", function()
	local b = SnapshotBuffer.new()
	b:push(state(10), 0)
	assert(not b:push(state(10), 1))
	assert(not b:push(state(9), 1))
	b:push(state(0, "kickoff", 2), 2)
	assert(not b:push(state(100, "playing", 1), 3))
	b:push(state(0, "kickoff", 2, 2), 4)
	assert(not b:push(state(100, "playing", 2, 1), 5))
	near(b.arrivedAt, 4)
end)
test("blackout_freezes_without_extrapolation", function()
	local b = SnapshotBuffer.new()
	b:push(state(0), 0)
	b:sample(0)
	b:push(state(2), 1 / 30)
	for tick = 2, 120 do
		local p = b:sample(tick / 60)
		assert(p.ball.x >= 0 and p.ball.x <= 4)
	end
	near(b:sample(2).ball.x, 4)
	assert(b.underflows == 1 and b.status.ageMs > 1900)
	assert(b.status.renderLagMs > 1900)
end)
test("goal_pause_round_and_match_do_not_crossfade", function()
	local b = SnapshotBuffer.new()
	b:push(state(10), 0)
	b:sample(0)
	b:push(state(12, "goalPause"), 0.1)
	near(b:sample(0.1).ball.x, 24)
	near(b:sample(0.5).ball.x, 24)
	b:push(state(0, "kickoff", 2), 0.6)
	near(b:sample(0.6).ball.x, 0)
	assert(#b.frames == 1)
	b:push(state(1, "playing", 2), 0.7)
	near(b:sample(0.7).ball.x, 2)
	b:push(state(0, "kickoff", 2, 2), 0.8)
	near(b:sample(0.8).ball.x, 0)
end)
test("large_recovery_rebuffers_instead_of_long_catchup", function()
	local b = SnapshotBuffer.new()
	b:push(state(0), 0)
	b:sample(0)
	b:push(state(2), 1 / 30)
	b:sample(0.1)
	b:sample(2)
	b:push(state(120), 2)
	local _, status = b:sample(2)
	assert(status.rebuffers == 1 and status.renderLagMs <= 100 + 1e-7)
end)
test("stalled_server_gets_fresh_clock_anchor", function()
	local b = SnapshotBuffer.new()
	b:push(state(0), 0)
	b:sample(0)
	b:push(state(2), 1 / 30)
	b:sample(0.1)
	b:sample(2)
	b:push(state(4), 2.1)
	local _, status = b:sample(2.1)
	near(b.offset, 4 - 2.1 * 60)
	assert(status.renderLagMs <= 100 + 1e-7)
end)
test("empty_metrics_are_not_reported_as_zero", function()
	local m = NetMetrics.new()
	local report = m:report()
	assert(report.samples.ackMs.count == 0 and report.samples.ackMs.p95 == nil)
end)
test("invalid_samples_are_rejected", function()
	local m = NetMetrics.new()
	for _, value in ipairs({ -1, 0 / 0, math.huge, "x" }) do
		assert(not m:add("ackMs", value))
	end
	assert(not m:add("unknown", 2))
	assert(m:add("ackMs", 0))
end)
test("nearest_rank_percentiles_use_bounded_window", function()
	local m = NetMetrics.new()
	for i = 1, 1000 do
		m:add("ackMs", i)
	end
	local r = m:report().samples.ackMs
	assert(r.count == 256 and r.total == 1000)
	assert(r.p50 == 872 and r.p95 == 988 and r.max == 1000)
end)
test("reports_are_detached_from_mutable_storage", function()
	local m = NetMetrics.new()
	m:add("ackMs", 10)
	m:count("inputBytes", 482)
	local r = m:report()
	r.counters.inputBytes = 0
	r.samples.ackMs.p95 = 0
	assert(m:report().counters.inputBytes == 482)
	assert(m:report().samples.ackMs.p95 == 10)
end)

for _, fps in ipairs({ 30, 60, 240 }) do
	for _, loss in ipairs({ 0, 5, 15 }) do
		test("seed_1731_" .. fps .. "fps_" .. loss .. "pct_loss", function()
			local seed = 1731
			local function random()
				seed = seed * 48271 % 2147483647
				return seed / 2147483647
			end
			local queue = {}
			for tick = 0, 1800, 2 do
				local lost = random() * 100 < loss
				local due = tick / 60 + 0.05 + random() * 0.07
				if not lost then
					table.insert(queue, { tick = tick, due = due })
				end
			end
			table.sort(queue, function(a, b)
				return a.due < b.due
			end)
			local b = SnapshotBuffer.new()
			local index, previousCursor = 1, nil
			local oldPrevious, oldLatest, oldAt, oldX, lastX
			local speedError, oldError, steps = 0, 0, 0
			for f = 0, math.floor(30.2 * fps) do
				local now = f / fps
				while queue[index] and queue[index].due <= now do
					local item = queue[index]
					index += 1
					if oldLatest == nil or item.tick > oldLatest then
						oldPrevious, oldLatest, oldAt = oldLatest or item.tick, item.tick, now
						b:push(state(item.tick), now)
					end
				end
				local p, status = b:sample(now)
				if p then
					assert(status.tick <= b.latest.tick + 1e-6)
					assert(not previousCursor or status.tick >= previousCursor)
					assert(status.frames <= 32)
					assert(status.delayMs >= 1000 / 30 - 1e-6 and status.delayMs <= 100 + 1e-6)
					near(p.ball.x, status.tick * 2)
					local interval = math.max(1 / 30, (oldLatest - oldPrevious) / 60)
					local x = 2 * (oldPrevious + (oldLatest - oldPrevious)
						* math.clamp((now - oldAt) / interval, 0, 1))
					if now > 2 and now < 29 and lastX then
						speedError += math.abs((p.ball.x - lastX) * fps - 120)
						oldError += math.abs((x - oldX) * fps - 120)
						steps += 1
					end
					lastX, oldX, previousCursor = p.ball.x, x, status.tick
				end
			end
			assert(steps > 0 and speedError / steps < oldError / steps)
			if loss == 0 then
				assert(b.rebuffers == 0)
			end
		end)
	end
end

test("ack_uses_creation_time_and_deduplicates_confirmations", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	assert(c:sample(1, 0, 1).seq == 1)
	c:sample(0, 1, 1.01)
	local ok, confirmed = c:confirm(2, 1.1)
	assert(ok and #confirmed == 2)
	near(confirmed[1].ms, 100)
	near(confirmed[2].ms, 90)
	local _, again = c:confirm(2, 1.2)
	assert(#again == 0 and not c:confirm(1, 1.3))
end)
test("ack_rebase_preserves_confirmed_pending_timing", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	c:sample(1, 0, 0)
	local ok, confirmed = c:confirm(5, 0.2)
	assert(ok and #confirmed == 1 and c.seq == 5 and #c.pending == 0)
	near(confirmed[1].ms, 200)
end)
test("ack_without_valid_time_never_invents_latency", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	c:sample(1, 0, 1)
	local ok, confirmed = c:confirm(1)
	assert(ok and #confirmed == 0 and #c.pending == 0)
end)
test("reset_discards_pending_measurements_of_old_epoch", function()
	local c = NetInputClient.new()
	c:reset(1, 1, 0)
	c:sample(1, 0, 0)
	c:reset(2, 1, 0)
	local _, confirmed = c:confirm(0, 1)
	assert(#confirmed == 0 and #c.pending == 0)
end)
local function predictionState()
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

test("corrections_need_same_tick_forecast_and_count_once", function()
	local s = predictionState()
	local p = NetPrediction.new()
	p:restore(s, 1)
	assert(not p.correctionSample)
	p:advance(2, 1)
	s.tick = 1
	p:restore(s, 1)
	assert(p.correctionSample and p.correction > 0)
	near(p.ballCorrection, 0)
	p:restore(s, 1)
	assert(not p.correctionSample)
	s.round = 2
	s.tick = 0
	p:restore(s, 1)
	assert(not p.correctionSample)
end)

emit(json(results))
