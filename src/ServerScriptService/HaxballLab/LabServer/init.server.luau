local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lab = ReplicatedStorage:WaitForChild("SimpleSoccerGame")
local remotes = lab:WaitForChild("Remotes")
local function requireRemote(name, className)
    local remote = remotes:WaitForChild(name, 15)
    assert(remote and remote:IsA(className), string.format("Simple Soccer remote %s missing or invalid", name))
    return remote
end
local inputRemote = requireRemote("Input", "RemoteEvent")
local snapshotRemote = requireRemote("Snapshot", "RemoteEvent")
local commandRemote = requireRemote("DebugCommand", "RemoteEvent")
local inputStream = requireRemote("InputStream", "UnreliableRemoteEvent")
local stateStream = requireRemote("StateStream", "UnreliableRemoteEvent")
local controlRemote = requireRemote("Control", "RemoteEvent")
local NetCodec = require(lab:WaitForChild("NetCodec"))
local NetServer = require(script.Parent:WaitForChild("NetServer"))
local network = NetServer.new()
local lastAppliedMasks = {}
local debugEnabled = lab:GetAttribute("EnableSimpleSoccerDiagnostics") == true
local controlRequests = {}
local RosterAllocator = require(lab:WaitForChild("RosterAllocator"))
local Physics2D = require(script.Parent:WaitForChild("Physics2D"))
local PhysicsCore2D = Physics2D.MatchCore
local ClassicStadium2D = require(script.Parent:WaitForChild("ClassicStadium2D"))
local StadiumProfile2D = require(lab:WaitForChild("StadiumReference2D"))
local MatchRules2D = require(script.Parent:WaitForChild("MatchRules2D"))
local LocalMatch2D = require(script.Parent:WaitForChild("LocalMatch2D"))
local localMatch
local matchId = 0
local LabRegression = require(script.Parent:WaitForChild("LabRegression"))
local debugState = script.Parent:WaitForChild("DebugState")

Players.CharacterAutoLoads = false
local state = Physics2D.newState()
local matchState = MatchRules2D.newMatch()
local currentInput = { x = 0, y = 0, kick = false }
local currentInputs = { [1] = currentInput }
local lastCoreKickInputs = {}
local touchingCoreBall = {}
local playerUserSlots = {}
local slotUserIds = {}
local lastKick = false
local facingX, facingY = 1, 0
local controlledPlayer = nil
local accumulator = 0
local stepDt = 1 / Physics2D.Config.tickRate
local recording = debugEnabled
local historyCapacity = 3600
local historyBuffer = {}
local historyWrite = 1
local historyCount = 0
local events = {}
local eventCapacity = 300
local pairMode = false
local crowdMode = false
local legacyMode = false
local speedRunRemaining = 0
local touchingBall = false
local touchingPlayers = false
local touchingCrowdPairs = {}
local metrics = {
	kickAttempts = 0,
	successfulKicks = 0,
	ballContacts = 0,
	ballWallBounces = 0,
	playerWallBounces = 0,
	lastKickSuccessTick = -1,
	playerContacts = 0,
	maxPlayerPenetration = 0,
	maxPlayerCorrection = 0,
	lastPlayerContactTick = -1,
	lastPlayerImpulse = 0,
	crowdContacts = 0,
	crowdContactsP1P2 = 0,
	crowdContactsP1Ball = 0,
	crowdContactsP2Ball = 0,
	crowdPeakPenetration = 0,
	crowdLastResidualPenetration = 0,
	crowdWorstResidualPenetration = 0,
	crowdLastSolverIterations = 0,
	crowdMaxSolverIterations = 0,
	lastCollisionSubsteps = 0,
	maxCollisionSubsteps = 0,
	regressionRan = false,
	regressionPassed = 0,
	regressionFailed = 0,
	regressionTotal = 0,
}
local function clearHistory()
	table.clear(historyBuffer)
	historyWrite, historyCount = 1, 0
end
local function logEvent(kind, data, eventTick)
	local event = data or {}
	event.kind = kind
	event.tick = eventTick or state.tick + 1
	table.insert(events, event)
	if #events > eventCapacity then
		table.remove(events, 1)
	end
end
local function clearMetrics()
	metrics.kickAttempts = 0
	metrics.successfulKicks = 0
	metrics.ballContacts = 0
	metrics.ballWallBounces = 0
	metrics.playerWallBounces = 0
	metrics.lastKickSuccessTick = -1
	metrics.playerContacts = 0
	metrics.maxPlayerPenetration = 0
	metrics.maxPlayerCorrection = 0
	metrics.lastPlayerContactTick = -1
	metrics.lastPlayerImpulse = 0
	metrics.crowdContacts = 0
	metrics.crowdContactsP1P2 = 0
	metrics.crowdContactsP1Ball = 0
	metrics.crowdContactsP2Ball = 0
	metrics.crowdPeakPenetration = 0
	metrics.crowdLastResidualPenetration = 0
	metrics.crowdWorstResidualPenetration = 0
	metrics.crowdLastSolverIterations = 0
	metrics.crowdMaxSolverIterations = 0
	metrics.lastCollisionSubsteps = 0
	metrics.maxCollisionSubsteps = 0
	metrics.regressionRan = false
	metrics.regressionPassed = 0
	metrics.regressionFailed = 0
	metrics.regressionTotal = 0
	table.clear(events)
	clearHistory()
	touchingBall = false
	touchingPlayers = false
	touchingCrowdPairs = {}
