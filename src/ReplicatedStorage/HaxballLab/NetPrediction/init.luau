-- Whole-world prediction: remote players hold their last known input.
-- Predicted contacts/ball motion are visual forecasts; scores are never committed here.
local Core = require(script.Parent:WaitForChild("PhysicsCore2D"))
local Profile = require(script.Parent:WaitForChild("StadiumReference2D"))
local Geometry = require(script.Parent:WaitForChild("ClassicReference230"))
local Codec = require(script.Parent:WaitForChild("NetCodec"))
local Prediction = {}
Prediction.__index = Prediction
function Prediction.new()
	local self = setmetatable(
		{ world = nil, history = {}, forecasts = {}, epoch = nil, correction = 0, reconciliations = 0 },
		Prediction
	)
	return self
end
function Prediction:_world()
	local p = Profile.PhysicsBaseline.active
	local w = Core.newWorld({ useBounds = false, solverMode = "haxballDiscrete" })
	Core.addDisc(w, {
		id = "ball",
		kind = "ball",
		radius = p.ball.radius,
		invMass = p.ball.invMass,
		damping = p.ball.damping,
		bCoef = p.ball.bounce,
		kickable = true,
		collisionGroup = 1,
	})
	Core.setReferenceGeometry(w, Geometry)
	for _, post in ipairs(Geometry.posts) do
		local s = table.clone(post)
		s.kind = "post"
		s.invMass = 0
		s.damping = 1
		Core.addDisc(w, s)
	end
	for slot = 1, 10 do
		Core.addDisc(w, {
			id = slot,
			kind = "player",
			team = slot <= 5 and "red" or "blue",
			radius = p.player.radius,
			invMass = p.player.invMass,
			damping = p.player.damping,
			bCoef = p.player.bounce,
			acceleration = p.player.acceleration,
			kickAcceleration = p.player.kickAcceleration,
			kickDamping = p.player.kickDamping,
			kickStrength = p.player.kickStrength,
			kickback = p.player.kickback,
			collisionGroup = slot <= 5 and 2 or 4,
			collisionMask = 39,
		})
	end
	return w
end
function Prediction:restore(s, slot)
	local epoch = tostring(s.matchId) .. ":" .. s.round .. ":" .. slot
	if self.epoch ~= epoch then
		self.world = self:_world()
		self.history = {}
		self.forecasts = {}
		self.epoch = epoch
		self.correction = 0
		self.lastMeasuredTick = nil
	end
	local previous = self.forecasts[s.tick]
	self.correctionSample = previous ~= nil and self.lastMeasuredTick ~= s.tick
	if self.correctionSample then
		self.lastMeasuredTick = s.tick
	end
	self.ballCorrection = previous and math.sqrt((previous.ballX - s.ball.x)^2 + (previous.ballY - s.ball.y)^2) or 0
	local dx = previous and previous.x - s.players[slot].x or 0
	local dy = previous and previous.y - s.players[slot].y or 0
	self.correction = math.sqrt(dx * dx + dy * dy)
	self.offsetX, self.offsetY = 0, 0
	self.ballOffsetX, self.ballOffsetY = 0, 0
	if self.correction < 10 and s.matchPhase == "playing" then
		self.offsetX, self.offsetY = dx, dy
	end
	if previous and s.matchPhase == "playing" then
		local bx, by = previous.ballX - s.ball.x, previous.ballY - s.ball.y
		if bx * bx + by * by < 100 then
			self.ballOffsetX, self.ballOffsetY = bx, by
		end
	end
	self.reconciliations += 1
	self.slot = slot
	self.phase = s.matchPhase
	self.kickoffTeam = s.kickoffTeam
	self.world.tick = s.tick
	self.confirmedTick = s.tick
	local ball = self.world.discs[1]
	for _, key in ipairs({ "x", "y", "vx", "vy" }) do
		ball[key] = s.ball[key]
	end
	self.lastMasks = {}
	self.release = {}
	for i, d in ipairs(s.players) do
		local p = self.world.discs[5 + i]
		for _, key in ipairs({ "x", "y", "vx", "vy", "kickHeld", "kickArmed", "kickCooldown", "collisionMask" }) do
			p[key] = d[key]
		end
		self.lastMasks[i] = d.inputMask or 0
		self.release[i] = d.needsKickRelease == true
	end
	for tick in pairs(self.history) do
		if tick < s.tick - 2 then
			self.history[tick] = nil
		end
	end
	for tick in pairs(self.forecasts) do
		if tick < s.tick - 2 then
			self.forecasts[tick] = nil
		end
	end
end
function Prediction:advance(targetTick, mask)
	if not self.world or self.phase ~= "playing" then
		return nil
	end
	-- Never extrapolate indefinitely after a stalled/lost stream.
	targetTick = math.min(targetTick, self.confirmedTick + 18)
	while self.world.tick < targetTick do
		local tick = self.world.tick + 1
		local localMask = self.history[tick]
		if localMask == nil then
			localMask = mask
			self.history[tick] = mask
		end
		local inputs = {}
		for i = 1, 10 do
			local value = Codec.input(i == self.slot and localMask or self.lastMasks[i])
			if not value.kick then
				self.release[i] = false
			end
			if self.release[i] or self.kickoffTeam and (i <= 5 and "red" or "blue") ~= self.kickoffTeam then
				value.kick = false
			end
			inputs[i] = value
		end
		local _, events = Core.stepWorld(self.world, inputs)
		for _, e in ipairs(events) do
			local id = e.kind == "kick" and e.playerId or e.discA == "ball" and e.discB or e.discB == "ball" and e.discA
			if type(id) == "number" and self.kickoffTeam and (id <= 5 and "red" or "blue") == self.kickoffTeam then
				local ball = self.world.discs[1]
				if ball.vx ~= 0 or ball.vy ~= 0 then
					self.kickoffTeam = nil
					for i = 1, 10 do
						self.world.discs[5 + i].collisionMask = 39
					end
				end
			end
		end
		local actor = self.world.discs[5 + self.slot]
		self.forecasts[self.world.tick] =
			{ x = actor.x, y = actor.y, ballX = self.world.discs[1].x, ballY = self.world.discs[1].y }
	end
	local actor = self.world.discs[5 + self.slot]
	return actor, self.world.discs[1]
end
function Prediction:visual(actor, ball, dt)
	local factor = math.exp(-math.max(0, dt) / 0.05)
	self.offsetX = (self.offsetX or 0) * factor
	self.offsetY = (self.offsetY or 0) * factor
	self.ballOffsetX = (self.ballOffsetX or 0) * factor
	self.ballOffsetY = (self.ballOffsetY or 0) * factor
	return { x = actor.x + self.offsetX, y = actor.y + self.offsetY }, {
		x = ball.x + self.ballOffsetX,
		y = ball.y + self.ballOffsetY,
	}
end
return Prediction
