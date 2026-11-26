-- One production server + ten production client scripts. Time/transport/UI use adapters.
local results = {}
local function check(name, fn)
	local ok, detail = pcall(fn)
	table.insert(results, { CONFIG.name .. "/" .. name, ok, ok and (detail or "PASS") or tostring(detail) })
end
local now, order = 0, 0
local events, peers = {}, {}
local serverPackets, serverBytes = 0, 0
local fpsPattern = { 30, 60, 120, 240, 60, 30, 120, 60, 240, 60 }
local function clone(value)
	if type(value) == "table" then
		local out = {}
		for k, v in pairs(value) do
			out[k] = clone(v)
		end
		return out
	end
	if typeof(value) == "buffer" then
		local out = buffer.create(buffer.len(value))
		buffer.copy(out, 0, value)
		return out
	end
	return value
end
local function schedule(peer, direction, kind, reliable, args)
	local function random()
		peer.rng = peer.rng * 48271 % 2147483647
		return peer.rng / 2147483647
	end
	local size = typeof(args[1]) == "buffer" and buffer.len(args[1]) or 0
	if direction == "up" and kind == "input" and size == 0 then
		peer.rawInputs += 1
	end
	local stats = peer[direction]
	stats.packets += 1
	stats.bytes += size
	if not reliable and random() * 100 < CONFIG.loss then
		stats.dropped += 1
		return
	end
	local ratio = CONFIG.asymmetric and (direction == "up" and 0.25 or 0.75) or 0.5
	local delay = peer.rtt / 1000 * ratio + (random() - 0.5) * 0.025
	local due = now + math.max(1 / 240, delay)
	local blackout = CONFIG.blackout and (peer.slot == 3 or peer.slot == 7)
	if blackout and ((now >= 4 and now < 5.2) or (due >= 4 and due < 5.2)) then
		if not reliable then
			stats.dropped += 1
			return
		end
		due = math.max(due, 5.2 + peer.rtt / 2000)
	end
	if reliable then
		local channel = direction .. ":" .. kind
		due = math.max(due, (peer.ordered[channel] or 0) + 1e-6)
		peer.ordered[channel] = due
	end
	local function enqueue(at)
		order += 1
		table.insert(
			events,
			{ at = at, id = order, peer = peer, direction = direction, kind = kind, args = clone(args) }
		)
	end
	enqueue(due)
	if not reliable and random() < 0.1 then
		enqueue(due + 0.025)
		stats.duplicates += 1
	end
end
local function sendDown(peer, kind, reliable, ...)
	schedule(peer, "down", kind, reliable, { ... })
end
for slot = 2, 10 do
	local p = { UserId = 122 + slot }
	table.insert(roster, p)
	players.PlayerAdded.fn(p)
end
for slot, p in ipairs(roster) do
	local rtt = (CONFIG.reverse and 11 - slot or slot) * 20
	local peer = {
		slot = slot,
		player = p,
		rtt = rtt,
		fps = fpsPattern[slot],
		rng = (CONFIG.seed + slot * 997) % 2147483647,
		ordered = {},
		nextFrame = 0,
		lastFrame = 0,
		up = { packets = 0, bytes = 0, dropped = 0, duplicates = 0 },
		down = { packets = 0, bytes = 0, dropped = 0, duplicates = 0 },
		maxPending = 0,
		maxAge = 0,
		maxCorrection = 0,
		booted = false,
		rawInputs = 0,
	}
	peers[slot] = peer
	local transport = {
		send = function(self, kind, reliable, ...)
			schedule(peer, "up", kind, reliable, { ... })
		end,
	}
	peer.client = makeClient(p, transport, slot * 17.123)
end
local oldFull = snapshots.FireAllClients
snapshots.FireAllClients = function(self, s)
	oldFull(self, s)
	for _, p in ipairs(peers) do
		sendDown(p, "snapshot", true, s)
	end
end
snapshots.FireClient = function(self, p, s)
	for _, peer in ipairs(peers) do
		if peer.player == p then
			sendDown(peer, "snapshot", true, s)
			return
		end
	end
end
local oldStream = stateStream.FireAllClients
stateStream.FireAllClients = function(self, b)
	oldStream(self, b)
	serverPackets += 1
	serverBytes += buffer.len(b)
	for _, p in ipairs(peers) do
		sendDown(p, "state", false, b)
	end
end
control.FireClient = function(self, p, ...)
	for _, peer in ipairs(peers) do
		if peer.player == p then
			sendDown(peer, "control", true, ...)
			return
		end
	end
end
local seenGoal, seenReset = false, false
local beforeReset
local function deliver()
	table.sort(events, function(a, b)
		return a.at == b.at and a.id < b.id or a.at < b.at
	end)
	while events[1] and events[1].at <= now + 1e-9 do
		local e = table.remove(events, 1)
		if e.direction == "down" then
			e.peer.client.receive(e.kind, e.args, now)
		elseif e.kind == "input" then
			-- Both channels have the real same server handler; reliable sequencing is in transport.
			input.fn(e.peer.player, table.unpack(e.args))
		elseif e.kind == "control" then
			control.fn(e.peer.player, table.unpack(e.args))
		elseif e.kind == "command" then
			command.fn(e.peer.player, table.unpack(e.args))
		else
			error(e.kind)
		end
	end
