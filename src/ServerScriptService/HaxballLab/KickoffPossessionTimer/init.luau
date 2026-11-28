-- Pure deterministic timer for releasing kickoff ownership after a fixed number of match ticks.
local Timer = {}

function Timer.Start(match, team)
    assert(type(match) == "table", "match state is required")
    assert(team == "red" or team == "blue", "kickoff team must be red or blue")
    match.kickoffTeam = team
    match.kickoffWaitTicks = 0
end

function Timer.Clear(match)
    local team = match.kickoffTeam
    match.kickoffTeam = nil
    match.kickoffWaitTicks = 0
    return team
end

function Timer.Advance(match, timeoutTicks)
    assert(type(match) == "table", "match state is required")
    assert(type(timeoutTicks) == "number" and timeoutTicks > 0 and timeoutTicks % 1 == 0,
        "kickoff timeout must be a positive integer number of ticks")
    if not match.kickoffTeam then
        match.kickoffWaitTicks = 0
        return nil
    end
    match.kickoffWaitTicks = (match.kickoffWaitTicks or 0) + 1
    if match.kickoffWaitTicks >= timeoutTicks then
        return Timer.Clear(match)
    end
    return nil
end

return Timer
