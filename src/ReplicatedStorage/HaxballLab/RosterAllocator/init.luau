--!strict
-- Pure deterministic 4v4 slot allocation. No Roblox services or instances.
local Allocator = {}

function Allocator.nextSlot(slotUserIds: { [number]: number? }, playerCount: number, playersPerTeam: number): number?
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
    for _, teamName in ipairs({ firstTeam, secondTeam }) do
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

return Allocator
