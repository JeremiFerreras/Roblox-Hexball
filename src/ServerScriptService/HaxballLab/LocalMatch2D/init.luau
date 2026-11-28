-- Local match orchestration. No Roblox services, scheduler, rendering or transport.
local Core = require(script.Parent:WaitForChild("PhysicsCore2D"))
local Rules = require(script.Parent:WaitForChild("MatchRules2D"))
local KickoffTimer = require(script.Parent:WaitForChild("KickoffPossessionTimer"))
local Match = {}
Match.__index = Match

local function duration(value, fallback)
	value = value == nil and fallback or value
	assert(
		type(value) == "number" and value == value and value >= 0 and value < 1e9 and value % 1 == 0,
		"duration/limit must be a nonnegative integer"
	)
	return value
end
local function stop(state)
	state.ball.vx, state.ball.vy = 0, 0
	state.ball.kickHeld, state.ball.kickArmed, state.ball.kickCooldown = false, false, 0
	for _, p in ipairs(state.players) do
		p.vx, p.vy = 0, 0
		p.kickHeld, p.kickArmed, p.kickCooldown = false, false, 0
	end
end
local function copyTouch(touch)
	return touch and table.clone(touch) or nil
end
function Match.attach(state, options)
	options = options or {}
	assert(
		state.coreWorld and state.players and state.spawnPoints and state.playerCollisionMasks,
		"complete local state required"
	)
	local self = setmetatable(
		{ state = state, match = Rules.newMatch(), needsKickRelease = {}, round = 0, elapsedTicks = 0 },
		Match
	)
	self.goalPauseTicks = duration(options.goalPauseTicks, Rules.GoalPauseTicks)
	self.kickoffTicks = duration(options.kickoffTicks, Rules.KickoffTicks)
	self.kickoffWaitTicks = duration(options.kickoffWaitTicks, Rules.KickoffPossessionTimeoutTicks)
	self.scoreLimit = duration(options.scoreLimit, 0)
	assert(self.goalPauseTicks > 0 and self.kickoffTicks > 0 and self.kickoffWaitTicks > 0,
		"pause, kickoff and kickoff possession durations must be at least one tick")
	self.startingTeam = options.startingTeam or "red"
	assert(self.startingTeam == "red" or self.startingTeam == "blue", "starting team must be red or blue")
	if options.startWithKickoff ~= false then
		self:restart(self.startingTeam)
	else
		self.round = 1
	end
	return self
end
function Match:_masks()
	for slot, p in ipairs(self.state.players) do
		p.collisionMask = Rules.kickoffCollisionMask(
			self.match,
			p.team,
			self.state.playerCollisionMasks[slot],
			self.state.ball.collisionGroup
		)
	end
end
function Match:_resetRound(team)
	local s, m = self.state, self.match
	Rules.resetKickoff(s.ball, s.players, s.spawnPoints)
	stop(s)
	self.round += 1
	m.lastTouch = nil
	m.phase, m.remainingTicks = "kickoff", self.kickoffTicks
	KickoffTimer.Start(m, team)
	-- A kick held across a reset must be released; movement remains an input state.
	for slot in ipairs(s.players) do
		self.needsKickRelease[slot] = true
	end
	s.coreWorld.events = {}
	s.coreWorld.motionSegments = {}
	self:_masks()
end
function Match:restart(team)
	team = team or self.startingTeam
	assert(team == "red" or team == "blue", "invalid starting team")
	self.state.score.red, self.state.score.blue = 0, 0
	self.elapsedTicks = 0
	self.match.lastGoal = nil
	self.match.winner = nil
	self:_resetRound(team)
