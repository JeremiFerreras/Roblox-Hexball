local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local palette = {
    background = Color3.fromRGB(31, 52, 38),
    grass = Color3.fromRGB(102, 139, 91),
    stripe = Color3.fromRGB(118, 151, 105),
    line = Color3.fromRGB(190, 213, 173),
    red = Color3.fromRGB(194, 119, 109),
    blue = Color3.fromRGB(112, 143, 187),
    ball = Color3.fromRGB(244, 242, 220),
    text = Color3.fromRGB(235, 237, 218),
    muted = Color3.fromRGB(190, 207, 176),
    track = Color3.fromRGB(64, 91, 64),
}

local gui = Instance.new("ScreenGui")
gui.Name = "SimpleSoccerBoot"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame")
overlay.Name = "Backdrop"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = palette.background
overlay.BorderSizePixel = 0
overlay.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.fromScale(0.5, 0.035)
title.Size = UDim2.fromScale(0.78, 0.065)
title.BackgroundTransparency = 1
title.Text = "SIMPLE SOCCER GAME"
title.TextColor3 = palette.text
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = overlay

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.fromScale(0.5, 0.102)
subtitle.Size = UDim2.fromScale(0.7, 0.035)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FÚTBOL 2D  ·  PARTIDOS 4 CONTRA 4"
subtitle.TextColor3 = palette.muted
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 13
subtitle.Parent = overlay

-- The preview uses the same 2.1:1 horizontal proportion as the live stadium.
local pitch = Instance.new("Frame")
pitch.Name = "TikiTakaPreview"
pitch.AnchorPoint = Vector2.new(0.5, 0.5)
pitch.Position = UDim2.fromScale(0.5, 0.49)
pitch.Size = UDim2.fromScale(0.82, 0.70)
pitch.BackgroundColor3 = palette.grass
pitch.BorderSizePixel = 0
pitch.ClipsDescendants = true
pitch.Parent = overlay
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 2.1
aspect.DominantAxis = Enum.DominantAxis.Width
aspect.Parent = pitch
local pitchCorner = Instance.new("UICorner")
pitchCorner.CornerRadius = UDim.new(0, 12)
pitchCorner.Parent = pitch
local pitchStroke = Instance.new("UIStroke")
pitchStroke.Color = palette.line
pitchStroke.Transparency = 0.38
pitchStroke.Thickness = 1.5
pitchStroke.Parent = pitch

-- Soft alternating mowing bands; no high-contrast blocks.
for index = 1, 8 do
    local stripe = Instance.new("Frame")
    stripe.Name = "GrassBand" .. index
    stripe.Position = UDim2.fromScale((index - 1) / 8, 0)
    stripe.Size = UDim2.fromScale(1 / 8, 1)
    stripe.BackgroundColor3 = palette.stripe
    stripe.BackgroundTransparency = index % 2 == 0 and 0.78 or 0.9
    stripe.BorderSizePixel = 0
    stripe.ZIndex = 1
    stripe.Parent = pitch
end

local function addLine(name, x1, y1, x2, y2, thickness, color, transparency)
    local dx = (x2 - x1) * 2.1
    local dy = y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    local line = Instance.new("Frame")
    line.Name = name
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.fromScale((x1 + x2) * 0.5, (y1 + y2) * 0.5)
    line.Size = UDim2.new(length * pitch.AbsoluteSize.Y / pitch.AbsoluteSize.X, 0, 0, thickness)
    line.Rotation = math.deg(math.atan2(dy, dx))
    line.BackgroundColor3 = color or palette.line
    line.BackgroundTransparency = transparency or 0.38
    line.BorderSizePixel = 0
    line.ZIndex = 2
    line.Parent = pitch
    return line
end

