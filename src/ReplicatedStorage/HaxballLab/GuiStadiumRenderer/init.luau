-- GUI-only renderer. This module never creates or moves physical Parts.
local Renderer = {}
Renderer.__index = Renderer

local function defaultUI()
    return {
        new = function(className)
            return Instance.new(className)
        end,
        color = function(r, g, b)
            return Color3.fromRGB(r, g, b)
        end,
        offset = function(x, y)
            return UDim2.fromOffset(x, y)
        end,
        scale = function(x, y)
            return UDim2.fromScale(x, y)
        end,
        vector = function(x, y)
            return Vector2.new(x, y)
        end,
        circleCorner = UDim.new(1, 0),
        strokeBorder = Enum.ApplyStrokeMode.Border,
        boldFont = Enum.Font.GothamBold,
        siblingZIndex = Enum.ZIndexBehavior.Sibling,
    }
end

local function colorFrom(ui, palette, key)
    local rgb = palette[key]
    assert(rgb, "unknown GUI palette key: " .. tostring(key))
    return ui.color(rgb[1], rgb[2], rgb[3])
end

local function create(ui, className, parent, properties)
    local object = ui.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function makeStroke(ui, parent, color, thickness)
    return create(ui, "UIStroke", parent, {
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = ui.strokeBorder,
    })
end

local function makeCircle(ui, parent, name, zIndex, fill, stroke, strokeWidth)
    local frame = create(ui, "Frame", parent, {
        Name = name,
        AnchorPoint = ui.vector(0.5, 0.5),
        BackgroundColor3 = fill or ui.color(0, 0, 0),
        BackgroundTransparency = fill and 0 or 1,
        BorderSizePixel = 0,
        Position = ui.offset(0, 0),
        Size = ui.offset(0, 0),
        Visible = false,
        ZIndex = zIndex,
    })
    create(ui, "UICorner", frame, { CornerRadius = ui.circleCorner })
    if stroke then
        makeStroke(ui, frame, stroke, strokeWidth or 2)
    end
    return frame
end

local function makeLine(ui, parent, name, color, zIndex)
    return create(ui, "Frame", parent, {
        Name = name,
        AnchorPoint = ui.vector(0.5, 0.5),
        BackgroundColor3 = color,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = ui.offset(0, 0),
        Size = ui.offset(0, 0),
        Visible = false,
        ZIndex = zIndex,
    })
end

local function placeLine(ui, frame, x1, y1, x2, y2, thickness)
    local dx, dy = x2 - x1, y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    frame.Visible = length > 0.01
    if not frame.Visible then
        return
    end
    frame.Position = ui.offset((x1 + x2) * 0.5, (y1 + y2) * 0.5)
    frame.Size = ui.offset(length, math.max(1, thickness))
    frame.Rotation = math.deg(math.atan2(dy, dx))
end

local function near(a, b)
    return math.abs(a - b) < 1e-4
end

function Renderer.hideLegacyField(field)
    if not field then
        return
    end
    for _, descendant in ipairs(field:GetDescendants()) do
        if descendant:IsA("BasePart") then
            -- Presentation only: never modify collision/touch/query flags here.
            descendant.LocalTransparencyModifier = 1
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = 1
        end
    end
end

