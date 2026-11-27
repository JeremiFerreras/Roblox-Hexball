local Scene = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumScene")
local Renderer = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumRenderer")
local Profile = require("../../src/ReplicatedStorage/HaxballLab/StadiumReference2D")
local Reference = require("../../src/ReplicatedStorage/HaxballLab/ClassicReference230")
local Codec = require("../../src/ReplicatedStorage/HaxballLab/NetCodec")
local RosterAllocator = require("../../src/ReplicatedStorage/HaxballLab/RosterAllocator")

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
check("scene roster is exactly four versus four", scene.playerCount == 8 and scene.playersPerTeam == 4)
check("spawn configuration contains exactly eight players", Profile.PlayerCount == 8 and #Profile.SpawnPoints == 8)
check("outer grass matches reference RGB", table.concat(scene.palette.outerGrass, ",") == "116,146,92")
check("main grass matches reference RGB", table.concat(scene.palette.grass, ",") == "112,156,93")
check("mowing stripe matches reference RGB", table.concat(scene.palette.stripeA, ",") == "123,164,108")
check("pitch lines match reference RGB", table.concat(scene.palette.line, ",") == "199,235,187")
check("team reds match reference RGB", table.concat(scene.palette.red, ",") == "217,99,89")
check("team blues match reference RGB", table.concat(scene.palette.blue, ",") == "89,130,221")
check("goal posts match reference RGB", table.concat(scene.palette.post, ",") == "249,198,205")
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
            if key == "BackgroundColor3" and value == nil then
                error("BackgroundColor3 cannot be nil; use a valid transparent fill color")
            end
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
    CanCollide = true,
    CanTouch = true,
    CanQuery = true,
    IsA = function(_, className) return className == "BasePart" end,
}
local legacyField = {
    GetDescendants = function() return { legacyPart } end,
}
local fakePlayerGui = { Children = {} }
local renderer = Renderer.new(fakePlayerGui, scene, fakeUI, legacyField, Scene)
check("GUI renderer creates ScreenGui in PlayerGui", renderer.gui.Parent == fakePlayerGui)
check("GUI renderer creates static grass and stripe layers", renderer.grass ~= nil and #renderer.stripeFrames == #scene.stripes)
check("legacy 3D BaseParts are hidden locally", legacyPart.LocalTransparencyModifier == 1)
check("GUI hiding leaves physical collision flags untouched", legacyPart.CanCollide == true
    and legacyPart.CanTouch == true and legacyPart.CanQuery == true)
check("GUI renderer creates eight reusable player tokens", #renderer.playerTokens == 8)
check("GUI renderer creates one reusable ball token", renderer.ballToken ~= nil)

renderer:render({
    players = {
        [1] = { id = 1, userId = 12345, x = -162.5, y = 0, radius = 15, team = "red", label = "01" },
        [5] = { id = 5, x = -120, y = 20, radius = 15, team = "blue", label = "05" },
    },
    ball = { x = -150, y = 24, radius = 10, visible = true },
    debugLines = {
        { a = { x = -162.5, y = 0 }, b = { x = -150, y = 24 }, color = { 70, 255, 130 }, visible = true },
    },
}, { x = -162.5, y = 0 })

local tokenOne = renderer.playerTokens[1]
local tokenFive = renderer.playerTokens[5]
check("red token is visible and centered on followed player", tokenOne.frame.Visible
    and near(tokenOne.frame.Position.X, 640) and near(tokenOne.frame.Position.Y, 360))
check("blue slot five uses its remote position", tokenFive.frame.Visible
    and near(tokenFive.frame.Position.X, 708) and near(tokenFive.frame.Position.Y, 328))
check("owned player receives a Roblox headshot thumbnail", tokenOne.avatar.Visible
    and tokenOne.avatar.Image == "rbxthumb://type=AvatarHeadShot&id=12345&w=48&h=48")
check("unowned blue slot uses numeric badge without avatar request", not tokenFive.avatar.Visible
    and tokenFive.label.Text == "05")
check("player token diameter matches physical radius", near(tokenOne.frame.Size.X, 48))
check("ball diameter matches physical radius", near(renderer.ballToken.Size.X, 32))
check("absent players remain hidden", renderer.playerTokens[2].frame.Visible == false)
check("debug collision line is represented in GUI", renderer.debugLines[1].Visible)
renderer:render({
    players = { [1] = { id = 1, x = 0, y = 0, radius = 15, team = "red", label = "01" } },
    ball = { x = 0, y = 0, radius = 10, visible = true },
}, { x = 0, y = 0 })
check("avatar image is cleared when a slot becomes unowned", not tokenOne.avatar.Visible and tokenOne.avatar.Image == "")
check("center circle keeps 75-unit visual radius", near(renderer.centerCircle.Size.X, 240))
renderer:destroy()
check("renderer cleanup destroys its ScreenGui", renderer.gui == nil)


-- Network codec contract for the four-a-side roster.
local commands = {}
for index = 1, 8 do
    commands[index] = { seq = index, tick = index * 2, mask = index % 2 == 0 and 2 or 1 }
end
local encodedInputs = Codec.encodeInput(7, 3, commands)
local decodedInputs = Codec.decodeInput(encodedInputs)
check("4v4 input packet accepts eight command records", decodedInputs ~= nil and #decodedInputs.commands == 8)

local wirePlayers = {}
for slot = 1, Profile.PlayerCount do
    wirePlayers[slot] = {
        id = slot, team = slot <= Profile.PlayersPerTeam and "red" or "blue",
        x = slot * 10, y = -slot * 2, vx = 0.25, vy = -0.5,
        ack = slot, kickCooldown = 0, kickHeld = false, kickArmed = true,
        needsKickRelease = false, collisionMask = Profile.CollisionMasks.player,
        inputMask = 0, ownerUserId = 1000 + slot,
    }
end
local state = {
    coreMode = true, players = wirePlayers, matchPhase = "playing",
    matchId = 21, round = 4, tick = 120, elapsedMatchTicks = 120,
    pauseTicksRemaining = 0, kickoffTeam = nil, winner = nil,
    score = { red = 2, blue = 1 },
    lastTouch = { playerId = 8, team = "blue", kind = "kick", tick = 119 },
    lastGoal = nil, ball = { x = 1.25, y = -2.5, vx = 3, vy = 4 },
}
local encodedState = Codec.encodeState(state)
check("4v4 state packet is 400 bytes", buffer.len(encodedState) == 400)
local decodedState = Codec.decodeState(encodedState, state)
check("4v4 state packet restores all eight players", decodedState ~= nil and #decodedState.players == 8)
check("blue team starts at slot five", decodedState ~= nil and decodedState.player2.id == 5)
check("player eight touch survives network encoding", decodedState ~= nil and decodedState.lastTouch.playerId == 8)
check("player ownership metadata survives bootstrap", decodedState ~= nil and decodedState.players[8].ownerUserId == 1008)
local invalid = table.clone(state)
invalid.players = table.clone(wirePlayers)
invalid.players[9] = table.clone(wirePlayers[8])
invalid.players[10] = table.clone(wirePlayers[8])
local acceptedLegacyTen = pcall(function() Codec.encodeState(invalid) end)
check("legacy ten-player state is rejected", not acceptedLegacyTen)


local roster = {}
local joinOrder = {}
for player = 1, 8 do
    local slot = RosterAllocator.nextSlot(roster, 8, 4)
    joinOrder[player] = slot
    roster[slot] = 5000 + player
end
check("4v4 allocator alternates teams while counts are tied",
    joinOrder[1] == 1 and joinOrder[2] == 5 and joinOrder[3] == 2 and joinOrder[4] == 6)
check("4v4 allocator fills exactly four red and four blue slots",
    joinOrder[5] == 3 and joinOrder[6] == 7 and joinOrder[7] == 4 and joinOrder[8] == 8)
check("4v4 allocator rejects a ninth player without overwriting owners",
    RosterAllocator.nextSlot(roster, 8, 4) == nil and roster[1] == 5001 and roster[8] == 5008)
local unbalancedRoster = { [1] = 7001, [2] = 7002 }
check("4v4 allocator fills the smaller team first",
    RosterAllocator.nextSlot(unbalancedRoster, 8, 4) == 5)

local mockDisc = {
    x = 90, y = 40, vx = 4, vy = -3,
    ownerUserId = nil, enabled = false,
    kickHeld = true, kickArmed = true, kickCooldown = 2,
}
RosterAllocator.activate(mockDisc, 9876)
check("allocated player disc becomes active and owner-bound",
    mockDisc.enabled and mockDisc.ownerUserId == 9876)
RosterAllocator.deactivate(mockDisc, { x = -150, y = 0 })
check("released player disc is inactive, stopped and returned to spawn",
    not mockDisc.enabled and mockDisc.ownerUserId == nil
    and mockDisc.vx == 0 and mockDisc.vy == 0
    and mockDisc.x == -150 and mockDisc.y == 0
    and not mockDisc.kickHeld and not mockDisc.kickArmed and mockDisc.kickCooldown == 0)

local Core = require("../../src/ReplicatedStorage/HaxballLab/PhysicsCore2D")
local inactiveWorld = Core.newWorld({ useBounds = false })
local testBall = Core.addDisc(inactiveWorld, { id = "ball", kind = "ball", x = 0, y = 0, radius = 10, invMass = 1 })
local emptySlot = Core.addDisc(inactiveWorld, {
    id = 1, kind = "player", x = 0, y = 0, radius = 15, invMass = 1,
    enabled = false,
})
Core.stepWorld(inactiveWorld, {})
check("unoccupied disabled slot cannot push the ball", testBall.x == 0 and testBall.y == 0)
emptySlot.enabled = true
Core.stepWorld(inactiveWorld, {})
check("occupied enabled player disc participates in physical collision",
    testBall.x ~= 0 or testBall.y ~= 0)

print(string.format("GUI_STADIUM_TESTS_OK passed=%d", passed))
