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
	assert(#inputCalls - before <= 12, "keepalive/retransmission rate exceeded budget")
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
		if s.matchPhase == "playing" then
			assert(
				math.abs(field.children.BallDisc.Position.X - s.ball.x * 0.5) <= math.max(2, s.ball.speed * 2),
				"visual forecast exceeded bounded horizon"
			)
		else
			near(field.children.BallDisc.Position.X, s.ball.x * 0.5)
		end
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
check("real_client_interpolates_remote_player_using_buffer", function()
	local template = table.clone(snapshots.latest)
	template.matchPhase = "playing"
	template.kickoffTeam = nil
	for i = 0, 2 do
		local s = table.clone(template)
		s.tick = 100 + i * 2
		s.players = table.clone(template.players)
		s.players[2] = table.clone(template.players[2])
		s.players[2].x = i * 20
		snapshotSignal.fn(s)
		frameOnly(1 / 30)
	end
	local x = field.children.PlayerDisc2.Position.X
	assert(x > 10 and x <= 20, "remote player did not use buffered authority: " .. x)
end)
check("real_client_exposes_local_network_measurements", function()
	local r = guiRoot.children.HaxballLabDebug.children.NetworkDiagnostics.OnInvoke()
	assert(r.capacity == 256 and r.samples.ackMs.count > 0)
	assert(r.counters.inputPackets > 0 and r.counters.inputBytes >= r.counters.inputPackets * 21)
	assert(r.counters.stateBytes == r.counters.statePackets * 482)
	assert(r.presentation.frames <= 32 and r.presentation.delayMs <= 100)
end)
check("duplicate_reliable_snapshot_does_not_refresh_state_age", function()
	frameOnly(0.1)
	local get = guiRoot.children.HaxballLabDebug.children.NetworkDiagnostics.OnInvoke
	local before = get().presentation.ageMs
	local duplicate = table.clone(snapshots.latest)
	duplicate.tick = 104
	duplicate.matchPhase = "playing"
	snapshotSignal.fn(duplicate)
	frameOnly(1 / 60)
	assert(get().presentation.ageMs >= before + 15)
end)
check("camera_refits_after_viewport_resize", function()
	camera.ViewportSize = vector(600, 1000, nil, "Vector2")
	frameOnly(1 / 60)
	local expected = StadiumRender2D.cameraHeight(Profile.Presentation, Profile.Bounds, 35, 600, 1000)
	near(camera.CFrame.Position.Y, expected)
end)
check("old_state_packet_cannot_rewind_the_actual_client", function()
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	local current = snapshots.latest
	local old = table.clone(current)
	old.tick = 0
	old.ball = table.clone(current.ball)
	old.ball.x = 100
	stateSignal.fn(NetCodec.encodeState(old))
	frameOnly(1 / 60)
	near(field.children.BallDisc.Position.X, 0)
end)
check("state_from_unknown_round_waits_for_reliable_bootstrap", function()
	local current = snapshots.latest
	local future = table.clone(current)
	future.round += 1
	future.ball = table.clone(current.ball)
	future.ball.x = 100
	stateSignal.fn(NetCodec.encodeState(future))
	frameOnly(1 / 60)
	near(field.children.BallDisc.Position.X, 0)
end)
check("duplicate_tick_state_cannot_replace_the_accepted_state", function()
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	local duplicate = table.clone(snapshots.latest)
	duplicate.ball = table.clone(duplicate.ball)
	duplicate.ball.x = 100
	stateSignal.fn(NetCodec.encodeState(duplicate))
	frameOnly(1 / 60)
	near(field.children.BallDisc.Position.X, 0)
end)
check("round_reset_counts_cancelled_unconfirmed_commands", function()
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	button("InputDelay500").Activated.fn()
	moveState = vector(-1, 0, nil, "Vector2")
	frameOnly(1 / 60)
	local get = guiRoot.children.HaxballLabDebug.children.NetworkDiagnostics.OnInvoke
	local before = get().counters.cancelledInputs or 0
	assert(get().pendingInputs > 0, "test did not create unconfirmed input")
	button("ResetScenario").Activated.fn()
	advance(1 / 60)
	assert((get().counters.cancelledInputs or 0) > before, "reset did not classify cancelled inputs")
	button("InputDelay0").Activated.fn()
end)
check("stalled_stream_holds_last_bounded_forecast_without_rewinding", function()
	button("ResetScenario").Activated.fn()
	moveState = vector(1, 0, nil, "Vector2")
	for i = 1, 60 do
		advance(1 / 60)
	end
	frameOnly(0.25)
	frameOnly(1 / 60)
	frameOnly(1 / 60)
	local held = field.children.PlayerDisc.Position.X
	frameOnly(0.1)
	near(field.children.PlayerDisc.Position.X, held)
	local r = guiRoot.children.HaxballLabDebug.children.NetworkDiagnostics.OnInvoke()
	assert(r.predictedTick <= r.authority.tick + 18, "forecast escaped confirmed horizon")
end)
emit(json(result))
