-- Client-side stadium ambience, transition, shot and priority goal playback.
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local Catalog = require(script.Parent:WaitForChild("StadiumAudioCatalog"))

local Audio = {}
Audio.__index = Audio
local FADE = 2.2

local COOLDOWNS = {
    dangerousAttack = 8, fastBreak = 7, nearMiss = 4.5,
    sustainedPressure = 18, boxThreat = 9,
    shotAttempt = 2.2, shotOnTarget = 2.0,
    goalScored = 0.75, kickoffReset = 1.5,
    kickoffComplete = 1.5, kickoffTimeout = 2, matchFinished = 2,
}

local function makeSound(name)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.Volume = 0
    sound.Looped = false
    sound.Parent = SoundService
    return sound
end

local function setStatus(layer, state, detail)
    pcall(function()
        SoundService:SetAttribute("StadiumAudioLastCueLayer", layer)
        SoundService:SetAttribute("StadiumAudioLastCueState", state)
        SoundService:SetAttribute("StadiumAudioLastCueDetail", detail and tostring(detail) or "")
    end)
end

function Audio.new()
    local self = setmetatable({}, Audio)
    self.enabled = true
    self.baseVolume = 0.24
    self.ambientVolume = self.baseVolume
    self.ambientRunning = false
    self.ambientToken = 0
    self.currentAmbient = nil
    self.random = Random.new()
    self.tweens = {}
    self.cueTokens = {}
    self.lastRegions = {}
    self.lastEventAt = {}
    self.seenIds = {}
    self.seenQueue = {}
    self.intensityToken = 0
    self.ambientSlots = { makeSound("StadiumCrowd_A"), makeSound("StadiumCrowd_B") }
    self.cueSlots = {
        transition = makeSound("StadiumTransition"),
        reaction = makeSound("StadiumCrowdReaction"),
        shot = makeSound("StadiumShotReaction"),
        goal = makeSound("StadiumGoalReaction"),
        whistle = makeSound("StadiumWhistleCandidate"),
        chant = makeSound("StadiumChant"),
    }
    return self
end

function Audio:_tween(sound, value, seconds, onComplete)
    if self.tweens[sound] then
        self.tweens[sound]:Cancel()
        self.tweens[sound] = nil
    end
    if seconds <= 0 then
        sound.Volume = value
        if onComplete then onComplete() end
        return
    end
    local tween = TweenService:Create(
        sound,
        TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { Volume = value }
    )
    self.tweens[sound] = tween
    tween.Completed:Connect(function(state)
        if self.tweens[sound] == tween then
            self.tweens[sound] = nil
            if state == Enum.PlaybackState.Completed and onComplete then onComplete() end
        end
    end)
    tween:Play()
end

