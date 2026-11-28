-- Main menu: home page with the live bot showcase, and the team selection page behind "Jugar".
-- Presentation only. The server still decides whether a slot is available.
local TweenService = game:GetService("TweenService")

local MainMenu = {}
MainMenu.__index = MainMenu

local JOIN_TIMEOUT = 10
-- The server ignores control requests closer than 15 ticks apart.
local RETRY_COOLDOWN = 0.35

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

-- Soft greens taken from the pitch, so the panels and the field read as one scene.
local Palette = {
	backdropTop = rgb(104, 139, 94),
	backdropBottom = rgb(82, 112, 79),
	panel = rgb(76, 105, 74),
	line = rgb(199, 235, 187),
	text = rgb(244, 247, 232),
	muted = rgb(219, 232, 205),
	button = rgb(226, 238, 199),
	buttonHover = rgb(241, 248, 223),
	buttonPressed = rgb(205, 221, 176),
	buttonText = rgb(43, 68, 45),
	quiet = rgb(93, 124, 88),
	quietHover = rgb(108, 141, 100),
	red = rgb(170, 88, 77),
	redHover = rgb(187, 100, 88),
	blue = rgb(76, 109, 163),
	blueHover = rgb(89, 124, 180),
	disabled = rgb(105, 122, 100),
}
MainMenu.Palette = Palette

local TEAMS = {
	red = { name = "ROJO", color = Palette.red, hover = Palette.redHover },
	blue = { name = "AZUL", color = Palette.blue, hover = Palette.blueHover },
}

local function create(className, parent, properties)
	local object = Instance.new(className)
	for key, value in pairs(properties) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function round(object, radius)
	create("UICorner", object, { CornerRadius = UDim.new(0, radius) })
end

