local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local lab = ReplicatedStorage:WaitForChild("SimpleSoccerGame", 20)
if not lab then
    error("Simple Soccer: ReplicatedStorage.SimpleSoccerGame did not replicate")
end
local function setBootStage(stage, detail, bootError)
    lab:SetAttribute("ClientBootStage", stage)
    if detail then lab:SetAttribute("ClientBootDetail", detail) end
    if bootError then lab:SetAttribute("ClientBootError", tostring(bootError)) end
end
local remotes = lab:WaitForChild("Remotes", 20)
if not remotes then
    setBootStage("ERROR", "No se encontraron los canales de red", "Remotes no replicados")
    error("Simple Soccer: Remotes folder did not replicate")
end
local function requireRemote(name, className)
    local remote = remotes:WaitForChild(name, 20)
    if not remote or not remote:IsA(className) then
        local message = string.format("Remote %s missing or expected %s", name, className)
        setBootStage("ERROR", "No se pudo preparar la conexión", message)
        error("Simple Soccer: " .. message)
    end
    return remote
end
local inputRemote = requireRemote("Input", "RemoteEvent")
local snapshotRemote = requireRemote("Snapshot", "RemoteEvent")
local commandRemote = requireRemote("DebugCommand", "RemoteEvent")
local inputStream = requireRemote("InputStream", "UnreliableRemoteEvent")
local stateStream = requireRemote("StateStream", "UnreliableRemoteEvent")
local controlRemote = requireRemote("Control", "RemoteEvent")
local processSnapshot = nil
local processStatePacket = nil
local processControlEvent = nil
local earlySnapshots = {}
local earlyStatePackets = {}
local earlyControlEvents = {}

