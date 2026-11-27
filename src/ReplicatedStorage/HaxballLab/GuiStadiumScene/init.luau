--!strict
-- Pure 2D stadium description. No Roblox Instances, services, or physics mutations.
type Point = { x: number, y: number }
type Rect = { minX: number, maxX: number, minY: number, maxY: number }
type RGB = { number }
type Palette = {
    outerGrass: RGB, grass: RGB, stripeA: RGB, stripeB: RGB,
    line: RGB, goal: RGB, post: RGB, red: RGB, blue: RGB, ball: RGB, debug: RGB,
}
type StadiumSegment = {
    id: string?, x1: number, y1: number, x2: number, y2: number,
    curveF: number?, centerX: number?, centerY: number?, arcRadius: number?,
    collisionGroup: number,
}
type StadiumProfile = {
    Bounds: { minX: number, maxX: number, minY: number, maxY: number, spanWidth: number, spanHeight: number },
    PlayArea: { minX: number, maxX: number, minY: number, maxY: number },
    StadiumProperties: { bg: { width: number, height: number, kickOffRadius: number } },
    CollisionGroups: { wall: number },
}
type StadiumReference = {
    segments: { StadiumSegment },
    posts: { { id: string?, x: number, y: number, radius: number } },
}
type Stripe = { id: string, a: Point, b: Point, thickness: number, color: string }
type SceneLine = { id: string, a: Point, b: Point, thickness: number, color: string, layer: string }
type Circle = { id: string, x: number, y: number, radius: number, thickness: number, color: string }
type Post = { id: string, x: number, y: number, radius: number, fill: string, stroke: string }
type SceneData = {
    width: number, height: number, bounds: Rect, grass: Rect, palette: Palette,
    stripes: { Stripe }, lines: { SceneLine }, circles: { Circle }, posts: { Post },
}
type Layout = { width: number, height: number, scale: number }
type Camera = { x: number?, y: number? }

local Scene = {}

Scene.Palette = {
    outerGrass = { 116, 146, 92 },
    grass = { 120, 160, 104 },
    stripeA = { 127, 168, 112 },
    stripeB = { 108, 152, 89 },
    line = { 199, 221, 184 },
    goal = { 12, 15, 13 },
    post = { 246, 191, 198 },
    red = { 229, 105, 98 },
    blue = { 75, 130, 224 },
    ball = { 255, 255, 255 },
    debug = { 255, 220, 70 },
}

local function finite(value: any): boolean
    return type(value) == "number" and value == value and math.abs(value) < 1e12
end

local function copyPoint(point: Point): Point
    return { x = point.x, y = point.y }
end

local function clipAxis(origin: number, direction: number, low: number, high: number): (number?, number?)
    if math.abs(direction) < 1e-9 then
        if origin < low or origin > high then
            return nil, nil
        end
        return -math.huge, math.huge
    end
    local first = (low - origin) / direction
    local last = (high - origin) / direction
    return math.min(first, last), math.max(first, last)
end

local function clipDiagonal(rect: Rect, offset: number, angle: number): (Point?, Point?)
    local dx, dy = math.cos(angle), math.sin(angle)
    local nx, ny = -dy, dx
    local x0, y0 = nx * offset, ny * offset
    local tx0, tx1 = clipAxis(x0, dx, rect.minX, rect.maxX)
    local ty0, ty1 = clipAxis(y0, dy, rect.minY, rect.maxY)
    if tx0 == nil or ty0 == nil then
        return nil, nil
    end
    local xStart, xEnd = assert(tx0), assert(tx1)
    local yStart, yEnd = assert(ty0), assert(ty1)
    local t0, t1 = math.max(xStart, yStart), math.min(xEnd, yEnd)
    if not finite(t0) or not finite(t1) or t1 - t0 < 1e-8 then
        return nil, nil
    end
    return {
        x = x0 + dx * t0,
        y = y0 + dy * t0,
    }, {
        x = x0 + dx * t1,
        y = y0 + dy * t1,
    }
end

