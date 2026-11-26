-- Minimal numeric/property adapters. These do not render or emulate Roblox services.
local nativeTypeof = typeof
local vectorMeta = {}
vectorMeta.__index = function(v, k)
	if k == "Magnitude" then
		return math.sqrt(v.X * v.X + v.Y * v.Y + (v.Z or 0) ^ 2)
	end
end
local function vector(x, y, z, kind)
	return setmetatable({ X = x, Y = y, Z = z, __type = kind or "Vector3" }, vectorMeta)
end
vectorMeta.__add = function(a, b)
	return vector(a.X + b.X, a.Y + b.Y, (a.Z or 0) + (b.Z or 0), a.__type)
end
vectorMeta.__sub = function(a, b)
	return vector(a.X - b.X, a.Y - b.Y, (a.Z or 0) - (b.Z or 0), a.__type)
end
vectorMeta.__mul = function(a, b)
	return vector(a.X * b, a.Y * b, (a.Z or 0) * b, a.__type)
end
local function typeof(v)
	return type(v) == "table" and v.__type or nativeTypeof(v)
end
local Vector3 = {
	new = function(x, y, z)
		return vector(x, y, z)
	end,
}
local Vector2 = { zero = vector(0, 0, nil, "Vector2") }
local frameMeta
frameMeta = {
	__mul = function(a, b)
		return setmetatable({ Position = a.Position or b.Position, rotation = b.rotation or a.rotation }, frameMeta)
	end,
}
local CFrame = {
	new = function(x, y, z)
		return setmetatable({ Position = type(x) == "table" and x or vector(x, y, z) }, frameMeta)
	end,
	Angles = function(x, y, z)
		return setmetatable({ rotation = { x, y, z } }, frameMeta)
	end,
	lookAt = function(a, b)
		assert((b - a).Magnitude > 0)
		return setmetatable({ Position = a, target = b }, frameMeta)
	end,
}
local Color3 = {
	new = function(...)
		return { ... }
	end,
	fromRGB = function(...)
		return { ... }
	end,
}
local UDim2 = {
	new = function(...)
		return { ... }
	end,
	fromOffset = function(...)
		return { ... }
	end,
}
local Enum = {
	PartType = { Ball = "Ball", Cylinder = "Cylinder" },
	Material = { Neon = "Neon" },
	CameraType = { Scriptable = "Scriptable" },
	Font = { Code = "Code", GothamMedium = "GothamMedium" },
	TextXAlignment = { Left = "Left" },
	TextYAlignment = { Top = "Top" },
}
local objects = {}
local nodeMeta = {}
local function object(name, class)
	local o = setmetatable({
		_props = {
			Name = name,
			ClassName = class,
			Position = vector(0, 11, 0),
			Size = vector(1, 1, 1),
			Material = "Plastic",
			Transparency = 0,
		},
		children = {},
	}, nodeMeta)
	o.Activated = signal()
	table.insert(objects, o)
	return o
end
nodeMeta.__index = function(self, key)
	if key == "WaitForChild" then
		return function(o, name)
			assert(o.children[name], o.Name .. " missing child " .. name)
			return o.children[name]
		end
	end
	if key == "Position" and self._props.CFrame then
		return self._props.CFrame.Position
	end
	return self._props[key]
end
nodeMeta.__newindex = function(self, key, value)
	self._props[key] = value
	if key == "Parent" then
		value.children[self.Name] = self
	end
end
local Instance = {
	new = function(class)
		return object(class, class)
	end,
}
local guiRoot = object("PlayerGui", "PlayerGui")
local camera = object("Camera", "Camera")
local field = object("HaxballLab", "Model")
for _, name in ipairs({ "PlayerDisc", "PlayerDisc2", "BallDisc", "DebugLine", "PairDebugLine", "BallP2DebugLine" }) do
	local p = object(name, "Part")
	p.Parent = field
end
local workspace = {
	CurrentCamera = camera,
	WaitForChild = function(self, name)
		assert(name == "HaxballLab")
		return field
	end,
}
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