local function retainEarly(queue, payload, limit)
    queue[#queue + 1] = payload
    if #queue > limit then
        table.remove(queue, 1)
    end
end

-- Register the listeners before requiring any gameplay module or waiting for input assets.
-- The ReplicatedStorage input-context name is resolved later; incoming state is buffered meanwhile.
snapshotRemote.OnClientEvent:Connect(function(snapshot)
    if processSnapshot then
        processSnapshot(snapshot)
    else
        retainEarly(earlySnapshots, snapshot, 4)
    end
end)
stateStream.OnClientEvent:Connect(function(packet)
    if processStatePacket then
        processStatePacket(packet)
    else
        retainEarly(earlyStatePackets, packet, 8)
    end
end)
controlRemote.OnClientEvent:Connect(function(kind, nonce)
    if processControlEvent then
        processControlEvent(kind, nonce)
    else
        retainEarly(earlyControlEvents, { kind = kind, nonce = nonce }, 8)
    end
end)

setBootStage("LOADING_MODULES", "Módulos locales: física 2D, reglas 4v4, predicción y red")
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
local StadiumProfile2D = require(lab:WaitForChild("StadiumReference2D"))
local inputFolder = ReplicatedStorage:WaitForChild("Inputs", 20)
local inputContext = inputFolder and inputFolder:WaitForChild("SimpleSoccerControls", 20)
if not inputContext then
    setBootStage("ERROR", "No se encontraron los controles", "Inputs.SimpleSoccerControls no está disponible")
    error("Simple Soccer: ReplicatedStorage.Inputs.SimpleSoccerControls did not replicate")
end
local moveAction = inputContext:WaitForChild("Move", 10)
local kickAction = inputContext:WaitForChild("Kick", 10)
if not moveAction or not kickAction then
    setBootStage("ERROR", "Faltan acciones de control", "Se requieren Move y Kick")
    error("Simple Soccer: Move/Kick input actions did not replicate")
end
local ClassicReference230 = require(lab:WaitForChild("ClassicReference230"))
local stadiumRenderer = nil
local menuRenderer = nil
local menuGui = nil
local previewReplay = nil
local previewStartedAt = 0
local menuOpen = false
local joinPending = false
local joinRequestedAt = 0
local playButton = nil
local menuStatusLabel = nil
local matchHud = nil
local firstRenderReady = false

local showDiagnostics = lab:GetAttribute("EnableSimpleSoccerDiagnostics") == true
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleSoccerDebug"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
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
label.Text = "Simple Soccer diagnostics | opt-in"
label.Visible = showDiagnostics
label.Parent = gui

matchHud = Instance.new("ScreenGui")
matchHud.Name = "SimpleSoccerHUD"
matchHud.ResetOnSpawn = false
matchHud.IgnoreGuiInset = true
matchHud.DisplayOrder = 20
matchHud.Parent = player:WaitForChild("PlayerGui")
matchHud.Enabled = false
local hudPanel = Instance.new("Frame")
hudPanel.Name = "ScorePanel"
hudPanel.AnchorPoint = Vector2.new(0.5, 0)
hudPanel.Position = UDim2.new(0.5, 0, 0, 14)
hudPanel.Size = UDim2.fromOffset(350, 62)
hudPanel.BackgroundColor3 = Color3.fromRGB(36, 57, 43)
hudPanel.BackgroundTransparency = 0.10
hudPanel.BorderSizePixel = 0
hudPanel.Parent = matchHud
local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hudPanel
local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(157, 181, 139)
hudStroke.Transparency = 0.58
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
local redScoreLabel = makeHudLabel("RedScore", "RED  0", UDim2.fromOffset(12, 5), UDim2.fromOffset(112, 34), Color3.fromRGB(213, 139, 128), 19)
local scoreDivider = makeHudLabel("ScoreDivider", ":", UDim2.fromOffset(161, 5), UDim2.fromOffset(28, 34), Color3.fromRGB(220, 226, 207), 21)
local blueScoreLabel = makeHudLabel("BlueScore", "0  BLUE", UDim2.fromOffset(226, 5), UDim2.fromOffset(112, 34), Color3.fromRGB(143, 172, 210), 19)
local statusLabel = makeHudLabel("MatchStatus", "PREPARANDO PARTIDA", UDim2.fromOffset(10, 37), UDim2.new(1, -20, 0, 19), Color3.fromRGB(196, 211, 181), 11, Enum.Font.GothamMedium)
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
-- Client-local console: PlayerGui.SimpleSoccerDebug.NetworkDiagnostics:Invoke().
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
local studsPerUnit = StadiumProfile2D.Presentation.studsPerUnit
calibrationLabel.Text = string.format(
	"CLASSIC | physics/presentation reference independent classic-game reference\nLogical %dx%d | goal opening %d | geometry %dP/%dS/%dV/%d posts\nVisual %.2f studs/unit | independent reference; official comparison pending",
	bounds.spanWidth,
	bounds.spanHeight,
	goals.openingWidth,
	#ClassicReference230.planes,
	#ClassicReference230.segments,
	#ClassicReference230.vertices,
	#ClassicReference230.posts,
	studsPerUnit
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
local hasReceivedSnapshot = false
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
    if not hasReceivedSnapshot then
        hasReceivedSnapshot = true
        setBootStage("SYNCHRONIZING", "Estado inicial recibido; sincronizando jugadores y balón")
    end
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
processSnapshot = function(s)
    networkMetrics:count("fullSnapshotPackets")
    -- Bootstrap carries ownership/static configuration; dynamic packets carry no diagnostics.
    if not latest or s.matchId > latest.matchId or s.matchId == latest.matchId and s.round >= latest.round then
        bootstrap = s
    end
    if s.resync and latest and s.matchId == latest.matchId and s.round == latest.round
        and s.tick < latest.tick and ownSlot then
        resetInputs(s.matchId, s.round, math.max(s.players[ownSlot].ack or 0, latest.players[ownSlot].ack or 0))
    end
    acceptSnapshot(s)
end

processStatePacket = function(b)
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
end

processControlEvent = function(kind, nonce)
    if kind == "pong" and pingTimes[nonce] then
        local sample = math.max(0, os.clock() - pingTimes[nonce])
        pingTimes[nonce] = nil
        networkMetrics:add("rttMs", sample * 1000)
        rtt = rtt == 0 and sample or rtt * 0.8 + sample * 0.2
    elseif kind == "joined" then
        if menuStatusLabel then
            menuStatusLabel.Text = "ENTRANDO A LA CANCHA..."
        end
    elseif kind == "full" then
        joinPending = false
        if playButton then
            playButton.Active = true
            playButton.Text = "REINTENTAR"
        end
        if menuStatusLabel then
            menuStatusLabel.Text = "NO HAY PLAZAS DISPONIBLES EN ESTE MOMENTO"
        end
    end
end

-- Replay reliable bootstrap snapshots first, then the most recent unreliable packets.
for _, snapshot in ipairs(earlySnapshots) do
    processSnapshot(snapshot)
end
table.clear(earlySnapshots)
for _, packet in ipairs(earlyStatePackets) do
    processStatePacket(packet)
end
table.clear(earlyStatePackets)
for _, event in ipairs(earlyControlEvents) do
    processControlEvent(event.kind, event.nonce)
end
table.clear(earlyControlEvents)

-- The menu and live match use the same generated Classic stadium scene and GUI renderer.
setBootStage("BUILDING_PITCH", "Preparando cancha, simulación local y menú 4v4")
local GuiStadiumScene = require(lab:WaitForChild("GuiStadiumScene"))
local GuiStadiumRenderer = require(lab:WaitForChild("GuiStadiumRenderer"))
local PhysicsCore2D = require(lab:WaitForChild("PhysicsCore2D"))
local MenuPreview = require(lab:WaitForChild("MenuPreview"))
local stadiumScene = GuiStadiumScene.build(StadiumProfile2D, ClassicReference230)
local visualOk, visualError = pcall(function()
    -- Optional presentation leftover: the GUI pitch must never depend on a 3D model.
    local legacyField = workspace:FindFirstChild("SimpleSoccerGame")
    stadiumRenderer = GuiStadiumRenderer.new(player:WaitForChild("PlayerGui"), stadiumScene, nil, legacyField, GuiStadiumScene)
end)
if not visualOk then
    setBootStage("VISUAL_ERROR", "No se pudo construir la cancha", tostring(visualError))
    warn("Simple Soccer GUI initialization failed: " .. tostring(visualError))
else
    -- The full-screen live renderer stays hidden until the player actually joins.
    if stadiumRenderer.gui then
        stadiumRenderer.gui.Enabled = false
    end
    local playerGui = player:WaitForChild("PlayerGui")
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "SimpleSoccerMainMenu"
    menuGui.ResetOnSpawn = false
    menuGui.IgnoreGuiInset = true
    menuGui.DisplayOrder = 15
    menuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuGui.Parent = playerGui

    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(22, 34, 27)
    backdrop.BorderSizePixel = 0
    backdrop.Parent = menuGui
    local backdropGradient = Instance.new("UIGradient")
    backdropGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 31, 25)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(31, 49, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 29, 24)),
    })
    backdropGradient.Rotation = 12
    backdropGradient.Parent = backdrop

    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "MenuPanel"
    leftPanel.Size = UDim2.fromScale(0.365, 1)
    leftPanel.BackgroundColor3 = Color3.fromRGB(17, 28, 22)
    leftPanel.BackgroundTransparency = 0.08
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = backdrop
    local panelGradient = Instance.new("UIGradient")
    panelGradient.Color = ColorSequence.new(Color3.fromRGB(16, 27, 21), Color3.fromRGB(31, 47, 34))
    panelGradient.Rotation = 90
    panelGradient.Parent = leftPanel

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.AnchorPoint = Vector2.new(1, 0)
    accent.Position = UDim2.fromScale(1, 0)
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(148, 190, 111)
    accent.BorderSizePixel = 0
    accent.Parent = leftPanel

    local eyebrow = Instance.new("TextLabel")
    eyebrow.Name = "Eyebrow"
    eyebrow.AnchorPoint = Vector2.new(0.5, 0)
    eyebrow.Position = UDim2.fromScale(0.5, 0.205)
    eyebrow.Size = UDim2.fromScale(0.82, 0.035)
    eyebrow.BackgroundTransparency = 1
    eyebrow.Text = "FÚTBOL 2D  /  4 CONTRA 4"
    eyebrow.TextColor3 = Color3.fromRGB(157, 190, 132)
    eyebrow.Font = Enum.Font.GothamBold
    eyebrow.TextSize = 12
    eyebrow.TextXAlignment = Enum.TextXAlignment.Center
    eyebrow.Parent = leftPanel

    local title = Instance.new("TextLabel")
    title.Name = "GameTitle"
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.fromScale(0.5, 0.255)
    title.Size = UDim2.fromScale(0.86, 0.16)
    title.BackgroundTransparency = 1
    title.Text = "SIMPLE\nSOCCER GAME"
    title.TextColor3 = Color3.fromRGB(239, 241, 222)
    title.Font = Enum.Font.GothamBlack
    title.TextScaled = true
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = leftPanel
    local titleConstraint = Instance.new("UITextSizeConstraint")
    titleConstraint.MinTextSize = 28
    titleConstraint.MaxTextSize = 58
    titleConstraint.Parent = title

    local divider = Instance.new("Frame")
    divider.AnchorPoint = Vector2.new(0.5, 0)
    divider.Position = UDim2.fromScale(0.5, 0.435)
    divider.Size = UDim2.fromScale(0.22, 0)
    divider.Size = UDim2.new(0.22, 0, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(143, 184, 106)
    divider.BorderSizePixel = 0
    divider.Parent = leftPanel

    playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.AnchorPoint = Vector2.new(0.5, 0)
    playButton.Position = UDim2.fromScale(0.5, 0.49)
    playButton.Size = UDim2.new(0.72, 0, 0, 62)
    playButton.BackgroundColor3 = Color3.fromRGB(144, 184, 105)
    playButton.BorderSizePixel = 0
    playButton.AutoButtonColor = false
    playButton.Active = true
    playButton.Selectable = true
    playButton.Text = "Jugar"
    playButton.TextColor3 = Color3.fromRGB(21, 34, 25)
    playButton.Font = Enum.Font.GothamBold
    playButton.TextSize = 21
    playButton.Parent = leftPanel
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 13)
    buttonCorner.Parent = playButton
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(209, 226, 183)
    buttonStroke.Transparency = 0.38
    buttonStroke.Thickness = 1.2
    buttonStroke.Parent = playButton
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new(Color3.fromRGB(170, 205, 126), Color3.fromRGB(126, 169, 91))
    buttonGradient.Rotation = 90
    buttonGradient.Parent = playButton
    local buttonScale = Instance.new("UIScale")
    buttonScale.Scale = 1
    buttonScale.Parent = playButton
    local hoverTween = nil
    local function animateButton(scale, color)
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(buttonScale, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = scale,
        })
        hoverTween:Play()
        TweenService:Create(playButton, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = color,
        }):Play()
    end
    playButton.MouseEnter:Connect(function()
        animateButton(1.075, Color3.fromRGB(174, 207, 133))
    end)
    playButton.MouseLeave:Connect(function()
        animateButton(1, Color3.fromRGB(144, 184, 105))
    end)
    playButton.SelectionGained:Connect(function()
        animateButton(1.075, Color3.fromRGB(174, 207, 133))
    end)
    playButton.SelectionLost:Connect(function()
        animateButton(1, Color3.fromRGB(144, 184, 105))
    end)
    playButton.MouseButton1Down:Connect(function()
        animateButton(0.97, Color3.fromRGB(126, 169, 91))
    end)
    playButton.MouseButton1Up:Connect(function()
        if not joinPending then
            animateButton(1.075, Color3.fromRGB(174, 207, 133))
        end
    end)

    menuStatusLabel = Instance.new("TextLabel")
    menuStatusLabel.Name = "MenuStatus"
    menuStatusLabel.AnchorPoint = Vector2.new(0.5, 0)
    menuStatusLabel.Position = UDim2.fromScale(0.5, 0.585)
    menuStatusLabel.Size = UDim2.fromScale(0.84, 0.055)
    menuStatusLabel.BackgroundTransparency = 1
    menuStatusLabel.Text = "OCHO JUGADORES  ·  DOS EQUIPOS"
    menuStatusLabel.TextColor3 = Color3.fromRGB(166, 185, 155)
    menuStatusLabel.Font = Enum.Font.GothamMedium
    menuStatusLabel.TextSize = 11
    menuStatusLabel.TextWrapped = true
    menuStatusLabel.Parent = leftPanel

    local footer = Instance.new("TextLabel")
    footer.Name = "Footer"
    footer.AnchorPoint = Vector2.new(0.5, 1)
    footer.Position = UDim2.fromScale(0.5, 0.95)
    footer.Size = UDim2.fromScale(0.84, 0.03)
    footer.BackgroundTransparency = 1
    footer.Text = "SIMPLE SOCCER GAME  /  4V4"
    footer.TextColor3 = Color3.fromRGB(119, 143, 113)
    footer.Font = Enum.Font.GothamMedium
    footer.TextSize = 9
    footer.Parent = leftPanel

    local previewHeading = Instance.new("TextLabel")
    previewHeading.Name = "PreviewHeading"
    previewHeading.AnchorPoint = Vector2.new(0.5, 0)
    previewHeading.Position = UDim2.fromScale(0.69, 0.145)
    previewHeading.Size = UDim2.fromScale(0.48, 0.045)
    previewHeading.BackgroundTransparency = 1
    previewHeading.Text = "TIKI-TAKA"
    previewHeading.TextColor3 = Color3.fromRGB(231, 238, 215)
    previewHeading.Font = Enum.Font.GothamBold
    previewHeading.TextSize = 17
    previewHeading.TextXAlignment = Enum.TextXAlignment.Center
    previewHeading.Parent = backdrop

    local pitchFrame = Instance.new("Frame")
    pitchFrame.Name = "PhysicsPreviewPitch"
    pitchFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    pitchFrame.Position = UDim2.fromScale(0.685, 0.53)
    pitchFrame.Size = UDim2.fromScale(0.585, 0.66)
    pitchFrame.BackgroundColor3 = Color3.fromRGB(112, 156, 93)
    pitchFrame.BorderSizePixel = 0
    pitchFrame.ClipsDescendants = true
    pitchFrame.Parent = backdrop
    local pitchAspect = Instance.new("UIAspectRatioConstraint")
    pitchAspect.AspectRatio = 2.1
    pitchAspect.DominantAxis = Enum.DominantAxis.Width
    pitchAspect.Parent = pitchFrame
    local pitchCorner = Instance.new("UICorner")
    pitchCorner.CornerRadius = UDim.new(0, 12)
    pitchCorner.Parent = pitchFrame
    local pitchStroke = Instance.new("UIStroke")
    pitchStroke.Color = Color3.fromRGB(194, 219, 172)
    pitchStroke.Transparency = 0.35
    pitchStroke.Thickness = 1.4
    pitchStroke.Parent = pitchFrame

    local previewInfo = Instance.new("TextLabel")
    previewInfo.Name = "PreviewInfo"
    previewInfo.AnchorPoint = Vector2.new(0.5, 0)
    previewInfo.Position = UDim2.fromScale(0.69, 0.885)
    previewInfo.Size = UDim2.fromScale(0.58, 0.035)
    previewInfo.BackgroundTransparency = 1
    previewInfo.Text = "MOVIMIENTO CALCULADO CON LA FÍSICA DE PARTIDA"
    previewInfo.TextColor3 = Color3.fromRGB(166, 185, 155)
    previewInfo.Font = Enum.Font.GothamMedium
    previewInfo.TextSize = 10
    previewInfo.TextXAlignment = Enum.TextXAlignment.Center
    previewInfo.Parent = backdrop

    local previewBuilt, previewError = pcall(function()
        previewReplay = MenuPreview.getReplay(PhysicsCore2D, StadiumProfile2D, ClassicReference230)
        menuRenderer = GuiStadiumRenderer.new(playerGui, stadiumScene, nil, nil, GuiStadiumScene, pitchFrame)
        local pitchViewportCorner = Instance.new("UICorner")
        pitchViewportCorner.CornerRadius = UDim.new(0, 12)
        pitchViewportCorner.Parent = menuRenderer.root
    end)
    if not previewBuilt then
        menuStatusLabel.Text = "NO SE PUDO PREPARAR LA VISTA PREVIA"
        warn("Simple Soccer menu preview initialization failed: " .. tostring(previewError))
    end

    playButton.Activated:Connect(function()
        if joinPending or not menuOpen then
            return
        end
        joinPending = true
        joinRequestedAt = os.clock()
        playButton.Active = false
        playButton.Text = "CONECTANDO..."
        menuStatusLabel.Text = "SOLICITANDO PLAZA EN LA PARTIDA 4V4"
        controlRemote:FireServer("join")
    end)

    previewStartedAt = os.clock()
    menuOpen = true
    firstRenderReady = true
    setBootStage("READY", "Menú principal listo · simulación local preparada")
    lab:SetAttribute("ClientBootReady", true)
    -- The full-screen pitch is GUI-rendered, so no physical world is needed behind it.
    pcall(function()
        RunService:Set3dRenderingEnabled(false)
    end)
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

