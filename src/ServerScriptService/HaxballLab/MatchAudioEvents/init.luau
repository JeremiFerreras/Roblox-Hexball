-- Match-context audio events. Confirmed goals still come from LocalMatch2D.
local MatchAudioEvents = {}
MatchAudioEvents.__index = MatchAudioEvents

function MatchAudioEvents.new(profile, options)
    assert(type(profile) == "table" and type(profile.Goals) == "table", "goal profile is required")
    options = options or {}
    return setmetatable({
        profile = profile,
        tickRate = options.tickRate or 60,
        attackRange = options.attackRange or 220,
        minAttackSpeed = options.minAttackSpeed or 1.6,
        fastBreakSpeed = options.fastBreakSpeed or 4.2,
        pressureSeconds = options.pressureSeconds or 2.6,
        nearMissCooldownTicks = options.nearMissCooldownTicks or 210,
        shotCooldownTicks = options.shotCooldownTicks or 72,
        boxThreatCooldownTicks = options.boxThreatCooldownTicks or 300,
        attackActive = false,
        attackSide = nil,
        pressureTicks = 0,
        pressureSent = false,
        boxThreatActive = false,
        lastAttackEventTick = -math.huge,
        lastNearMissTick = -math.huge,
        lastShotTick = -math.huge,
        lastBoxThreatTick = -math.huge,
    }, MatchAudioEvents)
end

function MatchAudioEvents:Reset()
    self.attackActive = false
    self.attackSide = nil
    self.pressureTicks = 0
    self.pressureSent = false
    self.boxThreatActive = false
    self.lastAttackEventTick = -math.huge
    self.lastNearMissTick = -math.huge
    self.lastShotTick = -math.huge
    self.lastBoxThreatTick = -math.huge
end

local function magnitude(x, y)
    return math.sqrt(x * x + y * y)
end

function MatchAudioEvents:ObserveKick(ball, shooter, tick)
    local emitted = {}
    if type(ball) ~= "table" then
        return emitted
    end
    tick = tick or 0
    local goals = self.profile.Goals
    local vx, vy = ball.vx or 0, ball.vy or 0
    local speed = magnitude(vx, vy)
    if speed < 3.0 or math.abs(vx) < 2.4 then
        return emitted
    end

    local side, scoringTeam, distance
    if vx > 0 then
        side, scoringTeam = "right", goals.scoringTeams.right
        distance = goals.rightX - (ball.x or 0)
    else
        side, scoringTeam = "left", goals.scoringTeams.left
        distance = (ball.x or 0) - goals.leftX
    end
    if distance <= 16 or distance > 250 then
        return emitted
    end

    local projectedY = (ball.y or 0) + vy * (distance / math.abs(vx))
    local lateral = math.abs(projectedY)
    if lateral > goals.halfHeight + 28 or tick - self.lastShotTick < self.shotCooldownTicks then
        return emitted
    end

    self.lastShotTick = tick
    local kind = lateral <= goals.halfHeight and "shotOnTarget" or "shotAttempt"
    table.insert(emitted, {
        kind = kind,
        tick = tick,
        targetSide = side,
        scoringTeam = scoringTeam,
        shooterId = shooter and shooter.id or nil,
        shooterTeam = shooter and shooter.team or nil,
        distanceToGoal = distance,
        ballSpeed = speed,
        projectedY = projectedY,
    })
    return emitted
end

function MatchAudioEvents:Step(ball, phase, tick)
    local emitted = {}
    tick = tick or 0
    if phase ~= "playing" or type(ball) ~= "table" then
        self.attackActive = false
        self.attackSide = nil
        self.pressureTicks = 0
        self.pressureSent = false
        self.boxThreatActive = false
        return emitted
    end

    local goals = self.profile.Goals
    local vx, vy = ball.vx or 0, ball.vy or 0
    local speed = magnitude(vx, vy)
    local x, y = ball.x or 0, ball.y or 0
    local side, scoringTeam, distance

    if vx >= self.minAttackSpeed and x < goals.rightX then
        side, scoringTeam = "right", goals.scoringTeams.right
        distance = goals.rightX - x
    elseif vx <= -self.minAttackSpeed and x > goals.leftX then
        side, scoringTeam = "left", goals.scoringTeams.left
        distance = x - goals.leftX
    end

    local attackCorridor = side ~= nil
        and distance >= 0 and distance <= self.attackRange
        and math.abs(y) <= goals.halfHeight + 28
        and speed >= self.minAttackSpeed

    if attackCorridor then
        if not self.attackActive or self.attackSide ~= side then
            self.attackActive = true
            self.attackSide = side
            self.pressureTicks = 0
            self.pressureSent = false
            if tick - self.lastAttackEventTick >= self.tickRate * 1.5 then
                local kind = speed >= self.fastBreakSpeed and "fastBreak" or "dangerousAttack"
                table.insert(emitted, {
                    kind = kind, tick = tick, targetSide = side, scoringTeam = scoringTeam,
                    distanceToGoal = distance, ballSpeed = speed,
                })
                self.lastAttackEventTick = tick
            end
        end

        self.pressureTicks += 1
        if not self.pressureSent and self.pressureTicks >= self.tickRate * self.pressureSeconds then
            self.pressureSent = true
            table.insert(emitted, {
                kind = "sustainedPressure", tick = tick, targetSide = side, scoringTeam = scoringTeam,
                durationTicks = self.pressureTicks, distanceToGoal = distance, ballSpeed = speed,
            })
        end
    else
        self.attackActive = false
        self.attackSide = nil
        self.pressureTicks = 0
        self.pressureSent = false
    end

    local inBoxThreat = side ~= nil and distance >= 0 and distance <= 92
        and math.abs(y) <= goals.halfHeight + 48 and speed >= 1.35
    if inBoxThreat and not self.boxThreatActive
        and tick - self.lastBoxThreatTick >= self.boxThreatCooldownTicks then
        self.boxThreatActive = true
        self.lastBoxThreatTick = tick
        table.insert(emitted, {
            kind = "boxThreat", tick = tick, targetSide = side, scoringTeam = scoringTeam,
            distanceToGoal = distance, ballSpeed = speed,
        })
    elseif not inBoxThreat then
        self.boxThreatActive = false
    end

    -- Near miss is an approach just outside the known goal opening, never a scored goal.
    local nearMiss = side ~= nil and distance >= 0 and distance <= 18
        and math.abs(y) > goals.halfHeight and math.abs(y) <= goals.halfHeight + 30
        and speed >= self.minAttackSpeed
        and tick - self.lastNearMissTick >= self.nearMissCooldownTicks
    if nearMiss then
        self.lastNearMissTick = tick
        table.insert(emitted, {
            kind = "nearMiss", tick = tick, targetSide = side, scoringTeam = scoringTeam,
            distanceToGoal = distance, ballSpeed = speed,
            lateralMiss = math.abs(y) - goals.halfHeight,
        })
    end
    return emitted
end

return MatchAudioEvents