local function outline(object, color, transparency, thickness)
	return create("UIStroke", object, {
		Color = color,
		Transparency = transparency,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function frame(parent, name, x, y, width, height, color, transparency)
	return create("Frame", parent, {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(width, height),
		BackgroundColor3 = color or Palette.panel,
		BackgroundTransparency = transparency or 0,
		BorderSizePixel = 0,
	})
end

-- Scaled text with an upper limit, so the same layout works on phones and wide monitors.
local function label(parent, name, text, x, y, width, height, color, maxSize, font)
	local item = create("TextLabel", parent, {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(width, height),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color,
		Font = font or Enum.Font.GothamBold,
		TextScaled = true,
		TextWrapped = true,
		ZIndex = 3,
	})
	create("UITextSizeConstraint", item, { MinTextSize = 8, MaxTextSize = maxSize })
	return item
end

local function tween(object, seconds, goal, style, direction, delaySeconds)
	local info = TweenInfo.new(seconds, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out, 0,
		false, delaySeconds or 0)
	local animation = TweenService:Create(object, info, goal)
	animation:Play()
	return animation
end

local function button(parent, name, text, x, y, width, height, colors, textColor, maxSize)
	local item = create("TextButton", parent, {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(width, height),
		BackgroundColor3 = colors.idle,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Selectable = true,
		Text = text,
		TextColor3 = textColor,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		ZIndex = 3,
	})
	create("UITextSizeConstraint", item, { MinTextSize = 9, MaxTextSize = maxSize })
	round(item, 12)
	local scale = create("UIScale", item, { Scale = 1 })
	local function animate(size, color)
		tween(scale, 0.16, { Scale = size })
		if item.Active then
			tween(item, 0.16, { BackgroundColor3 = color })
		end
	end
	item.MouseEnter:Connect(function()
		animate(1.05, colors.hover)
	end)
	item.MouseLeave:Connect(function()
		animate(1, colors.idle)
	end)
	item.SelectionGained:Connect(function()
		animate(1.05, colors.hover)
	end)
	item.SelectionLost:Connect(function()
		animate(1, colors.idle)
	end)
	item.MouseButton1Down:Connect(function()
		animate(0.97, colors.pressed or colors.idle)
	end)
	item.MouseButton1Up:Connect(function()
		animate(1.05, colors.hover)
	end)
	return item
end

function MainMenu:_buildHome()
	local home = frame(self.backdrop, "HomePage", 0.5, 0.5, 1, 1, Palette.panel, 1)
	self.home = home

	local panel = frame(home, "MenuPanel", 0.17, 0.5, 0.3, 0.88, Palette.panel)
	round(panel, 18)
	outline(panel, Palette.line, 0.72, 1.2)
	self.panel = panel

	label(panel, "Eyebrow", "FÚTBOL 2D  ·  4 CONTRA 4", 0.5, 0.16, 0.84, 0.045, Palette.muted, 15)
	label(panel, "GameTitle", "SIMPLE\nSOCCER GAME", 0.5, 0.3, 0.86, 0.2, Palette.text, 54, Enum.Font.GothamBlack)
	local divider = frame(panel, "Divider", 0.5, 0.435, 0.2, 0, Palette.line, 0.2)
	divider.Size = UDim2.new(0.2, 0, 0, 3)

	self.playButton = button(panel, "PlayButton", "JUGAR", 0.5, 0.56, 0.74, 0.12, {
		idle = Palette.button,
		hover = Palette.buttonHover,
		pressed = Palette.buttonPressed,
	}, Palette.buttonText, 28)
	self.playButton.Activated:Connect(function()
		self:showTeams()
	end)

	label(panel, "MenuHint", "Elige equipo y salta a la cancha", 0.5, 0.67, 0.82, 0.04, Palette.muted, 14,
		Enum.Font.GothamMedium)
	label(panel, "Footer", "SIMPLE SOCCER GAME  ·  4V4", 0.5, 0.94, 0.82, 0.03, Palette.muted, 11,
		Enum.Font.GothamMedium)

	local stage = frame(home, "ShowcaseStage", 0.66, 0.5, 0.63, 0.9, Palette.panel, 1)
	create("UIAspectRatioConstraint", stage, { AspectRatio = 840 / 540 })
	self.stage = stage

	self.playTitle = label(stage, "PlayTitle", "JUGADAS DE DEMOSTRACIÓN", 0.5, 0.045, 0.96, 0.075, Palette.text,
		30, Enum.Font.GothamBlack)
	self.playCaption = label(stage, "PlayCaption", "", 0.5, 0.113, 0.96, 0.048, Palette.muted, 16,
		Enum.Font.GothamMedium)

	-- 840x400 logical pitch inside an 840x540 stage.
	local pitch = frame(stage, "PhysicsPreviewPitch", 0.5, 0.15 + 400 / 540 / 2, 1, 400 / 540, rgb(116, 146, 92))
	pitch.ClipsDescendants = true
	round(pitch, 14)
	outline(pitch, Palette.line, 0.5, 1.4)
	self.pitch = pitch

	self.goalBanner = label(pitch, "GoalBanner", "¡GOL!", 0.5, 0.2, 0.26, 0.17, Palette.text, 52,
		Enum.Font.GothamBlack)
	self.goalBanner.BackgroundColor3 = Palette.red
	self.goalBanner.BackgroundTransparency = 0.08
	self.goalBanner.Visible = false
	self.goalBanner.ZIndex = 40
	round(self.goalBanner, 14)
	self.goalScale = create("UIScale", self.goalBanner, { Scale = 1 })

	self.cover = frame(pitch, "PlayFade", 0.5, 0.5, 1, 1, Palette.backdropBottom, 1)
	self.cover.ZIndex = 50

	self.playCounter = label(stage, "PlayCounter", "", 0.2, 0.945, 0.38, 0.048, Palette.muted, 14)
	self.dots = {}
	for index = 1, #self.plays do
		local dot = create("TextButton", stage, {
			Name = "PlayDot" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.97 - (#self.plays - index) * 0.05, 0.945),
			Size = UDim2.fromScale(0.032, 0.05),
			BackgroundColor3 = Palette.line,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Selectable = true,
			Text = "",
			ZIndex = 3,
		})
		create("UIAspectRatioConstraint", dot, { AspectRatio = 1 })
		create("UICorner", dot, { CornerRadius = UDim.new(1, 0) })
		dot.Activated:Connect(function()
			if self.show then
				self.show:select(index)
				self.shownPlay = nil
			end
		end)
		self.dots[index] = dot
	end
end

function MainMenu:_buildTeamCard(page, team, x)
	local style = TEAMS[team]
	local card = button(page, team == "red" and "RedTeam" or "BlueTeam", "", x, 0.52, 0.29, 0.52, {
		idle = style.color,
		hover = style.hover,
	}, Palette.text, 10)
	outline(card, Palette.text, 0.6, 2)

	local disc = frame(card, "TeamDisc", 0.5, 0.23, 0.4, 0.3, style.hover)
	create("UIAspectRatioConstraint", disc, { AspectRatio = 1 })
	create("UICorner", disc, { CornerRadius = UDim.new(1, 0) })
	outline(disc, Palette.text, 0.1, 4)
	disc.ZIndex = 4

	label(card, "TeamName", style.name, 0.5, 0.49, 0.86, 0.17, Palette.text, 52, Enum.Font.GothamBlack).ZIndex = 4
	local count = label(card, "TeamCount", "0 / 4 JUGADORES", 0.5, 0.63, 0.86, 0.07, Palette.text, 18)
	count.ZIndex = 4

	local pips = {}
	for index = 1, 4 do
		local pip = frame(card, "Slot" .. index, 0.5 + (index - 2.5) * 0.13, 0.73, 0.075, 0.07, Palette.text, 0.75)
		create("UIAspectRatioConstraint", pip, { AspectRatio = 1 })
		create("UICorner", pip, { CornerRadius = UDim.new(1, 0) })
		pip.ZIndex = 4
		pips[index] = pip
	end

	local action = label(card, "TeamAction", "UNIRME", 0.5, 0.875, 0.7, 0.12, Palette.buttonText, 22)
	action.BackgroundTransparency = 0
	action.BackgroundColor3 = Palette.button
	action.ZIndex = 4
	round(action, 10)

	local pop = card:FindFirstChildOfClass("UIScale")
	card.Activated:Connect(function()
		self:chooseTeam(team)
	end)
	self.cards[team] = { card = card, count = count, pips = pips, action = action, scale = pop, players = 0 }
end

function MainMenu:_buildTeams()
	local page = frame(self.backdrop, "TeamPage", 1.5, 0.5, 1, 1, Palette.panel, 1)
	page.Visible = false
	self.teams = page

	label(page, "TeamTitle", "ELIGE TU EQUIPO", 0.5, 0.12, 0.7, 0.1, Palette.text, 48, Enum.Font.GothamBlack)
	label(page, "TeamSubtitle", "Partido 4 contra 4", 0.5, 0.2, 0.6, 0.045, Palette.muted, 18, Enum.Font.GothamMedium)
	self.cards = {}
	self:_buildTeamCard(page, "red", 0.34)
	self:_buildTeamCard(page, "blue", 0.66)

	self.status = label(page, "TeamStatus", "", 0.5, 0.82, 0.8, 0.045, Palette.muted, 16, Enum.Font.GothamMedium)
	self.backButton = button(page, "BackButton", "VOLVER", 0.5, 0.9, 0.18, 0.075, {
		idle = Palette.quiet,
		hover = Palette.quietHover,
	}, Palette.text, 18)
	outline(self.backButton, Palette.line, 0.6, 1.2)
	self.backButton.Activated:Connect(function()
		self:showHome()
	end)
end

-- Landscape puts the panel beside the showcase; portrait stacks the showcase above it.
function MainMenu:_applyOrientation()
	local size = self.gui.AbsoluteSize
	local portrait = size ~= nil and size.Y > size.X
	if portrait == self.portrait then
		return
	end
	self.portrait = portrait
	if portrait then
		self.stage.Position = UDim2.fromScale(0.5, 0.27)
		self.stage.Size = UDim2.fromScale(0.94, 0.46)
		self.panel.Position = UDim2.fromScale(0.5, 0.73)
		self.panel.Size = UDim2.fromScale(0.86, 0.46)
	else
		self.stage.Position = UDim2.fromScale(0.66, 0.5)
		self.stage.Size = UDim2.fromScale(0.63, 0.9)
		self.panel.Position = UDim2.fromScale(0.17, 0.5)
		self.panel.Size = UDim2.fromScale(0.3, 0.88)
	end
end

--[[
	options: playerGui, lab, scene, sceneApi, Renderer, Preview, Plays, Core, Profile, Reference,
	onJoin(team) is called when the player picks a side.
]]
function MainMenu.new(options)
	local self = setmetatable({
		options = options,
		plays = options.Plays,
		page = "home",
		pageChangedAt = 0,
		pendingTeam = nil,
		pendingSince = 0,
		retryAt = 0,
		shownPlay = nil,
		connections = {},
	}, MainMenu)

	self.gui = create("ScreenGui", options.playerGui, {
		Name = "SimpleSoccerMainMenu",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 15,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	self.backdrop = create("Frame", self.gui, {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	create("UIGradient", self.backdrop, {
		Color = ColorSequence.new(Palette.backdropTop, Palette.backdropBottom),
		Rotation = 90,
	})

	self:_buildHome()
	self:_buildTeams()
	self:_applyOrientation()

	local built, failure = pcall(function()
		self.show = options.Preview.newShow(options.Core, options.Profile, options.Reference, options.Plays)
		self.renderer = options.Renderer.new(options.playerGui, options.scene, nil, nil, options.sceneApi, self.pitch)
		self.renderer.fitWholePitch = true
	end)
	if not built then
		self.show = nil
		self.playCaption.Text = "No se pudo preparar la demostración"
		warn("Simple Soccer menu showcase failed: " .. tostring(failure))
	else
		task.defer(function()
			self:_prepareNext()
		end)
	end

	local function refreshRoster()
		self:setRoster(options.lab:GetAttribute("RosterRed"), options.lab:GetAttribute("RosterBlue"))
	end
	for _, attribute in ipairs({ "RosterRed", "RosterBlue" }) do
		table.insert(self.connections, options.lab:GetAttributeChangedSignal(attribute):Connect(refreshRoster))
	end
	refreshRoster()
	return self
end

function MainMenu:_prepareNext()
	if self.show then
		local ok, failure = pcall(function()
			self.show:prepareNext()
		end)
		if not ok then
			warn("Simple Soccer menu showcase failed: " .. tostring(failure))
		end
	end
end

function MainMenu:_refreshCards()
	for team, entry in pairs(self.cards) do
		local full = entry.players >= 4
		entry.count.Text = tostring(entry.players) .. " / 4 JUGADORES"
		for index, pip in ipairs(entry.pips) do
			pip.BackgroundTransparency = index <= entry.players and 0 or 0.75
		end
		local available = not full and self.pendingTeam == nil
		entry.card.Active = available
		entry.card.BackgroundColor3 = (full and Palette.disabled) or TEAMS[team].color
		entry.action.BackgroundColor3 = (full and Palette.muted) or Palette.button
		entry.action.BackgroundTransparency = full and 0.45 or 0
		if self.pendingTeam == team then
			entry.action.Text = "ENTRANDO..."
		elseif full then
			entry.action.Text = "LLENO"
		else
			entry.action.Text = "UNIRME"
		end
	end
	self.backButton.Visible = self.pendingTeam == nil
end

function MainMenu:setRoster(red, blue)
	self.cards.red.players = type(red) == "number" and red or 0
	self.cards.blue.players = type(blue) == "number" and blue or 0
	self:_refreshCards()
end

function MainMenu:showTeams()
	if self.page == "teams" or self.closed then
		return
	end
	self.page = "teams"
	self.pageChangedAt = os.clock()
	self.status.Text = ""
	self.teams.Visible = true
	self.teams.Position = UDim2.fromScale(1.5, 0.5)
	tween(self.home, 0.5, { Position = UDim2.fromScale(-0.5, 0.5) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	tween(self.teams, 0.5, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	local delaySeconds = 0.22
	for _, team in ipairs({ "red", "blue" }) do
		local scale = self.cards[team].scale
		scale.Scale = 0.78
		tween(scale, 0.42, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, delaySeconds)
		delaySeconds = delaySeconds + 0.09
	end
	self:_refreshCards()
end

function MainMenu:showHome()
	if self.page == "home" or self.pendingTeam or self.closed then
		return
	end
	self.page = "home"
	self.pageChangedAt = os.clock()
	tween(self.home, 0.45, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	tween(self.teams, 0.45, { Position = UDim2.fromScale(1.5, 0.5) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
end

function MainMenu:chooseTeam(team)
	local entry = self.cards[team]
	local now = os.clock()
	if self.closed or self.page ~= "teams" or self.pendingTeam or entry.players >= 4 or now < self.retryAt then
		return false
	end
	self.pendingTeam = team
	self.pendingSince = now
	self.status.Text = "Pidiendo plaza en el equipo " .. TEAMS[team].name .. "..."
	self:_refreshCards()
	self.options.onJoin(team)
	return true
end

function MainMenu:_cancelJoin(message)
	self.pendingTeam = nil
	self.retryAt = os.clock() + RETRY_COOLDOWN
	self.status.Text = message
	self:_refreshCards()
end

function MainMenu:onJoined()
	self.status.Text = "Entrando a la cancha..."
end

function MainMenu:onFull()
	local name = self.pendingTeam and TEAMS[self.pendingTeam].name
	if name then
		self:_cancelJoin("El equipo " .. name .. " ya está completo. Elige otro o espera una plaza.")
	end
end

-- Called every rendered frame while the menu is open.
function MainMenu:update(dt)
	if self.closed then
		return
	end
	local now = os.clock()
	self:_applyOrientation()
	if self.pendingTeam and now - self.pendingSince > JOIN_TIMEOUT then
		self:_cancelJoin("La conexión tardó demasiado. Inténtalo de nuevo.")
	end
	-- The showcase rests while the team page fully covers it.
	if not self.show or (self.page == "teams" and now - self.pageChangedAt > 0.6) then
		return
	end
	local pose, info = self.show:advance(dt)
	self.renderer:render(pose, { x = 0, y = 0 })
	self.cover.BackgroundTransparency = 1 - info.cover
	if self.shownPlay ~= info.index then
		self.shownPlay = info.index
		self.playTitle.Text = info.title
		self.playCaption.Text = info.caption
		self.goalBanner.BackgroundColor3 = TEAMS[info.team].color
		for index, dot in ipairs(self.dots) do
			dot.BackgroundTransparency = index == info.index and 0 or 0.7
		end
		self.shownPasses = nil
	end
	if info.changed then
		task.defer(function()
			self:_prepareNext()
		end)
	end
	if self.shownPasses ~= info.passes then
		self.shownPasses = info.passes
		self.playCounter.Text = "JUGADA " .. info.index .. " DE " .. info.count .. "  ·  PASES " .. info.passes
	end
	if self.goalBanner.Visible ~= info.goal then
		self.goalBanner.Visible = info.goal
		if info.goal then
			self.goalScale.Scale = 0.4
			tween(self.goalScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	end
end

-- Fades through the chosen team colour into the match, then removes the menu.
function MainMenu:close(onCovered)
	if self.closed then
		return
	end
	self.closed = true
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	local style = TEAMS[self.pendingTeam or "red"]
	local curtain = frame(self.gui, "MatchCurtain", 0.5, 0.5, 1, 1, style.color, 1)
	curtain.ZIndex = 100
	tween(curtain, 0.25, { BackgroundTransparency = 0 })
	task.delay(0.27, function()
		if self.renderer then
			self.renderer:destroy()
			self.renderer = nil
		end
		self.backdrop:Destroy()
		onCovered()
		tween(curtain, 0.4, { BackgroundTransparency = 1 })
		task.delay(0.45, function()
			self.gui:Destroy()
		end)
	end)
end

return MainMenu
