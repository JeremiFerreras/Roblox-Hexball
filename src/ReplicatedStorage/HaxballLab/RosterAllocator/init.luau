--!strict
-- Pure deterministic 4v4 slot allocation. No Roblox services or instances.
local Allocator = {}

-- preferredTeam ("red"/"blue") restricts the search to that side; nil keeps the automatic balance.
function Allocator.nextSlot(
    slotUserIds: { [number]: number? },
    playerCount: number,
    playersPerTeam: number,
    preferredTeam: string?
): number?
    assert(type(slotUserIds) == "table", "slot ownership table is required")
    assert(type(playerCount) == "number" and playerCount > 0 and playerCount % 1 == 0, "player count must be a positive integer")
    assert(type(playersPerTeam) == "number" and playersPerTeam > 0 and playersPerTeam % 1 == 0, "team size must be a positive integer")
    assert(playerCount == playersPerTeam * 2, "allocator requires two equal teams")

    local redCount, blueCount = 0, 0
    for slot = 1, playerCount do
        if slotUserIds[slot] ~= nil then
            if slot <= playersPerTeam then
                redCount += 1
            else
                blueCount += 1
            end
        end
    end

    local firstTeam = redCount <= blueCount and "red" or "blue"
    local secondTeam = firstTeam == "red" and "blue" or "red"
    local order = { firstTeam, secondTeam }
    if preferredTeam ~= nil then
        assert(preferredTeam == "red" or preferredTeam == "blue", "preferred team must be red or blue")
        order = { preferredTeam }
    end
    for _, teamName in ipairs(order) do
        local firstSlot = teamName == "red" and 1 or playersPerTeam + 1
        local lastSlot = firstSlot + playersPerTeam - 1
        for slot = firstSlot, lastSlot do
            if slotUserIds[slot] == nil then
                return slot
            end
        end
    end
    return nil
end

function Allocator.activate(disc, userId: number)
    assert(type(disc) == "table", "player disc is required")
    assert(type(userId) == "number" and userId > 0 and userId % 1 == 0, "user id must be a positive integer")
    disc.ownerUserId = userId
    disc.enabled = true
end

function Allocator.deactivate(disc, spawn: { x: number, y: number }?)
    assert(type(disc) == "table", "player disc is required")
    disc.ownerUserId = nil
    disc.enabled = false
    disc.vx, disc.vy = 0, 0
    disc.kickHeld, disc.kickArmed, disc.kickCooldown = false, false, 0
    if spawn then
        disc.x, disc.y = spawn.x, spawn.y
    end
end

return Allocator
