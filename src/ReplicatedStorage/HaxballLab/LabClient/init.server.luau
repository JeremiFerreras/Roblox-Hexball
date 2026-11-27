local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local lab = ReplicatedStorage:WaitForChild("HaxballLab")
local remotes = lab.Remotes
local inputRemote = remotes.Input
local snapshotRemote = remotes.Snapshot
local commandRemote = remotes.DebugCommand
local inputStream = remotes:WaitForChild("InputStream")
local stateStream = remotes:WaitForChild("StateStream")
local controlRemote = remotes:WaitForChild("Control")
local NetCodec = require(lab:WaitForChild("NetCodec"))
local NetInputClient = require(lab:WaitForChild("NetInputClient"))
local netInput = NetInputClient.new()
local NetPrediction = require(lab:WaitForChild("NetPrediction"))
local prediction = NetPrediction.new()
local SnapshotBuffer = require(lab:WaitForChild("SnapshotBuffer"))
local presentation = SnapshotBuffer.new()
local NetMetrics = require(lab:WaitForChild("NetMetrics"))
local networkMetrics = NetMetrics.new()
local nextMetricsAt, nextHudAt = 0, 0
local function resetInputs(matchId, round, ack)
	networkMetrics:count("cancelledInputs", #netInput.pending)
	netInput:reset(matchId, round, ack)
end
local function confirmInputs(ack)
	local _, confirmed = netInput:confirm(ack, os.clock())
	for _, entry in ipairs(confirmed or {}) do
		networkMetrics:add("ackMs", entry.ms)
		networkMetrics:count("confirmedInputs")
	end
end
local bootstrap, ownSlot, latest
local lastAuthorityAt = 0
local nextPingAt = 0
local pingNonce = 0
local pingTimes = {}
local rtt = 0
local function sendWire(b, reliable)
	networkMetrics:count("inputPackets")
	networkMetrics:count("inputBytes", buffer.len(b))
	if reliable then
		networkMetrics:count("reliableFallbackPackets")
	end
	if reliable then
		inputRemote:FireServer(b)
	else
		inputStream:FireServer(b)
	end
end
local PredictionLab2D = require(lab:WaitForChild("PredictionLab2D"))
local StadiumProfile2D = require(lab:WaitForChild("StadiumReference2D"))
local inputContext = ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("HaxballGameplay")
local moveAction = inputContext:WaitForChild("Move")
local kickAction = inputContext:WaitForChild("Kick")
local ClassicReference230 = require(lab:WaitForChild("ClassicReference230"))
local GuiStadiumScene = require(lab:WaitForChild("GuiStadiumScene"))
local GuiStadiumRenderer = require(lab:WaitForChild("GuiStadiumRenderer"))
local stadiumScene = GuiStadiumScene.build(StadiumProfile2D, ClassicReference230)
local legacyField = workspace:WaitForChild("HaxballLab")
local stadiumRenderer = GuiStadiumRenderer.new(player:WaitForChild("PlayerGui"), stadiumScene, nil, legacyField, GuiStadiumScene)

local showDiagnostics = lab:GetAttribute("EnableHaxballDiagnostics") == true
local gui = Instance.new("ScreenGui")
gui.Name = "HaxballLabDebug"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(500, 190)
label.Position = UDim2.fromOffset(14, 14)
label.BackgroundTransparency = 0.18
label.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Text = "Haxball diagnostics | opt-in"
label.Visible = showDiagnostics
label.Parent = gui

local matchHud = Instance.new("ScreenGui")
matchHud.Name = "HaxballMatchHud"
matchHud.ResetOnSpawn = false
matchHud.IgnoreGuiInset = true
matchHud.DisplayOrder = 20
matchHud.Parent = player:WaitForChild("PlayerGui")
local hudPanel = Instance.new("Frame")
hudPanel.Name = "ScorePanel"
hudPanel.AnchorPoint = Vector2.new(0.5, 0)
hudPanel.Position = UDim2.new(0.5, 0, 0, 18)
hudPanel.Size = UDim2.fromOffset(390, 72)
hudPanel.BackgroundColor3 = Color3.fromRGB(13, 24, 35)
hudPanel.BackgroundTransparency = 0.08
hudPanel.BorderSizePixel = 0
hudPanel.Parent = matchHud
local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 14)
hudCorner.Parent = hudPanel
local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(103, 139, 153)
hudStroke.Transparency = 0.55
hudStroke.Thickness = 1
hudStroke.Parent = hudPanel
local function makeHudLabel(name, text, position, size, color, textSize, font)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.Text = text
	item.TextColor3 = color
	item.Font = font or Enum.Font.GothamBold
	item.TextSize = textSize
	item.TextXAlignment = Enum.TextXAlignment.Center
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = hudPanel
	return item
