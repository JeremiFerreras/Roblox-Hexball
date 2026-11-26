-- Remote presentation only. Never drives authority, input scheduling or physical prediction.
local SnapshotBuffer = {}
SnapshotBuffer.__index = SnapshotBuffer
local RATE, MIN_DELAY, MAX_DELAY, CAPACITY = 60, 2, 6, 32

local function pose(d)
	return { x = d.x, y = d.y }
end

local function frame(s)
	local players = {}
	for i, d in ipairs(s.players or {}) do
		players[i] = pose(d)
	end
	return {
		tick = s.tick,
		ball = pose(s.ball),
		player = pose(s.player),
		player2 = pose(s.player2),
		players = players,
	}
end

function SnapshotBuffer.new()
	return setmetatable({
		frames = {},
		delayTicks = MIN_DELAY,
		jitter = 0,
		underflows = 0,
		rebuffers = 0,
	}, SnapshotBuffer)
end

-- Input is an already validated authoritative snapshot and a local monotonic arrival time.
function SnapshotBuffer:push(s, now)
	if self.latest and (
		s.matchId < self.matchId
		or s.matchId == self.matchId and (
			s.round < self.round or s.round == self.round and s.tick <= self.latest.tick
		)
	) then
		return false
	end
	local reset = self.matchId ~= s.matchId or self.round ~= s.round
		or self.phase ~= s.matchPhase or self.coreMode ~= s.coreMode
	local offset = s.tick - now * RATE
	if reset then
		self.frames = {}
		self.cursor = s.tick
		self.jitter = 0
		self.delayTicks = MIN_DELAY
		self.lastSample = now
		self.started = false
		self.starved = false
		self.offset = offset
	else
		local gap = now - self.arrivedAt
		local residual = math.abs(gap * RATE - (s.tick - self.latest.tick))
		self.jitter = self.jitter * 0.9 + math.min(residual, MAX_DELAY) * 0.1
		-- Late packets cannot keep pulling the presentation clock backwards.
		-- A stalled authority that resumes with few ticks gets a fresh clock anchor.
		if gap > 0.5 and s.tick - self.latest.tick < gap * RATE * 0.5 then
			self.offset = offset
		else
			self.offset = math.max(self.offset, offset)
		end
	end
	self.matchId, self.round = s.matchId, s.round
	self.phase, self.coreMode = s.matchPhase, s.coreMode
	self.latest = frame(s)
	self.arrivedAt = now
	table.insert(self.frames, self.latest)
	if #self.frames > CAPACITY then
		table.remove(self.frames, 1)
	end
	return true
end

local function mix(a, b, alpha)
	return { x = a.x + (b.x - a.x) * alpha, y = a.y + (b.y - a.y) * alpha }
end

function SnapshotBuffer:sample(now)
	if not self.latest then
		return nil
	end
	local dt = math.max(0, now - self.lastSample)
	self.lastSample = math.max(now, self.lastSample)
	local target = math.clamp(MIN_DELAY + 2 * self.jitter, MIN_DELAY, MAX_DELAY)
	-- Rise faster than decay, with explicit rates in ticks per second.
	self.delayTicks += math.clamp(target - self.delayTicks, -dt * 0.5, dt * 3)
	local age = math.max(0, now - self.arrivedAt)
	local estimated = now * RATE + self.offset
	if not self.coreMode or self.phase ~= "playing" then
		self.cursor = self.latest.tick
	else
		local desired = math.min(self.latest.tick, estimated - self.delayTicks)
		if self.cursor < self.latest.tick - MAX_DELAY - 2 then
			self.cursor = math.max(self.cursor, self.latest.tick - self.delayTicks)
			self.rebuffers += 1
		end
		local delta = desired - self.cursor
		if delta > 0 then
			local speed = math.clamp(1 + (delta - dt * RATE) * 0.1, 0.9, 1.1)
			self.cursor += math.min(delta, dt * RATE * speed)
			self.started = true
		end
		local starved = self.started and estimated - self.delayTicks > self.latest.tick + 1e-6
		if starved and not self.starved then
			self.underflows += 1
		end
		self.starved = starved
	end
	-- The newest confirmed state is a hard boundary: remote motion never extrapolates.
	self.cursor = math.clamp(self.cursor, self.frames[1].tick, self.latest.tick)
	local a, b = self.frames[1], self.latest
	for i = 2, #self.frames do
		if self.frames[i].tick >= self.cursor then
			a, b = self.frames[i - 1], self.frames[i]
			break
		end
	end
	local alpha = b.tick > a.tick and math.clamp((self.cursor - a.tick) / (b.tick - a.tick), 0, 1) or 1
	local result = {
		ball = mix(a.ball, b.ball, alpha),
		player = mix(a.player, b.player, alpha),
		player2 = mix(a.player2, b.player2, alpha),
		players = {},
	}
	for i, d in ipairs(b.players) do
		result.players[i] = mix(a.players[i] or d, d, alpha)
	end
	self.status = {
		tick = self.cursor,
		delayMs = self.delayTicks / RATE * 1000,
		ageMs = age * 1000,
		renderLagMs = math.max(0, estimated - self.cursor) / RATE * 1000,
		underflows = self.underflows,
		rebuffers = self.rebuffers,
		frames = #self.frames,
	}
	return result, self.status
end

return SnapshotBuffer
