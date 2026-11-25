-- Pure geometry sampling; rendering never participates in the physical simulation.
local Render = {}
function Render.segmentPoints(segment, angularStep)
	angularStep = angularStep or math.pi / 48
	assert(angularStep > 0 and angularStep < math.pi, "invalid angular step")
	if not segment.curveF then
		return { { x = segment.x1, y = segment.y1 }, { x = segment.x2, y = segment.y2 } }
	end
	local angle = math.atan2(segment.y1 - segment.centerY, segment.x1 - segment.centerX)
	local sweep = segment.curveF == 0 and math.pi or 2 * math.atan(1 / segment.curveF)
	local count = math.ceil(math.abs(sweep) / angularStep)
	local points = {}
	for i = 0, count do
		local a = angle + sweep * i / count
		table.insert(points, {
			x = segment.centerX + segment.arcRadius * math.cos(a),
			y = segment.centerY + segment.arcRadius * math.sin(a),
		})
	end
	-- Keep endpoints exact to avoid visible joins separating through rounding.
	points[1] = { x = segment.x1, y = segment.y1 }
	points[#points] = { x = segment.x2, y = segment.y2 }
	return points
end
function Render.toWorld(x, y, presentation)
	local p = presentation
	return {
		x = p.worldOrigin.x + (x - p.logicalOrigin.x) * p.studsPerUnit,
		y = p.floorY,
		z = p.worldOrigin.z + (p.invertLogicalY and -1 or 1) * (y - p.logicalOrigin.y) * p.studsPerUnit,
	}
end
function Render.cameraHeight(presentation, bounds, fovDegrees, width, height)
	assert(fovDegrees > 0 and fovDegrees < 180, "invalid field of view")
	local aspect = (width and height and width > 0 and height > 0) and width / height or 16 / 9
	local halfWidth = (bounds.maxX - bounds.minX) * presentation.studsPerUnit * 0.5 + 10
	local halfHeight = (bounds.maxY - bounds.minY) * presentation.studsPerUnit * 0.5 + 10
	local tangent = math.tan(math.rad(fovDegrees) * 0.5)
	return presentation.floorY + math.max(halfHeight / tangent, halfWidth / (aspect * tangent))
end
return Render
