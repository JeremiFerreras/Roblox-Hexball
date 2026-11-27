local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
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
local field = workspace:WaitForChild("HaxballLab")
local playerDisc = field:WaitForChild("PlayerDisc")
local playerDisc2 = field:WaitForChild("PlayerDisc2")
local ballDisc = field:WaitForChild("BallDisc")
playerDisc.Color = Color3.fromRGB(229, 105, 98)
playerDisc2.Color = Color3.fromRGB(75, 130, 224)
playerDisc.Material = Enum.Material.SmoothPlastic
playerDisc2.Material = Enum.Material.SmoothPlastic
local debugLine = field:WaitForChild("DebugLine")
local pairDebugLine = field:WaitForChild("PairDebugLine")
local ballP2DebugLine = field:WaitForChild("BallP2DebugLine")

local playerVisuals = { [1] = playerDisc, [2] = playerDisc2 }
for playerId = 3, 10 do
	local visual = Instance.new("Part")
	visual.Name = "PlayerDisc" .. playerId
	visual.Shape = Enum.PartType.Ball
	visual.Size = playerDisc.Size
	visual.Anchored = true
	visual.CanCollide = false
	visual.CanTouch = false
	visual.CanQuery = false
	visual.CastShadow = false
	visual.Material = Enum.Material.SmoothPlastic
	visual.Color = playerId % 2 == 1 and Color3.fromRGB(229, 105, 98) or Color3.fromRGB(75, 130, 224)
	visual.Parent = field
	playerVisuals[playerId] = visual
end
local playerRims, playerAccents = {}, {}
local DISC_SCALE = StadiumProfile2D.Presentation.studsPerUnit
for playerId = 1, 10 do
	local rim = Instance.new("Part")
	rim.Name = "PlayerRim" .. playerId
	rim.Shape = Enum.PartType.Ball
	rim.Size = Vector3.new(18, 2.6, 18)
	rim.Anchored = true
	rim.CanCollide = false
	rim.CanTouch = false
	rim.CanQuery = false
	rim.CastShadow = false
	rim.Material = Enum.Material.SmoothPlastic
	rim.Transparency = 1
	rim.Parent = field
	playerRims[playerId] = rim
	playerAccents[playerId] = {}
end
local function updatePlayerRim(playerId, position, radius, team)
	local rim = playerRims[playerId]
	if not rim then return end
	local diameter = (radius * 2 + 1.8) * DISC_SCALE
	rim.Size = Vector3.new(diameter, math.max(1.25, diameter * 0.22), diameter)
	rim.CFrame = CFrame.new(position.X, position.Y - 0.3, position.Z)
	rim.Color = team == "red" and Color3.fromRGB(157, 67, 64) or Color3.fromRGB(48, 87, 157)
	rim.Transparency = 0
end
local function hidePlayerAccents(playerId)
	for _, accent in ipairs(playerAccents[playerId] or {}) do accent.Transparency = 1 end
end

