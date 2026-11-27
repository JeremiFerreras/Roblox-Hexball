local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(ReplicatedStorage:WaitForChild("SimpleSoccerGame"):WaitForChild("StadiumReference2D"))
local Rules = {}

Rules.GoalLines = {
	{ side = "left", x = Profile.Goals.leftX, team = Profile.Goals.scoringTeams.left },
	{ side = "right", x = Profile.Goals.rightX, team = Profile.Goals.scoringTeams.right },
}
Rules.GoalHalfHeight = Profile.Goals.halfHeight
Rules.GoalPauseTicks = 90
Rules.KickoffTicks = 30

function Rules.newMatch()
	return { phase = "playing", remainingTicks = 0, lastGoal = nil, kickoffTeam = nil }
end

function Rules.findGoalCrossing(motionSegments, ballId)
	if type(motionSegments) ~= "table" then
		return nil
	end
	ballId = ballId or "ball"
	for _, path in ipairs(motionSegments) do
		if path.discId == ballId then
			for _, goal in ipairs(Rules.GoalLines) do
				local crossed = goal.side == "right" and path.x0 < goal.x and path.x1 >= goal.x
					or goal.side == "left" and path.x0 > goal.x and path.x1 <= goal.x
				if crossed then
					local dx = path.x1 - path.x0
					if math.abs(dx) > 1e-12 then
						local alpha = (goal.x - path.x0) / dx
						local y = path.y0 + (path.y1 - path.y0) * alpha
						if math.abs(y) <= Rules.GoalHalfHeight then
							return {
								side = goal.side,
								team = goal.team,
								x = goal.x,
								y = y,
								substep = path.substep,
								substeps = path.substeps,
								fraction = alpha,
							}
						end
					end
				end
			end
		end
	end
	return nil
end

function Rules.beginGoalPause(match, score, goal, ball, players, pauseTicks)
	assert(match.phase == "playing", "goal can only be recorded while playing")
	assert(goal and (goal.team == "red" or goal.team == "blue"), "goal team is invalid")
	score[goal.team] += 1
	match.phase = "goalPause"
	match.remainingTicks = pauseTicks or Rules.GoalPauseTicks
	match.lastGoal = { team = goal.team, side = goal.side, x = goal.x, y = goal.y, tick = goal.tick }
	ball.vx, ball.vy = 0, 0
	for _, player in ipairs(players) do
		player.vx, player.vy = 0, 0
		player.kickHeld = false
		player.kickArmed = false
		player.kickCooldown = 0
	end
	return match.lastGoal
end

function Rules.advancePause(match)
	if match.phase ~= "goalPause" then
		return false
	end
	match.remainingTicks = math.max(0, match.remainingTicks - 1)
	return match.remainingTicks == 0
end

function Rules.resetKickoff(ball, players, spawnPoints)
	ball.x, ball.y, ball.vx, ball.vy = 0, 0, 0, 0
	for index, player in ipairs(players) do
		local spawn = spawnPoints[index]
		assert(spawn and type(spawn.x) == "number" and type(spawn.y) == "number", "spawn point is missing")
		player.x, player.y, player.vx, player.vy = spawn.x, spawn.y, 0, 0
		player.kickHeld, player.kickArmed, player.kickCooldown = false, false, 0
	end
end

function Rules.beginKickoff(match, team, ticks)
	assert(match.phase == "goalPause", "kickoff can only follow a goal pause")
	assert(team == "red" or team == "blue", "kickoff team is invalid")
	match.phase, match.remainingTicks, match.kickoffTeam = "kickoff", ticks or Rules.KickoffTicks, team
end

function Rules.advanceKickoff(match)
	if match.phase ~= "kickoff" then
		return false
	end
	match.remainingTicks = math.max(0, match.remainingTicks - 1)
	return match.remainingTicks == 0
end

function Rules.resume(match)
	match.phase, match.remainingTicks = "playing", 0
end

function Rules.recordTouch(match, playerId, team, tick, kind)
	if type(playerId) ~= "number" or (team ~= "red" and team ~= "blue") then
		return false
	end
	match.lastTouch = { playerId = playerId, team = team, tick = tick, kind = kind }
	return true
end

function Rules.kickoffCollisionMask(match, playerTeam, defaultMask, ballGroup)
	local mask = defaultMask
	if match.kickoffTeam then
		local kickoffFlag = match.kickoffTeam == "red" and Profile.CollisionGroups.redKO
			or Profile.CollisionGroups.blueKO
		-- The designated kickoff side receives its group flag; the ball remains enabled.
		mask = bit32.bor(mask, kickoffFlag)
	end
	return mask
end

function Rules.filterKickoffInput(match, playerTeam, input)
	if match.kickoffTeam and playerTeam ~= match.kickoffTeam and input.kick then
		return { x = input.x, y = input.y, kick = false }, true
	end
	return input, false
end

function Rules.completeKickoff(match, playerTeam)
	if match.phase ~= "playing" or not match.kickoffTeam or playerTeam ~= match.kickoffTeam then
		return false
	end
	match.kickoffTeam = nil
	return true
end

return Rules
