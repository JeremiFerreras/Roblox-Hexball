local result = {}
local function check(name, fn)
	local ok, err = pcall(fn)
	table.insert(result, { name, ok, ok and "PASS" or tostring(err) })
end
local function near(a, b)
	assert(math.abs(a - b) < 1e-8, tostring(a) .. " ~= " .. tostring(b))
end
check("real_client_initializes_camera_geometry_and_controls", function()
	assert(render.fn and snapshotSignal.fn)
	assert(camera.CameraType == "Scriptable")
	local outline = field.children.ClassicPhysicalOutline
	assert(outline)
	local n = 0
	for _, part in pairs(outline.children) do
		n += 1
		assert(part.Anchored and part.CanCollide == false and part.CanQuery == false and part.CanTouch == false)
	end
	assert(n > 100)
	assert(button("ResetScenario").Activated.fn)
end)
check("actual_server_snapshots_drive_all_ten_visual_discs", function()
	advance(1 / 60)
	local s = snapshots.latest
	for i = 1, 10 do
		local name = i == 1 and "PlayerDisc" or "PlayerDisc" .. i
		local v = field.children[name]
		local p = s.players[i]
		near(v.Position.X, p.x * 0.5)
		near(v.Position.Z, -p.y * 0.5)
		near(v.Size.X, 1)
		near(v.Size.Y, 2 * p.radius * 0.5)
		near(v.Size.Z, 2 * p.radius * 0.5)
		near(v.CFrame.rotation[3], math.pi / 2)
		assert(v.Shape == "Cylinder" and v.Transparency == 0)
	end
	near(field.children.BallDisc.Size.Y, 10)
end)
check("held_movement_passes_from_real_client_to_real_server", function()
	moveState = vector(1, 0, nil, "Vector2")
	frameOnly(1 / 60)
	local before = #inputCalls
	for i = 1, 30 do
		advance(1 / 60)
	end
	assert(snapshots.latest.player.x > -80)
	assert(#inputCalls == before, "unchanged input flooded server")
end)
check("reset_button_starts_new_match_and_resends_held_input", function()
	local before = #inputCalls
	local id = snapshots.latest.matchId
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	assert(snapshots.latest.matchId > id and snapshots.latest.matchPhase == "kickoff")
	assert(#inputCalls == before + 1)
	near(field.children.BallDisc.Position.X, 0)
	near(field.children.PlayerDisc.Position.X, -40)
end)
check("ball_rendering_and_reposition_are_driven_by_completed_match", function()
	moveState = Vector2.zero
	button("GoalTest").Activated.fn()
	local goal, reset = false, false
	for i = 1, 240 do
		advance(1 / 60)
		local s = snapshots.latest
		near(field.children.BallDisc.Position.X, s.ball.x * 0.5)
		near(field.children.BallDisc.Position.Z, -s.ball.y * 0.5)
		if s.matchPhase == "goalPause" then
			goal = true
			assert(s.score.red == 1)
		end
		if goal and s.round == 2 then
			reset = true
			near(field.children.BallDisc.Position.X, 0)
			break
		end
	end
	assert(goal and reset)
end)
check("delayed_old_round_input_is_discarded_on_reset", function()
	button("InputDelay500").Activated.fn()
	moveState = vector(-1, 0, nil, "Vector2")
	kickState = true
	frameOnly(1 / 60)
	local before = #inputCalls
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	moveState = Vector2.zero
	kickState = false
	frameOnly(1 / 60)
	-- If the previous queue survived, both the old and new-round X packets would arrive.
	for i = 1, 35 do
		advance(1 / 60)
	end
	local kicks = 0
	for i = before + 1, #inputCalls do
		if inputCalls[i][3] then
			kicks += 1
		end
	end
	assert(kicks == 1, "old-round delayed kick leaked across reset")
	assert(snapshots.latest.score.red == 0 and snapshots.latest.score.blue == 0)
	button("InputDelay0").Activated.fn()
end)
check("legacy_pair_mode_hides_ball_and_physical_outline", function()
	button("PairHeadOn").Activated.fn()
	advance(1 / 60)
	assert(field.children.BallDisc.Transparency == 1)
	for _, part in pairs(field.children.ClassicPhysicalOutline.children) do
		assert(part.Transparency == 1)
	end
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	assert(field.children.BallDisc.Transparency == 0)
end)
check("match_identifier_detects_reset_at_same_tick_and_round", function()
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	local previous = snapshots.latest
	moveState = vector(1, 0, nil, "Vector2")
	frameOnly(1 / 60)
	local count = #inputCalls
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	assert(snapshots.latest.tick == previous.tick and snapshots.latest.round == previous.round)
	assert(snapshots.latest.matchId ~= previous.matchId and #inputCalls == count + 1)
end)
check("real_client_interpolates_ball_between_snapshots", function()
	local a = table.clone(snapshots.latest)
	a.tick = 100
	a.ball = table.clone(a.ball)
	a.ball.x = 10
	local b = table.clone(a)
	b.tick = 101
	b.ball = table.clone(a.ball)
	b.ball.x = 20
	snapshotSignal.fn(a)
	snapshotSignal.fn(b)
	frameOnly(1 / 120)
	near(field.children.BallDisc.Position.X, 7.5)
end)
check("camera_refits_after_viewport_resize", function()
	camera.ViewportSize = vector(600, 1000, nil, "Vector2")
	frameOnly(1 / 60)
	local expected = StadiumRender2D.cameraHeight(Profile.Presentation, Profile.Bounds, 35, 600, 1000)
	near(camera.CFrame.Position.Y, expected)
end)
emit(json(result))