function Scene.segmentPoints(segment: StadiumSegment, angularStep: number?): { Point }
    angularStep = angularStep or math.pi / 36
    assert(finite(angularStep) and angularStep > 0 and angularStep < math.pi, "invalid angular step")
    if type(segment.curveF) ~= "number" then
        return {
            { x = segment.x1, y = segment.y1 },
            { x = segment.x2, y = segment.y2 },
        }
    end

    local curveF = assert(segment.curveF)
    local centerX = assert(segment.centerX)
    local centerY = assert(segment.centerY)
    local arcRadius = assert(segment.arcRadius)
    local sweep = curveF == 0 and math.pi or 2 * math.atan(1 / curveF)
    local startAngle = math.atan2(segment.y1 - centerY, segment.x1 - centerX)
    local count = math.max(1, math.ceil(math.abs(sweep) / angularStep))
    local points: { Point } = {}
    for index = 0, count do
        local angle = startAngle + sweep * index / count
        table.insert(points, {
            x = centerX + arcRadius * math.cos(angle),
            y = centerY + arcRadius * math.sin(angle),
        })
    end
    -- Exact endpoints prevent hairline gaps at joins.
    points[1] = { x = segment.x1, y = segment.y1 }
    points[#points] = { x = segment.x2, y = segment.y2 }
    return points
end

local function appendLine(lines: { SceneLine }, id: string, a: Point, b: Point, thickness: number, color: string, layer: string?)
    local dx, dy = b.x - a.x, b.y - a.y
    if dx * dx + dy * dy <= 1e-12 then
        return
    end
    table.insert(lines, {
        id = id,
        a = copyPoint(a),
        b = copyPoint(b),
        thickness = thickness,
        color = color,
        layer = layer or "marking",
    })
end

function Scene.build(profile: StadiumProfile, reference: StadiumReference): SceneData
    assert(type(profile) == "table" and type(reference) == "table", "profile and reference are required")
    local bounds = profile.Bounds
    local playArea = profile.PlayArea
    local bg = profile.StadiumProperties.bg
    assert(bounds and playArea and bg and reference.segments and reference.posts, "incomplete stadium reference")

    local grass: Rect = {
        minX = playArea.minX or -bg.width,
        maxX = playArea.maxX or bg.width,
        minY = playArea.minY or -bg.height,
        maxY = playArea.maxY or bg.height,
    }
    local scene: SceneData = {
        width = bounds.spanWidth,
        height = bounds.spanHeight,
        bounds = {
            minX = bounds.minX,
            maxX = bounds.maxX,
            minY = bounds.minY,
            maxY = bounds.maxY,
        },
        grass = grass,
        palette = Scene.Palette,
        stripes = {},
        lines = {},
        circles = {},
        posts = {},
    }

    -- Diagonal mowing bands use the same clipped rectangle for every resolution.
    local stripeAngle = math.rad(-45)
    local stripeSpacing = 36
    local stripeWidth = 18
    local nx, ny = -math.sin(stripeAngle), math.cos(stripeAngle)
    local maxOffset = math.abs(nx) * grass.maxX + math.abs(ny) * grass.maxY
    local stripeIndex = 0
    for offset = -maxOffset, maxOffset, stripeSpacing do
        local a, b = clipDiagonal(grass, offset, stripeAngle)
        if a and b then
            stripeIndex += 1
            table.insert(scene.stripes, {
                id = string.format("mowing-stripe-%02d", stripeIndex),
                a = a,
                b = b,
                thickness = stripeWidth,
                color = stripeIndex % 2 == 0 and "stripeA" or "stripeB",
            })
        end
    end

    -- Touchlines and halfway line are presentation geometry only.
    appendLine(scene.lines, "touchline-top",
        { x = grass.minX, y = grass.maxY }, { x = grass.maxX, y = grass.maxY },
        1.8, "line", "marking")
    appendLine(scene.lines, "touchline-bottom",
        { x = grass.minX, y = grass.minY }, { x = grass.maxX, y = grass.minY },
        1.8, "line", "marking")
    appendLine(scene.lines, "halfway-line",
        { x = 0, y = grass.minY }, { x = 0, y = grass.maxY },
        1.8, "line", "marking")

    -- Reuse the exact reference segments that the discrete collision profile installs.
    local wallGroup = profile.CollisionGroups.wall
    for segmentIndex, segment in ipairs(reference.segments) do
        if segment.collisionGroup == wallGroup then
            local goalSegment = math.max(math.abs(segment.x1), math.abs(segment.x2)) > grass.maxX + 0.5
            local color = goalSegment and "goal" or "line"
            local thickness = goalSegment and 2.25 or 1.8
            local points = Scene.segmentPoints(segment, math.pi / 72)
            for pointIndex = 1, #points - 1 do
                appendLine(scene.lines,
                    string.format("reference-segment-%02d-%02d", segmentIndex, pointIndex),
                    points[pointIndex], points[pointIndex + 1],
                    thickness, color, goalSegment and "goal" or "marking")
            end
        end
    end

    -- The Classic reference uses a 75-unit kickoff circle. Do not scale it down
    -- to the old cosmetic 45-unit approximation.
    table.insert(scene.circles, {
        id = "center-circle",
        x = 0,
        y = 0,
        radius = bg.kickOffRadius,
        thickness = 1.8,
        color = "line",
    })

    for index, post in ipairs(reference.posts) do
        table.insert(scene.posts, {
            id = post.id or ("post-" .. index),
            x = post.x,
            y = post.y,
            radius = post.radius,
            fill = "post",
            stroke = "goal",
        })
    end

    assert(scene.width > 0 and scene.height > 0, "invalid stadium bounds")
    assert(#scene.stripes > 0 and #scene.lines >= 10 and #scene.posts == 4, "incomplete Classic stadium scene")
    return scene
end

function Scene.fit(viewportWidth: number, viewportHeight: number): Layout
    assert(finite(viewportWidth) and finite(viewportHeight) and viewportWidth > 0 and viewportHeight > 0,
        "viewport dimensions must be positive finite numbers")
    -- Show the full 400-unit pitch height with a small horizontal crop on 16:9,
    -- as in the reference screenshot. Narrow screens fall back to width fitting.
    local scale = math.min(viewportWidth / 700, viewportHeight / 450)
    return {
        width = viewportWidth,
        height = viewportHeight,
        scale = scale,
    }
end

function Scene.toViewport(x: number, y: number, layout: Layout, camera: Camera?): (number, number)
    assert(finite(x) and finite(y) and type(layout) == "table" and finite(layout.scale) and layout.scale > 0,
        "invalid world point or layout")
    camera = camera or { x = 0, y = 0 }
    local cameraX = finite(camera.x) and camera.x or 0
    local cameraY = finite(camera.y) and camera.y or 0
    return layout.width * 0.5 + (x - cameraX) * layout.scale,
        layout.height * 0.5 - (y - cameraY) * layout.scale
end

function Scene.toLogical(screenX: number, screenY: number, layout: Layout, camera: Camera?): Point
    assert(finite(screenX) and finite(screenY) and type(layout) == "table" and finite(layout.scale) and layout.scale > 0,
        "invalid screen point or layout")
    camera = camera or { x = 0, y = 0 }
    local cameraX = finite(camera.x) and camera.x or 0
    local cameraY = finite(camera.y) and camera.y or 0
    return {
        x = cameraX + (screenX - layout.width * 0.5) / layout.scale,
        y = cameraY - (screenY - layout.height * 0.5) / layout.scale,
    }
end

return Scene
