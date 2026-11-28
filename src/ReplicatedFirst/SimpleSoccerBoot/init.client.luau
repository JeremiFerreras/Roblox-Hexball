local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Same soft greens as the main menu, so the hand-over between both screens is seamless.
local palette = {
    backgroundTop = Color3.fromRGB(104, 139, 94),
    backgroundBottom = Color3.fromRGB(82, 112, 79),
    line = Color3.fromRGB(199, 235, 187),
    ball = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(244, 247, 232),
    muted = Color3.fromRGB(219, 232, 205),
    track = Color3.fromRGB(70, 97, 69),
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
overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
overlay.BorderSizePixel = 0
overlay.Parent = gui
local overlayGradient = Instance.new("UIGradient")
overlayGradient.Color = ColorSequence.new(palette.backgroundTop, palette.backgroundBottom)
overlayGradient.Rotation = 90
overlayGradient.Parent = overlay

local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.36)
title.Size = UDim2.fromScale(0.78, 0.09)
title.BackgroundTransparency = 1
title.Text = "SIMPLE SOCCER GAME"
title.TextColor3 = palette.text
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = overlay

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.fromScale(0.5, 0.44)
subtitle.Size = UDim2.fromScale(0.7, 0.035)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FÚTBOL 2D  ·  PARTIDOS 4 CONTRA 4"
subtitle.TextColor3 = palette.muted
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextScaled = true
subtitle.Parent = overlay

-- A single ball rolling along the progress bar: a loader, not a fake match.
local ball = Instance.new("Frame")
ball.Name = "LoadingBall"
ball.AnchorPoint = Vector2.new(0.5, 1)
ball.Position = UDim2.new(0.33, 0, 0.6, -6)
ball.Size = UDim2.fromOffset(20, 20)
ball.BackgroundColor3 = palette.ball
ball.BorderSizePixel = 0
ball.Parent = overlay
local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = ball
local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(5, 8, 3)
ballStroke.Thickness = 2
ballStroke.Parent = ball

local progressTrack = Instance.new("Frame")
progressTrack.Name = "ProgressTrack"
progressTrack.AnchorPoint = Vector2.new(0.5, 0)
progressTrack.Position = UDim2.fromScale(0.5, 0.6)
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
stageLabel.Position = UDim2.fromScale(0.5, 0.64)
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
detailLabel.Position = UDim2.fromScale(0.5, 0.675)
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
footer.TextColor3 = palette.muted
footer.Font = Enum.Font.GothamMedium
footer.TextSize = 9
footer.Parent = overlay

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

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
        local progress = stageProgress[stage] or 0.15
        TweenService:Create(progressFill, TweenInfo.new(0.22), {
            Size = UDim2.fromScale(progress, 1),
        }):Play()
        TweenService:Create(ball, TweenInfo.new(0.22), {
            Position = UDim2.new(0.33 + 0.34 * progress, 0, 0.6, -6),
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
    if not loadingFinished and bootReady then
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
    -- Attribute signals are enough: no polling loop waking the client every 0.1 s.
    refresh()
end)

-- Frame-rate independent bounce while the real preparation stages advance.
local startedAt = os.clock()
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not gui.Parent then
        if renderConnection then renderConnection:Disconnect() end
        return
    end
    local hop = math.abs(math.sin((os.clock() - startedAt) * 4))
    ball.AnchorPoint = Vector2.new(0.5, 1 + hop * 0.7)
end)
