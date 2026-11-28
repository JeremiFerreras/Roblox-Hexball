local Catalog = require("../../src/ReplicatedStorage/HaxballLab/StadiumAudioCatalog")
local MatchAudioEvents = require("../../src/ServerScriptService/HaxballLab/MatchAudioEvents")
local ChantDirector = require("../../src/ReplicatedStorage/HaxballLab/CrowdChantDirector")
local Profile = require("../../src/ReplicatedStorage/HaxballLab/StadiumReference2D")

local passed = 0
local function check(name, condition)
    if not condition then error("FAIL " .. name, 2) end
    passed += 1
    print("PASS " .. name)
end
local function hasKind(events, expected)
    for _, event in ipairs(events) do
        if event.kind == expected then return true end
    end
    return false
end

local valid, errors = Catalog.Validate()
check("six uploaded assets and all playback regions are valid", valid)
local assets = 0
for key, asset in pairs(Catalog.Assets) do
    assets += 1
    check(key .. " has a valid ID and at least one region", asset.soundId > 0 and #asset.regions > 0)
end
check("catalog has exactly six assets", assets == 6)

local classifier = MatchAudioEvents.new(Profile)
local initial = classifier:Step({ x = 250, y = 0, vx = 5.1, vy = 0 }, "playing", 1)
check("fast attack toward goal is detected", hasKind(initial, "fastBreak"))
local duplicate = classifier:Step({ x = 260, y = 0, vx = 5.1, vy = 0 }, "playing", 2)
check("continuous attack does not spam a start event", #duplicate == 0)
local pressure = false
for tick = 3, 185 do
    local emitted = classifier:Step({ x = 270, y = 0, vx = 5.1, vy = 0 }, "playing", tick)
    pressure = pressure or hasKind(emitted, "sustainedPressure")
end
check("sustained pressure fires after three seconds", pressure)
local later = classifier:Step({ x = 280, y = 0, vx = 5.1, vy = 0 }, "playing", 186)
check("sustained pressure does not fire each tick", not hasKind(later, "sustainedPressure"))

local nearMiss = MatchAudioEvents.new(Profile):Step({
    x = 358, y = 78, vx = 3.2, vy = 0,
}, "playing", 10)
check("ball just outside the goal opening is a near miss", hasKind(nearMiss, "nearMiss"))
local quiet = MatchAudioEvents.new(Profile):Step({
    x = 0, y = 0, vx = 1, vy = 0,
}, "playing", 1)
check("ordinary midfield movement creates no crowd event", #quiet == 0)
check("non-playing phase clears pressure tracking",
    #classifier:Step({ x = 280, y = 0, vx = 5.1, vy = 0 }, "kickoff", 190) == 0)

local fakeAudio = {
    calls = 0,
    PlayExternalCue = function(self, layer, soundId, startSec, endSec, options)
        self.calls += 1
        return true
    end,
}
local chants = ChantDirector.new(fakeAudio)
check("chant director defaults to no unverified chants", not chants:IsReady())
check("unconfigured chant director does not label generic crowd noise", not chants:HandleEvent("goalScored"))
check("verified chant pattern can be registered", chants:RegisterPattern("home-chant", {
    events = { goalScored = true, sustainedPressure = true },
    cooldown = 0,
    clips = { { soundId = 123456789, startSec = 2, endSec = 8, volume = 0.2 } },
}))
check("chant director becomes ready when clips are registered", chants:IsReady())
check("registered chant uses the shared playback-region channel",
    chants:HandleEvent("goalScored") and fakeAudio.calls == 1)
chants:RemovePattern("home-chant")
check("removing last chant pattern disables playback", not chants:IsReady())

print(string.format("PASS %d stadium audio checks", passed))