end
check("run_16seconds_ten_clients", function()
	for frame = 0, 16 * 240 do
		now = frame / 240
		deliver()
		if frame == 6 * 240 then
			command.fn(player, "setupGoalTest")
		end
		if frame == 12 * 240 then
			beforeReset = debugState.OnInvoke("summary").current.matchId
			command.fn(player, "reset")
		end
		if frame > 0 and frame % 4 == 0 then
			heartbeat.fn(1 / 60)
		end
		for slot, peer in ipairs(peers) do
			if now + 1e-9 >= peer.nextFrame then
				local mask = 0
				if now < 9 then
					mask = (math.floor(now * 60 / (31 + slot)) % 2 == 0 and 2 or 1)
						+ (math.floor(now * 60 / 47 + slot) % 3 == 0 and 4 or 0)
						+ (math.floor(now * 60) % (79 + slot) < 3 and 16 or 0)
				end
				peer.client.frame(now, 1 / peer.fps, mask)
				peer.nextFrame += 1 / peer.fps
			end
		end
		if frame % 60 == 0 then
			local s = debugState.OnInvoke("summary").current
			seenGoal = seenGoal or s.matchPhase == "goalPause" or s.score.red + s.score.blue > 0
			seenReset = seenReset or beforeReset ~= nil and s.matchId > beforeReset
			for _, peer in ipairs(peers) do
				local report = peer.client.report(now)
				assert(report.pendingInputs <= 32, "unbounded input queue")
				peer.maxPending = math.max(peer.maxPending, report.pendingInputs)
				if report.authority then
					peer.booted = true
					assert(report.authority.ownSlot == peer.slot, "wrong controller identity")
					peer.maxAge = math.max(peer.maxAge, report.authority.ageMs)
					assert(
						not report.predictedTick or report.predictedTick <= report.authority.tick + 18,
						"unbounded prediction"
					)
					assert(report.presentation.frames <= 32 and report.presentation.delayMs <= 100 + 1e-7)
					assert(report.presentation.tick <= report.authority.tick + 1e-7, "future remote pose")
				end
				local m = report.samples.playerCorrection
				if m.max then
					peer.maxCorrection = math.max(peer.maxCorrection, m.max)
				end
			end
		end
	end
	assert(seenGoal and seenReset, "goal or match reset not observed")
end)
for slot, peer in ipairs(peers) do
	check("client_" .. slot .. "_recovery_and_metrics", function()
		local r = peer.client.report(now)
		local s = debugState.OnInvoke("summary").current
		assert(peer.rawInputs == 0, "raw legacy input sent before bootstrap")
		assert(
			peer.booted and r.authority.matchId == s.matchId and r.authority.round == s.round,
			"epoch did not converge"
		)
		assert(r.pendingInputs == 0 and r.inputs.sequence == r.inputs.acknowledged, "unconfirmed settled inputs")
		assert(r.inputs.mask == 0 and s.players[slot].inputMask == 0, "stuck control")
		local counts = r.counters
		assert(
			counts.queuedInputs == (counts.confirmedInputs or 0) + (counts.cancelledInputs or 0) + r.pendingInputs,
			"lost input accounting"
		)
		assert(counts.inputBytes > 0 and counts.stateBytes == counts.statePackets * 482, "payload accounting")
		assert(
			r.samples.ackMs.count > 0 and r.samples.rttMs.count > 0 and r.samples.playerCorrection.count > 0,
			"missing observations"
		)
		for _, metric in pairs(r.samples) do
			assert(metric.count <= 256)
		end
		for i, p in ipairs(s.players) do
			local x, y = peer.client.pose(i)
			assert(math.abs(x - p.x) < 1e-6 and math.abs(y - p.y) < 1e-6, "settled visual divergence")
		end
		return {
			"rtt/fps",
			peer.rtt,
			peer.fps,
			"ack p50/p95/max ms",
			r.samples.ackMs.p50,
			r.samples.ackMs.p95,
			r.samples.ackMs.max,
			"correction p95/peak units",
			r.samples.playerCorrection.p95,
			peer.maxCorrection,
			"age peak ms",
			peer.maxAge,
			"input/state raw bytes",
			counts.inputBytes,
			counts.stateBytes,
			"max pending",
			peer.maxPending,
			"underflows/rebuffers",
			r.presentation.underflows,
			r.presentation.rebuffers,
		}
	end)
end
check("bounded_server_payload_and_no_stale_epoch_control", function()
	assert(serverPackets <= 16 * 30 + 8 and serverBytes == serverPackets * 482, "state send budget exceeded")
	assert(seenReset)
	return { "datagrams", serverPackets, "raw bytes per stream before fanout", serverBytes }
end)
emit(json(results))
