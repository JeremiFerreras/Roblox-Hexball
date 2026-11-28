-- Conservative match context classifier. Confirmed outcomes come from LocalMatch2D.
local MatchAudioEvents = {}
MatchAudioEvents.__index = MatchAudioEvents

function MatchAudioEvents.new(profile, options)
    assert(type(profile) == "table" and type(profile.Goals) == "table", "goal profile is required")
    options = options or {}
    return setmetatable({
        profile = profile,
        tickRate = options.tickRate or 60,
        attackRange = options.attackRange or 165,
        minAttackSpeed = options.minAttackSpeed or 2.4,
        fastBreakSpeed = options.fastBreakSpeed or 4.4,
        pressureSeconds = options.pressureSeconds or 3,
        nearMissCooldownTicks = options.nearMissCooldownTicks or 240,
        attackActive = false,
        attackSide = nil,
        pressureTicks = 0,
        pressureSent = false,
        lastAttackEventTick = -math.huge,
        lastNearMissTick = -math.huge,
    }, MatchAudioEvents)
end

function MatchAudioEvents:Reset()
    self.attackActive = false
    self.attackSide = nil
    self.pressureTicks = 0
    self.pressureSent = false
    self.lastAttackEventTick = -math.huge
    self.lastNearMissTick = -math.huge
end

local function magnitude(x, y)
    return math.sqrt(x * x + y * y)
end

function MatchAudioEvents:Step(ball, phase, tick)
    local emitted = {}
    tick = tick or 0
    if phase ~= "playing" or type(ball) ~= "table" then
        self.attackActive = false
        self.attackSide = nil
        self.pressureTicks = 0
        self.pressureSent = false
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

    local inGoalCorridor = side ~= nil and distance >= 0 and distance <= self.attackRange
        and math.abs(y) <= goals.halfHeight and speed >= self.minAttackSpeed

    if inGoalCorridor then
        if not self.attackActive or self.attackSide ~= side then
            self.attackActive = true
            self.attackSide = side
            self.pressureTicks = 0
            self.pressureSent = false
            if tick - self.lastAttackEventTick >= self.tickRate * 2 then
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

    -- A near miss is an approach just outside the known goal opening, never a scored goal.
    local nearMiss = side ~= nil and distance >= 0 and distance <= 14
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
