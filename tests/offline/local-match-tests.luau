local results = {}
local function test(name, fn)
	local ok, err = pcall(fn)
	table.insert(results, { name, ok, ok and "PASS" or tostring(err) })
end
local function equal(a, b)
	assert(a == b, tostring(a) .. " ~= " .. tostring(b))
end
local function make(options)
	local world = Core.newWorld({ solverMode = "haxballDiscrete", useBounds = false })
	local ball = Core.addDisc(world, {
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
	Stadium.install(Core, world)
	local players, masks = {}, {}
	for slot, spawn in ipairs(Profile.SpawnPoints) do
		local p = Core.addDisc(world, {
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
			kickDamping = 0.96,
			kickStrength = 5,
			kickback = 0,
			collisionGroup = slot <= 5 and 2 or 4,
			collisionMask = 39,
		})
		players[slot] = p
		masks[slot] = 39
	end
	local state = {
		coreWorld = world,
		ball = ball,
		players = players,
		spawnPoints = Profile.SpawnPoints,
		playerCollisionMasks = masks,
		score = { red = 0, blue = 0 },
		tick = 0,
	}
	return LocalMatch.attach(state, options)
end
local function countdown(m)
	while m.match.phase == "kickoff" do
		m:step({})
	end
end
local function takeKickoff(m)
	countdown(m)
	local slot = m.match.kickoffTeam == "red" and 1 or 6
	local p = m.state.players[slot]
	p.x, p.y, p.vx, p.vy = -27, 0, 0, 0
	m.state.ball.x, m.state.ball.y, m.state.ball.vx, m.state.ball.vy = 0, 0, 0, 0
	m:step({})
	local r = m:step({ [slot] = { kick = true } })
	equal(m.match.kickoffTeam, nil)
	return r
end
local function score(m, team)
	assert(m.match.phase == "playing")
	local b = m.state.ball
	b.x, b.y, b.vx, b.vy = team == "red" and 369 or -369, 0, team == "red" and 4 or -4, 0
	return m:step({})
end
local function waitPause(m)
	while m.match.phase == "goalPause" do
		m:step({})
	end
end
local function snapshot(m)
	local row = {
		m.state.tick,
		m.state.score.red,
		m.state.score.blue,
		m.match.phase,
		m.match.remainingTicks,
		m.match.kickoffTeam or "",
		m.round,
		m.elapsedTicks,
	}
	for _, d in ipairs(m.state.coreWorld.discs) do
		table.insert(
			row,
			{ d.x, d.y, d.vx, d.vy, d.collisionMask, d.kickHeld == true, d.kickArmed == true, d.kickCooldown or 0 }
		)
	end
	return json(row)
end

test("initial_kickoff_freezes_every_disc_for_exact_countdown", function()
	local m = make()
	equal(m.match.phase, "kickoff")
	equal(m.match.kickoffTeam, "red")
	local p = m.state.players[1]
	local x, y = p.x, p.y
	p.vx, p.vy = 99, 10
	m.state.ball.vx = 500
	for i = 1, 29 do
		m:step({ [1] = { x = 1, kick = true } })
		equal(m.match.phase, "kickoff")
		equal(p.x, x)
		equal(p.y, y)
		equal(m.state.ball.x, 0)
		equal(p.vx, 0)
	end
	m:step({})
	equal(m.match.phase, "playing")
	equal(m.state.tick, 30)
	equal(m.match.kickoffTeam, "red")
	equal(m.elapsedTicks, 0)
end)
test("red_kickoff_applies_and_clears_all_barrier_masks", function()
	local m = make()
	for _, p in ipairs(m.state.players) do
		equal(p.collisionMask, 47)
	end
	local r = takeKickoff(m)
	local found = false
	for _, e in ipairs(r.ruleEvents) do
		if e.kind == "kickoffTaken" then
			found = true
		end
	end
	assert(found)
	for _, p in ipairs(m.state.players) do
		equal(p.collisionMask, 39)
	end
	equal(m.match.lastTouch.playerId, 1)
end)
test("blue_can_start_and_clear_blue_barriers", function()
	local m = make({ startingTeam = "blue" })
	for _, p in ipairs(m.state.players) do
		equal(p.collisionMask, 55)
	end
	takeKickoff(m)
	equal(m.match.lastTouch.playerId, 6)
end)
test("wrong_team_cannot_kick_during_kickoff", function()
	local m = make()
	countdown(m)
	local p = m.state.players[6]
	p.x, p.y = 27, 0
	local r = m:step({ [6] = { kick = true } })
	equal(r.inputs[6].kick, false)
	equal(m.state.ball.vx, 0)
	equal(m.match.kickoffTeam, "red")
end)
test("physical_touch_can_take_kickoff_without_pressing_X", function()
	local m = make()
	countdown(m)
	local p = m.state.players[1]
	p.x, p.y, p.vx = -26, 0, 2
	m:step({})
	equal(m.match.kickoffTeam, nil)
	equal(m.match.lastTouch.kind, "contact")
end)
test("held_kick_across_countdown_requires_release", function()
	local m = make()
	local p = m.state.players[1]
	for i = 1, 30 do
		m:step({ [1] = { kick = true } })
	end
	p.x, p.y = -27, 0
	for i = 1, 3 do
		local r = m:step({ [1] = { kick = true } })
		equal(r.inputs[1].kick, false)
		equal(m.state.ball.vx, 0)
	end
	m:step({ [1] = { kick = false } })
	m:step({ [1] = { kick = true } })
	assert(m.state.ball.vx > 0)
end)
test("one_goal_one_point_and_immutable_last_touch", function()
	local m = make()
	takeKickoff(m)
	local oldTouch = m.match.lastTouch
	local r = score(m, "red")
	equal(m.state.score.red, 1)
	equal(m.state.score.blue, 0)
	equal(m.match.phase, "goalPause")
	equal(m.match.lastGoal.lastTouch.playerId, 1)
	oldTouch.playerId = 999
	equal(m.match.lastGoal.lastTouch.playerId, 1)
	local goals = 0
	for _, e in ipairs(r.ruleEvents) do
		if e.kind == "goalScored" then
			goals += 1
		end
	end
	equal(goals, 1)
end)
test("pause_has_no_motion_contacts_or_duplicate_goals", function()
	local m = make()
	takeKickoff(m)
	score(m, "red")
	local b = m.state.ball
	local x, y = b.x, b.y
	for i = 1, 89 do
		local r = m:step({ [1] = { x = 1, kick = true } })
		equal(m.match.phase, "goalPause")
		equal(#r.physicsEvents, 0)
		equal(b.x, x)
		equal(b.y, y)
		equal(m.state.score.red, 1)
	end
	local r = m:step({})
	equal(m.match.phase, "kickoff")
	equal(m.match.kickoffTeam, "blue")
	assert(r.roundChanged)
	equal(b.x, 0)
	equal(b.y, 0)
	equal(m.match.lastTouch, nil)
	for slot, p in ipairs(m.state.players) do
		equal(p.x, Profile.SpawnPoints[slot].x)
		equal(p.y, Profile.SpawnPoints[slot].y)
		equal(p.vx, 0)
		equal(p.kickArmed, false)
		equal(p.collisionMask, 55)
	end
end)
test("goal_counter_keeps_working_for_20_complete_rounds", function()
	local m = make({ goalPauseTicks = 3, kickoffTicks = 2 })
	for i = 1, 20 do
		takeKickoff(m)
		local team = i % 2 == 1 and "red" or "blue"
		score(m, team)
		waitPause(m)
		equal(m.match.kickoffTeam, team == "red" and "blue" or "red")
		equal(m.round, i + 1)
	end
	equal(m.state.score.red, 10)
	equal(m.state.score.blue, 10)
end)
test("score_limit_finishes_then_restart_clears_match", function()
	local m = make({ scoreLimit = 2, goalPauseTicks = 2, kickoffTicks = 1 })
	for i = 1, 2 do
		takeKickoff(m)
		score(m, "red")
		waitPause(m)
	end
	equal(m.match.phase, "finished")
	equal(m.match.winner, "red")
	for i = 1, 20 do
		m:step({ [1] = { x = 1, kick = true } })
	end
	equal(m.state.score.red, 2)
	equal(m.state.ball.vx, 0)
	m:restart("blue")
	equal(m.state.score.red, 0)
	equal(m.state.score.blue, 0)
	equal(m.match.lastGoal, nil)
	equal(m.match.winner, nil)
	equal(m.elapsedTicks, 0)
	equal(m.match.kickoffTeam, "blue")
end)
test("own_goal_awards_opposite_goal_owner_and_preserves_touch", function()
	local m = make()
	takeKickoff(m)
	Rules.recordTouch(m.match, 6, "blue", m.state.tick, "kick")
	score(m, "red")
	equal(m.match.lastGoal.team, "red")
	equal(m.match.lastGoal.lastTouch.team, "blue")
end)
test("clock_stops_during_countdown_pause_and_waiting_for_kickoff", function()
	local m = make()
	countdown(m)
	for i = 1, 60 do
		m:step({})
	end
	equal(m.elapsedTicks, 0)
	takeKickoff(m)
	local t = m.elapsedTicks
	m:step({})
	equal(m.elapsedTicks, t + 1)
	score(m, "red")
	t = m.elapsedTicks
	waitPause(m)
	countdown(m)
	equal(m.elapsedTicks, t)
end)
test("goal_line_edges_reverse_and_no_crossing", function()
	local function crossing(x0, y0, x1, y1)
		return Rules.findGoalCrossing({ { discId = "ball", x0 = x0, y0 = y0, x1 = x1, y1 = y1 } }, "ball")
	end
	assert(crossing(369, 63.999, 371, 63.999))
	equal(crossing(369, 64.001, 371, 64.001), nil)
	equal(crossing(371, 0, 369, 0), nil)
	equal(crossing(369, 0, 369.5, 0), nil)
	equal(crossing(-369, 0, -371, 0).team, "blue")
end)
test("invalid_configuration_fails_before_match_runs", function()
	for _, options in ipairs({
		{ goalPauseTicks = -1 },
		{ goalPauseTicks = 0 },
		{ kickoffTicks = 0 },
		{ kickoffTicks = 0 / 0 },
		{ scoreLimit = 1.5 },
		{ startingTeam = "green" },
	}) do
		local ok = pcall(function()
			make(options)
		end)
		assert(not ok)
	end
end)
test("5v5_session_12000_ticks_is_finite_and_deterministic", function()
	local function run()
		local m = make({ goalPauseTicks = 3, kickoffTicks = 2 })
		local goals = 0
		local trace = {}
		for t = 1, 12000 do
			if t % 500 == 0 and m.match.phase == "playing" then
				local b = m.state.ball
				b.x, b.y, b.vx, b.vy = t % 1000 == 0 and 369 or -369, 0, t % 1000 == 0 and 4 or -4, 0
			end
			local inputs = {}
			for slot = 1, 10 do
				inputs[slot] = {
					x = ((math.floor(t / 31) + slot) % 3) - 1,
					y = ((math.floor(t / 47) + slot * 2) % 3) - 1,
					kick = t % 19 < 4,
				}
			end
			local r = m:step(inputs)
			for _, e in ipairs(r.ruleEvents) do
				if e.kind == "goalScored" then
					goals += 1
				end
			end
			table.insert(trace, snapshot(m))
			local eventRows = {}
			for _, e in ipairs(r.physicsEvents) do
				table.insert(eventRows, {
					e.kind,
					e.tick,
					tostring(e.discA or e.discId or e.playerId or ""),
					tostring(e.discB or e.targetId or e.geometryId or ""),
				})
			end
			for _, e in ipairs(r.ruleEvents) do
				table.insert(eventRows, { e.kind, e.tick, e.team or e.teamToKick or "" })
			end
			table.insert(trace, json(eventRows))
			for _, d in ipairs(m.state.coreWorld.discs) do
				assert(
					d.x == d.x
						and math.abs(d.x) < 1e6
						and d.y == d.y
						and math.abs(d.y) < 1e6
						and d.vx == d.vx
						and math.abs(d.vx) < 1e6
						and d.vy == d.vy
						and math.abs(d.vy) < 1e6
				)
			end
		end
		equal(goals, m.state.score.red + m.state.score.blue)
		assert(goals >= 20)
		equal(m.state.tick, 12000)
		return table.concat(trace, "\n")
	end
	equal(run(), run())
end)
test("kickoff_arcs_block_opponent_and_allow_team_approach", function()
	for _, team in ipairs({ "red", "blue" }) do
		local m = make({ startingTeam = team })
		countdown(m)
		local own = team == "red" and m.state.players[1] or m.state.players[6]
		local other = team == "red" and m.state.players[6] or m.state.players[1]
		local sign = team == "red" and 1 or -1
		other.x, other.y, other.vx, other.vy = 90 * sign, 0, -2 * sign, 0
		own.x, own.y, own.vx, own.vy = -90 * sign, 0, 2 * sign, 0
		m:step({})
		assert(other.x * sign >= 90 - 1e-9, "opponent crossed kickoff circle: " .. team .. " x=" .. tostring(other.x))
		assert(own.x * sign > -90, "own player could not approach ball")
	end
end)
test("simultaneous_kicks_last_touch_follows_physical_event_order", function()
	local m = make({ startWithKickoff = false })
	local a, b = m.state.players[1], m.state.players[6]
	a.x, a.y = -27, 0
	b.x, b.y = 27, 0
	local r = m:step({ [1] = { kick = true }, [6] = { kick = true } })
	local last
	for _, e in ipairs(r.physicsEvents) do
		if e.kind == "kick" then
			last = e.playerId
		elseif e.kind == "discContact" then
			if e.discA == "ball" then
				last = e.discB
			elseif e.discB == "ball" then
				last = e.discA
			end
		end
	end
	assert(last)
	equal(m.match.lastTouch.playerId, last)
end)
test("visual_curves_follow_physical_arc_and_join_exact_endpoints", function()
	for _, segment in ipairs(ClassicReference230.segments) do
		local points = StadiumRender2D.segmentPoints(segment)
		equal(points[1].x, segment.x1)
		equal(points[1].y, segment.y1)
		equal(points[#points].x, segment.x2)
		equal(points[#points].y, segment.y2)
		if segment.curveF then
			for i, p in ipairs(points) do
				local radius = math.sqrt((p.x - segment.centerX) ^ 2 + (p.y - segment.centerY) ^ 2)
				assert(math.abs(radius - segment.arcRadius) < 1e-9)
				if i > 1 then
					local prev = points[i - 1]
					local chord = math.sqrt((p.x - prev.x) ^ 2 + (p.y - prev.y) ^ 2)
					assert(chord <= segment.arcRadius * math.pi / 48 + 1e-8, "arc has discontinuity")
				end
			end
		end
	end
end)
test("visual_coordinate_mapping_matches_logical_scale_and_y_direction", function()
	local p = StadiumRender2D.toWorld(370, 64, Profile.Presentation)
	equal(p.x, 185)
	equal(p.y, 11)
	equal(p.z, -32)
	local origin = StadiumRender2D.toWorld(0, 0, Profile.Presentation)
	equal(origin.x, 0)
	equal(origin.z, 0)
end)
test("camera_fits_physical_bounds_in_wide_square_and_tall_viewports", function()
	for _, viewport in ipairs({ { 1920, 1080 }, { 1024, 768 }, { 900, 900 }, { 600, 1000 } }) do
		local y = StadiumRender2D.cameraHeight(Profile.Presentation, Profile.Bounds, 35, viewport[1], viewport[2])
		local vertical = (y - Profile.Presentation.floorY) * math.tan(math.rad(35) * 0.5)
		local horizontal = vertical * viewport[1] / viewport[2]
		assert(vertical >= 110 - 1e-9 and horizontal >= 220 - 1e-9)
	end
end)
emit(json(results))
