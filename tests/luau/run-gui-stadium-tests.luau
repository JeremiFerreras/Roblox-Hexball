local Scene = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumScene")
local Renderer = require("../../src/ReplicatedStorage/HaxballLab/GuiStadiumRenderer")
local Profile = require("../../src/ReplicatedStorage/HaxballLab/StadiumReference2D")
local Reference = require("../../src/ReplicatedStorage/HaxballLab/ClassicReference230")
local Codec = require("../../src/ReplicatedStorage/HaxballLab/NetCodec")
local SnapshotBuffer = require("../../src/ReplicatedStorage/HaxballLab/SnapshotBuffer")
local RosterAllocator = require("../../src/ReplicatedStorage/HaxballLab/RosterAllocator")
local MenuPreview = require("../../src/ReplicatedStorage/HaxballLab/MenuPreview")
local Plays = require("../../src/ReplicatedStorage/HaxballLab/ShowcasePlays")

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
check("presentation scale is explicitly configured", Profile.Presentation ~= nil and near(Profile.Presentation.studsPerUnit, 0.5))
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
local nearWall = Scene.clampCamera(layout, scene.bounds, { x = -162.5, y = 0 })
check("camera near a wall stops where the view edge meets the stadium edge",
    near(nearWall.x, -20) and near(nearWall.y, 0))
local insideRange = Scene.clampCamera(layout, scene.bounds, { x = 10, y = 150 })
check("camera follows X inside its range and centres a view taller than the stadium",
    near(insideRange.x, 10) and near(insideRange.y, 0))
local portraitCamera = Scene.clampCamera(portrait, scene.bounds, { x = 400, y = 0 })
check("narrow viewports pan horizontally but never past the stadium edge", near(portraitCamera.x, 70))
local missingCamera = Scene.clampCamera(layout, scene.bounds, nil)
check("missing camera focus defaults to the stadium centre", near(missingCamera.x, 0) and near(missingCamera.y, 0))

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
check("player number is a centered child of its moving disc",
    tokenOne.label.Parent == tokenOne.frame
    and near(tokenOne.label.Position.ScaleX, 0.5)
    and near(tokenOne.label.Position.ScaleY, 0.5)
    and near(tokenOne.label.Size.ScaleX, 0.88)
    and near(tokenOne.label.Size.ScaleY, 0.88))
-- At 1280x720 the view spans 800x450 units, so the camera may only travel x in [-20, 20]:
-- following the player at x=-162.5 is clamped to -20 and the player sits left of centre.
check("static pitch World container follows the clamped camera",
    near(renderer.world.Position.X, 672) and near(renderer.world.Position.Y, 360))
check("red token is visible and offset from the clamped camera", tokenOne.frame.Visible
    and near(tokenOne.frame.Position.X, 412) and near(tokenOne.frame.Position.Y, 360))
check("blue slot five uses its remote position", tokenFive.frame.Visible
    and near(tokenFive.frame.Position.X, 480) and near(tokenFive.frame.Position.Y, 328))
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

local pitchHost = fakeNode("Frame")
local mountedRenderer = Renderer.new(fakePlayerGui, scene, fakeUI, nil, Scene, pitchHost)
check("stadium renderer can mount inside a menu pitch panel", mountedRenderer.gui == nil
    and mountedRenderer.root.Parent == pitchHost)
mountedRenderer:render({
    players = { [1] = { id = 1, x = 0, y = 0, radius = 15, team = "red", label = "01" } },
    ball = { x = 10, y = 4, radius = 10, visible = true },
}, { x = 0, y = 0 })
check("mounted menu renderer uses the same stadium geometry", mountedRenderer.grass ~= nil
    and mountedRenderer.ballToken.Visible)
mountedRenderer:destroy()
check("mounted renderer cleanup destroys only its viewport", mountedRenderer.root == nil
    and pitchHost.Destroyed ~= true)


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



-- The live client renders at the display rate while snapshots arrive at 30 Hz.
local function presentationState(tick, phase, ballPosition, ballVelocity)
    local players = {}
    for slot = 1, Profile.PlayerCount do
        local velocity = slot * 60
        players[slot] = {
            x = tick * slot,
            y = 0,
            vx = slot,
            vy = 0,
        }
    end
    return {
        matchId = 88,
        round = 1,
        tick = tick,
        matchPhase = phase or "playing",
        coreMode = true,
        ball = { x = ballPosition or tick, y = 0, vx = ballVelocity or 1, vy = 0 },
        player = { x = tick, y = 0, vx = 1, vy = 0 },
        player2 = { x = tick * 2, y = 0, vx = 2, vy = 0 },
        players = players,
    }
end

local presentation = SnapshotBuffer.new()
presentation:push(presentationState(0), 0)
presentation:sample(0)
presentation:sample(1 / 60)
presentation:push(presentationState(2), 2 / 60)
presentation:sample(2 / 60)
local interpolated, interpolationStatus = presentation:sample(3 / 60)
check("30 Hz snapshots produce a distinct midpoint at a 60 Hz render sample",
    interpolated ~= nil and near(interpolated.ball.x, 1))