function Renderer.new(playerGui, scene, ui, legacyField, sceneApi)
    assert(playerGui and scene and sceneApi, "PlayerGui, scene data, and scene API are required")
    ui = ui or defaultUI()
    local self = setmetatable({
        ui = ui,
        scene = scene,
        sceneApi = sceneApi,
        lastView = nil,
        playerTokens = {},
        debugLines = {},
    }, Renderer)

    self.gui = create(ui, "ScreenGui", playerGui, {
        Name = "SimpleSoccerStadium2D",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 0,
        ZIndexBehavior = ui.siblingZIndex,
    })
    self.root = create(ui, "Frame", self.gui, {
        Name = "Viewport",
        AnchorPoint = ui.vector(0, 0),
        Position = ui.offset(0, 0),
        Size = ui.scale(1, 1),
        BackgroundColor3 = colorFrom(ui, scene.palette, "outerGrass"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 0,
    })

    local grass = scene.grass
    self.grass = create(ui, "Frame", self.root, {
        Name = "ClassicGrass",
        AnchorPoint = ui.vector(0, 0),
        Position = ui.offset(0, 0),
        Size = ui.offset(0, 0),
        BackgroundColor3 = colorFrom(ui, scene.palette, "grass"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    })

    self.stripeFrames = {}
    for _, stripe in ipairs(scene.stripes) do
        local frame = makeLine(ui, self.grass, stripe.id,
            colorFrom(ui, scene.palette, stripe.color), 2)
        table.insert(self.stripeFrames, { frame = frame, source = stripe })
    end

    self.lineFrames = {}
    for _, line in ipairs(scene.lines) do
        local frame = makeLine(ui, self.root, line.id,
            colorFrom(ui, scene.palette, line.color), line.layer == "goal" and 6 or 5)
        table.insert(self.lineFrames, { frame = frame, source = line })
    end

    self.centerCircle = makeCircle(ui, self.root, "CenterCircle", 7, nil,
        colorFrom(ui, scene.palette, "line"), 2.2)
    self.postFrames = {}
    for _, post in ipairs(scene.posts) do
        local frame = makeCircle(ui, self.root, post.id, 8,
            colorFrom(ui, scene.palette, post.fill),
            colorFrom(ui, scene.palette, post.stroke), 2.4)
        table.insert(self.postFrames, { frame = frame, source = post })
    end

    for slot = 1, scene.playerCount do
        local team = slot <= scene.playersPerTeam and "red" or "blue"
        local frame = makeCircle(ui, self.root, "Player" .. slot, 20,
            colorFrom(ui, scene.palette, team),
            colorFrom(ui, scene.palette, "goal"), 2.4)
        local avatar = create(ui, "ImageLabel", frame, {
            Name = "Avatar",
            AnchorPoint = ui.vector(0.5, 0.5),
            Position = ui.scale(0.5, 0.5),
            Size = ui.scale(0.66, 0.66),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = "",
            Visible = false,
            ZIndex = 21,
        })
        create(ui, "UICorner", avatar, { CornerRadius = ui.circleCorner })
        local label = create(ui, "TextLabel", frame, {
            Name = "Number",
            AnchorPoint = ui.vector(1, 1),
            Position = ui.scale(1, 1),
            Size = ui.scale(0.38, 0.38),
            BackgroundColor3 = colorFrom(ui, scene.palette, "outerGrass"),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Text = string.format("%02d", slot),
            TextColor3 = colorFrom(ui, scene.palette, "ball"),
            TextScaled = true,
            TextWrapped = false,
            Font = ui.boldFont,
            ZIndex = 22,
        })
        create(ui, "UICorner", label, { CornerRadius = ui.circleCorner })
        makeStroke(ui, label, colorFrom(ui, scene.palette, "goal"), 1)
        self.playerTokens[slot] = { frame = frame, avatar = avatar, label = label }
    end

    self.ballToken = makeCircle(ui, self.root, "Ball", 22,
        colorFrom(ui, scene.palette, "ball"),
        colorFrom(ui, scene.palette, "goal"), 2.2)

    for index = 1, 3 do
        self.debugLines[index] = makeLine(ui, self.root, "DebugLine" .. index,
            colorFrom(ui, scene.palette, "debug"), 18)
    end

    self.grassRect = grass
    Renderer.hideLegacyField(legacyField)
    return self
end

function Renderer:_placeStatic(layout, camera)
    local scale = layout.scale
    local cameraX = camera.x
    local cameraY = camera.y
    local last = self.lastView
    local changed = not last
        or not near(last.width, layout.width)
        or not near(last.height, layout.height)
        or not near(last.scale, scale)
        or not near(last.cameraX, cameraX)
        or not near(last.cameraY, cameraY)
    if not changed then
        return
    end

    local grass = self.grassRect
    local gx, gy = self.sceneApi.toViewport(grass.minX, grass.maxY, layout, camera)
    self.grass.Position = self.ui.offset(gx, gy)
    self.grass.Size = self.ui.offset((grass.maxX - grass.minX) * scale, (grass.maxY - grass.minY) * scale)

    for _, entry in ipairs(self.stripeFrames) do
        local stripe = entry.source
        local x1 = (stripe.a.x - grass.minX) * scale
        local y1 = (grass.maxY - stripe.a.y) * scale
        local x2 = (stripe.b.x - grass.minX) * scale
        local y2 = (grass.maxY - stripe.b.y) * scale
        placeLine(self.ui, entry.frame, x1, y1, x2, y2, stripe.thickness * scale)
    end

    for _, entry in ipairs(self.lineFrames) do
        local line = entry.source
        local x1, y1 = self.sceneApi.toViewport(line.a.x, line.a.y, layout, camera)
        local x2, y2 = self.sceneApi.toViewport(line.b.x, line.b.y, layout, camera)
        placeLine(self.ui, entry.frame, x1, y1, x2, y2, line.thickness * scale)
    end

    local circle = self.scene.circles[1]
    if circle then
        local cx, cy = self.sceneApi.toViewport(circle.x, circle.y, layout, camera)
        self.centerCircle.Position = self.ui.offset(cx, cy)
        self.centerCircle.Size = self.ui.offset(circle.radius * 2 * scale, circle.radius * 2 * scale)
        self.centerCircle.Visible = true
    end

    for _, entry in ipairs(self.postFrames) do
        local post = entry.source
        local px, py = self.sceneApi.toViewport(post.x, post.y, layout, camera)
        local diameter = post.radius * 2 * scale
        entry.frame.Position = self.ui.offset(px, py)
        entry.frame.Size = self.ui.offset(diameter, diameter)
        entry.frame.Visible = true
    end

    self.lastView = {
        width = layout.width,
        height = layout.height,
        scale = scale,
        cameraX = cameraX,
        cameraY = cameraY,
    }
end

function Renderer:render(frame, focus)
    local viewport = self.root.AbsoluteSize
    local width = viewport and viewport.X or 0
    local height = viewport and viewport.Y or 0
    if width <= 0 or height <= 0 then
        return false
    end

    local camera = {
        x = focus and type(focus.x) == "number" and focus.x or 0,
        y = focus and type(focus.y) == "number" and focus.y or 0,
    }
    local layout = self.sceneApi.fit(width, height)
    self:_placeStatic(layout, camera)

    local players = frame.players or {}
    for slot = 1, self.scene.playerCount do
        local token = self.playerTokens[slot]
        local actor = players[slot]
        local visible = actor ~= nil and actor.visible ~= false
        token.frame.Visible = visible
        if visible then
            local px, py = self.sceneApi.toViewport(actor.x, actor.y, layout, camera)
            local diameter = math.max(8, (actor.radius or 15) * 2 * layout.scale)
            token.frame.Position = self.ui.offset(px, py)
            token.frame.Size = self.ui.offset(diameter, diameter)
            token.frame.BackgroundColor3 = colorFrom(self.ui, self.scene.palette,
                actor.team == "blue" and "blue" or "red")
            token.label.Text = actor.label or string.format("%02d", actor.id or slot)
            local userId = actor.userId
            local avatarUri = type(userId) == "number" and userId > 0 and userId < 9007199254740992
                and ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(math.floor(userId)) .. "&w=48&h=48")
                or ""
            if token.avatar.Image ~= avatarUri then
                token.avatar.Image = avatarUri
            end
            token.avatar.Visible = avatarUri ~= ""
        end
    end

    local ball = frame.ball
    self.ballToken.Visible = ball ~= nil and ball.visible ~= false
    if self.ballToken.Visible then
        local bx, by = self.sceneApi.toViewport(ball.x, ball.y, layout, camera)
        local diameter = math.max(6, (ball.radius or 10) * 2 * layout.scale)
        self.ballToken.Position = self.ui.offset(bx, by)
        self.ballToken.Size = self.ui.offset(diameter, diameter)
    end

    local debug = frame.debugLines or {}
    for index, lineFrame in ipairs(self.debugLines) do
        local line = debug[index]
        lineFrame.Visible = line ~= nil and line.visible ~= false
        if lineFrame.Visible then
            local x1, y1 = self.sceneApi.toViewport(line.a.x, line.a.y, layout, camera)
            local x2, y2 = self.sceneApi.toViewport(line.b.x, line.b.y, layout, camera)
            placeLine(self.ui, lineFrame, x1, y1, x2, y2, 1.5)
            lineFrame.BackgroundColor3 = self.ui.color(line.color[1], line.color[2], line.color[3])
        end
    end
    return true
end

function Renderer:destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return Renderer
