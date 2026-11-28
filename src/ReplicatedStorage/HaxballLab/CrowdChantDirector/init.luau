-- Extensible chant director.
-- No supplied clip is positively identified as an organized chant, so defaults are empty.
local Director = {}
Director.__index = Director

function Director.new(audioController)
    assert(type(audioController) == "table", "audio controller is required")
    return setmetatable({
        audio = audioController,
        patterns = {},
        lastPlayedAt = {},
        lastClipIndex = {},
        enabled = true,
    }, Director)
end

function Director:RegisterPattern(name, definition)
    assert(type(name) == "string" and name ~= "", "pattern name is required")
    assert(type(definition) == "table" and type(definition.events) == "table", "pattern events are required")
    assert(type(definition.clips) == "table" and #definition.clips > 0, "verified chant clips are required")
    local clips = {}
    for index, clip in ipairs(definition.clips) do
        assert(type(clip.soundId) == "number" or type(clip.soundId) == "string", "chant sound ID is required")
        assert(type(clip.startSec) == "number" and type(clip.endSec) == "number"
            and clip.startSec >= 0 and clip.endSec > clip.startSec
            and clip.endSec - clip.startSec <= 420, "chant region is invalid")
        clips[index] = {
            soundId = clip.soundId, startSec = clip.startSec, endSec = clip.endSec,
            volume = math.clamp(clip.volume or 0.24, 0, 1),
        }
    end
    local eventMap = {}
    for eventName, enabled in pairs(definition.events) do
        if enabled == true then eventMap[eventName] = true end
    end
    assert(next(eventMap) ~= nil, "at least one chant event is required")
    self.patterns[name] = {
        events = eventMap,
        clips = clips,
        cooldown = math.max(0, definition.cooldown or 35),
    }
    return true
end

function Director:RemovePattern(name)
    self.patterns[name] = nil
    self.lastPlayedAt[name] = nil
    self.lastClipIndex[name] = nil
end

function Director:IsReady()
    return self.enabled and next(self.patterns) ~= nil
end

function Director:HandleEvent(eventName)
    if not self.enabled then return false end
    local now = os.clock()
    local played = false
    for name, pattern in pairs(self.patterns) do
        if pattern.events[eventName] and now - (self.lastPlayedAt[name] or -math.huge) >= pattern.cooldown then
            local index = math.random(1, #pattern.clips)
            if #pattern.clips > 1 and index == self.lastClipIndex[name] then
                index = index % #pattern.clips + 1
            end
            local clip = pattern.clips[index]
            if self.audio:PlayExternalCue("chant", clip.soundId, clip.startSec, clip.endSec, {
                volume = clip.volume, fadeIn = 0.5, fadeOut = 0.9,
            }) then
                self.lastPlayedAt[name] = now
                self.lastClipIndex[name] = index
                played = true
            end
        end
    end
    return played
end

function Director:SetEnabled(enabled)
    self.enabled = enabled == true
    if not self.enabled and self.audio.cueSlots and self.audio.cueSlots.chant then
        self.audio.cueSlots.chant:Stop()
    end
end

return Director