check("all eight player poses interpolate between server states",
    interpolated ~= nil and near(interpolated.players[5].x, 5)
    and near(interpolated.players[8].x, 8))
check("ball and player velocities are used as cubic Hermite tangents",
    interpolated ~= nil and near(interpolated.player2.x, 2))
check("presentation reports actual render cadence and source cadence",
    interpolationStatus ~= nil and interpolationStatus.renderFps > 55
    and interpolationStatus.renderFps < 65 and near(interpolationStatus.sourceRateHz, 30))
check("live presentation identifies the Hermite interpolation mode",
    interpolationStatus ~= nil and interpolationStatus.interpolation == "cubic-hermite")

local easingPresentation = SnapshotBuffer.new()
local easingStart = presentationState(0)
easingStart.ball.x, easingStart.ball.vx = 0, 0
local easingEnd = presentationState(2)
easingEnd.ball.x, easingEnd.ball.vx = 2, 2
easingPresentation:push(easingStart, 0)
easingPresentation:sample(0)
easingPresentation:push(easingEnd, 2 / 60)
easingPresentation:sample(2 / 60)
local eased = easingPresentation:sample(3 / 60)
check("Hermite interpolation preserves acceleration instead of forcing linear motion",
    eased ~= nil and near(eased.ball.x, 0.5))

local boundedPresentation = SnapshotBuffer.new()
local boundedStart = presentationState(0)
boundedStart.ball.x, boundedStart.ball.vx = 0, -3
local boundedEnd = presentationState(2)
boundedEnd.ball.x, boundedEnd.ball.vx = 2, 3
boundedPresentation:push(boundedStart, 0)
boundedPresentation:sample(0)
boundedPresentation:push(boundedEnd, 2 / 60)
boundedPresentation:sample(2 / 60)
local bounded = boundedPresentation:sample(3 / 60)
check("collision-direction changes cannot create large spline overshoot",
    bounded ~= nil and bounded.ball.x >= 0 and bounded.ball.x <= 2)

local kickoffPresentation = SnapshotBuffer.new()
kickoffPresentation:push(presentationState(0, "kickoff"), 0)
kickoffPresentation:sample(0)
kickoffPresentation:push(presentationState(2, "kickoff"), 2 / 60)
kickoffPresentation:sample(2 / 60)
local kickoffPose = kickoffPresentation:sample(3 / 60)
check("kickoff and non-playing phases are interpolated instead of packet-stepped",
    kickoffPose ~= nil and near(kickoffPose.ball.x, 1))

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

-- Team selection: a requested side is honoured, and a full side is never overflowed.
local choice = {}
check("chosen blue side receives the first blue slot", RosterAllocator.nextSlot(choice, 8, 4, "blue") == 5)
check("chosen red side receives the first red slot", RosterAllocator.nextSlot(choice, 8, 4, "red") == 1)
choice[1], choice[2], choice[3], choice[4] = 1, 2, 3, 4
check("full chosen side is rejected even with free rival slots",
    RosterAllocator.nextSlot(choice, 8, 4, "red") == nil and RosterAllocator.nextSlot(choice, 8, 4, "blue") == 5)
check("unknown team names are refused", not pcall(RosterAllocator.nextSlot, choice, 8, 4, "green"))