local function newBallCosmetic(name, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(67, 84, 61)
	part.Parent = field
	return part
end
local ballTrim = newBallCosmetic("BallVisualTrim", Enum.PartType.Cylinder)
ballTrim.Shape = Enum.PartType.Ball
ballTrim.Transparency = 1
local function updateBallDesign(position, radius, visible)
	local worldRadius = radius * DISC_SCALE
	local diameter = worldRadius * 2
	ballTrim.Size = Vector3.new(diameter + 0.45, 1.7, diameter + 0.45)
	ballTrim.CFrame = CFrame.new(position.X, position.Y - 0.36, position.Z)
	ballTrim.Transparency = visible and 0.5 or 1
end
local predictionGhost = Instance.new("Part")
predictionGhost.Name = "PredictionGhost"
predictionGhost.Shape = Enum.PartType.Cylinder
predictionGhost.Size = playerDisc.Size
predictionGhost.Anchored = true
predictionGhost.CanCollide = false
predictionGhost.CanTouch = false
predictionGhost.CanQuery = false
predictionGhost.CastShadow = false
predictionGhost.Material = Enum.Material.Neon
predictionGhost.Color = Color3.fromRGB(255, 220, 70)
predictionGhost.Transparency = 1
predictionGhost.Parent = field

local ClassicReference230 = require(lab:WaitForChild("ClassicReference230"))
local StadiumRender2D = require(lab:WaitForChild("StadiumRender2D"))
local StadiumVisualBuilder = require(lab:WaitForChild("VisualStadiumBuilder"))
local visualStadium = StadiumVisualBuilder.build(field, StadiumProfile2D, ClassicReference230, StadiumRender2D)
local Presentation = StadiumProfile2D.Presentation
local SCALE = Presentation.studsPerUnit
local function toWorld(logicalX, logicalY)
	local p = StadiumRender2D.toWorld(logicalX, logicalY, Presentation)
	return Vector3.new(p.x, p.y, p.z)
end
local function drawDisc(part, position, radius)
	local diameter = 2 * radius * SCALE
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(diameter, math.max(1.35, diameter * 0.2), diameter)
	part.CFrame = CFrame.new(position)
end
-- Draw the same segment/arc/post coordinates used by the discrete solver.
local geometryFolder = Instance.new("Folder")
geometryFolder.Name = "ClassicPhysicalOutline"
geometryFolder.Parent = field
local geometryVisuals = {}
local function visualPart(name)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Color = Color3.fromRGB(220, 230, 235)
	part.Parent = geometryFolder
	return part
end
for _, segment in ipairs(ClassicReference230.segments) do
	local points = StadiumRender2D.segmentPoints(segment)
	for i = 1, #points - 1 do
		local a, b = toWorld(points[i].x, points[i].y), toWorld(points[i + 1].x, points[i + 1].y)
		local part = visualPart(segment.id .. ":" .. i)
		part.Size = Vector3.new(0.18, 0.18, (b - a).Magnitude)
		part.CFrame = CFrame.lookAt((a + b) * 0.5, b)
		table.insert(geometryVisuals, { part = part, group = segment.collisionGroup })
	end
end
for _, logicalY in ipairs({ -170, 170 }) do
	local a, b = toWorld(-370, logicalY), toWorld(370, logicalY)
	local part = visualPart("BallAreaLine" .. logicalY)
	part.Size = Vector3.new(0.18, 0.18, (b - a).Magnitude)
	part.CFrame = CFrame.lookAt((a + b) * 0.5, b)
	table.insert(geometryVisuals, { part = part, group = 32 })
end
for _, post in ipairs(ClassicReference230.posts) do
	local part = visualPart(post.id)
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(post.radius * 2 * SCALE, post.radius * 2 * SCALE, post.radius * 2 * SCALE)
	part.Position = toWorld(post.x, post.y)
	table.insert(geometryVisuals, { part = part, group = 32 })
end
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 35
local viewportWidth, viewportHeight
local function fitCamera()
	local viewport = camera.ViewportSize
	local width, height = viewport and viewport.X or 0, viewport and viewport.Y or 0
	if width ~= viewportWidth or height ~= viewportHeight then
		viewportWidth, viewportHeight = width, height
		local y = StadiumRender2D.cameraHeight(Presentation, StadiumProfile2D.Bounds, camera.FieldOfView, width, height)
		camera.CFrame = CFrame.new(Presentation.worldOrigin.x, y, Presentation.worldOrigin.z)
			* CFrame.Angles(-math.pi / 2, 0, 0)
	end
end
fitCamera()

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

local function renderLine(part, a, b, color, visible)
	local delta = b - a
	local length = delta.Magnitude
	part.Transparency = visible and 0.2 or 1
	if visible and length > 0.05 then
		part.Size = Vector3.new(0.18, 0.18, length)
		part.CFrame = CFrame.lookAt((a + b) * 0.5, b)
		part.Color = color
	end
end

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
	fitCamera()
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

	predictionGhost.Transparency = 1
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
	local p1 = toWorld(poses.player.x, poses.player.y)
	local p2 = toWorld(poses.player2.x, poses.player2.y)
	local ball = toWorld(poses.ball.x, poses.ball.y)
	local predictedActor, predictedBall
	-- advance() clamps at confirmedTick + 18. Keep that final forecast during a
	-- stalled stream instead of jumping back to an older authoritative pose.
	if latest.coreMode and ownSlot and latest.matchPhase == "playing" then
		local target = latest.tick + math.min(18, 1 + math.ceil(rtt * 30) + math.floor(snapshotAge * 60))
		predictedActor, predictedBall = prediction:advance(target, NetCodec.mask(move.X, move.Y, kick))
		if predictedBall then
			predictedActor, predictedBall = prediction:visual(predictedActor, predictedBall, dt)
			ball = toWorld(predictedBall.x, predictedBall.y)
		end
	end
	drawDisc(ballDisc, ball, latest.ball.radius or 10)
	drawDisc(playerDisc, p1, latest.player.radius or 15)
	drawDisc(playerDisc2, p2, latest.player2.radius or 15)
	updatePlayerRim(1, p1, latest.player.radius or 15, "red")
	updatePlayerRim(2, p2, latest.player2.radius or 15, "blue")
	local extraDiscMode = latest.pairMode or latest.crowdMode
	if latest.players and #latest.players > 0 then
		for slot, disc in ipairs(latest.players) do
			local remotePose = poses.players[slot] or disc
			local px, py = remotePose.x, remotePose.y
			local visual = playerVisuals[slot]
			if visual then
				if predictedActor and slot == ownSlot then
					px, py = predictedActor.x, predictedActor.y
				end
				drawDisc(visual, toWorld(px, py), disc.radius or 15)
				visual.Transparency = 0
				visual.Color = disc.team == "red" and Color3.fromRGB(229, 105, 98) or Color3.fromRGB(75, 130, 224)
				updatePlayerRim(slot, toWorld(px, py), disc.radius or 15, disc.team)
			end
		end
		for slot = #latest.players + 1, #playerVisuals do
			if playerVisuals[slot] then
				playerVisuals[slot].Transparency = 1
			end
			if playerRims[slot] then playerRims[slot].Transparency = 1 end
			hidePlayerAccents(slot)
		end
	else
		for slot = 2, #playerVisuals do
			if playerVisuals[slot] then
				playerVisuals[slot].Transparency = slot == 2 and (extraDiscMode and 0 or 1) or 1
			end
			if playerRims[slot] then playerRims[slot].Transparency = slot == 2 and extraDiscMode and 0 or 1 end
			if not (slot == 2 and extraDiscMode) then hidePlayerAccents(slot) end
		end
	end
	local ballVisible = not latest.pairMode
	ballDisc.Transparency = ballVisible and 0 or 1
	ballDisc.Color = Color3.fromRGB(242, 243, 232)
	updateBallDesign(ball, latest.ball.radius or 10, ballVisible)
	if showDiagnostics then
		renderLine(
			debugLine,
			p1,
			ball,
			latest.touchingBall and Color3.fromRGB(70, 255, 130) or Color3.fromRGB(255, 220, 70),
			not latest.pairMode
		)
		renderLine(
			pairDebugLine,
			p1,
			p2,
			latest.touchingPlayers and Color3.fromRGB(70, 255, 130) or Color3.fromRGB(80, 220, 255),
			extraDiscMode
		)
		renderLine(
			ballP2DebugLine,
			p2,
			ball,
			latest.touchingPlayer2Ball and Color3.fromRGB(70, 255, 130) or Color3.fromRGB(255, 110, 90),
			latest.crowdMode
		)
	else
		debugLine.Transparency = 1
		pairDebugLine.Transparency = 1
		ballP2DebugLine.Transparency = 1
	end

	for _, visual in ipairs(geometryVisuals) do
		local visible = latest.coreMode
			and (
				visual.group == 32
				or latest.kickoffTeam and bit32.band(visual.group, latest.kickoffTeam == "red" and 8 or 16) ~= 0
			)
		visual.part.Transparency = showDiagnostics and visible and 0 or 1
	end
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
				"3D %d contacts | peak overlap %.3f | residual %.4f/max %.4f | iter %d/%d",
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


