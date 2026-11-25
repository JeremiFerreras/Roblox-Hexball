local result = {}
for _, case in ipairs(cases) do
	local modes = {}
	for _, mode in ipairs({ "haxballDiscrete" }) do
		local w = Core.newWorld({ useBounds = false, solverMode = mode })
		if case.classic and mode == "haxballDiscrete" then
			Core.addDisc(w, case.initial[1])
			Stadium.install(Core, w)
			for index = 6, #case.initial do
				Core.addDisc(w, case.initial[index])
			end
		else
			for _, d in ipairs(case.initial) do
				Core.addDisc(w, d)
			end
		end
		for _, p in ipairs(case.planes) do
			Core.addPlane(w, p)
		end
		if mode == "haxballDiscrete" and not case.classic then
			Core.setReferenceGeometry(w, case.geometry)
		end
		local frames = {}
		local goals = {}
		local kickEvents = {}
		local goalEvents = {}
		local kicks = 0
		for _, step in ipairs(case.steps) do
			local inputs = {}
			for playerId, discId in pairs(case.playerIds) do
				inputs[discId] = step[playerId] or step[tostring(playerId)] or {}
			end
			local _, events = Core.stepWorld(w, inputs)
			local goal = Rules.findGoalCrossing(w.motionSegments, 1)
			table.insert(goals, goal and 1 or 0)
			if goal then
				table.insert(goalEvents, { w.tick, goal.team == "red" and 1 or 2 })
			end
			for _, e in ipairs(events) do
				if e.kind == "kick" then
					kicks += 1
					for playerId, discId in pairs(case.playerIds) do
						if discId == e.playerId then
							table.insert(kickEvents, { w.tick, tonumber(playerId) })
						end
					end
				end
			end
			local row = {}
			for _, d in ipairs(w.discs) do
				table.insert(row, { d.x, d.y, d.vx, d.vy })
			end
			table.insert(frames, row)
		end
		table.insert(modes, { frames, kicks, goals, kickEvents, goalEvents })
	end
	table.insert(result, modes)
end
emit(json(result))