end
local redScoreLabel = makeHudLabel("RedScore", "RED  0", UDim2.fromOffset(12, 8), UDim2.fromOffset(112, 34), Color3.fromRGB(255, 137, 124), 21)
local scoreDivider = makeHudLabel("ScoreDivider", ":", UDim2.fromOffset(181, 8), UDim2.fromOffset(28, 34), Color3.fromRGB(205, 222, 227), 23)
local blueScoreLabel = makeHudLabel("BlueScore", "0  BLUE", UDim2.fromOffset(266, 8), UDim2.fromOffset(112, 34), Color3.fromRGB(132, 190, 255), 21)
local statusLabel = makeHudLabel("MatchStatus", "CONNECTING", UDim2.fromOffset(16, 42), UDim2.new(1, -32, 0, 21), Color3.fromRGB(204, 220, 224), 12, Enum.Font.GothamMedium)
local predictionLabel = Instance.new("TextLabel")
predictionLabel.Name = "NetworkPredictionDebug"
predictionLabel.Size = UDim2.fromOffset(370, 72)
predictionLabel.Position = UDim2.new(1, -384, 0, 14)
predictionLabel.BackgroundTransparency = 0.18
predictionLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
predictionLabel.TextColor3 = Color3.fromRGB(255, 235, 150)
predictionLabel.Font = Enum.Font.Code
predictionLabel.TextSize = 13
predictionLabel.TextXAlignment = Enum.TextXAlignment.Left
predictionLabel.TextYAlignment = Enum.TextYAlignment.Top
predictionLabel.TextWrapped = true
predictionLabel.Text = "Predicción experimental | input delay 0 ms"
predictionLabel.Visible = showDiagnostics
predictionLabel.Parent = gui
-- Client-local console: PlayerGui.HaxballLabDebug.NetworkDiagnostics:Invoke().
local networkDiagnostics = Instance.new("BindableFunction")
networkDiagnostics.Name = "NetworkDiagnostics"
networkDiagnostics.OnInvoke = function()
	local report = networkMetrics:report()
	report.presentation = presentation.status and table.clone(presentation.status) or nil
	report.pendingInputs = #netInput.pending
	report.authority = latest
			and {
				matchId = latest.matchId,
				round = latest.round,
				tick = latest.tick,
				ownSlot = ownSlot,
				ageMs = math.max(0, os.clock() - lastAuthorityAt) * 1000,
			}
		or nil
	report.inputs = { sequence = netInput.seq, acknowledged = netInput.ack, mask = netInput.mask }
	report.predictedTick = prediction.world and prediction.world.tick or nil
	return report