-- Full field outline, halfway line, centre circle, penalty areas and goal frames.
local marks = {}
marks[#marks + 1] = addLine("TouchlineTop", 0.012, 0.035, 0.988, 0.035, 1.5)
marks[#marks + 1] = addLine("TouchlineBottom", 0.012, 0.965, 0.988, 0.965, 1.5)
marks[#marks + 1] = addLine("GoalLineLeft", 0.012, 0.035, 0.012, 0.965, 1.5)
marks[#marks + 1] = addLine("GoalLineRight", 0.988, 0.035, 0.988, 0.965, 1.5)
marks[#marks + 1] = addLine("HalfwayLine", 0.5, 0.035, 0.5, 0.965, 1.5)

local centerCircle = Instance.new("Frame")
centerCircle.Name = "CenterCircle"
centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
centerCircle.Position = UDim2.fromScale(0.5, 0.5)
centerCircle.Size = UDim2.fromScale(0.18, 0.38)
centerCircle.BackgroundTransparency = 1
centerCircle.ZIndex = 2
centerCircle.Parent = pitch
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = centerCircle
local circleStroke = Instance.new("UIStroke")
circleStroke.Color = palette.line
circleStroke.Transparency = 0.42
circleStroke.Thickness = 1.3
circleStroke.Parent = centerCircle

local function addBox(name, x, y, width, height)
    local box = Instance.new("Frame")
    box.Name = name
    box.Position = UDim2.fromScale(x, y)
    box.Size = UDim2.fromScale(width, height)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ZIndex = 2
    box.Parent = pitch
    local stroke = Instance.new("UIStroke")
    stroke.Color = palette.line
    stroke.Transparency = 0.44
    stroke.Thickness = 1.2
    stroke.Parent = box
    return box
end
addBox("LeftPenaltyArea", 0.012, 0.25, 0.17, 0.5)
addBox("RightPenaltyArea", 0.818, 0.25, 0.17, 0.5)
addBox("LeftGoalArea", 0.012, 0.37, 0.075, 0.26)
addBox("RightGoalArea", 0.913, 0.37, 0.075, 0.26)

local function addGoal(name, x)
    local goal = Instance.new("Frame")
    goal.Name = name
    goal.AnchorPoint = Vector2.new(0.5, 0.5)
    goal.Position = UDim2.fromScale(x, 0.5)
    goal.Size = UDim2.fromScale(0.035, 0.2)
    goal.BackgroundColor3 = palette.line
    goal.BackgroundTransparency = 0.78
    goal.BorderSizePixel = 0
    goal.ZIndex = 3
    goal.Parent = pitch
    local stroke = Instance.new("UIStroke")
    stroke.Color = palette.line
    stroke.Transparency = 0.28
    stroke.Thickness = 1.5
    stroke.Parent = goal
    return goal
end
addGoal("LeftGoal", 0.006)
addGoal("RightGoal", 0.994)

local actors = {}
local initial = {
    { 0.18, 0.50 }, { 0.30, 0.28 }, { 0.30, 0.72 }, { 0.44, 0.50 },
    { 0.94, 0.50 }, { 0.74, 0.29 }, { 0.77, 0.50 }, { 0.74, 0.71 },
}
for slot = 1, 8 do
    local disc = Instance.new("Frame")
    disc.Name = "PreviewPlayer" .. slot
    disc.AnchorPoint = Vector2.new(0.5, 0.5)
    disc.Position = UDim2.fromScale(initial[slot][1], initial[slot][2])
    disc.Size = UDim2.fromOffset(34, 34)
    disc.BackgroundColor3 = slot <= 4 and palette.red or palette.blue
    disc.BorderSizePixel = 0
    disc.ZIndex = 5
    disc.Parent = pitch
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = disc
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(54, 66, 50)
    stroke.Transparency = 0.2
    stroke.Thickness = 1.5
    stroke.Parent = disc

    -- The shirt number is a child of the moving disc, not a separately positioned object.
    local number = Instance.new("TextLabel")
    number.Name = "Number"
    number.AnchorPoint = Vector2.new(0.5, 0.5)
    number.Position = UDim2.fromScale(0.5, 0.5)
    number.Size = UDim2.fromScale(1, 1)
    number.BackgroundTransparency = 1
    number.Text = string.format("%02d", slot)
    number.TextColor3 = Color3.fromRGB(246, 242, 222)
    number.TextStrokeColor3 = Color3.fromRGB(48, 61, 45)
    number.TextStrokeTransparency = 0.38
    number.TextScaled = true
    number.Font = Enum.Font.GothamBold
    number.ZIndex = 6
    number.Parent = disc
    actors[slot] = disc
end

local ball = Instance.new("Frame")
ball.Name = "PreviewBall"
ball.AnchorPoint = Vector2.new(0.5, 0.5)
ball.Position = UDim2.fromScale(0.18, 0.5)
ball.Size = UDim2.fromOffset(12, 12)
ball.BackgroundColor3 = palette.ball
ball.BorderSizePixel = 0
ball.ZIndex = 8
ball.Parent = pitch
local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = ball
local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(66, 77, 58)
ballStroke.Thickness = 1.2
ballStroke.Parent = ball

local goalBanner = Instance.new("TextLabel")
goalBanner.Name = "GoalBanner"
goalBanner.AnchorPoint = Vector2.new(0.5, 0.5)
goalBanner.Position = UDim2.fromScale(0.5, 0.17)
goalBanner.Size = UDim2.fromScale(0.25, 0.12)
goalBanner.BackgroundColor3 = Color3.fromRGB(39, 61, 43)
goalBanner.BackgroundTransparency = 0.12
goalBanner.Text = "¡GOL!"
goalBanner.TextColor3 = palette.text
goalBanner.TextStrokeColor3 = Color3.fromRGB(48, 61, 45)
goalBanner.TextStrokeTransparency = 0.7
goalBanner.Font = Enum.Font.GothamBold
goalBanner.TextScaled = true
goalBanner.Visible = false
goalBanner.ZIndex = 12
goalBanner.Parent = pitch
local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 8)
bannerCorner.Parent = goalBanner
local bannerStroke = Instance.new("UIStroke")
bannerStroke.Color = palette.line
bannerStroke.Transparency = 0.5
bannerStroke.Parent = goalBanner

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "PreviewScore"
scoreLabel.AnchorPoint = Vector2.new(0.5, 0)
scoreLabel.Position = UDim2.fromScale(0.5, 0.035)
scoreLabel.Size = UDim2.fromScale(0.3, 0.055)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "RED  0  :  0  BLUE"
scoreLabel.TextColor3 = palette.text
scoreLabel.TextStrokeTransparency = 0.75
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.TextScaled = true
scoreLabel.ZIndex = 10
scoreLabel.Parent = pitch

local progressTrack = Instance.new("Frame")
progressTrack.Name = "ProgressTrack"
progressTrack.AnchorPoint = Vector2.new(0.5, 0)
progressTrack.Position = UDim2.fromScale(0.5, 0.855)
progressTrack.Size = UDim2.fromScale(0.34, 0)
progressTrack.Size = UDim2.new(0.34, 0, 0, 5)
progressTrack.BackgroundColor3 = palette.track
progressTrack.BorderSizePixel = 0
progressTrack.Parent = overlay
local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = progressTrack
local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.fromScale(0.08, 1)
progressFill.BackgroundColor3 = palette.line
progressFill.BorderSizePixel = 0
progressFill.Parent = progressTrack
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressFill

local stageLabel = Instance.new("TextLabel")
stageLabel.Name = "Stage"
stageLabel.AnchorPoint = Vector2.new(0.5, 0)
stageLabel.Position = UDim2.fromScale(0.5, 0.875)
stageLabel.Size = UDim2.fromScale(0.78, 0.03)
stageLabel.BackgroundTransparency = 1
stageLabel.Text = "INICIALIZANDO CLIENTE"
stageLabel.TextColor3 = palette.text
stageLabel.Font = Enum.Font.GothamMedium
stageLabel.TextSize = 13
stageLabel.Parent = overlay

local detailLabel = Instance.new("TextLabel")
detailLabel.Name = "Detail"
detailLabel.AnchorPoint = Vector2.new(0.5, 0)
detailLabel.Position = UDim2.fromScale(0.5, 0.91)
detailLabel.Size = UDim2.fromScale(0.82, 0.04)
detailLabel.BackgroundTransparency = 1
detailLabel.Text = "Preparando partido 4v4"
detailLabel.TextColor3 = palette.muted
detailLabel.Font = Enum.Font.Gotham
detailLabel.TextSize = 12
detailLabel.TextWrapped = true
detailLabel.Parent = overlay

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.AnchorPoint = Vector2.new(0.5, 0)
footer.Position = UDim2.fromScale(0.5, 0.965)
footer.Size = UDim2.fromScale(0.82, 0.02)
footer.BackgroundTransparency = 1
footer.Text = "SIMPLE SOCCER GAME"
footer.TextColor3 = Color3.fromRGB(154, 177, 146)
footer.Font = Enum.Font.GothamMedium
footer.TextSize = 9
footer.Parent = overlay

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

-- Eight timestamped team poses: three passes, a run into the box, a shot and a goal.
-- Coordinates are in pitch-space and are sampled on every rendered frame with Catmull-Rom interpolation.
local keyframes = {
    { players = {{.18,.50},{.30,.28},{.30,.72},{.44,.50},{.94,.50},{.74,.29},{.77,.50},{.74,.71}}, ball = {.18,.50} },
    { players = {{.23,.48},{.34,.30},{.34,.70},{.48,.48},{.93,.50},{.71,.30},{.73,.50},{.72,.70}}, ball = {.34,.30} },
    { players = {{.27,.45},{.38,.32},{.39,.67},{.56,.45},{.92,.50},{.68,.32},{.70,.49},{.69,.68}}, ball = {.56,.45} },
    { players = {{.34,.43},{.40,.33},{.49,.62},{.64,.43},{.92,.50},{.66,.35},{.68,.50},{.69,.65}}, ball = {.49,.62} },
    { players = {{.41,.41},{.47,.32},{.61,.56},{.70,.46},{.92,.50},{.63,.38},{.66,.50},{.68,.63}}, ball = {.70,.46} },
    { players = {{.47,.39},{.55,.32},{.69,.59},{.81,.47},{.92,.51},{.68,.40},{.71,.51},{.73,.64}}, ball = {.81,.47} },
    { players = {{.53,.38},{.59,.34},{.75,.58},{.89,.48},{.92,.53},{.79,.42},{.83,.51},{.80,.63}}, ball = {.92,.49} },
    { players = {{.56,.39},{.62,.35},{.77,.57},{.93,.49},{.94,.55},{.84,.43},{.87,.51},{.82,.62}}, ball = {.992,.50} },
}
local segmentDuration = 0.34
local animationDuration = segmentDuration * (#keyframes - 1)
local animationStart = os.clock()
local animationFinished = false

local function catmull(a, b, c, d, t)
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * (
        2 * b
        + (-a + c) * t
        + (2 * a - 5 * b + 4 * c - d) * t2
        + (-a + 3 * b - 3 * c + d) * t3
    )
end

local function samplePoint(previous, current, following, after, alpha)
    return {
        math.clamp(catmull(previous[1], current[1], following[1], after[1], alpha), 0.025, 0.985),
        math.clamp(catmull(previous[2], current[2], following[2], after[2], alpha), 0.08, 0.92),
    }
end

local function renderPlay(elapsed)
    local position = math.clamp(elapsed / segmentDuration, 0, #keyframes - 1)
    local segment = math.min(math.floor(position) + 1, #keyframes - 1)
    local alpha = position - (segment - 1)
    local previous = keyframes[math.max(1, segment - 1)]
    local current = keyframes[segment]
    local following = keyframes[segment + 1]
    local after = keyframes[math.min(#keyframes, segment + 2)]

    for slot = 1, 8 do
        local point = samplePoint(
            previous.players[slot],
            current.players[slot],
            following.players[slot],
            after.players[slot],
            alpha
        )
        actors[slot].Position = UDim2.fromScale(point[1], point[2])
    end

    local ballPoint = samplePoint(previous.ball, current.ball, following.ball, after.ball, alpha)
    ball.Position = UDim2.fromScale(ballPoint[1], ballPoint[2])
end

local stageProgress = {
    INITIALIZING = 0.08,
    CONNECTING = 0.18,
    LOADING_MODULES = 0.32,
    BUILDING_PITCH = 0.56,
    WAITING_FOR_STATE = 0.68,
    SYNCHRONIZING = 0.84,
    READY = 1,
    VISUAL_ERROR = 0.9,
    ERROR = 0.18,
}
local stageTitles = {
    INITIALIZING = "INICIALIZANDO CLIENTE",
    CONNECTING = "CONECTANDO CON EL SERVIDOR",
    LOADING_MODULES = "PREPARANDO SIMULACIÓN",
    BUILDING_PITCH = "PREPARANDO CANCHA 4v4",
    WAITING_FOR_STATE = "ESPERANDO ESTADO DEL SERVIDOR",
    SYNCHRONIZING = "SINCRONIZANDO JUGADORES Y BALÓN",
    READY = "PARTIDA PREPARADA",
    VISUAL_ERROR = "CONEXIÓN LISTA · REVISANDO VISUALIZACIÓN",
    ERROR = "NO SE PUDO COMPLETAR LA INICIALIZACIÓN",
}
local lastStage = "INITIALIZING"
local function applyStage(folder)
    local stage = folder:GetAttribute("ClientBootStage") or "INITIALIZING"
    local detail = folder:GetAttribute("ClientBootDetail")
    local bootError = folder:GetAttribute("ClientBootError")
    if stage ~= lastStage then
        lastStage = stage
        stageLabel.Text = stageTitles[stage] or "PREPARANDO PARTIDA"
        TweenService:Create(progressFill, TweenInfo.new(0.22), {
            Size = UDim2.fromScale(stageProgress[stage] or 0.15, 1),
        }):Play()
    end
    if type(detail) == "string" and detail ~= "" then
        detailLabel.Text = detail
    end
    if type(bootError) == "string" and bootError ~= "" then
        detailLabel.Text = string.sub(bootError, 1, 160)
    end
    return folder:GetAttribute("ClientBootReady") == true
end

local function finishLoading()
    local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, object in ipairs(gui:GetDescendants()) do
        if object:IsA("Frame") then
            TweenService:Create(object, tweenInfo, { BackgroundTransparency = 1 }):Play()
        elseif object:IsA("TextLabel") then
            TweenService:Create(object, tweenInfo, { TextTransparency = 1 }):Play()
        elseif object:IsA("UIStroke") then
            TweenService:Create(object, tweenInfo, { Transparency = 1 }):Play()
        end
    end
    TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
    task.delay(0.5, function()
        if gui.Parent then gui:Destroy() end
    end)
end

local bootReady = false
local loadingFinished = false
local function tryFinishLoading()
    if not loadingFinished and bootReady and animationFinished then
        loadingFinished = true
        finishLoading()
    end
end

task.spawn(function()
    local folder = ReplicatedStorage:WaitForChild("SimpleSoccerGame", 30)
    if not folder then
        lastStage = "ERROR"
        stageLabel.Text = stageTitles.ERROR
        detailLabel.Text = "No se encontró la configuración del juego en ReplicatedStorage"
        return
    end

    local function refresh()
        bootReady = applyStage(folder)
        tryFinishLoading()
    end
    for _, attribute in ipairs({ "ClientBootStage", "ClientBootDetail", "ClientBootError", "ClientBootReady" }) do
        folder:GetAttributeChangedSignal(attribute):Connect(refresh)
    end
    refresh()
    while gui.Parent and not loadingFinished do
        task.wait(0.1)
        refresh()
    end
end)

-- RenderStepped follows the actual client frame rate; no fixed 20 Hz animation loop.
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not gui.Parent then
        if renderConnection then renderConnection:Disconnect() end
        return
    end

    local elapsed = math.min(os.clock() - animationStart, animationDuration)
    renderPlay(elapsed)

    if elapsed >= animationDuration and not animationFinished then
        animationFinished = true
        goalBanner.Visible = true
        scoreLabel.Text = "RED  1  :  0  BLUE"
        stageLabel.Text = "JUGADA COMPLETADA"
        detailLabel.Text = "PASE · DESMARQUE · REMATE · GOL"
        progressFill.Size = UDim2.fromScale(1, 1)
        tryFinishLoading()
    end
end)
