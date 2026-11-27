local Scene = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumScene")
local Renderer = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumRenderer")
local Profile = require("../../src/ReplicatedStorage/HaxballLab/StadiumReference2D")
local Reference = require("../../src/ReplicatedStorage/HaxballLab/ClassicReference230")

local passed = 0
local function check(name, condition)
    if not condition then
        error("FAIL " .. name, 2)
    end
    passed += 1
    print("PASS " .. name)
end

local function near(a, b, epsilon)
    return math.abs(a - b) <= (epsilon or 1e-7)
end

local scene = Scene.build(Profile, Reference)
check("stadium bounds retain 840x400 logical units", scene.width == 840 and scene.height == 400)
check("playable grass rectangle matches Classic HBS", scene.grass.minX == -370 and scene.grass.maxX == 370
    and scene.grass.minY == -170 and scene.grass.maxY == 170)
check("all four physical posts are present", #scene.posts == 4)
check("center circle uses the 75-unit reference radius", #scene.circles == 1 and scene.circles[1].radius == 75)
check("diagonal stripes are generated in a bounded count", #scene.stripes >= 18 and #scene.stripes <= 24)
check("pitch and goal markings are generated", #scene.lines >= 20)

for _, stripe in ipairs(scene.stripes) do
    check("stripe endpoints remain inside grass: " .. stripe.id,
        stripe.a.x >= scene.grass.minX - 1e-6 and stripe.a.x <= scene.grass.maxX + 1e-6
        and stripe.b.x >= scene.grass.minX - 1e-6 and stripe.b.x <= scene.grass.maxX + 1e-6
        and stripe.a.y >= scene.grass.minY - 1e-6 and stripe.a.y <= scene.grass.maxY + 1e-6
        and stripe.b.y >= scene.grass.minY - 1e-6 and stripe.b.y <= scene.grass.maxY + 1e-6)
end

local goalCurveCount = 0
for _, line in ipairs(scene.lines) do
    if line.layer == "goal" then
        goalCurveCount += 1
    end
    check("non-degenerate line: " .. line.id,
        (line.a.x - line.b.x)^2 + (line.a.y - line.b.y)^2 > 1e-8)
end
check("curved physical goal outlines are sampled", goalCurveCount >= 20)

local layout = Scene.fit(1280, 720)
check("16:9 reference view uses 1.6 px per logical unit", near(layout.scale, 1.6))
local lineX = Scene.toViewport(0, 0, layout, { x = -162.5, y = 0 })
check("camera follow places halfway line at reference x=900", near(lineX, 900))
local centerX, centerY = Scene.toViewport(0, 0, layout, { x = 0, y = 0 })
check("origin is centered for a neutral camera", near(centerX, 640) and near(centerY, 360))
local roundTrip = Scene.toLogical(777, 284, layout, { x = -35, y = 12 })
local roundTripX, roundTripY = Scene.toViewport(roundTrip.x, roundTrip.y, layout, { x = -35, y = 12 })
check("world/screen transform round-trips", near(roundTripX, 777) and near(roundTripY, 284))
local portrait = Scene.fit(390, 844)
check("portrait viewport scales by width without stretching", near(portrait.scale, 390 / 700))
local wide = Scene.fit(1920, 1080)
check("ultrawide layout remains finite", wide.scale > 0 and wide.scale < 3)

-- Exercise the GUI renderer with a fake UI adapter: no Roblox Studio or 3D engine.
local function fakeNode(className)
    local node = { ClassName = className, Children = {} }
    setmetatable(node, {
        __newindex = function(target, key, value)
            rawset(target, key, value)
            if key == "Parent" and type(value) == "table" and value.Children then
                table.insert(value.Children, target)
            end
        end,
    })
    if className == "Frame" then
        node.AbsoluteSize = { X = 1280, Y = 720 }
    end
    node.Destroy = function(self) self.Destroyed = true end
    return node
end

local fakeUI = {
    new = fakeNode,
    color = function(r, g, b) return { R = r, G = g, B = b } end,
    offset = function(x, y) return { X = x, Y = y } end,
    scale = function(x, y) return { ScaleX = x, ScaleY = y } end,
    vector = function(x, y) return { X = x, Y = y } end,
    circleCorner = { Scale = 1, Offset = 0 },
    strokeBorder = "Border",
    boldFont = "GothamBold",
    siblingZIndex = "Sibling",
}

local legacyPart = {
    IsA = function(_, className) return className == "BasePart" end,
}
local legacyField = {
    GetDescendants = function() return { legacyPart } end,
}
local fakePlayerGui = { Children = {} }
local renderer = Renderer.new(fakePlayerGui, scene, fakeUI, legacyField, Scene)
check("GUI renderer creates ScreenGui in PlayerGui", renderer.gui.Parent == fakePlayerGui)
check("GUI renderer creates static grass and stripe layers", renderer.grass ~= nil and #renderer.stripeFrames == #scene.stripes)
check("legacy 3D BaseParts are hidden locally", legacyPart.LocalTransparencyModifier == 1
    and legacyPart.CanCollide == false and legacyPart.CanTouch == false and legacyPart.CanQuery == false)
check("GUI renderer creates ten reusable player tokens", #renderer.playerTokens == 10)
check("GUI renderer creates one reusable ball token", renderer.ballToken ~= nil)

renderer:render({
    players = {
        [1] = { id = 1, x = -162.5, y = 0, radius = 15, team = "red", label = "01" },
        [6] = { id = 6, x = -120, y = 20, radius = 15, team = "blue", label = "06" },
    },
    ball = { x = -150, y = 24, radius = 10, visible = true },
    debugLines = {
        { a = { x = -162.5, y = 0 }, b = { x = -150, y = 24 }, color = { 70, 255, 130 }, visible = true },
    },
}, { x = -162.5, y = 0 })

local tokenOne = renderer.playerTokens[1]
local tokenSix = renderer.playerTokens[6]
check("red token is visible and centered on followed player", tokenOne.frame.Visible
    and near(tokenOne.frame.Position.X, 640) and near(tokenOne.frame.Position.Y, 360))
check("blue token uses its remote position", tokenSix.frame.Visible
    and near(tokenSix.frame.Position.X, 707.2) and near(tokenSix.frame.Position.Y, 328))
check("player token diameter matches physical radius", near(tokenOne.frame.Size.X, 48))
check("ball diameter matches physical radius", near(renderer.ballToken.Size.X, 32))
check("absent players remain hidden", renderer.playerTokens[2].frame.Visible == false)
check("debug collision line is represented in GUI", renderer.debugLines[1].Visible)
check("center circle keeps 75-unit visual radius", near(renderer.centerCircle.Size.X, 240))
renderer:destroy()
check("renderer cleanup destroys its ScreenGui", renderer.gui == nil)

print(string.format("GUI_STADIUM_TESTS_OK passed=%d", passed))