end
local function finite(n)
	return typeof(n) == "number" and n == n and math.abs(n) < 1e6
end

local function setController(player)
	if controlledPlayer == nil then
		controlledPlayer = player
	end
	if not playerUserSlots[player.UserId] then
        local slot = RosterAllocator.nextSlot(
            slotUserIds,
            StadiumProfile2D.PlayerCount,
            StadiumProfile2D.PlayersPerTeam
        )
        if slot then
            playerUserSlots[player.UserId] = slot
            slotUserIds[slot] = player.UserId
            if state.players and state.players[slot] then
                state.players[slot].ownerUserId = player.UserId
            end
        end
    end
	if player.Character then
		player.Character:Destroy()
	end
end
Players.PlayerAdded:Connect(setController)
for _, player in Players:GetPlayers() do
	setController(player)
end
Players.PlayerRemoving:Connect(function(player)
	controlRequests[player.UserId] = nil
	local slot = playerUserSlots[player.UserId]
	if slot then
		network:release(slot)
		playerUserSlots[player.UserId] = nil
		slotUserIds[slot] = nil
		currentInputs[slot] = { x = 0, y = 0, kick = false }
		lastCoreKickInputs[slot] = nil
		touchingCoreBall[slot] = nil
		if state.players and state.players[slot] then
			state.players[slot].ownerUserId = nil
		end
	end
	if player == controlledPlayer then
		controlledPlayer = nil
		for _, candidate in Players:GetPlayers() do
			if candidate ~= player then
				controlledPlayer = candidate
				break
			end
		end
		currentInput = { x = 0, y = 0, kick = false }
		if state.coreWorld then
			-- Removing the controller must not clear input owned by a different slot.
			currentInput = currentInputs[1] or currentInput
		else
			currentInputs[1] = currentInput
		end
		lastKick = false
		if state.players then
			local newSlot = controlledPlayer and playerUserSlots[controlledPlayer.UserId]
			if newSlot and state.players[newSlot] then
				state.players[newSlot].ownerUserId = controlledPlayer.UserId
			end
		elseif state.player then
			state.player.ownerUserId = controlledPlayer and controlledPlayer.UserId or nil
		end
	end
end)

local function allocateInput(playerSlot, x, y, kick)
	if not finite(x) or not finite(y) then
		return nil
	end
	local magnitude = math.sqrt(x * x + y * y)
	if magnitude > 1 then
		x, y = x / magnitude, y / magnitude
	end
	local value = { x = x, y = y, kick = kick == true }
	local old = currentInputs[playerSlot] or { x = 0, y = 0, kick = false }
	if x ~= old.x or y ~= old.y or value.kick ~= old.kick then
		logEvent("input", { playerId = playerSlot, x = x, y = y, kick = value.kick })
	end
	currentInputs[playerSlot] = value
	return value
end
local function receiveInput(player, x, y, kick)
	local slot = playerUserSlots[player.UserId]
	if state.coreWorld then
		if slot then
			network:receive(slot, x, state.tick)
		end
		return
	end
	local slot = playerUserSlots[player.UserId]
	if not slot then
		return
	end
	if pairMode or crowdMode or legacyMode then
		if player ~= controlledPlayer then
			return
		end
		local value = allocateInput(1, x, y, kick)
		if value then
			currentInput = value
		end
		if value and x * x + y * y > 0.01 then
			local magnitude = math.sqrt(x * x + y * y)
			facingX, facingY = x / magnitude, y / magnitude
		end
		return
	end
	local value = allocateInput(slot, x, y, kick)
	if value and slot == 1 then
		currentInput = value
	end
end
inputRemote.OnServerEvent:Connect(receiveInput)
inputStream.OnServerEvent:Connect(receiveInput)

local function speed(d)
	return math.sqrt(d.vx * d.vx + d.vy * d.vy)
