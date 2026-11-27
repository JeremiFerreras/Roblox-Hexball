local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local palette = {
    background = Color3.fromRGB(31, 52, 38),
    grass = Color3.fromRGB(102, 139, 91),
    stripe = Color3.fromRGB(116, 151, 104),
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
title.Position = UDim2.fromScale(0.5, 0.07)
title.Size = UDim2.fromScale(0.78, 0.075)
title.BackgroundTransparency = 1
title.Text = "SIMPLE SOCCER GAME"
title.TextColor3 = palette.text
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = overlay

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.fromScale(0.5, 0.145)
subtitle.Size = UDim2.fromScale(0.7, 0.035)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FÚTBOL 2D  ·  PARTIDOS 4 CONTRA 4"
subtitle.TextColor3 = palette.muted
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 13
subtitle.Parent = overlay

local pitch = Instance.new("Frame")
pitch.Name = "TikiTakaPreview"
pitch.AnchorPoint = Vector2.new(0.5, 0.5)
pitch.Position = UDim2.fromScale(0.5, 0.46)
pitch.Size = UDim2.fromScale(0.74, 0.49)
pitch.BackgroundColor3 = palette.grass
pitch.BorderSizePixel = 0
pitch.ClipsDescendants = true
pitch.Parent = overlay
local pitchCorner = Instance.new("UICorner")
pitchCorner.CornerRadius = UDim.new(0, 13)
pitchCorner.Parent = pitch
local pitchStroke = Instance.new("UIStroke")
pitchStroke.Color = palette.line
pitchStroke.Transparency = 0.45
pitchStroke.Thickness = 1.2
pitchStroke.Parent = pitch

for index = 1, 7 do
    local stripe = Instance.new("Frame")
    stripe.Name = "GrassBand" .. index
    stripe.AnchorPoint = Vector2.new(0.5, 0.5)
    stripe.Position = UDim2.fromScale((index - 2) * 0.19, 0.5)
    stripe.Size = UDim2.fromScale(0.13, 1.65)
    stripe.Rotation = -28
    stripe.BackgroundColor3 = palette.stripe
    stripe.BackgroundTransparency = 0.62
    stripe.BorderSizePixel = 0
    stripe.ZIndex = 1
    stripe.Parent = pitch
end

local function addPitchLine(name, position, size)
    local line = Instance.new("Frame")
    line.Name = name
    line.Position = position
    line.Size = size
    line.BackgroundColor3 = palette.line
    line.BackgroundTransparency = 0.42
    line.BorderSizePixel = 0
    line.ZIndex = 2
    line.Parent = pitch
    return line
end
addPitchLine("HalfwayLine", UDim2.fromScale(0.5, 0), UDim2.new(0, 1, 1, 0))

local centerCircle = Instance.new("Frame")
centerCircle.Name = "CenterCircle"
centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
centerCircle.Position = UDim2.fromScale(0.5, 0.5)
centerCircle.Size = UDim2.fromScale(0.16, 0.43)
centerCircle.BackgroundTransparency = 1
centerCircle.ZIndex = 3
centerCircle.Parent = pitch
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = centerCircle
local circleStroke = Instance.new("UIStroke")
circleStroke.Color = palette.line
circleStroke.Transparency = 0.35
circleStroke.Thickness = 1
circleStroke.Parent = centerCircle

local actors = {}
local initial = {
    { 0.19, 0.50 }, { 0.31, 0.27 }, { 0.31, 0.73 }, { 0.43, 0.50 },
    { 0.70, 0.25 }, { 0.76, 0.50 }, { 0.70, 0.75 }, { 0.84, 0.50 },
}
for slot = 1, 8 do
    local disc = Instance.new("Frame")
    disc.Name = "PreviewPlayer" .. slot
    disc.AnchorPoint = Vector2.new(0.5, 0.5)
    disc.Position = UDim2.fromScale(initial[slot][1], initial[slot][2])
    disc.Size = UDim2.fromOffset(27, 27)
    disc.BackgroundColor3 = slot <= 4 and palette.red or palette.blue
    disc.BorderSizePixel = 0
    disc.ZIndex = 5
    disc.Parent = pitch
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = disc
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(42, 56, 43)
    stroke.Transparency = 0.16
    stroke.Thickness = 1.7
    stroke.Parent = disc
    local number = Instance.new("TextLabel")
    number.Name = "Number"
    number.Size = UDim2.fromScale(1, 1)
    number.BackgroundTransparency = 1
    number.Text = tostring(slot)
    number.TextColor3 = Color3.fromRGB(246, 242, 222)
    number.TextSize = 10
    number.Font = Enum.Font.GothamBold
    number.ZIndex = 6
    number.Parent = disc
    actors[slot] = disc
end

local ball = Instance.new("Frame")
ball.Name = "PreviewBall"
ball.AnchorPoint = Vector2.new(0.5, 0.5)
ball.Position = UDim2.fromScale(0.19, 0.5)
ball.Size = UDim2.fromOffset(11, 11)
ball.BackgroundColor3 = palette.ball
ball.BorderSizePixel = 0
ball.ZIndex = 8
ball.Parent = pitch
local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = ball
local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(43, 55, 42)
ballStroke.Thickness = 1
ballStroke.Parent = ball

local progressTrack = Instance.new("Frame")
progressTrack.Name = "ProgressTrack"
progressTrack.AnchorPoint = Vector2.new(0.5, 0)
progressTrack.Position = UDim2.fromScale(0.5, 0.79)
progressTrack.Size = UDim2.fromOffset(330, 5)
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
stageLabel.Position = UDim2.fromScale(0.5, 0.82)
stageLabel.Size = UDim2.fromScale(0.78, 0.035)
stageLabel.BackgroundTransparency = 1
stageLabel.Text = "INICIALIZANDO CLIENTE"
stageLabel.TextColor3 = palette.text
stageLabel.Font = Enum.Font.GothamMedium
stageLabel.TextSize = 13
stageLabel.Parent = overlay

local detailLabel = Instance.new("TextLabel")
detailLabel.Name = "Detail"
detailLabel.AnchorPoint = Vector2.new(0.5, 0)
detailLabel.Position = UDim2.fromScale(0.5, 0.855)
detailLabel.Size = UDim2.fromScale(0.82, 0.045)
detailLabel.BackgroundTransparency = 1
detailLabel.Text = "Preparando interfaz y secuencia de pases"
detailLabel.TextColor3 = palette.muted
detailLabel.Font = Enum.Font.Gotham
detailLabel.TextSize = 12
detailLabel.TextWrapped = true
detailLabel.Parent = overlay

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.AnchorPoint = Vector2.new(0.5, 0)
footer.Position = UDim2.fromScale(0.5, 0.94)
footer.Size = UDim2.fromScale(0.82, 0.025)
footer.BackgroundTransparency = 1
footer.Text = "SECUENCIA TÁCTICA LOCAL  ·  SIN DESCARGA DE MODELOS 3D"
footer.TextColor3 = Color3.fromRGB(154, 177, 146)
footer.Font = Enum.Font.GothamMedium
footer.TextSize = 9
footer.Parent = overlay

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

-- Original 4v4 passing animation; authored as local keyframes, not a video or a physics match.
local keyframes = {
    {
        players = {{.19,.50},{.31,.27},{.31,.73},{.43,.50},{.70,.25},{.76,.50},{.70,.75},{.84,.50}},
        ball = {.19,.50},
    },
    {
        players = {{.24,.48},{.34,.29},{.35,.70},{.45,.48},{.68,.27},{.73,.49},{.68,.73},{.82,.50}},
        ball = {.34,.29},
    },
    {
        players = {{.29,.46},{.35,.30},{.37,.68},{.48,.47},{.65,.28},{.71,.47},{.66,.71},{.80,.49}},
        ball = {.48,.47},
    },
    {
        players = {{.35,.43},{.37,.31},{.39,.65},{.53,.44},{.64,.30},{.69,.45},{.64,.69},{.78,.48}},
        ball = {.37,.31},
    },
    {
        players = {{.40,.42},{.40,.33},{.42,.63},{.58,.43},{.62,.31},{.67,.43},{.62,.67},{.75,.47}},
        ball = {.58,.43},
    },
    {
        players = {{.48,.40},{.42,.34},{.44,.61},{.64,.41},{.60,.33},{.66,.42},{.60,.65},{.73,.46}},
        ball = {.64,.41},
    },
    {
        players = {{.55,.39},{.47,.36},{.48,.59},{.69,.40},{.58,.35},{.64,.42},{.58,.63},{.71,.45}},
        ball = {.71,.45},
    },
    {
        players = {{.54,.39},{.45,.36},{.46,.60},{.68,.42},{.58,.36},{.64,.42},{.59,.62},{.70,.46}},
        ball = {.94,.49},
    },
    {
        players = {{.19,.50},{.31,.27},{.31,.73},{.43,.50},{.70,.25},{.76,.50},{.70,.75},{.84,.50}},
        ball = {.19,.50},
    },
}
local function lerp(a, b, alpha)
    return a + (b - a) * alpha
end
local animationStart = os.clock()
local animationDuration = 9.6
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
    BUILDING_PITCH = "CONSTRUYENDO CANCHA 2D",
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
        local target = stageProgress[stage] or 0.15
        TweenService:Create(progressFill, TweenInfo.new(0.25), {
            Size = UDim2.fromScale(target, 1),
        }):Play()
    end
    if type(detail) == "string" and detail ~= "" then
        detailLabel.Text = detail
    end
    if type(bootError) == "string" and bootError ~= "" then
        detailLabel.Text = string.sub(bootError, 1, 160)
    end
    if folder:GetAttribute("ClientBootReady") == true then
        stageLabel.Text = stageTitles.READY
        detailLabel.Text = "Cancha, controles y primer estado recibidos"
        TweenService:Create(progressFill, TweenInfo.new(0.35), {
            Size = UDim2.fromScale(1, 1),
        }):Play()
        return true
    end
    return false
end

local function finishLoading()
    local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
    task.delay(0.75, function()
        if gui.Parent then gui:Destroy() end
    end)
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
        if applyStage(folder) then
            finishLoading()
            return true
        end
        return false
    end
    for _, attribute in ipairs({ "ClientBootStage", "ClientBootDetail", "ClientBootError", "ClientBootReady" }) do
        folder:GetAttributeChangedSignal(attribute):Connect(refresh)
    end
    refresh()
    while gui.Parent and folder:GetAttribute("ClientBootReady") ~= true do
        task.wait(0.5)
        if os.clock() - animationStart > 18 and lastStage == "WAITING_FOR_STATE" then
            detailLabel.Text = "La simulación sigue esperando confirmación; se reintentan los remotes"
        end
    end
end)

-- Reuse the same eight circular tokens; no per-frame instances or physics simulation.
task.spawn(function()
    local frameDuration = 1 / 20
    while gui.Parent do
        local t = (os.clock() - animationStart) % animationDuration
        local scaled = t / animationDuration * (#keyframes - 1)
        local index = math.floor(scaled) + 1
        local alpha = scaled - math.floor(scaled)
        local current = keyframes[index]
        local following = keyframes[index + 1]
        for slot = 1, 8 do
            local a, b = current.players[slot], following.players[slot]
            actors[slot].Position = UDim2.fromScale(lerp(a[1], b[1], alpha), lerp(a[2], b[2], alpha))
        end
        local bx = lerp(current.ball[1], following.ball[1], alpha)
        local by = lerp(current.ball[2], following.ball[2], alpha)
        ball.Position = UDim2.fromScale(bx, by)
        task.wait(frameDuration)
    end
end)