end
networkDiagnostics.Parent = gui
local calibrationLabel = Instance.new("TextLabel")
calibrationLabel.Name = "StadiumCalibrationDebug"
calibrationLabel.Size = UDim2.fromOffset(760, 82)
calibrationLabel.Position = UDim2.fromOffset(14, 466)
calibrationLabel.BackgroundTransparency = 0.18
calibrationLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
calibrationLabel.TextColor3 = Color3.fromRGB(190, 225, 255)
calibrationLabel.Font = Enum.Font.Code
calibrationLabel.TextSize = 12
calibrationLabel.TextXAlignment = Enum.TextXAlignment.Left
calibrationLabel.TextYAlignment = Enum.TextYAlignment.Top
calibrationLabel.TextWrapped = true
local meta = StadiumProfile2D.Metadata
local bounds = StadiumProfile2D.Bounds
local playArea = StadiumProfile2D.PlayArea
local goals = StadiumProfile2D.Goals
local activePhysics = StadiumProfile2D.PhysicsBaseline.active
local replayPhysics = StadiumProfile2D.PhysicsBaseline.replayCandidate
calibrationLabel.Text = string.format(
	"CLASSIC | physics/presentation reference Node-Haxball 2.3.0\nLogical %dx%d | goal opening %d | geometry %dP/%dS/%dV/%d posts\nVisual %.2f studs/unit | independent reference; official comparison pending",
	bounds.spanWidth,
	bounds.spanHeight,
	goals.openingWidth,
	#ClassicReference230.planes,
	#ClassicReference230.segments,
	#ClassicReference230.vertices,
	#ClassicReference230.posts,
	SCALE
)
calibrationLabel.Visible = showDiagnostics
calibrationLabel.Parent = gui

local function makeButton(name, text, x, width, y)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(width, 30)
	button.Position = UDim2.fromOffset(x, y)
	button.BackgroundColor3 = Color3.fromRGB(35, 55, 70)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 13
	button.Text = text
	button.Visible = showDiagnostics
	button.Parent = gui
	return button
end
local resetButton = makeButton("ResetScenario", "Reiniciar", 14, 92, 212)
local kickSetupButton = makeButton("KickScenario", "Preparar patada", 112, 122, 212)
local wallSetupButton = makeButton("WallScenario", "Probar pared", 240, 102, 212)
local recordButton = makeButton("RecordingToggle", "Pausar registro", 348, 120, 212)
local headOnButton = makeButton("PairHeadOn", "Choque frontal", 14, 132, 248)
local obliqueButton = makeButton("PairOblique", "Choque oblicuo", 152, 132, 248)
local overlapButton = makeButton("PairOverlap", "Centros coincidentes", 290, 178, 248)
local crowdOverlapButton = makeButton("CrowdOverlap", "Trío solapado", 14, 132, 284)
local crowdApproachButton = makeButton("CrowdApproach", "Dos al balón", 152, 132, 284)
local fastCrossingButton = makeButton("FastCrossing", "Cruce rápido", 290, 132, 284)
local fastBallButton = makeButton("FastBall", "Jugador-balón rápido", 14, 142, 320)
local speedRunButton = makeButton("SpeedRun", "Velocidad constante", 14, 152, 356)
local regressionButton = makeButton("RegressionSuite", "Ejecutar pruebas", 174, 160, 356)
local fastDiagonalButton = makeButton("FastDiagonal", "Diagonal rápida", 162, 132, 320)
local multiWallButton = makeButton("MultiWall", "Rebotes múltiples", 300, 160, 320)
local goalTestButton = makeButton("GoalTest", "Tiro a gol", 14, 120, 392)
local latencyButtons = {}
for index, delayMs in ipairs({ 0, 50, 100, 150, 200, 300, 500 }) do
	latencyButtons[delayMs] = makeButton(
		"InputDelay" .. delayMs,
		delayMs == 0 and "Delay 0" or (tostring(delayMs) .. " ms"),
		14 + (index - 1) * 70,
		66,
		428
	)