end
local function makeCoreState()
	local legacy = Physics2D.newState()
	local world = PhysicsCore2D.newWorld({
		tickRate = Physics2D.Config.tickRate,
		fieldHalfWidth = Physics2D.Config.fieldHalfWidth,
		fieldHalfHeight = Physics2D.Config.fieldHalfHeight,
		useBounds = false,
		solverMode = "classicDiscrete",
	})
	-- Preserve stadium order: ball, static posts, then eight player discs.
	local ball = PhysicsCore2D.addDisc(world, {
		id = "ball",
		kind = "ball",
		x = 0,
		y = 0,
		radius = Physics2D.Config.ballRadius,
		invMass = Physics2D.Config.ballInvMass,
		damping = Physics2D.Config.ballDamping,
		traceMotion = true,
		bCoef = Physics2D.Config.ballBounce,
		kickable = true,
		collisionGroup = ClassicStadium2D.Groups.ball,
	})
	local stadiumGeometry = ClassicStadium2D.install(PhysicsCore2D, world)
	local spawnPoints = table.clone(StadiumProfile2D.SpawnPoints)
	local players = {}
	local playerCollisionMasks = {}
	for slot = 1, StadiumProfile2D.PlayerCount do
		local position = spawnPoints[slot]
		local disc = PhysicsCore2D.addDisc(world, {
			id = slot,
			kind = "player",
			team = slot <= StadiumProfile2D.PlayersPerTeam and "red" or "blue",
			x = position.x,
			y = position.y,
			radius = Physics2D.Config.playerRadius,
			invMass = Physics2D.Config.playerInvMass,
			damping = Physics2D.Config.playerDamping,
			kickDamping = Physics2D.Config.playerKickDamping,
			bCoef = Physics2D.Config.playerBounce,
			acceleration = Physics2D.Config.playerAcceleration,
			kickAcceleration = Physics2D.Config.playerKickAcceleration,
			kickStrength = Physics2D.Config.kickStrength,
			kickback = Physics2D.Config.kickback,
			kickRangeExtra = Physics2D.Config.kickRangeExtra,
			collisionGroup = slot <= StadiumProfile2D.PlayersPerTeam and ClassicStadium2D.Groups.red or ClassicStadium2D.Groups.blue,
			collisionMask = StadiumProfile2D.CollisionMasks.player,
		})
		disc.ownerUserId = slotUserIds[slot]
		players[slot] = disc
		playerCollisionMasks[slot] = disc.collisionMask
	end
	return {
		tick = 0,
		player = players[1],
		player2 = players[StadiumProfile2D.PlayersPerTeam + 1],
		players = players,
		ball = ball,
		score = legacy.score,
		coreWorld = world,
		stadiumGeometry = stadiumGeometry,
		spawnPoints = spawnPoints,
		playerCollisionMasks = playerCollisionMasks,
	}
end

local function newState(pairEnabled, crowdEnabled, legacyPhysicsEnabled, startWithKickoff)
	local useLegacy = pairEnabled == true or crowdEnabled == true or legacyPhysicsEnabled == true
	local new = useLegacy and Physics2D.newState() or makeCoreState()
	if not new.coreWorld then
		new.player.ownerUserId = controlledPlayer and controlledPlayer.UserId or nil
	end
	pairMode = pairEnabled == true
	crowdMode = crowdEnabled == true
	legacyMode = legacyPhysicsEnabled == true
	state = new
	matchId += 1
	-- Control request timestamps use match ticks, which start over here.
	table.clear(controlRequests)
	localMatch = new.coreWorld and LocalMatch2D.attach(new, { startWithKickoff = startWithKickoff == true }) or nil
	matchState = localMatch and localMatch.match or MatchRules2D.newMatch()
	network:epoch(matchId, localMatch and localMatch.round or 0)
	lastAppliedMasks = {}
	currentInputs = {}
	for slot = 1, StadiumProfile2D.PlayerCount do
		currentInputs[slot] = { x = 0, y = 0, kick = false }
	end
	currentInput = currentInputs[1]
	lastCoreKickInputs = {}
	touchingCoreBall = {}
	lastKick = false
	facingX, facingY = 1, 0
	accumulator = 0
	speedRunRemaining = 0
	clearMetrics()
	touchingCrowdPairs = {}
	return new