-- The menu showcase is generated by fixed-tick 4v4 gameplay physics, not authored poses or video.
check("playbook offers at least six distinct moves", #Plays >= 6)
local first = MenuPreview.getReplay(Core, Profile, Reference, Plays, 1)
check("showcase replays are cached per play and run at the 60 Hz physics tick",
    first == MenuPreview.getReplay(Core, Profile, Reference, Plays, 1 + #Plays) and first.tickRate == 60)

for index, play in ipairs(Plays) do
    local replay = MenuPreview.getReplay(Core, Profile, Reference, Plays, index)
    local report = replay.report
    print(string.format("SHOWCASE %s goal=%s actions=%d/%d opponent=%d stray=%d seconds=%.2f", play.id,
        tostring(report.goal), report.completed, report.actions, report.opponentTouches, report.strayTouches,
        replay.duration))
    check(play.id .. ": the scripted move ends in a goal", report.goal)
    check(play.id .. ": every touch of the move happens in order", report.completed == report.actions)
    check(play.id .. ": no defender or unplanned teammate deflects it",
        report.opponentTouches == 0 and report.strayTouches == 0)
    check(play.id .. ": brisk enough for a menu highlight", replay.duration > 3 and replay.duration < 12)
    check(play.id .. ": defenders actually contest the ball", report.closestOpponent < 60)

    local continuous, inside = true, true
    local travelled = table.create(8, 0)
    for tick = 2, #replay.frames do
        local before, after = replay.frames[tick - 1], replay.frames[tick]
        for slot = 1, 8 do
            local dx = after[slot * 2 - 1] - before[slot * 2 - 1]
            local dy = after[slot * 2] - before[slot * 2]
            local step = math.sqrt(dx * dx + dy * dy)
            travelled[slot] += step
            -- Top running speed is 2.4 units per tick; contacts add a small correction.
            continuous = continuous and step < 4
            inside = inside and math.abs(after[slot * 2 - 1]) <= 420 and math.abs(after[slot * 2]) <= 200
        end
        local bx, by = after[17] - before[17], after[18] - before[18]
        continuous = continuous and math.sqrt(bx * bx + by * by) < 12
        inside = inside and math.abs(after[17]) <= 420 and math.abs(after[18]) <= 200
    end
    check(play.id .. ": nothing teleports between physics ticks", continuous)
    check(play.id .. ": players and ball stay inside the stadium", inside)
    local everyoneMoves = true
    for slot = 1, 8 do
        everyoneMoves = everyoneMoves and travelled[slot] > 25
    end
    check(play.id .. ": all eight bots move during the play", everyoneMoves)

    local clearStart = true
    local initial = replay.frames[1]
    for slot = 1, 8 do
        local dx, dy = initial[slot * 2 - 1] - initial[17], initial[slot * 2] - initial[18]
        clearStart = clearStart and math.sqrt(dx * dx + dy * dy) >= 25
    end
    check(play.id .. ": nobody starts on top of the ball", clearStart)

    -- A bank pass must really come off the wall before the next touch.
    for order, action in ipairs(play.actions) do
        if action.bank then
            local kicked, collected = nil, nil
            local count = 0
            for _, kick in ipairs(replay.kicks) do
                count += 1
                local passIndex = 0
                for earlier = 1, order do
                    if play.actions[earlier].kind ~= "dribble" then
                        passIndex += 1
                    end
                end
                if count == passIndex then
                    kicked = kick.tick
                elseif count == passIndex + 1 then
                    collected = kick.tick
                end
            end
            local banked = false
            for tick = kicked or 1, collected or 1 do
                banked = banked or replay.frames[tick + 1][18] * action.bank > 159
            end
            check(play.id .. ": the bank pass rebounds off the wall", banked)
        end
    end
end

local poseA = MenuPreview.sample(first, 1.25)
local poseB = MenuPreview.sample(first, 1.25 + 1 / 120)
check("menu preview samples smoothly between 60 Hz physics ticks",
    math.abs(poseA.ball.x - poseB.ball.x) + math.abs(poseA.ball.y - poseB.ball.y) < 6)
check("sampled pose holds a full 4v4 and a ball trail",
    #poseA.players == 8 and poseA.players[1].team == "red" and poseA.players[5].team == "blue" and #poseA.trail > 0)

local mirroredIndex = nil
for index, play in ipairs(Plays) do
    if play.mirror then
        mirroredIndex = index
        break
    end
end
check("some highlights belong to the blue side", mirroredIndex ~= nil)
local mirrored = MenuPreview.getReplay(Core, Profile, Reference, Plays, mirroredIndex)
local mirroredPose = MenuPreview.sample(mirrored, 0)
check("a mirrored play flips the pitch and swaps shirt colours",
    near(mirroredPose.ball.x, -mirrored.frames[1][17])
    and mirroredPose.players[5].team == "blue" and near(mirroredPose.players[5].x, -mirrored.frames[1][1]))

local show = MenuPreview.newShow(Core, Profile, Reference, Plays)
local visited, wrapped, goalsShown = {}, false, 0
local hadGoal = false
for _ = 1, 60 * 90 do
    local _, info = show:advance(1 / 60)
    if info.goal and not hadGoal then
        goalsShown += 1
    end
    hadGoal = info.goal
    if visited[#Plays] and info.index == 1 then
        wrapped = true
        break
    end
    visited[info.index] = true
end
check("the showcase plays every move, celebrates each goal and loops",
    wrapped and #visited == #Plays and goalsShown == #Plays)
show:select(3)
local _, selected = show:advance(0)
check("a play can be selected directly and starts covered by the fade", selected.index == 3 and selected.cover == 1)

local trailHost = fakeNode("Frame")
local trailRenderer = Renderer.new(fakePlayerGui, scene, fakeUI, nil, Scene, trailHost)
trailRenderer.fitWholePitch = true
trailRenderer:render(MenuPreview.sample(first, 2), { x = 0, y = 0 })
check("spectator view fits the whole stadium", near(trailRenderer.lastScale, math.min(1280 / 840, 720 / 400)))
check("spectator view draws the ball trail", trailRenderer.trailTokens ~= nil and #trailRenderer.trailTokens > 0)
trailRenderer:destroy()

print(string.format("GUI_STADIUM_TESTS_OK passed=%d", passed))
