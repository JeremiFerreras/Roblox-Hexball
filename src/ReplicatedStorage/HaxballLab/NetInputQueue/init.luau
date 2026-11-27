-- One ordered transition per player per authoritative tick, independent of arrival order/FPS.
local Codec = require(script.Parent:WaitForChild("NetCodec"))
local Queue = {}
Queue.__index = Queue
function Queue.new(matchId, round)
	return setmetatable({
		matchId = matchId,
		round = round,
		ack = 0,
		pending = {},
		mask = 0,
		ackMask = 0,
		suspended = false,
		lastSeen = 0,
		budget = 16,
		budgetTick = 0,
		rejected = 0,
	}, Queue)
end
function Queue:receive(b, tick)
	local packet = Codec.decodeInput(b)
	if not packet or packet.matchId ~= self.matchId or packet.round ~= self.round then
		self.rejected += 1
		return false
	end
	self.budget = math.min(16, self.budget + math.max(0, tick - self.budgetTick))
	self.budgetTick = tick
	local new = {}
	local seen = {}
	for _, c in ipairs(packet.commands) do
		if seen[c.seq] then
			self.rejected += 1
			return false
		end
		seen[c.seq] = true
		local old = self.pending[c.seq]
		if old and (old.mask ~= c.mask or old.tick ~= c.tick) then
			self.rejected += 1
			return false
		end
		if c.seq > self.ack and not old then
			if c.seq > self.ack + 32 or c.tick > tick + 120 or c.tick + 600 < tick then
				self.rejected += 1
				return false
			end
			table.insert(new, c)
		end
	end
	if #new > self.budget then
		self.rejected += 1
		return false
	end
	for _, c in ipairs(new) do
		self.pending[c.seq] = c
	end
	if self.suspended then
		for _, c in ipairs(packet.commands) do
			if c.seq == self.ack and c.mask == self.ackMask then
				self.mask = self.ackMask
				self.suspended = false
			end
		end
	end
	self.budget -= #new
	self.lastSeen = tick
	return true
end
function Queue:step(tick)
	local c = self.pending[self.ack + 1]
	if c then
		self.ack = c.seq
		self.mask = c.mask
		self.ackMask = c.mask
		self.suspended = false
		self.pending[c.seq] = nil
	end
	-- Loss/disconnection must not leave a direction or X pressed forever.
	if tick - self.lastSeen > 30 then
		self.mask = 0
		self.suspended = true
	end
	local value = Codec.input(self.mask)
	value.awaitingFirstInput = self.ack == 0
	value.stale = self.suspended or value.awaitingFirstInput
	return value
end
return Queue