end
newState(false, false, false, true)
commandRemote.OnServerEvent:Connect(function(player, command)
	if not debugEnabled or player ~= controlledPlayer then
		return
	end
	if command == "reset" then
		newState(false, false, false, true)
		logEvent("scenarioReset", { scenario = "default" })
	elseif command == "setupKick" then
		local new = newState(false)
		new.player.x = -27
		logEvent("scenarioReset", { scenario = "kickFromRest", separation = 27 })
	elseif command == "setupWall" then
		local new = newState(false)
		new.ball.x = 0
		new.ball.y = 156
		new.ball.vy = 5
		logEvent("scenarioReset", { scenario = "ballWallBounce", ballY = new.ball.y, ballVy = new.ball.vy })
	elseif command == "setupGoalTest" then
		local new = newState(false)
		new.ball.x = 340
		new.ball.y = 0
		new.ball.vx = 12
		logEvent(
			"scenarioReset",
			{ scenario = "goalCrossing", ballX = new.ball.x, ballY = new.ball.y, ballVx = new.ball.vx }
		)
	elseif command == "setupSpeedRun" then
		local new = newState(false)
		new.player.x = -200
		new.player.y = 100
		currentInput = { x = 1, y = 0, kick = false }
		currentInputs[1] = currentInput
		speedRunRemaining = 120
		logEvent(
			"scenarioReset",
			{ scenario = "freeAccelerationRun", playerX = -200, playerY = 100, inputX = 1, inputY = 0 }
		)
	elseif command == "setupBallFastCrossing" then
		local new = newState(false, false, true)
		new.player.x = -40
		new.player.vx = 100
		new.ball.x = 0
		new.ball.y = 0
		logEvent("scenarioReset", { scenario = "fastPlayerBallCrossing", playerX = -40, playerVx = 100, ballX = 0 })
	elseif command == "setupBallFastDiagonal" then
		local new = newState(false, false, true)
		new.player.x = -40
		new.player.y = -40
		new.player.vx = 100
		new.player.vy = 100
		new.ball.x = 0
		new.ball.y = 0
		logEvent("scenarioReset", {
			scenario = "fastDiagonalPlayerBallCrossing",
			playerX = -40,
			playerY = -40,
			playerVx = 100,
			playerVy = 100,
			ballX = 0,
			ballY = 0,
		})
	elseif command == "setupMultiWall" then
		local new = newState(false, false, true)
		new.player.y = 100
		new.ball.x = 0
		new.ball.y = 0
		new.ball.vx = 3000
		logEvent("scenarioReset", { scenario = "multiWallBouncesInTick", ballX = 0, ballVx = 3000 })
	elseif command == "setupPairHeadOn" then
		local new = newState(true)
		new.player.x = -40
		new.player.vx = 2
		new.player2.x = 40
		new.player2.vx = -2
		logEvent("scenarioReset", { scenario = "playerHeadOn", p1x = -40, p1vx = 2, p2x = 40, p2vx = -2 })
	elseif command == "setupPairFastCrossing" then
		local new = newState(true)
		new.player.x = -40
		new.player.vx = 80
		new.player2.x = 40
		new.player2.vx = -80
		logEvent("scenarioReset", { scenario = "fastPairCrossing", p1x = -40, p1vx = 80, p2x = 40, p2vx = -80 })
	elseif command == "setupPairOblique" then
		local new = newState(true)
		new.player.x = -40
		new.player.y = -10
		new.player.vx = 2
		new.player2.x = 0
		new.player2.y = 15
		new.player2.vy = -0.8
		logEvent(
			"scenarioReset",
			{ scenario = "playerOblique", p1x = -40, p1y = -10, p1vx = 2, p2x = 0, p2y = 15, p2vy = -0.8 }
		)
	elseif command == "setupPairOverlap" then
		local new = newState(true)
		new.player.x = 0
		new.player.y = 0
		new.player2.x = 0
		new.player2.y = 0
		logEvent("scenarioReset", { scenario = "playerCoincidentCenters" })
	elseif command == "setupCrowdOverlap" then
		local new = newState(false, true)
		new.player.x = -14
		new.player2.x = 14
		new.ball.x = 0
		new.ball.y = 0
		logEvent("scenarioReset", { scenario = "threeDiscOverlap", p1x = -14, p2x = 14, ballX = 0 })
	elseif command == "setupCrowdApproach" then
		local new = newState(false, true)
		new.player.x = -32
		new.player.vx = 2
		new.player2.x = 32
		new.player2.vx = -2
		new.ball.x = 0
		new.ball.y = 0
		logEvent(
			"scenarioReset",
			{ scenario = "twoPlayersApproachBall", p1x = -32, p1vx = 2, p2x = 32, p2vx = -2, ballX = 0 }
		)
	elseif command == "runRegressionSuite" then
		local report = LabRegression.Run(Physics2D)
		metrics.regressionRan = true
		metrics.regressionPassed = report.passed
		metrics.regressionFailed = report.failed
		metrics.regressionTotal = report.total
		logEvent(
			"regressionSuiteCompleted",
			{ passed = report.passed, failed = report.failed, total = report.total, allPassed = report.allPassed }
		)
	elseif command == "toggleRecording" then
		recording = not recording
		logEvent("recordingChanged", { recording = recording })
	end
end)

local function snapshot()
	local p, p2, b = state.player, state.player2, state.ball
	local dx, dy = p.x - b.x, p.y - b.y
	local p2dx, p2dy = p.x - p2.x, p.y - p2.y
	local p2bdx, p2bdy = p2.x - b.x, p2.y - b.y
	local playerSnapshots = {}
	local redCount, blueCount = 0, 0
	if state.players then
		for slot, disc in ipairs(state.players) do
			if disc.team == "red" then
				redCount += 1
			elseif disc.team == "blue" then
				blueCount += 1
			end
			table.insert(playerSnapshots, {
				playerId = slot,
				team = disc.team,
				ownerUserId = disc.ownerUserId,
				x = disc.x,
				y = disc.y,
				vx = disc.vx,
				vy = disc.vy,
				speed = speed(disc),
				radius = disc.radius,
				collisionGroup = disc.collisionGroup,
				collisionMask = disc.collisionMask,
				ack = network.queues[slot] and network.queues[slot].ack or 0,
				kickHeld = disc.kickHeld,
				kickArmed = disc.kickArmed,
				kickCooldown = disc.kickCooldown,
				needsKickRelease = localMatch and localMatch.needsKickRelease[slot] or false,
				inputMask = lastAppliedMasks[slot] or 0,
			})
		end
	end
	return {
		tick = state.tick,
		gameTime = state.tick / Physics2D.Config.tickRate,
		matchId = matchId,
		round = localMatch and localMatch.round or 0,
		elapsedMatchTicks = localMatch and localMatch.elapsedTicks or 0,
		winner = matchState.winner,
		matchPhase = matchState.phase,
		pauseTicksRemaining = matchState.remainingTicks,
		kickoffTeam = matchState.kickoffTeam,
		lastGoal = matchState.lastGoal,
		lastTouch = matchState.lastTouch,
		player = { x = p.x, y = p.y, vx = p.vx, vy = p.vy, speed = speed(p), radius = p.radius },
		predictionParams = {
			acceleration = p.acceleration or Physics2D.Config.playerAcceleration,
			kickAcceleration = p.kickAcceleration or Physics2D.Config.playerKickAcceleration,
			damping = p.damping or Physics2D.Config.playerDamping,
			kickDamping = p.kickDamping or Physics2D.Config.playerDamping,
			maxSpeed = p.maxSpeed,
		},
		player2 = { x = p2.x, y = p2.y, vx = p2.vx, vy = p2.vy, speed = speed(p2), radius = p2.radius },
		players = playerSnapshots,
		playerCount = #playerSnapshots,
		redCount = redCount,
		blueCount = blueCount,
		ball = {
			x = b.x,
			y = b.y,
			vx = b.vx,
			vy = b.vy,
			speed = speed(b),
			radius = b.radius,
			collisionGroup = b.collisionGroup,
			collisionMask = b.collisionMask,
		},
		score = { red = state.score.red, blue = state.score.blue },
		ownerUserId = p.ownerUserId,
		physicsDiscCount = state.coreWorld and #state.coreWorld.discs or 0,
		input = { x = currentInput.x, y = currentInput.y, kick = currentInput.kick },
		separation = math.sqrt(dx * dx + dy * dy),
		playerSeparation = math.sqrt(p2dx * p2dx + p2dy * p2dy),
		player2BallSeparation = math.sqrt(p2bdx * p2bdx + p2bdy * p2bdy),
		touchingBall = not pairMode and math.sqrt(dx * dx + dy * dy) <= p.radius + b.radius + 0.02,
		touchingPlayer2Ball = crowdMode and math.sqrt(p2bdx * p2bdx + p2bdy * p2bdy) <= p2.radius + b.radius + 0.02,
		touchingPlayers = math.sqrt(p2dx * p2dx + p2dy * p2dy) <= p.radius + p2.radius + 0.02,
		pairMode = pairMode,
		crowdMode = crowdMode,
		coreMode = state.coreWorld ~= nil,
		legacyMode = legacyMode,
		ballActive = not pairMode,
		metrics = table.clone(metrics),
		networkStats = table.clone(network.stats),
		debugEnabled = debugEnabled,
		profileId = state.stadiumGeometry and state.stadiumGeometry.profileId or "legacy",
		recording = recording,
		historySamples = historyCount,
	}
