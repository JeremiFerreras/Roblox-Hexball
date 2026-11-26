-- Per-client transport/service adapters; the production LabClient source is loaded unchanged.
local now = clockBias
local os = {
	clock = function()
		return now
	end,
}
local render, snapshotSignal, stateSignal, controlSignal = signal(), signal(), signal(), signal()
local inputRemote = {
	FireServer = function(self, ...)
		transport:send("input", true, ...)
	end,
}
local inputStreamRemote = {
	FireServer = function(self, ...)
		transport:send("input", false, ...)
	end,
}
local controlRemote = {
	OnClientEvent = controlSignal,
	FireServer = function(self, ...)
		transport:send("control", true, ...)
	end,
}
local commandRemote = {
	FireServer = function(self, ...)
		transport:send("command", true, ...)
	end,
}
local moveState, kickState = Vector2.zero, false
local moveAction = {
	GetState = function()
		return moveState
	end,
}
local kickAction = {
	GetState = function()
		return kickState
	end,
}
local context = {
	WaitForChild = function(self, name)
		if name == "Move" then
			return moveAction
		elseif name == "Kick" then
			return kickAction
		end
		error(name)
	end,
}
local clientLab = {
	Remotes = {
		Input = inputRemote,
		Snapshot = { OnClientEvent = snapshotSignal },
		DebugCommand = commandRemote,
		InputStream = inputStreamRemote,
		StateStream = { OnClientEvent = stateSignal },
		Control = controlRemote,
	},
	WaitForChild = function(self, name)
		return name
	end,
}
clientLab.Remotes.WaitForChild = function(self, name)
	assert(self[name], name)
	return self[name]
end
local clientStore = {
	WaitForChild = function(self, name)
		if name == "HaxballLab" then
			return clientLab
		end
		if name == "Inputs" then
			return {
				WaitForChild = function()
					return context
				end,
			}
		end
		error(name)
	end,
}
player.WaitForChild = function(self, name)
	assert(name == "PlayerGui")
	return guiRoot
end
local game = {
	GetService = function(self, name)
		if name == "Players" then
			return { LocalPlayer = player }
		end
		if name == "ReplicatedStorage" then
			return clientStore
		end
		if name == "RunService" then
			return {
				RenderStepped = render,
				IsStudio = function()
					return false
				end,
			}
		end
		error(name)
	end,
}
local moduleMap = {
	NetPrediction = NetPrediction,
	SnapshotBuffer = SnapshotBuffer,
	NetMetrics = NetMetrics,
	NetCodec = NetCodec,
	NetInputClient = NetInputClient,
	PredictionLab2D = Prediction,
	StadiumReference2D = Profile,
	ClassicReference230 = ClassicReference230,
	StadiumRender2D = StadiumRender2D,
}
local function require(name)
	assert(moduleMap[name], name)
	return moduleMap[name]
end
