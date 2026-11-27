-- Versioned wire format. State is lossless f64; rendering precision is not physics precision.
local Codec = { VERSION = 1, PLAYER_COUNT = 8, PLAYERS_PER_TEAM = 4, STATE_BYTES = 72 + 8 * 41, MAX_COMMANDS = 8 }
local phases = { playing = 1, kickoff = 2, goalPause = 3, finished = 4 }
local phaseNames = { [1] = "playing", [2] = "kickoff", [3] = "goalPause", [4] = "finished" }
local function finite(v)
	return type(v) == "number" and v == v and math.abs(v) < 1e6
end
local function integer(v, max)
	return type(v) == "number" and v == v and v >= 0 and v % 1 == 0 and v <= max
end
local function team(t)
	return t == "red" and 1 or t == "blue" and 2 or 0
end
local function teamName(n)
	return n == 1 and "red" or n == 2 and "blue" or nil
end
function Codec.mask(x, y, kick)
	-- Digital directional controls. Opposite keys cancel before encoding.
	return (x < 0 and 1 or x > 0 and 2 or 0) + (y < 0 and 4 or y > 0 and 8 or 0) + (kick and 16 or 0)
end
function Codec.input(mask)
	local x = bit32.band(mask, 2) ~= 0 and 1 or bit32.band(mask, 1) ~= 0 and -1 or 0
	local y = bit32.band(mask, 8) ~= 0 and 1 or bit32.band(mask, 4) ~= 0 and -1 or 0
	return { x = x, y = y, kick = bit32.band(mask, 16) ~= 0 }
end
local function validMask(mask)
	return integer(mask, 31) and bit32.band(mask, 3) ~= 3 and bit32.band(mask, 12) ~= 12
