local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(ReplicatedStorage:WaitForChild("SimpleSoccerGame"):WaitForChild("StadiumReference2D"))
local Stadium = {}
Stadium.Metadata = Profile.Metadata
Stadium.Groups = Profile.CollisionGroups

local function copyRecord(record)
	return table.clone(record)
end

function Stadium.install(Core, world)
	assert(type(Core) == "table" and type(world) == "table", "Core and world are required")
	world.useBounds = false
	if world.config.solverMode == "classicDiscrete" then
		local reference = require(script.Parent:WaitForChild("ClassicReference230"))
		Core.setReferenceGeometry(world, reference)
		for _, post in ipairs(reference.posts) do
			local spec = table.clone(post)
			spec.kind = "post"
			spec.invMass = 0
			spec.damping = 1
			Core.addDisc(world, spec)
		end
		return {
			planes = #reference.planes,
			segments = #reference.segments,
			posts = #reference.posts,
			profileId = "simple-soccer-classic",
			sourceCommit = "independent-reference-profile",
		}
	end

	for _, spec in ipairs(Profile.Geometry.planes) do
		Core.addPlane(world, copyRecord(spec))
	end
	for _, spec in ipairs(Profile.Geometry.segments) do
		Core.addSegment(world, copyRecord(spec))
	end

	local hbsAll = Profile.CollisionMasks.all
	for _, post in ipairs(Profile.Geometry.posts) do
		Core.addDisc(world, {
			id = post.id,
			kind = "post",
			x = post.x,
			y = post.y,
			radius = post.radius,
			invMass = 0,
			damping = 1,
			bCoef = post.bCoef,
			collisionGroup = Profile.CollisionGroups.post,
			collisionMask = hbsAll,
		})
	end

	return {
		planes = #Profile.Geometry.planes,
		segments = #Profile.Geometry.segments,
		posts = #Profile.Geometry.posts,
		profileId = Profile.Metadata.id,
		sourceCommit = Profile.Metadata.sourceCommit,
	}
end

return Stadium