end
resetButton.Activated:Connect(function()
	commandRemote:FireServer("reset")
end)
kickSetupButton.Activated:Connect(function()
	commandRemote:FireServer("setupKick")
end)
wallSetupButton.Activated:Connect(function()
	commandRemote:FireServer("setupWall")
end)
recordButton.Activated:Connect(function()
	commandRemote:FireServer("toggleRecording")
end)
headOnButton.Activated:Connect(function()
	commandRemote:FireServer("setupPairHeadOn")
end)
obliqueButton.Activated:Connect(function()
	commandRemote:FireServer("setupPairOblique")
end)
overlapButton.Activated:Connect(function()
	commandRemote:FireServer("setupPairOverlap")
end)
crowdOverlapButton.Activated:Connect(function()
	commandRemote:FireServer("setupCrowdOverlap")
end)
crowdApproachButton.Activated:Connect(function()
	commandRemote:FireServer("setupCrowdApproach")
end)
fastCrossingButton.Activated:Connect(function()
	commandRemote:FireServer("setupPairFastCrossing")
end)
fastBallButton.Activated:Connect(function()
	commandRemote:FireServer("setupBallFastCrossing")
end)
speedRunButton.Activated:Connect(function()
	commandRemote:FireServer("setupSpeedRun")
end)
regressionButton.Activated:Connect(function()
	commandRemote:FireServer("runRegressionSuite")
end)
fastDiagonalButton.Activated:Connect(function()
	commandRemote:FireServer("setupBallFastDiagonal")
end)
multiWallButton.Activated:Connect(function()
	commandRemote:FireServer("setupMultiWall")
end)
goalTestButton.Activated:Connect(function()
	commandRemote:FireServer("setupGoalTest")
end)

local snapshotAge = 0
local lastSentX, lastSentY, lastSentKick = 0, 0, false
local syntheticInputDelayMs = 0
local delayedInputQueue = {}
local function setSyntheticInputDelay(delayMs)
	syntheticInputDelayMs = delayMs
	table.clear(delayedInputQueue)
	lastSentX, lastSentY, lastSentKick = nil, nil, nil
	for value, button in pairs(latencyButtons) do
		button.BackgroundColor3 = value == delayMs and Color3.fromRGB(130, 95, 30) or Color3.fromRGB(35, 55, 70)
	end
end
for delayMs, button in pairs(latencyButtons) do
	button.Activated:Connect(function()
		setSyntheticInputDelay(delayMs)
	end)
end
local function readAction(action, fallback)
	local ok, value = pcall(function()
		return action:GetState()
	end)
	if not ok then
		return fallback
	end
	if typeof(value) == "Vector2" or typeof(value) == "boolean" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return fallback
end
local function acceptSnapshot(s)
	if
		latest
		and (
			s.matchId < latest.matchId
			or s.matchId == latest.matchId
				and (s.round < latest.round or s.round == latest.round and s.tick < latest.tick)
		)
	then
		return false
	end
	local reset = latest and (s.matchId ~= latest.matchId or s.round ~= latest.round or s.tick < latest.tick)
	if reset or not latest then
		table.clear(delayedInputQueue)
		lastSentX, lastSentY, lastSentKick = nil, nil, nil
	end
	local unique = not latest or reset or s.tick > latest.tick
	latest = s
	if unique then
		snapshotAge = 0
		lastAuthorityAt = os.clock()
		presentation:push(s, lastAuthorityAt)
	end
	local slot
	for i, d in ipairs(s.players or {}) do
		if d.ownerUserId == player.UserId then
			slot = i
			break
		end
	end
	if s.coreMode and slot then
		if ownSlot == slot and netInput.matchId == s.matchId and netInput.round == s.round then
			confirmInputs(s.players[slot].ack or 0)
		end
		if reset or s.resync or ownSlot ~= slot or netInput.matchId ~= s.matchId or netInput.round ~= s.round then
			table.clear(delayedInputQueue)
			resetInputs(s.matchId, s.round, s.players[slot].ack or 0)
		end
		if unique or ownSlot ~= slot then
			prediction:restore(s, slot)
			if prediction.correctionSample then
				networkMetrics:add("playerCorrection", prediction.correction)
				networkMetrics:add("ballCorrection", prediction.ballCorrection)
				if prediction.correction > 0.01 then
					networkMetrics:count("playerCorrections")
				end
				if prediction.ballCorrection > 0.01 then
					networkMetrics:count("ballCorrections")
				end
			end
		end
	elseif netInput.matchId then
		table.clear(delayedInputQueue)
		resetInputs(nil, nil, 0)
	end
	ownSlot = slot
	return true
