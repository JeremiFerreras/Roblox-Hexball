-- Procedural, presentation-only classic soccer stadium.
-- Geometry is derived from StadiumReference2D / ClassicReference230 and never collides.
local Builder = {}

local PALETTE = {
	deck = Color3.fromRGB(246, 247, 239),
	deckEdge = Color3.fromRGB(235, 239, 226),
	grass = Color3.fromRGB(119, 151, 101),
	stripeA = Color3.fromRGB(128, 160, 111),
	stripeB = Color3.fromRGB(110, 144, 93),
	line = Color3.fromRGB(199, 221, 184),
	net = Color3.fromRGB(164, 190, 156),
	red = Color3.fromRGB(229, 105, 98),
	blue = Color3.fromRGB(75, 130, 224),
}

local function makePart(parent, name, size, cframe, color, material, transparency, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	if shape then part.Shape = shape end
	part.Parent = parent
	return part
end

local function toWorld(x, y, height, presentation, render)
	local point = render.toWorld(x, y, presentation)
	point.y = height
	return Vector3.new(point.x, point.y, point.z)
end

local function drawLine(parent, name, a, b, thickness, height, color, presentation, render, transparency)
	local p0 = toWorld(a.x, a.y, height, presentation, render)
	local p1 = toWorld(b.x, b.y, height, presentation, render)
	local delta = p1 - p0
	if delta.Magnitude < 1e-4 then return nil end
	return makePart(
		parent,
		name,
		Vector3.new(thickness, 0.055, delta.Magnitude + 0.08),
		CFrame.lookAt((p0 + p1) * 0.5, p1, Vector3.yAxis),
		color,
		Enum.Material.SmoothPlastic,
		transparency
	)
end

local function drawArc(parent, name, center, radius, startAngle, endAngle, segments, thickness, height, color, presentation, render)
	local previous
	for index = 0, segments do
		local angle = startAngle + (endAngle - startAngle) * index / segments
		local point = { x = center.x + radius * math.cos(angle), y = center.y + radius * math.sin(angle) }
		if previous then
			drawLine(parent, string.format("%s_%02d", name, index), previous, point, thickness, height, color, presentation, render)
		end
		previous = point
	end
end

local function clipDiagonal(xMin, xMax, yMin, yMax, offset, angle)
	local dx, dy = math.cos(angle), math.sin(angle)
	local nx, ny = -dy, dx
	local x0, y0 = nx * offset, ny * offset
	local function clipAxis(origin, direction, low, high)
		if math.abs(direction) < 1e-8 then
			if origin < low or origin > high then return nil end
			return -math.huge, math.huge
		end
		local a, b = (low - origin) / direction, (high - origin) / direction
		return math.min(a, b), math.max(a, b)
	end
	local tx0, tx1 = clipAxis(x0, dx, xMin, xMax)
	local ty0, ty1 = clipAxis(y0, dy, yMin, yMax)
	if not tx0 or not ty0 then return nil end
	local t0, t1 = math.max(tx0, ty0), math.min(tx1, ty1)
	if t0 >= t1 then return nil end
	return { x = x0 + dx * t0, y = y0 + dy * t0 }, { x = x0 + dx * t1, y = y0 + dy * t1 }
end

function Builder.build(fieldModel, profile, reference, render)
	assert(fieldModel and profile and reference and render, "missing stadium visual dependency")
	local old = fieldModel:FindFirstChild("Phase6ClassicVisual")
	if old then old:Destroy() end
	local visual = Instance.new("Model")
	visual.Name = "Phase6ClassicVisual"
	visual:SetAttribute("PresentationOnly", true)
	visual:SetAttribute("Source", "Classic HBS coordinates via StadiumReference2D / ClassicReference230")
	visual.Parent = fieldModel

	local presentation = profile.Presentation
	local scale = presentation.studsPerUnit
	local bounds, area, goals, bg = profile.Bounds, profile.PlayArea, profile.Goals, profile.StadiumProperties.bg
	local yDeck, yGrass, yStripe, yMark = 9.65, 10.22, 10.322, 10.405
	local halfOuterX, halfOuterZ = bounds.halfWidth * scale, bounds.halfHeight * scale
	local halfPlayX = area.width * scale * 0.5

	-- Light neutral apron matches the clean Classic reference and frames the field.
	makePart(visual, "StadiumApron", Vector3.new(halfOuterX * 2 + 12, 1.1, halfOuterZ * 2 + 12),
		CFrame.new(0, yDeck, 0), PALETTE.deck, Enum.Material.SmoothPlastic)
	makePart(visual, "ApronInset", Vector3.new(halfOuterX * 2 + 4, 0.08, halfOuterZ * 2 + 4),
		CFrame.new(0, 10.235, 0), PALETTE.deckEdge)

	-- HBS bg.width/bg.height are half extents, matching the physical Classic map.
	local bgX, bgZ = bg.width * scale, bg.height * scale
	makePart(visual, "ClassicGrass", Vector3.new(bgX * 2, 0.18, bgZ * 2),
		CFrame.new(0, yGrass, 0), PALETTE.grass, Enum.Material.SmoothPlastic)

	-- Soft diagonal mowing bands, clipped to the HBS grass rectangle.
	local stripeAngle, stripeSpacing, stripeWidth = math.rad(-45), 36, 8.5
	local nx, ny = -math.sin(stripeAngle), math.cos(stripeAngle)
	local maxOffset = math.abs(nx) * bg.width + math.abs(ny) * bg.height
	local stripeIndex = 0
	for offset = -maxOffset, maxOffset, stripeSpacing do
		local a, b = clipDiagonal(-bg.width, bg.width, -bg.height, bg.height, offset, stripeAngle)
		if a and b then
			local dx, dy = b.x - a.x, b.y - a.y
			local length = math.sqrt(dx * dx + dy * dy)
			local inset = stripeWidth / (2 * scale)
			if length > inset * 2 then
				local ux, uy = dx / length, dy / length
				a = { x = a.x + ux * inset, y = a.y + uy * inset }
				b = { x = b.x - ux * inset, y = b.y - uy * inset }
				stripeIndex += 1
				local color = stripeIndex % 2 == 0 and PALETTE.stripeA or PALETTE.stripeB
				drawLine(visual, string.format("MowingStripe_%02d", stripeIndex), a, b,
					stripeWidth, yStripe, color, presentation, render, 0.38)
			end
		end
	end

	-- Touchlines use the Classic pitch extents; goal-line pieces come from the pinned geometry below.
	local edge = { left = -area.maxX, right = area.maxX, top = area.maxY, bottom = area.minY }
	local edgePairs = {
		{ "TouchlineTop", { x = edge.left, y = edge.top }, { x = edge.right, y = edge.top } },
		{ "TouchlineBottom", { x = edge.left, y = edge.bottom }, { x = edge.right, y = edge.bottom } },
	}
	for _, entry in ipairs(edgePairs) do
		drawLine(visual, entry[1], entry[2], entry[3], 0.38, yMark, PALETTE.line, presentation, render)
	end

	-- Classic center stripe and the HBS bg kickoff circle (75 logical units).
	drawLine(visual, "HalfwayLine", { x = 0, y = area.minY }, { x = 0, y = area.maxY },
		0.34, yMark, PALETTE.line, presentation, render)
	-- Visual-only scale matches the supplied field reference; StadiumReference2D remains unchanged.
	local circleRadius = bg.kickOffRadius * 0.6
	local circleSegments = 144
	for i = 1, circleSegments do
		local a0, a1 = 2 * math.pi * (i - 1) / circleSegments, 2 * math.pi * i / circleSegments
		drawLine(visual, string.format("KickoffCircle_%03d", i),
			{ x = circleRadius * math.cos(a0), y = circleRadius * math.sin(a0) },
			{ x = circleRadius * math.cos(a1), y = circleRadius * math.sin(a1) },
			0.95, yMark + 0.006, PALETTE.line, presentation, render)
	end
	local centerRadius = 1.15 * scale
	makePart(visual, "CenterSpot", Vector3.new(0.12, centerRadius * 2, centerRadius * 2),
		CFrame.new(0, yMark + 0.03, 0) * CFrame.Angles(0, 0, math.pi / 2),
		PALETTE.line, Enum.Material.SmoothPlastic, 0, Enum.PartType.Cylinder)

	-- Pitch markings from the supplied reference: goal boxes, penalty arcs and corner arcs.
	local boxDepth, boxHalfHeight = 86, 100
	local smallBoxDepth, smallBoxHalfHeight = 50, 68
	for _, side in ipairs({ -1, 1 }) do
		local goalX = side * area.maxX
		local boxX = side * (area.maxX - boxDepth)
		local smallBoxX = side * (area.maxX - smallBoxDepth)
		local prefix = side < 0 and "Left" or "Right"
		for _, ySign in ipairs({ -1, 1 }) do
			local y = ySign * boxHalfHeight
			drawLine(visual, prefix .. "PenaltyBoxSide" .. ySign,
				{ x = goalX, y = y }, { x = boxX, y = y }, 0.34, yMark, PALETTE.line, presentation, render)
			local smallY = ySign * smallBoxHalfHeight
			drawLine(visual, prefix .. "GoalBoxSide" .. ySign,
				{ x = goalX, y = smallY }, { x = smallBoxX, y = smallY }, 0.34, yMark, PALETTE.line, presentation, render)
		end
		drawLine(visual, prefix .. "PenaltyBoxInner", { x = boxX, y = -boxHalfHeight },
			{ x = boxX, y = boxHalfHeight }, 0.34, yMark, PALETTE.line, presentation, render)
		drawLine(visual, prefix .. "GoalBoxInner", { x = smallBoxX, y = -smallBoxHalfHeight },
			{ x = smallBoxX, y = smallBoxHalfHeight }, 0.34, yMark, PALETTE.line, presentation, render)

		local spotX = side * (area.maxX - 75)
		local arcLimitX = side * (area.maxX - boxDepth)
		local normalized = math.clamp(math.abs(arcLimitX - spotX) / 22, 0, 1)
		local angle = math.acos(normalized)
		local arcStart, arcEnd = side < 0 and -angle or math.pi - angle, side < 0 and angle or math.pi + angle
		drawArc(visual, prefix .. "PenaltyArc", { x = spotX, y = 0 }, 22, arcStart, arcEnd,
			18, 0.34, yMark, PALETTE.line, presentation, render)
	end
	local cornerRadius = 8
	local corners = {
		{ "TopLeft", -area.maxX, area.maxY, math.pi * 1.5, math.pi * 2 },
		{ "TopRight", area.maxX, area.maxY, math.pi, math.pi * 1.5 },
		{ "BottomRight", area.maxX, -area.maxY, math.pi / 2, math.pi },
		{ "BottomLeft", -area.maxX, -area.maxY, 0, math.pi / 2 },
	}
	for _, corner in ipairs(corners) do
		drawArc(visual, "CornerArc" .. corner[1], { x = corner[2], y = corner[3] }, cornerRadius,
			corner[4], corner[5], 8, 0.34, yMark, PALETTE.line, presentation, render)
	end

	-- Draw curved goal mouths and backs from the pinned classic-field reference geometry.
	for _, segment in ipairs(reference.segments) do
		if segment.collisionGroup == profile.CollisionGroups.wall then
			local points = render.segmentPoints(segment, math.pi / 72)
			for i = 1, #points - 1 do
				drawLine(visual, string.format("HBS_%s_%02d", segment.id, i), points[i], points[i + 1],
					0.42, yMark + 0.012, PALETTE.line, presentation, render)
			end
		end
	end

	-- Decorative net lattice stays inside the exact rounded goal envelope in the reference geometry.
	local netBack = goals.netBackX
	local mouthX, mouthHalf, curveStart, curveRadius, backHalf = area.maxX, goals.halfHeight, 378, 22, 42
	local netRows = { -48, -24, 0, 24, 48 }
	for _, side in ipairs({ -1, 1 }) do
		local prefix = side < 0 and "Left" or "Right"
		for index, y in ipairs(netRows) do
			local excess = math.max(0, math.abs(y) - backHalf)
			local innerX = excess == 0 and mouthX or (curveStart + math.sqrt(curveRadius * curveRadius - excess * excess))
			local fromX = side * (netBack - 2)
			local toX = side * innerX
			drawLine(visual, prefix .. "NetCross" .. index, { x = fromX, y = y }, { x = toX, y = y },
				0.32, yMark + 0.004, PALETTE.net, presentation, render, 0)
		end
		for rib = 1, 3 do
			local xMagnitude = mouthX + (netBack - mouthX) * (rib / 4)
			local offset = math.max(0, xMagnitude - curveStart)
			local span = offset == 0 and mouthHalf or (backHalf + math.sqrt(curveRadius * curveRadius - offset * offset))
			local x = side * xMagnitude
			drawLine(visual, prefix .. "NetRib" .. rib, { x = x, y = -span }, { x = x, y = span },
				0.32, yMark + 0.006, PALETTE.net, presentation, render, 0)
		end
	end

	-- Rounded pale posts use the HBS centers and radii without team-coloured caps.
	for _, post in ipairs(profile.Geometry.posts) do
		local wp = toWorld(post.x, post.y, yMark + 0.07, presentation, render)
		local diameter = post.radius * 2 * scale
		makePart(visual, post.id .. "_Post", Vector3.new(diameter, diameter, diameter),
			CFrame.new(wp), PALETTE.line, Enum.Material.SmoothPlastic, 0, Enum.PartType.Ball)
	end

	-- Hide only the old flat prototype render pieces. Physics discs remain visible and active.
	for _, name in ipairs({ "Field", "BoundaryWest", "BoundaryEast", "BoundaryNorth", "BoundarySouth", "CenterLine", "CenterMark" }) do
		local oldPart = fieldModel:FindFirstChild(name)
		if oldPart and oldPart:IsA("BasePart") then oldPart.Transparency = 1 end
	end
	return visual
end

return Builder