end
controlRemote.OnServerEvent:Connect(function(player, kind, nonce)
	local previous = controlRequests[player.UserId] or -100
	if state.tick - previous < 15 then
		return
	end
	if kind == "ready" then
		controlRequests[player.UserId] = state.tick
		local slot = playerUserSlots[player.UserId]
		if slot and network.queues[slot] then
			network.queues[slot].pending = {}
		end
		local s = snapshot()
		s.resync = true
		snapshotRemote:FireClient(player, s)
	elseif kind == "ping" and type(nonce) == "number" and nonce % 1 == 0 and nonce >= 0 and nonce < 4294967296 then
		controlRequests[player.UserId] = state.tick
		controlRemote:FireClient(player, "pong", nonce, state.tick)
	end
end)
debugState.OnInvoke = function(request)
	local current = snapshot()
	if request == "regression" then
		return LabRegression.Run(Physics2D)
	end
	if request == "summary" then
		return {
			current = current,
			metrics = table.clone(metrics),
			eventCount = #events,
			historyCount = historyCount,
			recording = recording,
		}
	end
	local chronological = {}
	local limit = type(request) == "table" and math.clamp(request.limit or 600, 1, 1200) or 600
	local hasAfterTick = type(request) == "table" and type(request.afterTick) == "number"
	local afterTick = hasAfterTick and request.afterTick or -1
	local first = historyCount < historyCapacity and 1 or historyWrite
	local skip = hasAfterTick and 0 or math.max(0, historyCount - limit)
	for i = skip + 1, historyCount do
		local index = ((first + i - 2) % historyCapacity) + 1
		local sample = historyBuffer[index]
		if sample and sample.tick > afterTick then
			table.insert(chronological, table.clone(sample))
			if #chronological >= limit then
				break
			end
		end
	end
	local eventCopies = {}
	for _, event in events do
		table.insert(eventCopies, table.clone(event))
	end
	return {
		current = current,
		metrics = table.clone(metrics),
		events = eventCopies,
		history = chronological,
		recording = recording,
	}
end

