-- Render-only interpolation. It never advances authoritative or predicted physics.
local SnapshotBuffer = {}
SnapshotBuffer.__index = SnapshotBuffer

local RATE = 60
local MIN_DELAY = 2
local MAX_DELAY = 8
local CAPACITY = 32
local EPSILON = 1e-6

local function pose(d)
    d = d or {}
    return {
        x = d.x or 0,
        y = d.y or 0,
        vx = d.vx or 0,
        vy = d.vy or 0,
    }
end

local function frame(s)
    local players = {}
    for i, disc in ipairs(s.players or {}) do
        players[i] = pose(disc)
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
        renderFps = nil,
    }, SnapshotBuffer)
end

-- Only validated authoritative snapshots enter this buffer.
function SnapshotBuffer:push(s, now)
    if self.latest and (
        s.matchId < self.matchId
        or s.matchId == self.matchId and (
            s.round < self.round
            or s.round == self.round and s.tick <= self.latest.tick
        )
    ) then
        return false
    end

    local reset = self.matchId ~= s.matchId
        or self.round ~= s.round
        or self.phase ~= s.matchPhase
        or self.coreMode ~= s.coreMode
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
        local tickGap = s.tick - self.latest.tick
        local residual = math.abs(gap * RATE - tickGap)
        self.jitter = self.jitter * 0.9 + math.min(residual, MAX_DELAY) * 0.1

        -- Do not let late packets pull the presentation clock backwards.
        -- Re-anchor only after a real authority stall, not ordinary packet jitter.
        if gap > 0.5 and tickGap < gap * RATE * 0.5 then
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

-- Cubic Hermite interpolation with velocity tangents measured in world units/second.
-- Tangents are limited per axis to avoid large visual overshoot around collisions.
local function hermiteAxis(p0, p1, v0, v1, alpha, duration)
    local delta = p1 - p0
    local tangent0 = v0 * duration
    local tangent1 = v1 * duration

    if math.abs(delta) > EPSILON then
        -- A tangent pointing against the segment would make the disc visibly reverse
        -- before the authoritative collision has actually happened.
        if tangent0 * delta < 0 then tangent0 = 0 end
        if tangent1 * delta < 0 then tangent1 = 0 end

        -- Fritsch-Carlson limiter: retain the velocity curve without overshooting
        -- the interval endpoints when the body is moving monotonically.
        local a = tangent0 / delta
        local b = tangent1 / delta
        local magnitude = a * a + b * b
        if magnitude > 9 then
            local limiter = 3 / math.sqrt(magnitude)
            tangent0 = limiter * a * delta
            tangent1 = limiter * b * delta
        end
    elseif v0 * v1 >= 0 then
        -- Equal endpoints with same-direction tangents are normally a stationary
        -- contact. Do not invent a loop between identical authoritative positions.
        tangent0, tangent1 = 0, 0
    end

    local t2 = alpha * alpha
    local t3 = t2 * alpha
    local h00 = 2 * t3 - 3 * t2 + 1
    local h10 = t3 - 2 * t2 + alpha
    local h01 = -2 * t3 + 3 * t2
    local h11 = t3 - t2
    local value = h00 * p0 + h10 * tangent0 + h01 * p1 + h11 * tangent1

    -- If a collision changes direction between samples, allow a small velocity-based
    -- excursion, but never a large spline loop that can cross half the field.
    local excursion = math.max(math.abs(v0), math.abs(v1)) * duration * 0.25
    local low = math.min(p0, p1) - excursion
    local high = math.max(p0, p1) + excursion
    return math.clamp(value, low, high)
end

local function interpolate(a, b, alpha)
    local duration = math.max((b.tick - a.tick) / RATE, 1 / RATE)
    return {
        x = hermiteAxis(a.x, b.x, a.vx, b.vx, alpha, duration),
        y = hermiteAxis(a.y, b.y, a.vy, b.vy, alpha, duration),
    }
end

function SnapshotBuffer:sample(now)
    if not self.latest then
        return nil
    end

    local dt = math.max(0, now - self.lastSample)
    self.lastSample = math.max(now, self.lastSample)
    if dt > 1e-4 then
        local measuredFps = 1 / dt
        self.renderFps = self.renderFps
            and self.renderFps * 0.85 + measuredFps * 0.15
            or measuredFps
    end

    local target = math.clamp(MIN_DELAY + 2 * self.jitter, MIN_DELAY, MAX_DELAY)
    -- Add buffer quickly when delivery jitter rises; remove it slowly to avoid
    -- continuously moving the presentation clock forward and backward.
    self.delayTicks += math.clamp(target - self.delayTicks, -dt * 0.5, dt * 3)

    local age = math.max(0, now - self.arrivedAt)
    local estimated = now * RATE + self.offset

    -- Interpolate every phase and both the legacy and 4v4 snapshot paths.
    -- Phase/match changes already reset the buffer in push(); there is no reason
    -- to snap to the latest packet merely because the match is at kickoff or pause.
    if #self.frames == 1 then
        self.cursor = self.latest.tick
    else
        local desired = math.min(self.latest.tick, estimated - self.delayTicks)
        if self.cursor < self.frames[1].tick then
            self.cursor = self.frames[1].tick
        end
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
    end

    local starved = #self.frames > 1
        and self.started
        and estimated - self.delayTicks > self.latest.tick + 1e-6
    if starved and not self.starved then
        self.underflows += 1
    end
    self.starved = starved

    self.cursor = math.clamp(self.cursor, self.frames[1].tick, self.latest.tick)
    local a, b = self.frames[1], self.latest
    for i = 2, #self.frames do
        if self.frames[i].tick >= self.cursor then
            a, b = self.frames[i - 1], self.frames[i]
            break
        end
    end

    local alpha = b.tick > a.tick
        and math.clamp((self.cursor - a.tick) / (b.tick - a.tick), 0, 1)
        or 1
    local result = {
        ball = interpolate(a.ball, b.ball, alpha),
        player = interpolate(a.player, b.player, alpha),
        player2 = interpolate(a.player2, b.player2, alpha),
        players = {},
    }
    for i, disc in ipairs(b.players) do
        result.players[i] = interpolate(a.players[i] or disc, disc, alpha)
    end

    local sourceGap = math.max(0, b.tick - a.tick)
    self.status = {
        tick = self.cursor,
        delayMs = self.delayTicks / RATE * 1000,
        ageMs = age * 1000,
        renderLagMs = math.max(0, estimated - self.cursor) / RATE * 1000,
        renderFps = self.renderFps,
        sourceRateHz = sourceGap > 0 and RATE / sourceGap or 0,
        interpolation = "cubic-hermite",
        underflows = self.underflows,
        rebuffers = self.rebuffers,
        frames = #self.frames,
        sourceGapTicks = sourceGap,
    }
    return result, self.status
end

return SnapshotBuffer
