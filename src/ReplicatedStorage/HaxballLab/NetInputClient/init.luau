local Codec = require(script.Parent:WaitForChild("NetCodec"))
local Client = {}
Client.__index = Client
function Client.new()
	return setmetatable({
		matchId = nil,
		round = nil,
		seq = 0,
		ack = 0,
		pending = {},
		mask = nil,
		lastSend = -math.huge,
		lastReliable = -math.huge,
	}, Client)
end
function Client:reset(matchId, round, ack)
	self.matchId, self.round, self.seq, self.ack = matchId, round, ack or 0, ack or 0
	self.pending = {}
	self.mask = nil
	self.lastSend = -math.huge
	self.lastReliable = -math.huge
end
function Client:confirm(ack)
	if type(ack) ~= "number" or ack ~= ack or ack % 1 ~= 0 or ack > 4294967295 or ack < self.ack then
		return false
	end
	if ack > self.seq then
		self.seq = ack
		self.pending = {}
		self.mask = nil
	end
	self.ack = ack
	while self.pending[1] and self.pending[1].seq <= ack do
		table.remove(self.pending, 1)
	end
	return true
end
function Client:sample(mask, tick, now)
	if not self.matchId then
		return
	end
	self.lastTick = tick
	if mask ~= self.mask then
		if #self.pending >= 32 then
			return
		end -- bounded backlog, retry current state after acknowledgements
		self.seq += 1
		self.mask = mask
		table.insert(self.pending, { seq = self.seq, tick = tick, mask = mask, created = now })
	end
end
function Client:packet(now)
	if not self.matchId or self.seq == 0 or now - self.lastSend < 1 / 60 - 1e-6 then
		return nil
	end
	local hasPending = #self.pending > 0
	if not hasPending and now - self.lastSend < 0.1 then
		return nil
	end
	local commands = {}
	for i = 1, math.min(#self.pending, 8) do
		commands[i] = self.pending[i]
	end
	if #commands == 0 then
		commands[1] = { seq = self.seq, tick = self.lastTick or 0, mask = self.mask }
	end
	local b = Codec.encodeInput(self.matchId, self.round, commands)
	self.lastSend = now
	local reliable = hasPending and now - self.pending[1].created >= 0.15 and now - self.lastReliable >= 0.15
	if reliable then
		self.lastReliable = now
	end
	return b, reliable
end
return Client