end
snapshotRemote.OnClientEvent:Connect(function(s)
	networkMetrics:count("fullSnapshotPackets")
	-- Bootstrap carries ownership/static configuration; dynamic packets carry no diagnostics.
	if not latest or s.matchId > latest.matchId or s.matchId == latest.matchId and s.round >= latest.round then
		bootstrap = s
	end
	if
		s.resync
		and latest
		and s.matchId == latest.matchId
		and s.round == latest.round
		and s.tick < latest.tick
		and ownSlot
	then
		resetInputs(s.matchId, s.round, math.max(s.players[ownSlot].ack or 0, latest.players[ownSlot].ack or 0))
	end
	acceptSnapshot(s)
end)
stateStream.OnClientEvent:Connect(function(b)
	networkMetrics:count("statePackets")
	if typeof(b) == "buffer" then
		networkMetrics:count("stateBytes", buffer.len(b))
	end
	local s = NetCodec.decodeState(b, bootstrap)
	if s and (not latest or s.matchId ~= latest.matchId or s.round ~= latest.round or s.tick > latest.tick) then
		if not acceptSnapshot(s) then
			networkMetrics:count("rejectedStates")
		end
	else
		networkMetrics:count("rejectedStates")
	end
end)
controlRemote.OnClientEvent:Connect(function(kind, nonce)
	if kind == "pong" and pingTimes[nonce] then
		local sample = math.max(0, os.clock() - pingTimes[nonce])
		pingTimes[nonce] = nil
		networkMetrics:add("rttMs", sample * 1000)
		rtt = rtt == 0 and sample or rtt * 0.8 + sample * 0.2
	end
end)
controlRemote:FireServer("ready")

local function sendCoreInput(move, kick, now)
	local mask = NetCodec.mask(move.X, move.Y, kick)
	local tick = latest.tick + math.floor(math.max(0, now - lastAuthorityAt) * 60)
	local command = netInput:sample(mask, tick, now)
	if command then
		networkMetrics:count("queuedInputs")
	end
	local b, reliable = netInput:packet(now)
	if b then
		if syntheticInputDelayMs <= 0 then
			sendWire(b, reliable)
		else
			table.insert(
				delayedInputQueue,
				{ due = now + syntheticInputDelayMs / 1000, wire = b, reliable = reliable }
			)
		end
	end
	return command
end

local function onKickEdge(kick)
	if not (latest and latest.coreMode and ownSlot) then
		return
	end
	local move = readAction(moveAction, Vector2.zero)
	if typeof(move) ~= "Vector2" then
		move = Vector2.zero
	end
	local command = sendCoreInput(move, kick, os.clock())
	if command then
		prediction:recordKickEdge(command.mask)
	end
end

kickAction.Pressed:Connect(function()
	onKickEdge(true)
end)
kickAction.Released:Connect(function()
	onKickEdge(false)
end)

