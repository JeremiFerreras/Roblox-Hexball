local now = 0
local os = {
	clock = function()
		return now
	end,
}
local render = signal()
local snapshotSignal = signal()
local inputCalls = {}
local function forwardInput(b, y, kick)
	if typeof(b) == "buffer" then
		local decoded = NetCodec.decodeInput(b)
		local c = decoded.commands[#decoded.commands]
		local value = NetCodec.input(c.mask)
		table.insert(inputCalls, { value.x, value.y, value.kick, c.seq })
		input.fn(player, b)
	else
		table.insert(inputCalls, { b, y, kick })
		input.fn(player, b, y, kick)
	end
end
local inputRemote = {
	FireServer = function(self, ...)
		forwardInput(...)
	end,
}
local inputStreamRemote = {
	FireServer = function(self, ...)
		forwardInput(...)
	end,
}
local stateSignal = signal()
local controlSignal = signal()
local controlRemote = {
	OnClientEvent = controlSignal,
	FireServer = function(self, ...)
		control.fn(player, ...)
	end,
}
control.FireClient = function(self, p, ...)
	if p == player and controlSignal.fn then
		controlSignal.fn(...)
	end
end
local commandRemote = {
	FireServer = function(self, value)
		command.fn(player, value)
	end,
}
local moveState = Vector2.zero
local kickState = false
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
		elseif name == "Inputs" then
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
		elseif name == "ReplicatedStorage" then
			return clientStore
		elseif name == "RunService" then
			return {
				RenderStepped = render,
				IsStudio = function()
					return true
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
local oldPublish = snapshots.FireAllClients
snapshots.FireAllClients = function(self, s)
	oldPublish(self, s)
	if snapshotSignal.fn then
		snapshotSignal.fn(s)
	end
end
local oldState = stateStream.FireAllClients
stateStream.FireAllClients = function(self, b)
	oldState(self, b)
	if stateSignal.fn then
		stateSignal.fn(b)
	end
end
local function advance(dt)
	now += dt
	heartbeat.fn(dt)
	render.fn(dt)
end
local function frameOnly(dt)
	now += dt
	render.fn(dt)
end
local function button(name)
	local gui = guiRoot.children.HaxballLabDebug
	assert(gui and gui.children[name], "missing button " .. name)
	return gui.children[name]
end