function Audio:_region(key, requestedIndex)
    local asset = Catalog.Get(key)
    if not asset or #asset.regions == 0 then return nil end
    local index = requestedIndex
    if not index then
        index = self.random:NextInteger(1, #asset.regions)
        if #asset.regions > 1 and index == self.lastRegions[key] then
            index = index % #asset.regions + 1
        end
    end
    if not asset.regions[index] then return nil end
    self.lastRegions[key] = index
    return asset, asset.regions[index]
end

function Audio:_loadAmbient(sound, token)
    local deadline = os.clock() + 10
    while not sound.IsLoaded and os.clock() < deadline do
        if token ~= self.ambientToken or not self.ambientRunning then return false end
        task.wait(0.05)
    end
    return sound.IsLoaded and token == self.ambientToken and self.ambientRunning
end

function Audio:_ambientCycle(token, slotIndex)
    if not self.enabled or not self.ambientRunning or token ~= self.ambientToken then return end
    local asset, region = self:_region("Normal")
    if not asset then return end
    local sound = self.ambientSlots[slotIndex]
    local oldIndex = self.currentAmbient
    local oldSound = oldIndex and self.ambientSlots[oldIndex] or nil
    sound:Stop()
    sound.SoundId = "rbxassetid://" .. tostring(asset.soundId)
    sound.PlaybackRegionsEnabled = true
    sound.PlaybackRegion = NumberRange.new(region[1], region[2])
    sound.Looped = false
    sound.Volume = 0

    task.spawn(function()
        if not self:_loadAmbient(sound, token) then
            warn("Stadium audio: normal crowd asset did not load")
            return
        end
        sound:Play()
        self.currentAmbient = slotIndex
        self:_tween(sound, self.ambientVolume, FADE)
        if oldSound and oldSound ~= sound and oldSound.IsPlaying then
            self:_tween(oldSound, 0, FADE, function() oldSound:Stop() end)
        end
        task.delay(math.max(1, region[2] - region[1] - FADE), function()
            if token == self.ambientToken and self.ambientRunning then
                self:_ambientCycle(token, slotIndex == 1 and 2 or 1)
            end
        end)
    end)
end

function Audio:StartAmbient(volume)
    if not self.enabled then return false end
    self.baseVolume = volume or self.baseVolume
    self.ambientVolume = self.baseVolume
    if self.ambientRunning then
        self:SetAmbientIntensity(self.ambientVolume, 1)
        return true
    end
    self.ambientRunning = true
    self.ambientToken += 1
    self.currentAmbient = nil
    self:_ambientCycle(self.ambientToken, 1)
    return true
end

function Audio:SetAmbientIntensity(volume, seconds)
    self.ambientVolume = math.clamp(volume, 0, 1)
    for _, sound in ipairs(self.ambientSlots) do
        if sound.IsPlaying then self:_tween(sound, self.ambientVolume, seconds or 1) end
    end
end

function Audio:_boost(volume, holdSeconds)
    self.intensityToken += 1
    local token = self.intensityToken
    self:SetAmbientIntensity(volume, 0.9)
    task.delay(holdSeconds, function()
        if token == self.intensityToken and self.ambientRunning then
            self:SetAmbientIntensity(self.baseVolume, 2)
        end
    end)
end

function Audio:StopAmbient(seconds)
    self.ambientToken += 1
    self.ambientRunning = false
    self.currentAmbient = nil
    self.intensityToken += 1
    for _, sound in ipairs(self.ambientSlots) do
        if sound.IsPlaying then
            self:_tween(sound, 0, seconds or FADE, function() sound:Stop() end)
        else
            sound:Stop()
        end
    end
end

function Audio:PlayExternalCue(layer, soundId, startSec, endSec, options)
    options = options or {}
    if not self.enabled or (type(soundId) ~= "number" and type(soundId) ~= "string") then return false end
    if type(startSec) ~= "number" or type(endSec) ~= "number"
        or startSec < 0 or endSec <= startSec or endSec - startSec > 420 then return false end
    local sound = self.cueSlots[layer]
    if not sound then return false end
    if sound.IsPlaying and options.replace ~= true then
        setStatus(layer, "busy", "higher priority sound already occupies this channel")
        return false
    end

    local token = (self.cueTokens[layer] or 0) + 1
    self.cueTokens[layer] = token
    sound:Stop()
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.PlaybackRegionsEnabled = true
    sound.PlaybackRegion = NumberRange.new(startSec, endSec)
    sound.Looped = false
    sound.Volume = 0
    setStatus(layer, "loading", sound.SoundId)

    local targetVolume = math.clamp(options.volume or 0.3, 0, 1)
    local fadeIn = math.clamp(options.fadeIn or 0.2, 0, (endSec - startSec) * 0.45)
    local fadeOut = math.clamp(options.fadeOut or 0.45, 0, (endSec - startSec) * 0.45)

    task.spawn(function()
        local loaded, loadError = pcall(function()
            ContentProvider:PreloadAsync({ sound })
        end)
        if self.cueTokens[layer] ~= token or not self.enabled then return end
        if not loaded or not sound.IsLoaded then
            local reason = loaded and "Sound.IsLoaded remained false" or loadError
            setStatus(layer, "load_failed", reason)
            warn(string.format("Stadium audio: %s failed to load (%s)", layer, tostring(reason)))
            return
        end

        local timeLength = sound.TimeLength
        local actualEnd = math.min(endSec, timeLength)
        if timeLength <= startSec or actualEnd <= startSec then
            setStatus(layer, "invalid_region", string.format("TimeLength %.3f, region %.3f-%.3f", timeLength, startSec, endSec))
            warn(string.format("Stadium audio: %s region is outside asset TimeLength", layer))
            return
        end

        sound.PlaybackRegionsEnabled = true
        sound.PlaybackRegion = NumberRange.new(startSec, actualEnd)
        sound:Play()
        if not sound.IsPlaying then
            setStatus(layer, "play_failed", sound.SoundId)
            warn(string.format("Stadium audio: %s loaded but did not enter playback", layer))
            return
        end
        setStatus(layer, "playing", sound.SoundId)

        local duration = actualEnd - startSec
        local safeFadeOut = math.min(fadeOut, duration * 0.45)
        self:_tween(sound, targetVolume, fadeIn)
        task.delay(math.max(0, duration - safeFadeOut), function()
            if self.cueTokens[layer] ~= token then return end
            self:_tween(sound, 0, safeFadeOut, function()
                if self.cueTokens[layer] == token then
                    sound:Stop()
                    setStatus(layer, "ended", sound.SoundId)
                end
            end)
        end)
    end)
    return true
end

function Audio:PlayCue(layer, key, options)
    options = options or {}
    local asset, region = self:_region(key, options.regionIndex)
    if not asset then return false end
    return self:PlayExternalCue(layer, asset.soundId, region[1], region[2], options)
end

function Audio:_acceptEvent(kind, payload)
    local eventId = payload and payload.eventId
    if eventId and self.seenIds[eventId] then return false end
    if eventId then
        self.seenIds[eventId] = true
        table.insert(self.seenQueue, eventId)
        if #self.seenQueue > 128 then
            self.seenIds[table.remove(self.seenQueue, 1)] = nil
        end
    end
    local now = os.clock()
    local cooldown = COOLDOWNS[kind] or 0
    if now - (self.lastEventAt[kind] or -math.huge) < cooldown then return false end
    self.lastEventAt[kind] = now
    return true
end

function Audio:HandleEvent(kind, payload)
    payload = payload or {}
    if kind == "matchSync" then
        local volume = payload.phase == "playing" and 0.29 or 0.17
        self.baseVolume = volume
        return self:StartAmbient(volume)
    end
    if not self:_acceptEvent(kind, payload) then return false end
    pcall(function() SoundService:SetAttribute("StadiumAudioLastEvent", kind) end)

    if kind == "kickoffComplete" then
        self:_boost(0.32, 3.5)
        self:PlayCue("whistle", "Whistles", {
            volume = 0.38, fadeIn = 0.04, fadeOut = 0.3, replace = true,
        })
    elseif kind == "kickoffReset" then
        self:_boost(0.15, 4)
        self:PlayCue("transition", "Falling", { volume = 0.13, fadeIn = 0.45, fadeOut = 0.9 })
    elseif kind == "kickoffTimeout" then
        self:_boost(0.29, 2.5)
        self:PlayCue("whistle", "Whistles", {
            volume = 0.40, fadeIn = 0.03, fadeOut = 0.35, replace = true,
        })
        self:PlayCue("transition", "Rising", { volume = 0.12, fadeIn = 0.4, fadeOut = 0.8 })
    elseif kind == "goalScored" then
        self:_boost(0.60, 7)
        local played = self:PlayCue("goal", "Sustained", {
            volume = 0.68, fadeIn = 0.18, fadeOut = 1.35, replace = true,
        })
        if not played then
            self:PlayCue("shot", "ShortReaction", {
                volume = 0.52, fadeIn = 0.12, fadeOut = 0.85, replace = true,
            })
        end
        self:PlayCue("transition", "Rising", {
            volume = 0.16, fadeIn = 0.45, fadeOut = 0.95, replace = true,
        })
    elseif kind == "shotOnTarget" then
        self:_boost(0.43, 3.2)
        self:PlayCue("shot", "ShortReaction", {
            volume = 0.42, fadeIn = 0.08, fadeOut = 0.65, replace = true,
        })
    elseif kind == "shotAttempt" then
        self:PlayCue("transition", "Rising", { volume = 0.16, fadeIn = 0.2, fadeOut = 0.7 })
    elseif kind == "fastBreak" then
        self:_boost(0.40, 3.4)
        self:PlayCue("transition", "Rising", { volume = 0.20, fadeIn = 0.25, fadeOut = 0.8 })
        self:PlayCue("reaction", "ShortReaction", { volume = 0.20, fadeIn = 0.2, fadeOut = 0.55 })
    elseif kind == "dangerousAttack" or kind == "boxThreat" then
        self:PlayCue("transition", "Rising", { volume = kind == "boxThreat" and 0.17 or 0.13, fadeIn = 0.3, fadeOut = 0.8 })
    elseif kind == "nearMiss" then
        self:_boost(0.38, 2.8)
        self:PlayCue("shot", "ShortReaction", {
            volume = 0.33, fadeIn = 0.12, fadeOut = 0.6, replace = true,
        })
    elseif kind == "sustainedPressure" then
        self:_boost(0.44, 4.8)
        self:PlayCue("reaction", "Sustained", { volume = 0.34, fadeIn = 0.45, fadeOut = 1.2 })
    elseif kind == "matchFinished" then
        self:_boost(0.50, 7)
        self:PlayCue("goal", "Sustained", {
            volume = 0.56, fadeIn = 0.35, fadeOut = 1.4, replace = true,
        })
    end
    return true
end

function Audio:SetEnabled(enabled)
    self.enabled = enabled == true
    if not self.enabled then
        self:StopAmbient(1)
        for layer, sound in pairs(self.cueSlots) do
            self.cueTokens[layer] = (self.cueTokens[layer] or 0) + 1
            sound:Stop()
            sound.Volume = 0
        end
    end
end

function Audio:Destroy()
    self:StopAmbient(0)
    for _, sound in pairs(self.cueSlots) do sound:Stop(); sound:Destroy() end
    for _, sound in ipairs(self.ambientSlots) do sound:Stop(); sound:Destroy() end
end

return Audio