RunService.RenderStepped:Connect(function(dt)
	local move = readAction(moveAction, Vector2.zero)
	if typeof(move) ~= "Vector2" then
		move = Vector2.zero
	end
	local kick = readAction(kickAction, false) == true
	local now = os.clock()
	snapshotAge = latest and math.max(0, now - lastAuthorityAt) or 0
	if now >= nextPingAt then
		nextPingAt = now + 1
		if not latest or now - lastAuthorityAt > 1 then
			controlRemote:FireServer("ready")
		else
			pingNonce = (pingNonce + 1) % 4294967296
			-- Keep late replies measurable across subsequent probes; retain at most eight.
			pingTimes[(pingNonce - 8) % 4294967296] = nil
			pingTimes[pingNonce] = now
			controlRemote:FireServer("ping", pingNonce)
		end
	end
	if latest and latest.coreMode and ownSlot then
		sendCoreInput(move, kick, now)
	elseif latest and not latest.coreMode then
		if move.X ~= lastSentX or move.Y ~= lastSentY or kick ~= lastSentKick then
			lastSentX, lastSentY, lastSentKick = move.X, move.Y, kick
			inputRemote:FireServer(move.X, move.Y, kick)
		end
	end
	while delayedInputQueue[1] and delayedInputQueue[1].due <= now do
		local queued = table.remove(delayedInputQueue, 1)
		sendWire(queued.wire, queued.reliable)
	end
	if not latest then
		return
	end

	local poses, status = presentation:sample(now)
	if now >= nextMetricsAt then
		nextMetricsAt = now + 0.05
		networkMetrics:add("snapshotAgeMs", snapshotAge * 1000)
		if status then
			networkMetrics:add("renderLagMs", status.renderLagMs)
			networkMetrics:add("adaptiveDelayMs", status.delayMs)
		end
	end
	if showDiagnostics and now >= nextHudAt then
		nextHudAt = now + 1
		local report = networkMetrics:report()
		predictionLabel.Text = string.format(
			"NET v2 | RTT %.0f ms | state age %.0f ms\nACK p95 %s ms | pending %d | buffer %.0f ms\nCorrection p95 %s units | input delay %d ms",
			rtt * 1000,
			snapshotAge * 1000,
			report.samples.ackMs.p95 and string.format("%.0f", report.samples.ackMs.p95) or "--",
			#netInput.pending,
			status and status.delayMs or 0,
			report.samples.playerCorrection.p95 and string.format("%.3f", report.samples.playerCorrection.p95) or "--",
			syntheticInputDelayMs
		)
	end
	local extraDiscMode = latest.pairMode or latest.crowdMode
	local playerActors = {}
	if latest.coreMode and latest.players and #latest.players > 0 then
		for slot, disc in ipairs(latest.players) do
			-- The server reserves ten physics discs, but only owned slots are real
			-- lobby players. Keep explicit pair/crowd regression actors visible.
			local regressionActor = latest.pairMode and (slot == 1 or slot == 6)
				or latest.crowdMode and slot <= 3
			local occupied = disc.ownerUserId ~= nil or regressionActor == true
			if occupied then
				local remotePose = poses.players[slot] or disc
				local px, py = remotePose.x, remotePose.y
				if predictedActor and slot == ownSlot then
					px, py = predictedActor.x, predictedActor.y
				end
				playerActors[slot] = {
					id = slot,
					team = disc.team,
					userId = disc.ownerUserId,
					x = px,
					y = py,
					radius = disc.radius or 15,
					label = string.format("%02d", slot),
					visible = true,
				}
			end
		end
	else
		playerActors[1] = {
			id = 1, team = "red", x = poses.player.x, y = poses.player.y,
			radius = latest.player.radius or 15, label = "01", visible = true,
		}
		playerActors[2] = {
			id = 2, team = "blue", x = poses.player2.x, y = poses.player2.y,
			radius = latest.player2.radius or 15, label = "02", visible = extraDiscMode == true,
		}
	end

	local ballPose = predictedBall or poses.ball
	local debugLines
	if showDiagnostics then
		debugLines = {
			{
				a = poses.player,
				b = ballPose,
				color = latest.touchingBall and { 70, 255, 130 } or { 255, 220, 70 },
				visible = not latest.pairMode,
			},
			{
				a = poses.player,
				b = poses.player2,
				color = latest.touchingPlayers and { 70, 255, 130 } or { 80, 220, 255 },
				visible = extraDiscMode,
			},
			{
				a = poses.player2,
				b = ballPose,
				color = latest.touchingPlayer2Ball and { 70, 255, 130 } or { 255, 110, 90 },
				visible = latest.crowdMode,
			},
		}
	end

	local focus = playerActors[ownSlot or 1] or poses.player
	stadiumRenderer:render({
		players = playerActors,
		ball = {
			x = ballPose.x,
			y = ballPose.y,
			radius = latest.ball.radius or 10,
			visible = not latest.pairMode,
		},
		debugLines = debugLines,
	}, focus)
	local m = latest.metrics
	local lastTouchLine = latest.lastTouch
			and string.format(
				"Last: %s #%d (%s)",
				string.upper(latest.lastTouch.team),
				latest.lastTouch.playerId,
				latest.lastTouch.kind
			)
		or "Last: -"
	local p2Line = (latest.players and #latest.players > 0)
			and string.format(
				"Roster: %d | RED %d / BLUE %d | %s",
				latest.playerCount,
				latest.redCount,
				latest.blueCount,
				lastTouchLine
			)
		or (
			(latest.pairMode or latest.crowdMode)
				and string.format(
					"P2: (%.2f, %.2f) speed %.2f | %s",
					latest.player2.x,
					latest.player2.y,
					latest.player2.speed,
					lastTouchLine
				)
			or ("P2: inactive | " .. lastTouchLine)
		)
	local ballLine = latest.pairMode and "Ball: inactive in player-pair test"
		or string.format("Ball: (%.2f, %.2f) speed %.2f", latest.ball.x, latest.ball.y, latest.ball.speed)
	local contactLine = latest.crowdMode
			and string.format(
				"Separations P1-P2 %.2f | P1-ball %.2f | P2-ball %.2f",
				latest.playerSeparation,
				latest.separation,
				latest.player2BallSeparation
			)
		or (
			latest.pairMode
				and string.format("P1-P2: %.2f | contacts: %d", latest.playerSeparation, m.playerContacts)
			or string.format(
				"P1-ball: %.2f | contacts: %d | ball walls: %d",
				latest.separation,
				m.ballContacts,
				m.ballWallBounces
			)
		)
	local diagnosticsLine = latest.crowdMode
			and string.format(
				"3-disc test | peak overlap %.3f | residual %.4f/max %.4f | iter %d/%d",
				m.crowdContacts,
				m.crowdPeakPenetration,
				m.crowdLastResidualPenetration,
				m.crowdWorstResidualPenetration,
				m.crowdLastSolverIterations,
				m.crowdMaxSolverIterations
			)
		or string.format(
			"Max penetration %.3f | correction %.3f | impulse %.3f | substeps %d/%d | suite %s",
			m.maxPlayerPenetration,
			m.maxPlayerCorrection,
			m.lastPlayerImpulse,
			m.lastCollisionSubsteps,
			m.maxCollisionSubsteps,
			m.regressionRan and string.format("%d/%d", m.regressionPassed, m.regressionTotal) or "pendiente"
		)
	local matchStatus = latest.matchPhase == "goalPause" and string.format("GOAL PAUSE %d", latest.pauseTicksRemaining)
		or (
			latest.matchPhase == "kickoff"
				and string.format("KICKOFF %s %d", string.upper(latest.kickoffTeam or "-"), latest.pauseTicksRemaining)
			or (latest.kickoffTeam and ("WAIT KICK " .. string.upper(latest.kickoffTeam)) or "PLAYING")
		)
	if latest.matchPhase == "finished" then
		matchStatus = "FINISHED " .. string.upper(latest.winner or "-")
	end
	local matchLine = string.format("Score RED %d - %d BLUE | %s", latest.score.red, latest.score.blue, matchStatus)
	redScoreLabel.Text = string.format("RED  %d", latest.score.red)
	blueScoreLabel.Text = string.format("%d  BLUE", latest.score.blue)
	statusLabel.Text = string.upper(matchStatus)
	label.Text = string.format(
		"Haxball lab | WASD move | X kick\nTick: %d | t=%.2f s | %s\n%s\nKicks: %d attempts / %d accepted (last %d)\nP1: (%.2f, %.2f) speed %.2f\n%s\n%s\n%s\n%s\n%s | samples %d",
		latest.tick,
		latest.gameTime,
		latest.crowdMode and "THREE-DISC TEST"
			or (
				latest.pairMode and "PAIR TEST"
				or (
					latest.coreMode and ("CORE v1 | owner " .. tostring(latest.ownerUserId or "-"))
					or (latest.legacyMode and "LEGACY CCD TEST" or ("owner " .. tostring(latest.ownerUserId or "-")))
				)
			),
		matchLine,
		m.kickAttempts,
		m.successfulKicks,
		m.lastKickSuccessTick,
		latest.player.x,
		latest.player.y,
		latest.player.speed,
		p2Line,
		ballLine,
		contactLine,
		diagnosticsLine,
		latest.recording and "recording" or "paused",
		latest.historySamples or 0
	)
	if not showDiagnostics then
		label.Text = matchLine .. "\nWASD: mover | X: patear"
	end
	recordButton.Text = latest.recording and "Pausar registro" or "Reanudar registro"
end)