end
function Codec.encodeInput(matchId, round, commands)
	assert(integer(matchId, 4294967295) and integer(round, 4294967295))
	assert(#commands >= 1 and #commands <= Codec.MAX_COMMANDS)
	local b = buffer.create(12 + 9 * #commands)
	buffer.writeu8(b, 0, 1)
	buffer.writeu8(b, 1, 1)
	buffer.writeu16(b, 2, #commands)
	buffer.writeu32(b, 4, matchId)
	buffer.writeu32(b, 8, round)
	for i, c in ipairs(commands) do
		assert(integer(c.seq, 4294967295) and c.seq > 0 and integer(c.tick, 4294967295) and validMask(c.mask))
		local p = 12 + (i - 1) * 9
		buffer.writeu32(b, p, c.seq)
		buffer.writeu32(b, p + 4, c.tick)
		buffer.writeu8(b, p + 8, c.mask)
	end
	return b
end
function Codec.decodeInput(b)
	if typeof(b) ~= "buffer" or buffer.len(b) < 21 or buffer.len(b) > 84 then
		return nil, "size"
	end
	if buffer.readu8(b, 0) ~= 1 or buffer.readu8(b, 1) ~= 1 then
		return nil, "version"
	end
	local n = buffer.readu16(b, 2)
	if n < 1 or n > 8 or buffer.len(b) ~= 12 + 9 * n then
		return nil, "count"
	end
	local packet = { matchId = buffer.readu32(b, 4), round = buffer.readu32(b, 8), commands = {} }
	for i = 1, n do
		local p = 12 + (i - 1) * 9
		local c = { seq = buffer.readu32(b, p), tick = buffer.readu32(b, p + 4), mask = buffer.readu8(b, p + 8) }
		if c.seq == 0 or not validMask(c.mask) then
			return nil, "command"
		end
		table.insert(packet.commands, c)
	end
	return packet
end
function Codec.encodeState(s)
	assert(s.coreMode and #s.players == Codec.PLAYER_COUNT, "4v4 state required")
	local b = buffer.create(Codec.STATE_BYTES)
	buffer.writeu8(b, 0, 1)
	buffer.writeu8(b, 1, 2)
	buffer.writeu8(b, 2, Codec.PLAYER_COUNT + 1)
	buffer.writeu8(b, 3, assert(phases[s.matchPhase]))
	for _, f in ipairs({ { 4, s.matchId }, { 8, s.round }, { 12, s.tick }, { 16, s.elapsedMatchTicks or 0 } }) do
		assert(integer(f[2], 4294967295))
		buffer.writeu32(b, f[1], f[2])
	end
	assert(integer(s.pauseTicksRemaining, 65535) and integer(s.score.red, 65535) and integer(s.score.blue, 65535))
	buffer.writeu16(b, 20, s.pauseTicksRemaining)
	buffer.writeu8(b, 22, team(s.kickoffTeam))
	buffer.writeu8(b, 23, team(s.winner))
	buffer.writeu16(b, 24, s.score.red)
	buffer.writeu16(b, 26, s.score.blue)
	local touch = s.lastTouch
	buffer.writeu8(b, 28, touch and touch.playerId or 0)
	buffer.writeu8(b, 29, touch and touch.kind == "kick" and 1 or 0)
	buffer.writeu32(b, 30, touch and touch.tick or 0)
	buffer.writeu8(b, 34, touch and team(touch.team) or 0)
	buffer.writeu8(b, 35, s.lastGoal and team(s.lastGoal.team) or 0)
	buffer.writeu32(b, 36, s.lastGoal and s.lastGoal.tick or 0)
	local function body(d, p)
		for i, key in ipairs({ "x", "y", "vx", "vy" }) do
			assert(finite(d[key]))
			buffer.writef64(b, p + (i - 1) * 8, d[key])
		end
	end
	body(s.ball, 40)
	for slot, d in ipairs(s.players) do
		local p = 72 + (slot - 1) * 41
		body(d, p)
		assert(integer(d.ack or 0, 4294967295) and integer(d.kickCooldown or 0, 65535))
		buffer.writeu32(b, p + 32, d.ack or 0)
		buffer.writeu16(b, p + 36, d.kickCooldown or 0)
		buffer.writeu8(b, p + 38, (d.kickHeld and 1 or 0) + (d.kickArmed and 2 or 0) + (d.needsKickRelease and 4 or 0))
		buffer.writeu8(b, p + 39, d.collisionMask)
		buffer.writeu8(b, p + 40, d.inputMask or 0)
	end
	return b
end
function Codec.decodeState(b, base)
	if typeof(b) ~= "buffer" or buffer.len(b) ~= Codec.STATE_BYTES then
		return nil, "size"
	end
	if buffer.readu8(b, 0) ~= 1 or buffer.readu8(b, 1) ~= 2 or buffer.readu8(b, 2) ~= Codec.PLAYER_COUNT + 1 then
		return nil, "version"
	end
	if
		buffer.readu8(b, 22) > 2
		or buffer.readu8(b, 23) > 2
		or buffer.readu8(b, 29) > 1
		or buffer.readu8(b, 34) > 2
		or buffer.readu8(b, 35) > 2
	then
		return nil, "enum"
	end
	local phase = phaseNames[buffer.readu8(b, 3)]
	if not phase or not base or not base.players or #base.players ~= Codec.PLAYER_COUNT then
		return nil, "bootstrap"
	end
	local s = table.clone(base)
	s.resync = nil
	s.matchId = buffer.readu32(b, 4)
	s.round = buffer.readu32(b, 8)
	s.tick = buffer.readu32(b, 12)
	s.gameTime = s.tick / 60
	s.elapsedMatchTicks = buffer.readu32(b, 16)
	s.matchPhase = phase
	s.pauseTicksRemaining = buffer.readu16(b, 20)
	s.kickoffTeam = teamName(buffer.readu8(b, 22))
	s.winner = teamName(buffer.readu8(b, 23))
	s.score = { red = buffer.readu16(b, 24), blue = buffer.readu16(b, 26) }
	local goalTeam = teamName(buffer.readu8(b, 35))
	local goalTick = buffer.readu32(b, 36)
	s.lastGoal = goalTeam and { team = goalTeam, tick = goalTick } or nil
	if goalTeam and base.lastGoal and base.lastGoal.team == goalTeam and base.lastGoal.tick == goalTick then
		s.lastGoal = table.clone(base.lastGoal)
	end
	local touch = buffer.readu8(b, 28)
	if touch > Codec.PLAYER_COUNT then
		return nil, "touch"
	end
	s.lastTouch = touch > 0
			and {
				playerId = touch,
				kind = buffer.readu8(b, 29) == 1 and "kick" or "contact",
				tick = buffer.readu32(b, 30),
				team = teamName(buffer.readu8(b, 34)),
			}
		or nil
	if s.matchId ~= base.matchId or s.round ~= base.round then
		return nil, "epoch"
	end
	local function body(original, p)
		local d = table.clone(original)
		for i, key in ipairs({ "x", "y", "vx", "vy" }) do
			d[key] = buffer.readf64(b, p + (i - 1) * 8)
			if not finite(d[key]) then
				return nil
			end
		end
		d.speed = math.sqrt(d.vx * d.vx + d.vy * d.vy)
		return d
	end
	s.ball = body(base.ball, 40)
	if not s.ball then
		return nil, "finite"
	end
	s.players = {}
	for slot, original in ipairs(base.players) do
		local p = 72 + (slot - 1) * 41
		local d = body(original, p)
		if not d then
			return nil, "finite"
		end
		d.ack = buffer.readu32(b, p + 32)
		d.kickCooldown = buffer.readu16(b, p + 36)
		local flags = buffer.readu8(b, p + 38)
		d.kickHeld = bit32.band(flags, 1) ~= 0
		d.kickArmed = bit32.band(flags, 2) ~= 0
		d.needsKickRelease = bit32.band(flags, 4) ~= 0
		d.collisionMask = buffer.readu8(b, p + 39)
		d.inputMask = buffer.readu8(b, p + 40)
		if flags > 7 or not validMask(d.inputMask) then
			return nil, "flags"
		end
		s.players[slot] = d
	end
	s.player = s.players[1]
	s.player2 = s.players[Codec.PLAYERS_PER_TEAM + 1]
	return s
end
return Codec