-- Camera focus is eased in logical space (frame-rate independent) and then clamped to the
-- stadium by the renderer, so teleports after goals glide and walls never reveal empty space.
local CAMERA_SMOOTHING_SECONDS = 0.1
local cameraFocus = nil
local shownRed, shownBlue, shownStatus = nil, nil, nil

RunService.RenderStepped:Connect(function(dt)
	local move = readAction(moveAction, Vector2.zero)
	if typeof(move) ~= "Vector2" then
		move = Vector2.zero
	end
	local kick = readAction(kickAction, false) == true
	local now = os.clock()
	if menuOpen and not ownSlot then
		if menuRenderer and previewReplay then
			menuRenderer:render(MenuPreview.sample(previewReplay, now - previewStartedAt), { x = 0, y = 0 })
		end
		if joinPending and now - joinRequestedAt > 10 then
			joinPending = false
			if playButton then
				playButton.Active = true
				playButton.Text = "REINTENTAR"
			end
			if menuStatusLabel then
				menuStatusLabel.Text = "LA CONEXIÓN TARDÓ DEMASIADO · INTÉNTALO DE NUEVO"
			end
		end
		return
	elseif menuOpen and ownSlot then
		menuOpen = false
		if menuRenderer then
			menuRenderer:destroy()
			menuRenderer = nil
		end
		if menuGui then
			menuGui:Destroy()
			menuGui = nil
		end
		if stadiumRenderer and stadiumRenderer.gui then
			stadiumRenderer.gui.Enabled = true
		end
		if matchHud then
			matchHud.Enabled = true
		end
		setBootStage("READY", "Conectado · partida 4v4 sincronizada")
	end
	snapshotAge = latest and math.max(0, now - lastAuthorityAt) or 0
	if ownSlot and now >= nextPingAt then
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
        if now >= nextPingAt - 0.05 then
            setBootStage("WAITING_FOR_STATE", "Solicitando sincronización inicial al servidor")
        end
		return
	end

	local poses, status = presentation:sample(now)
	local predictedActor, predictedBall
	if latest.coreMode and ownSlot and prediction.world and latest.matchPhase == "playing" then
		-- Predict only the local player's control and its immediate ball interaction.
		-- Remote players remain on the buffered Hermite timeline.
		local targetTick = latest.tick + math.floor(math.max(0, now - lastAuthorityAt) * 60)
		local actor, ball = prediction:advance(targetTick, NetCodec.mask(move.X, move.Y, kick))
		if actor and ball then
			predictedActor, predictedBall = prediction:visual(actor, ball, dt)
		end
	end
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
			"NET v3 | RTT %.0f ms | state age %.0f ms\nACK p95 %s ms | pending %d | render %.0f FPS | stream %.0f Hz\nHermite buffer %.0f ms | correction p95 %s units | input delay %d ms",
			rtt * 1000,
			snapshotAge * 1000,
			report.samples.ackMs.p95 and string.format("%.0f", report.samples.ackMs.p95) or "--",
			#netInput.pending,
			status and status.renderFps or 0,
			status and status.sourceRateHz or 0,
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

	-- Follow our own disc; spectators (and a full lobby) follow the ball instead of slot 1.
	local target = ownSlot and playerActors[ownSlot]
	if not target then
		target = latest.coreMode and ballPose or poses.player
	end
	if not cameraFocus then
		cameraFocus = { x = target.x, y = target.y }
	else
		local blend = 1 - math.exp(-math.max(0, dt) / CAMERA_SMOOTHING_SECONDS)
		cameraFocus.x += (target.x - cameraFocus.x) * blend
		cameraFocus.y += (target.y - cameraFocus.y) * blend
	end
	if stadiumRenderer then
        local rendered = stadiumRenderer:render({
            players = playerActors,
            ball = {
                x = ballPose.x,
                y = ballPose.y,
                radius = latest.ball.radius or 10,
                visible = not latest.pairMode,
            },
            debugLines = debugLines,
        }, cameraFocus)
        if rendered and not firstRenderReady then
            firstRenderReady = true
            setBootStage("READY", "Cancha y primer estado preparados · 4 contra 4")
            lab:SetAttribute("ClientBootReady", true)
        end
    end
	local matchStatus = latest.matchPhase == "goalPause" and string.format("GOAL PAUSE %d", latest.pauseTicksRemaining)
		or (
			latest.matchPhase == "kickoff"
				and string.format("KICKOFF %s %d", string.upper(latest.kickoffTeam or "-"), latest.pauseTicksRemaining)
			or (latest.kickoffTeam and ("WAIT KICK " .. string.upper(latest.kickoffTeam)) or "PLAYING")
		)
	if latest.matchPhase == "finished" then
		matchStatus = "FINISHED " .. string.upper(latest.winner or "-")
	end
	-- HUD text is written only when it changes instead of on every rendered frame.
	if latest.score.red ~= shownRed then
		shownRed = latest.score.red
		redScoreLabel.Text = string.format("RED  %d", shownRed)
	end
	if latest.score.blue ~= shownBlue then
		shownBlue = latest.score.blue
		blueScoreLabel.Text = string.format("%d  BLUE", shownBlue)
	end
	if matchStatus ~= shownStatus then
		shownStatus = matchStatus
		statusLabel.Text = string.upper(matchStatus)
	end

	-- The diagnostics text is expensive to build; skip it entirely unless it is visible.
	if showDiagnostics then
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
					"3-disc test | contacts %d | peak overlap %.3f | residual %.4f/max %.4f | iter %d/%d",
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
		local matchLine = string.format("Score RED %d - %d BLUE | %s", latest.score.red, latest.score.blue, matchStatus)
		label.Text = string.format(
			"Simple Soccer | WASD move | X kick\nTick: %d | t=%.2f s | %s\n%s\nKicks: %d attempts / %d accepted (last %d)\nP1: (%.2f, %.2f) speed %.2f\n%s\n%s\n%s\n%s\n%s | samples %d",
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
		recordButton.Text = latest.recording and "Pausar registro" or "Reanudar registro"
	end
end)