end
function Match:step(rawInputs)
	rawInputs = rawInputs or {}
	local s, m = self.state, self.match
	local phase = m.phase
	local locked = phase ~= "playing"
	local inputs = {}
	for slot, p in ipairs(s.players) do
		local raw = rawInputs[slot] or {}
		local kick = raw.kick == true
		if locked and kick then
			self.needsKickRelease[slot] = true
		end
		-- A new slot may press X first. A timed-out slot must release a held kick.
		if raw.stale and not raw.awaitingFirstInput then
			self.needsKickRelease[slot] = true
		end
		if not kick and not raw.stale then
			self.needsKickRelease[slot] = false
		end
		local input = { x = raw.x or 0, y = raw.y or 0, kick = kick and not self.needsKickRelease[slot] }
		if locked then
			input = { x = 0, y = 0, kick = false }
		else
			input = Rules.filterKickoffInput(m, p.team, input)
		end
		inputs[p.id] = input
	end
	self:_masks()
	local result =
		{ physicsEvents = {}, ruleEvents = {}, inputs = inputs, locked = locked, substeps = 0, roundChanged = false }
	local function event(kind, data)
		data = data or {}
		data.kind = kind
		data.tick = s.coreWorld.tick
		table.insert(result.ruleEvents, data)
	end
	if locked then
		-- A pause must freeze positions as well as inputs: no collision corrections.
		stop(s)
		s.coreWorld.tick += 1
		s.coreWorld.events = {}
		s.coreWorld.motionSegments = {}
		s.coreWorld.lastSubsteps = 0
		if phase == "goalPause" and Rules.advancePause(m) then
			if self.scoreLimit > 0 and (s.score.red >= self.scoreLimit or s.score.blue >= self.scoreLimit) then
				m.phase, m.remainingTicks, m.kickoffTeam = "finished", 0, nil
				m.winner = s.score.red > s.score.blue and "red" or "blue"
				m.lastTouch = nil
				event("matchFinished", { winner = m.winner })
			else
				local team = m.lastGoal.team == "red" and "blue" or "red"
				self:_resetRound(team)
				result.roundChanged = true
				event("kickoffReset", { teamToKick = team, lockTicks = m.remainingTicks, round = self.round })
			end
		elseif phase == "kickoff" and Rules.advanceKickoff(m) then
			Rules.resume(m)
			event("kickoffComplete", { teamToKick = m.kickoffTeam })
		end
	else
		if not m.kickoffTeam then
			self.elapsedTicks += 1
		end
		local _, events, substeps = Core.stepWorld(s.coreWorld, inputs)
		result.physicsEvents, result.substeps = events, substeps
		for _, e in ipairs(events) do
			local slot, kind
			if e.kind == "kick" and e.targetId == s.ball.id then
				slot, kind = e.playerId, "kick"
			elseif e.kind == "discContact" then
				if e.discA == s.ball.id then
					slot = e.discB
				elseif e.discB == s.ball.id then
					slot = e.discA
				end
				kind = "contact"
			end
			local p = type(slot) == "number" and s.players[slot] or nil
			if p then
				Rules.recordTouch(m, p.id, p.team, s.coreWorld.tick, kind)
				if (s.ball.vx ~= 0 or s.ball.vy ~= 0) and Rules.completeKickoff(m, p.team) then
					KickoffTimer.Clear(m)
					event("kickoffTaken", { playerId = p.id, team = p.team })
				end
			end
		end
		local expiredKickoffTeam = KickoffTimer.Advance(m, self.kickoffWaitTicks)
		if expiredKickoffTeam then
			event("kickoffTimeout", {
				teamThatHadKickoff = expiredKickoffTeam,
				waitedTicks = self.kickoffWaitTicks,
				opponentCanTake = true,
			})
		end
		local goal = Rules.findGoalCrossing(s.coreWorld.motionSegments, s.ball.id)
		if goal then
			goal.tick = s.coreWorld.tick
			local lastTouch = copyTouch(m.lastTouch)
			Rules.beginGoalPause(m, s.score, goal, s.ball, s.players, self.goalPauseTicks)
			m.lastGoal.lastTouch = lastTouch
			KickoffTimer.Clear(m)
			stop(s)
			for slot in ipairs(s.players) do
				self.needsKickRelease[slot] = true
			end
			event("goalScored", { team = goal.team, side = goal.side, x = goal.x, y = goal.y, lastTouch = lastTouch })
		end
	end
	s.tick = s.coreWorld.tick
	self:_masks()
	result.phase = m.phase
	result.round = self.round
	return result
end
return Match
