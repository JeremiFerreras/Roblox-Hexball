local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Codec = require(ReplicatedStorage.SimpleSoccerGame:WaitForChild("NetCodec"))
local Queue = require(ReplicatedStorage.SimpleSoccerGame:WaitForChild("NetInputQueue"))
local Profile = require(ReplicatedStorage.SimpleSoccerGame:WaitForChild("StadiumReference2D"))
local Server = {}
Server.__index = Server
function Server.new()
	return setmetatable({
		matchId = 0,
		round = 0,
		queues = {},
		lastStateTick = -100,
		lastControlKey = nil,
		lastControlTick = -100,
		stats = { statePackets = 0, stateBytes = 0, controlPackets = 0, rejected = 0 },
	}, Server)
end
function Server:epoch(matchId, round, tick)
	if self.matchId == matchId and self.round == round then
		return false
	end
	local preserve = self.matchId == matchId
	self.matchId, self.round = matchId, round
	for slot = 1, Profile.PlayerCount do
		local old = self.queues[slot]
		local q = Queue.new(matchId, round)
		if preserve and old then
			q.mask = old.mask
			q.lastSeen = tick or old.lastSeen
		end
		self.queues[slot] = q
	end
	self.lastStateTick = -100
	return true
end
function Server:receive(slot, b, tick)
	local queue = self.queues[slot]
	if not queue or not queue:receive(b, tick) then
		self.stats.rejected += 1
		return false
	end
	return true
end
function Server:consume(tick)
	local inputs = {}
	for slot, q in ipairs(self.queues) do
		inputs[slot] = q:step(tick)
	end
	return inputs
end
function Server:release(slot)
	if self.queues[slot] then
		self.queues[slot] = Queue.new(self.matchId, self.round)
	end
end
function Server:publish(s, reliable, stream)
	if not s.coreMode then
		reliable(s)
		self.stats.controlPackets += 1
		return
	end
	local key = tostring(s.matchId) .. ":" .. s.round .. ":" .. s.matchPhase .. ":" .. tostring(s.kickoffTeam)
	for _, p in ipairs(s.players) do
		key ..= ":" .. tostring(p.ownerUserId or 0)
	end
	if key ~= self.lastControlKey or s.debugEnabled and s.tick - self.lastControlTick >= 60 then
		self.lastControlKey = key
		self.lastControlTick = s.tick
		reliable(s)
		self.stats.controlPackets += 1
	end
	if s.tick - self.lastStateTick >= 2 then
		self.lastStateTick = s.tick
		local b = Codec.encodeState(s)
		stream(b)
		self.stats.statePackets += 1
		self.stats.stateBytes += buffer.len(b)
	end
end
return Server