RunService.Heartbeat:Connect(function(dt)
	local publishState
	accumulator += dt
	local iterations = 0
	while accumulator >= stepDt and iterations < 8 do
		local p, p2, b = state.player, state.player2, state.ball
		local beforeBallVx, beforeBallVy = b.vx, b.vy
		local beforePlayerVx, beforePlayerVy = p.vx, p.vy
		local pairResolution = nil
		local crowdResiduals = nil
		local physicsStepInfo = nil
		local pairBeforeSeparation = math.sqrt((p.x - p2.x) ^ 2 + (p.y - p2.y) ^ 2)

		if pairMode then
			local _, resolution = Physics2D.stepPlayerPair(state)
			pairResolution = resolution
			local separation = math.sqrt((p.x - p2.x) ^ 2 + (p.y - p2.y) ^ 2)
			local nowTouching = separation <= p.radius + p2.radius + 0.02
			if resolution then
				metrics.maxPlayerPenetration = math.max(metrics.maxPlayerPenetration, resolution.penetration)
				metrics.maxPlayerCorrection =
					math.max(metrics.maxPlayerCorrection, resolution.correctionA + resolution.correctionB)
				if resolution and not touchingPlayers and (nowTouching or resolution.swept == true) then
					metrics.playerContacts += 1
					metrics.lastPlayerContactTick = state.tick
					metrics.lastPlayerImpulse = resolution.impulse
					logEvent("playerPlayerContact", {
						separation = resolution.swept and (p.radius + p2.radius - resolution.penetration) or separation,
						postStepSeparation = separation,
						penetration = resolution.penetration,
						correctionA = resolution.correctionA,
						correctionB = resolution.correctionB,
						normalX = resolution.normalX,
						normalY = resolution.normalY,
						normalSpeedBefore = resolution.normalSpeedBefore,
						impulse = resolution.impulse,
						swept = resolution.swept == true,
						impactFraction = resolution.impactFraction,
						p1x = p.x,
						p1y = p.y,
						p1vx = p.vx,
						p1vy = p.vy,
						p2x = p2.x,
						p2y = p2.y,
						p2vx = p2.vx,
						p2vy = p2.vy,
					}, state.tick)
				end
			end
			touchingPlayers = nowTouching
		elseif crowdMode then
			local _, impacts, residuals, maxResidual, iterationsUsed =
				Physics2D.stepThreeBody(state, Physics2D.Config.collisionIterations)
			crowdResiduals = residuals
			metrics.crowdLastSolverIterations = iterationsUsed
			metrics.crowdMaxSolverIterations = math.max(metrics.crowdMaxSolverIterations, iterationsUsed)
			local pairDefinitions = {
				{ key = "player1-player2", a = p, b = p2, metric = "crowdContactsP1P2" },
				{ key = "player1-ball", a = p, b = b, metric = "crowdContactsP1Ball" },
				{ key = "player2-ball", a = p2, b = b, metric = "crowdContactsP2Ball" },
			}
			for _, definition in pairDefinitions do
				local dx, dy = definition.a.x - definition.b.x, definition.a.y - definition.b.y
				local separation = math.sqrt(dx * dx + dy * dy)
				local isTouching = separation <= definition.a.radius + definition.b.radius + 0.02
				local impact = impacts[definition.key]
				if impact then
					metrics.crowdPeakPenetration = math.max(metrics.crowdPeakPenetration, impact.maxPenetration)
				end
				if isTouching and not touchingCrowdPairs[definition.key] then
					metrics.crowdContacts += 1
					metrics[definition.metric] += 1
					logEvent("threeDiscContact", {
						pair = definition.key,
						separation = separation,
						penetration = impact and impact.maxPenetration or 0,
						correctionA = impact and impact.correctionA or 0,
						correctionB = impact and impact.correctionB or 0,
						normalX = impact and impact.normalX or 0,
						normalY = impact and impact.normalY or 0,
						normalSpeedBefore = impact and impact.normalSpeedBefore or 0,
						impulseTotal = impact and impact.impulseTotal or 0,
						peakImpulseIncrement = impact and impact.peakImpulseIncrement or 0,
						lastImpulse = impact and impact.lastImpulse or 0,
						resolutionCount = impact and impact.resolutionCount or 0,
						residualPenetration = residuals[definition.key] or 0,
						p1x = p.x,
						p1y = p.y,
						p1vx = p.vx,
						p1vy = p.vy,
						p2x = p2.x,
						p2y = p2.y,
						p2vx = p2.vx,
						p2vy = p2.vy,
						ballX = b.x,
						ballY = b.y,
						ballVx = b.vx,
						ballVy = b.vy,
					}, state.tick)
				end
				touchingCrowdPairs[definition.key] = isTouching
			end
			metrics.crowdLastResidualPenetration = maxResidual
			metrics.crowdWorstResidualPenetration = math.max(metrics.crowdWorstResidualPenetration, maxResidual)
			touchingPlayers = touchingCrowdPairs["player1-player2"] == true
		elseif state.coreWorld then
			network:epoch(matchId, localMatch.round, state.tick)
			currentInputs = network:consume(state.tick + 1)
			if speedRunRemaining > 0 then
				currentInputs[1] = { x = 1, y = 0, kick = false }
			end
			currentInput = currentInputs[1]
			local result = localMatch:step(currentInputs)
			for slot, input in pairs(result.inputs) do
				lastAppliedMasks[slot] = NetCodec.mask(input.x, input.y, input.kick)
			end
			network:epoch(matchId, localMatch.round, state.tick)
			local coreInputs, kickAttempts = result.inputs, {}
			for slot = 1, StadiumProfile2D.PlayerCount do
				local input = coreInputs[slot] or {}
				if input.kick and not lastCoreKickInputs[slot] then
					table.insert(kickAttempts, slot)
				end
				lastCoreKickInputs[slot] = input.kick == true
			end
			local coreEvents, coreSubsteps = result.physicsEvents, result.substeps
			local stepInfo = {
				substeps = coreSubsteps,
				ballWallBounces = 0,
				playerWallBounces = 0,
				playerBallContacts = 0,
				lastPlayerBallContact = nil,
			}
			local acceptedKicks, currentTouches, contactsByPlayer = {}, {}, {}
			for _, event in ipairs(coreEvents) do
				if event.kind == "kick" then
					acceptedKicks[event.playerId] = true
					metrics.successfulKicks += 1
					metrics.lastKickSuccessTick = state.tick
					logEvent("kickApplied", {
						playerId = event.playerId,
						targetId = event.targetId,
						normalX = event.normalX,
						normalY = event.normalY,
					}, state.tick)
				elseif event.kind == "boundaryContact" then
					local count = event.count or 1
					if event.discId == "ball" then
						stepInfo.ballWallBounces += count
					elseif type(event.discId) == "number" then
						stepInfo.playerWallBounces += count
					end
				elseif
					event.kind == "planeContact"
					or event.kind == "segmentContact"
					or event.kind == "vertexContact"
				then
					if event.discId == "ball" then
						stepInfo.ballWallBounces += 1
					elseif type(event.discId) == "number" then
						stepInfo.playerWallBounces += 1
					end
				elseif event.kind == "discContact" then
					local playerId
					if event.discA == "ball" and type(event.discB) == "number" then
						playerId = event.discB
					elseif event.discB == "ball" and type(event.discA) == "number" then
						playerId = event.discA
					end
					if playerId then
						stepInfo.playerBallContacts += 1
						local nx, ny = event.normalX, event.normalY
						if event.discA == "ball" then
							nx, ny = -nx, -ny
						end
						local contact = {
							playerId = playerId,
							normalX = nx,
							normalY = ny,
							penetration = event.penetration,
							normalSpeedBefore = event.normalSpeedBefore,
							impulse = event.impulse,
						}
						stepInfo.lastPlayerBallContact = contact
						contactsByPlayer[playerId] = contact
						currentTouches[playerId] = true
					elseif type(event.discA) == "number" and type(event.discB) == "number" then
						metrics.playerContacts += 1
						metrics.lastPlayerContactTick = state.tick
						metrics.maxPlayerPenetration = math.max(metrics.maxPlayerPenetration, event.penetration or 0)
						metrics.lastPlayerImpulse = event.impulse or 0
						logEvent("playerPlayerContact", {
							playerA = event.discA,
							playerB = event.discB,
							normalX = event.normalX,
							normalY = event.normalY,
							penetration = event.penetration,
							normalSpeedBefore = event.normalSpeedBefore,
							impulse = event.impulse,
						}, state.tick)
					end
				end
			end
			metrics.kickAttempts += #kickAttempts
			for _, slot in ipairs(kickAttempts) do
				local accepted = acceptedKicks[slot] == true
				local actor = state.players[slot]
				local separation = math.sqrt((actor.x - b.x) ^ 2 + (actor.y - b.y) ^ 2)
				logEvent("kickAttempt", {
					playerId = slot,
					accepted = accepted,
					separation = separation,
					playerX = actor.x,
					playerY = actor.y,
					ballX = b.x,
					ballY = b.y,
				}, state.tick)
			end
			for slot, actor in ipairs(state.players) do
				local dx, dy = actor.x - b.x, actor.y - b.y
				local touching = math.sqrt(dx * dx + dy * dy) <= actor.radius + b.radius + 0.02
				if currentTouches[slot] and not touchingCoreBall[slot] then
					metrics.ballContacts += 1
					local contact = contactsByPlayer[slot] or {}
					logEvent("playerBallContact", {
						playerId = slot,
						separation = actor.radius + b.radius - (contact.penetration or 0),
						normalX = contact.normalX,
						normalY = contact.normalY,
						normalSpeedBefore = contact.normalSpeedBefore,
						impulse = contact.impulse,
						playerX = actor.x,
						playerY = actor.y,
						ballX = b.x,
						ballY = b.y,
					}, state.tick)
				end
				touchingCoreBall[slot] = touching
			end
			for _, event in ipairs(result.ruleEvents) do
				logEvent(event.kind, table.clone(event), event.tick)
			end
			if result.roundChanged or result.phase == "goalPause" then
				touchingCoreBall = {}
				touchingBall = false
				lastCoreKickInputs = {}
			end
			physicsStepInfo = stepInfo
			if speedRunRemaining > 0 then
				speedRunRemaining -= 1
				if speedRunRemaining == 0 then
					currentInput = { x = 0, y = 0, kick = false }
					currentInputs[1] = currentInput
					logEvent(
						"speedRunFinished",
						{ ticks = 120, playerX = p.x, playerVx = p.vx, playerSpeed = speed(p) },
						state.tick
					)
				end
			end
			metrics.lastCollisionSubsteps = stepInfo.substeps
			metrics.maxCollisionSubsteps = math.max(metrics.maxCollisionSubsteps, stepInfo.substeps)
			if stepInfo.ballWallBounces > 0 then
				metrics.ballWallBounces += stepInfo.ballWallBounces
				logEvent("ballBoundaryBounce", {
					count = stepInfo.ballWallBounces,
					x = b.x,
					y = b.y,
					vx = b.vx,
					vy = b.vy,
					substeps = stepInfo.substeps,
				}, state.tick)
			end
			if stepInfo.playerWallBounces > 0 then
				metrics.playerWallBounces += stepInfo.playerWallBounces
				logEvent("playerBoundaryBounce", {
					count = stepInfo.playerWallBounces,
					x = p.x,
					y = p.y,
					vx = p.vx,
					vy = p.vy,
					substeps = stepInfo.substeps,
				}, state.tick)
			end
			local separation = math.sqrt((p.x - b.x) ^ 2 + (p.y - b.y) ^ 2)
			local nowTouching = separation <= p.radius + b.radius + 0.02
			touchingBall = nowTouching
		else
			if currentInput.kick and not lastKick then
				metrics.kickAttempts += 1
				local dx, dy = b.x - p.x, b.y - p.y
				local separation = math.sqrt(dx * dx + dy * dy)
				local accepted = Physics2D.tryKick(state, facingX, facingY)
				if accepted then
					metrics.successfulKicks += 1
					metrics.lastKickSuccessTick = state.tick + 1
				end
				logEvent("kickAttempt", {
					accepted = accepted,
					separation = separation,
					playerX = p.x,
					playerY = p.y,
					ballX = b.x,
					ballY = b.y,
				})
			end
			lastKick = currentInput.kick
			local _, stepInfo = Physics2D.step(state, currentInput)
			physicsStepInfo = stepInfo
			if speedRunRemaining > 0 then
				speedRunRemaining -= 1
				if speedRunRemaining == 0 then
					currentInput = { x = 0, y = 0, kick = false }
					currentInputs[1] = currentInput
					logEvent(
						"speedRunFinished",
						{ ticks = 120, playerX = p.x, playerVx = p.vx, playerSpeed = speed(p) },
						state.tick
					)
				end
			end
			metrics.lastCollisionSubsteps = stepInfo.substeps
			metrics.maxCollisionSubsteps = math.max(metrics.maxCollisionSubsteps, stepInfo.substeps)
			if stepInfo.ballWallBounces > 0 then
				metrics.ballWallBounces += stepInfo.ballWallBounces
				logEvent("ballBoundaryBounce", {
					count = stepInfo.ballWallBounces,
					x = b.x,
					y = b.y,
					vx = b.vx,
					vy = b.vy,
					substeps = stepInfo.substeps,
				}, state.tick)
			end
			if stepInfo.playerWallBounces > 0 then
				metrics.playerWallBounces += stepInfo.playerWallBounces
				logEvent("playerBoundaryBounce", {
					count = stepInfo.playerWallBounces,
					x = p.x,
					y = p.y,
					vx = p.vx,
					vy = p.vy,
					substeps = stepInfo.substeps,
				}, state.tick)
			end
			local separation = math.sqrt((p.x - b.x) ^ 2 + (p.y - b.y) ^ 2)
			local nowTouching = separation <= p.radius + b.radius + 0.02
			if stepInfo.playerBallContacts > 0 and not touchingBall then
				metrics.ballContacts += 1
				local contact = stepInfo.lastPlayerBallContact or {}
				logEvent("playerBallContact", {
					separation = p.radius + b.radius - (contact.penetration or 0),
					postStepSeparation = separation,
					contactsThisTick = stepInfo.playerBallContacts,
					substep = contact.substep,
					substeps = stepInfo.substeps,
					normalX = contact.normalX,
					normalY = contact.normalY,
					normalSpeedBefore = contact.normalSpeedBefore,
					impulse = contact.impulse,
					penetration = contact.penetration,
					playerX = p.x,
					playerY = p.y,
					ballX = b.x,
					ballY = b.y,
				}, state.tick)
			end
			touchingBall = nowTouching
		end

		accumulator -= stepDt
		iterations += 1
		local current = recording and snapshot() or nil
		publishState = current
		if recording then
			historyBuffer[historyWrite] = {
				tick = current.tick,
				gameTime = current.gameTime,
				pairMode = pairMode,
				crowdMode = crowdMode,
				inputX = current.input.x,
				inputY = current.input.y,
				kick = current.input.kick,
				playerX = p.x,
				playerY = p.y,
				playerVx = p.vx,
				playerVy = p.vy,
				playerSpeed = current.player.speed,
				player2X = p2.x,
				player2Y = p2.y,
				player2Vx = p2.vx,
				player2Vy = p2.vy,
				player2Speed = current.player2.speed,
				players = current.players,
				ballX = b.x,
				ballY = b.y,
				ballVx = b.vx,
				ballVy = b.vy,
				ballSpeed = current.ball.speed,
				separation = current.separation,
				playerSeparation = current.playerSeparation,
				player2BallSeparation = current.player2BallSeparation,
				pairPenetration = pairResolution and pairResolution.penetration or 0,
				crowdContacts = metrics.crowdContacts,
				crowdResidual = metrics.crowdLastResidualPenetration,
				solverIterations = metrics.crowdLastSolverIterations,
				physicsSubsteps = physicsStepInfo and physicsStepInfo.substeps or 0,
				residualP1P2 = crowdResiduals and crowdResiduals["player1-player2"] or 0,
				residualP1Ball = crowdResiduals and crowdResiduals["player1-ball"] or 0,
				residualP2Ball = crowdResiduals and crowdResiduals["player2-ball"] or 0,
				pairNormalX = pairResolution and pairResolution.normalX or 0,
				pairNormalY = pairResolution and pairResolution.normalY or 0,
				pairImpulse = pairResolution and pairResolution.impulse or 0,
				touchingBall = current.touchingBall,
				touchingPlayers = current.touchingPlayers,
			}
			historyWrite = (historyWrite % historyCapacity) + 1
			historyCount = math.min(historyCapacity, historyCount + 1)
		end
	end
	if iterations > 0 then
		local current = publishState or snapshot()
		network:publish(current, function(s)
			snapshotRemote:FireAllClients(s)
		end, function(b)
			stateStream:FireAllClients(b)
		end)
	end
end)
