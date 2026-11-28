-- Director for the main-menu showcase: bots play scripted football moves on the real match physics.
--
-- A play (see ShowcasePlays) only says WHO should send the ball WHERE and which runs the others make.
-- Nothing is keyframed: every tick the bots read the world, decide a movement/kick input and the same
-- fixed-tick physics core used by the server moves the discs. Attackers solve the interception and the
-- kick angle; defenders press, mark, cover and keep goal with a human-like reaction delay.
-- The simulation is deterministic, so each play is computed once, cached and replayed.
local Preview = {}

local TICK_RATE = 60
local TEAM_SIZE = 4
local GOAL_X = 370
local GOAL_HALF = 64
local MAX_TICKS = TICK_RATE * 16
local CELEBRATION_TICKS = 130
local PREDICTION_TICKS = 150
local CONTACT_DISTANCE = 27.2
local KICK_REACH = 28.8

local function clamp(value, low, high)
	return math.max(low, math.min(high, value))
end

local function length(x, y)
	return math.sqrt(x * x + y * y)
end

local function unit(x, y)
	local size = length(x, y)
	if size < 1e-9 then
		return 1, 0
	end
	return x / size, y / size
end

-- Displacement tables of a player disc: coast[t] multiplies the current velocity and reach[t] is the
-- extra distance gained by holding full input for t ticks.
local function buildMotionTables(damping, acceleration)
	local coast, reach = {}, {}
	local carried, carry = 0, 1
	local velocity, position = 0, 0
	for tick = 1, PREDICTION_TICKS do
		carried = carried + carry
		carry = carry * damping
		coast[tick] = carried
		velocity = velocity + acceleration
		position = position + velocity
		velocity = velocity * damping
		reach[tick] = position
	end
	coast[0], reach[0] = 0, 0
	return coast, reach
end

-- Free-ball prediction including the reflective ball walls (the goal mouth is left open).
local function predictBall(ball, radius, damping, bounce, path)
	local x, y, vx, vy = ball.x, ball.y, ball.vx, ball.vy
	local limitX, limitY = GOAL_X - radius, 170 - radius
	local start = path[0]
	start.x, start.y, start.vx, start.vy = x, y, vx, vy
	for tick = 1, PREDICTION_TICKS do
		x = x + vx
		y = y + vy
		vx = vx * damping
		vy = vy * damping
		if y > limitY then
			y = limitY
			if vy > 0 then
				vy = -vy * bounce
			end
		elseif y < -limitY then
			y = -limitY
			if vy < 0 then
				vy = -vy * bounce
			end
		end
		if math.abs(y) > GOAL_HALF then
			if x > limitX then
				x = limitX
				if vx > 0 then
					vx = -vx * bounce
				end
			elseif x < -limitX then
				x = -limitX
				if vx < 0 then
					vx = -vx * bounce
				end
			end
		end
		local point = path[tick]
		point.x, point.y, point.vx, point.vy = x, y, vx, vy
	end
	return path
end

-- A bank pass aims at the mirror image of the target: the wall halves the normal speed, so the image
-- sits twice as far behind the wall as the target sits in front of it.
local function aimPoint(action)
	local x, y = action.x, action.y
	if action.bank then
		local wall = 160 * action.bank
		y = wall + 2 * (wall - y)
	end
	return x, y
end

-- Kick adds a fixed impulse along (ball - player). Returns the player-to-ball normal that makes the
-- resulting ball velocity point at the target, or nil when the incoming ball is too fast for it.
local function solveKick(bx, by, bvx, bvy, tx, ty, impulse, slowest)
	local dx, dy = unit(tx - bx, ty - by)
	local along = bvx * dx + bvy * dy
	local root = along * along - (bvx * bvx + bvy * bvy) + impulse * impulse
	if root < 0 then
		return nil
	end
	local speed = along + math.sqrt(root)
	if speed < (slowest or 1.6) then
		return nil
	end
	return (speed * dx - bvx) / impulse, (speed * dy - bvy) / impulse
end

local function drive(player, tx, ty, maxEffort, acceleration, cruise)
	local top = cruise or 2.2
	local desiredX, desiredY = (tx - player.x) * 0.075, (ty - player.y) * 0.075
	local wanted = length(desiredX, desiredY)
	if wanted > top then
		desiredX, desiredY = desiredX * top / wanted, desiredY * top / wanted
	end
	local ax = (desiredX - player.vx * player.damping) / acceleration
	local ay = (desiredY - player.vy * player.damping) / acceleration
	local magnitude = length(ax, ay)
	local effort = maxEffort or 1
	if magnitude > effort then
		ax, ay = ax * effort / magnitude, ay * effort / magnitude
	end
	return { x = ax, y = ay, kick = false }
end

local function segmentDistance(px, py, ax, ay, bx, by)
	local sx, sy = bx - ax, by - ay
	local size = sx * sx + sy * sy
	local t = 0
	if size > 1e-9 then
		t = clamp(((px - ax) * sx + (py - ay) * sy) / size, 0, 1)
	end
	return length(px - ax - sx * t, py - ay - sy * t)
end

-- A finish must be taken from shooting range with a clear line between both posts.
local function openShot(action, bx, by, tx, ty)
	if bx < (action.range or 120) or bx > GOAL_X - 30 then
		return false
	end
	local crossing = by + (ty - by) * (GOAL_X - bx) / (tx - bx)
	return math.abs(crossing) <= GOAL_HALF - 20
end

-- Input for the bot that has to strike the ball toward the action target.
local function strike(context, player, action, ready)
	local ball, path = context.ball, context.path
	local tx, ty = aimPoint(action)
	local coast, reach = context.coast, context.reach
	local contactX, contactY, normalX, normalY, arrival
	local earliest = 0
	if action.meet then
		earliest = action.meet
	end
	for tick = earliest, PREDICTION_TICKS do
		local future = path[tick]
		local nx, ny = nil, nil
		-- A finish is taken from shooting range and struck hard enough to beat the keeper.
		if action.kind ~= "shot" or openShot(action, future.x, future.y, tx, ty) then
			local slowest = 1.6
			if action.kind == "shot" then
				slowest = 3.4
			end
			nx, ny = solveKick(future.x, future.y, future.vx, future.vy, tx, ty, context.impulse, slowest)
		end
		if nx then
			local cx, cy = future.x - nx * CONTACT_DISTANCE, future.y - ny * CONTACT_DISTANCE
			local needX = cx - player.x - player.vx * coast[tick]
			local needY = cy - player.y - player.vy * coast[tick]
			if length(needX, needY) <= reach[tick] * 0.9 + 1.2 then
				contactX, contactY, normalX, normalY, arrival = cx, cy, nx, ny, tick
				break
			end
		end
	end
	if not arrival then
		-- Too fast to redirect yet: get in front of where it will slow down.
		local future = path[60]
		local nx, ny = unit(tx - future.x, ty - future.y)
		contactX, contactY = future.x - nx * 34, future.y - ny * 34
		normalX, normalY, arrival = nx, ny, 60
	end

	local horizon = math.max(arrival, 7)
	local input
	local needX = contactX - player.x - player.vx * coast[horizon]
	local needY = contactY - player.y - player.vy * coast[horizon]
	input = { x = needX / reach[horizon], y = needY / reach[horizon], kick = false }

	-- Go around the ball instead of running through it from the wrong side.
	local future = path[math.min(arrival, 10)]
	local away = length(contactX - player.x, contactY - player.y)
	local ahead = (player.x - future.x) * normalX + (player.y - future.y) * normalY
	if away > 14 and ahead > -20 and segmentDistance(future.x, future.y, player.x, player.y, contactX, contactY) < 31 then
		local sideX, sideY = -normalY, normalX
		if (player.x - future.x) * sideX + (player.y - future.y) * sideY < 0 then
			sideX, sideY = -sideX, -sideY
		end
		input = drive(player, future.x - normalX * 22 + sideX * 44, future.y - normalY * 22 + sideY * 44, 1,
			context.acceleration, 2.4)
	end

	-- Last steps: settle just behind the ball, matching its pace, until the angle is right.
	if arrival <= 14 and away < 22 then
		local near = path[2]
		local goalX, goalY = near.x - normalX * 26.6, near.y - normalY * 26.6
		local ax = (ball.vx + (goalX - player.x) * 0.16 - player.vx) / context.acceleration
		local ay = (ball.vy + (goalY - player.y) * 0.16 - player.vy) / context.acceleration
		input = { x = ax, y = ay, kick = false }
	end

	local dx, dy = ball.x - player.x, ball.y - player.y
	local gap = length(dx, dy)
	if ready and gap < KICK_REACH and gap > 1 then
		local outX = ball.vx + context.impulse * dx / gap
		local outY = ball.vy + context.impulse * dy / gap
		local aimX, aimY = unit(tx - ball.x, ty - ball.y)
		local outSize = length(outX, outY)
		local slowest = 1.6
		if action.kind == "shot" then
			slowest = 3.4
		end
		local inRange = action.kind ~= "shot" or openShot(action, ball.x, ball.y, tx, ty)
		local tolerance = action.tolerance or 0.07
		if action.kind == "shot" then
			tolerance = math.min(tolerance, 0.045)
		end
		if inRange and outSize >= slowest and outX * aimX + outY * aimY > 0
			and math.abs(outX * aimY - outY * aimX) / outSize <= tolerance then
			input.kick = true
		end
	end
	return input
end

-- Close control: short body touches that carry the ball toward a point.
local function dribble(context, player, action)
	local ball = context.ball
	local pace = action.effort or 0.65
	local dx, dy = unit(action.x - ball.x, action.y - ball.y)
	local wantX, wantY = dx * 2 * pace, dy * 2 * pace
	-- Push along the correction the ball needs, biased toward the destination.
	local nx, ny = unit(wantX - ball.vx + dx * 0.8, wantY - ball.vy + dy * 0.8)
	local targetX, targetY = ball.x + ball.vx * 3 - nx * 22.5, ball.y + ball.vy * 3 - ny * 22.5
	local ahead = (player.x - ball.x) * nx + (player.y - ball.y) * ny
	if ahead > -12 and segmentDistance(ball.x, ball.y, player.x, player.y, targetX, targetY) < 24 then
		local sideX, sideY = -ny, nx
		if (player.x - ball.x) * sideX + (player.y - ball.y) * sideY < 0 then
			sideX, sideY = -sideX, -sideY
		end
		return drive(player, ball.x - nx * 16 + sideX * 36, ball.y - ny * 16 + sideY * 36, 1,
			context.acceleration, 2.4)
	end
	local ax = (wantX + (targetX - player.x) * 0.13 - player.vx) / context.acceleration
	local ay = (wantY + (targetY - player.y) * 0.13 - player.vy) / context.acceleration
	return { x = ax, y = ay, kick = false }
end

-- Off-ball attackers follow their latest scripted run, breathing with the ball so nobody stands still.
local function support(context, slot)
	local play = context.play
	local spot = nil
	for _, run in ipairs(play.runs[slot] or {}) do
		if run[1] <= context.actionIndex then
			spot = run
		end
	end
	local start = play.red[slot]
	local x, y = start[1], start[2]
	if spot then
		x, y = spot[2], spot[3]
	end
	local coming = play.actions[context.actionIndex + 1]
	local current = play.actions[context.actionIndex]
	if coming and coming.by == slot and current and current.kind ~= "dribble" then
		-- Next in line: wait just behind the reception point, already facing the following pass.
		local aimX, aimY = aimPoint(coming)
		local dx, dy = unit(aimX - current.x, aimY - current.y)
		x, y = current.x - dx * 30, current.y - dy * 30
	end
	local ball = context.ball
	x = x + clamp((ball.x - x) * 0.07, -20, 20)
	y = y + clamp((ball.y - y) * 0.05, -12, 12)
	local player = context.players[slot]
	-- Never wander into the ball: a supporting player keeps the lane clear.
	local awayX, awayY = player.x - ball.x, player.y - ball.y
	local gap = length(awayX, awayY)
	if gap < 52 and gap > 0.1 then
		x = x + awayX / gap * (52 - gap) * 1.6
		y = y + awayY / gap * (52 - gap) * 1.6
	end
	return drive(player, x, y, 1, context.acceleration, 2.3)
end

local function defend(context, index)
	local role = context.play.defence[index]
	local player = context.players[TEAM_SIZE + index]
	local history = context.history
	local seen = history[math.max(1, #history - (role.delay or 14))]
	local ball = context.ball
	local x, y
	if role.kind == "keeper" then
		x = 347
		y = clamp(seen.y * 0.5, -44, 44)
		if seen.vx > 2.2 and seen.x > 150 then
			-- Shot on the way: dive toward the point where it will cross the keeper line.
			y = clamp(seen.y + seen.vy * (x - seen.x) / seen.vx, -56, 56)
		end
	elseif role.kind == "press" then
		local dx, dy = unit(GOAL_X - seen.x, -seen.y)
		x, y = seen.x + dx * (role.gap or 34), seen.y + dy * (role.gap or 34)
	elseif role.kind == "mark" then
		local man = context.players[role.man]
		x = man.x + (GOAL_X - man.x) * (role.gap or 0.2)
		y = man.y - man.y * (role.gap or 0.2) + (seen.y - man.y) * 0.1
	else
		x = seen.x + (GOAL_X - seen.x) * (role.gap or 0.55)
		y = seen.y * (1 - (role.gap or 0.55)) + (role.lane or 0)
	end
	x = clamp(x, -330, 352)
	y = clamp(y, -150, 150)
	local input = drive(player, x, y, role.effort or 0.7, context.acceleration, 2.3)
	-- Tackle: clear the ball only when the kick sends it away from the defender's own goal.
	if length(ball.x - player.x, ball.y - player.y) < KICK_REACH and ball.x < player.x - 6 then
		input.kick = true
	end
	return input
end

local function celebrate(context, slot)
	local player = context.players[slot]
	if slot <= TEAM_SIZE then
		local corner = 1
		if context.players[context.scorer].y < 0 then
			corner = -1
		end
		if slot == context.scorer then
			return drive(player, 285, 128 * corner, 1, context.acceleration, 2.3)
		end
		local leader = context.players[context.scorer]
		local order = (slot - context.scorer) % TEAM_SIZE
		return drive(player, leader.x - 30 - order * 9, leader.y + (order - 2) * 38, 0.9, context.acceleration, 2.2)
	end
	-- The beaten side walks back toward its own half of the box.
	local index = slot - TEAM_SIZE
	return drive(player, 235 + index * 14, (index - 2.5) * 52, 0.3, context.acceleration, 0.9)
end

local function createWorld(Core, Profile, Reference, play)
	local baseline = Profile.PhysicsBaseline.active
	local playerPhysics, ballPhysics = baseline.player, baseline.ball
	local world = Core.newWorld({
		tickRate = TICK_RATE,
		fieldHalfWidth = Profile.Bounds.halfWidth,
		fieldHalfHeight = Profile.Bounds.halfHeight,
		useBounds = false,
		solverMode = "classicDiscrete",
	})
	local ball = Core.addDisc(world, {
		id = "ball",
		kind = "ball",
		x = play.ball[1],
		y = play.ball[2],
		vx = play.ball[3] or 0,
		vy = play.ball[4] or 0,
		radius = ballPhysics.radius,
		invMass = ballPhysics.invMass,
		damping = ballPhysics.damping,
		bCoef = ballPhysics.bounce,
		kickable = true,
		collisionGroup = Profile.CollisionGroups.ball,
	})
	Core.setReferenceGeometry(world, Reference)
	for _, post in ipairs(Reference.posts) do
		local spec = table.clone(post)
		spec.kind = "post"
		spec.invMass = 0
		spec.damping = 1
		Core.addDisc(world, spec)
	end
	local players = {}
	for slot = 1, Profile.PlayerCount do
		local team, start = "red", play.red[slot]
		if slot > Profile.PlayersPerTeam then
			team, start = "blue", play.blue[slot - Profile.PlayersPerTeam]
		end
		players[slot] = Core.addDisc(world, {
			id = slot,
			kind = "player",
			team = team,
			x = start[1],
			y = start[2],
			radius = playerPhysics.radius,
			invMass = playerPhysics.invMass,
			damping = playerPhysics.damping,
			kickDamping = playerPhysics.kickDamping,
			bCoef = playerPhysics.bounce,
			acceleration = playerPhysics.acceleration,
			kickAcceleration = playerPhysics.kickAcceleration,
			kickStrength = playerPhysics.kickStrength,
			kickback = playerPhysics.kickback,
			kickRangeExtra = baseline.kickRangeExtra,
			collisionGroup = Profile.CollisionGroups[team],
			collisionMask = Profile.CollisionMasks.player,
		})
	end
	return world, ball, players, baseline
end

-- Simulates one play from its first touch to the end of the goal celebration.
function Preview.simulate(Core, Profile, Reference, play, options)
	assert(Core and Profile and Reference and play, "physics core, stadium profile, reference and play are required")
	local world, ball, players, baseline = createWorld(Core, Profile, Reference, play)
	local coast, reach = buildMotionTables(baseline.player.damping, baseline.player.acceleration)
	local context = {
		play = play,
		ball = ball,
		players = players,
		coast = coast,
		reach = reach,
		acceleration = baseline.player.acceleration,
		impulse = baseline.player.kickStrength * baseline.ball.invMass,
		history = {},
		path = {},
		actionIndex = 1,
	}
	for point = 0, PREDICTION_TICKS do
		context.path[point] = { x = 0, y = 0, vx = 0, vy = 0 }
	end
	local frames, kicks, touches = {}, {}, {}
	local actionStart, goalTick, passes = 0, nil, 0
	local report = { completed = 0, opponentTouches = 0, strayTouches = 0, closestOpponent = math.huge }
	local expected = play.actions[1].by

	local function capture(kickMask)
		local frame = table.create(20)
		for slot = 1, Profile.PlayerCount do
			frame[slot * 2 - 1] = players[slot].x
			frame[slot * 2] = players[slot].y
		end
		frame[17], frame[18] = ball.x, ball.y
		frame[19], frame[20] = kickMask, passes
		table.insert(frames, frame)
	end
	capture(0)

	local lastKicker = nil
	for tick = 1, MAX_TICKS do
		table.insert(context.history, { x = ball.x, y = ball.y, vx = ball.vx, vy = ball.vy })
		context.path = predictBall(ball, ball.radius, ball.damping, ball.bCoef, context.path)
		local action = play.actions[context.actionIndex]
		local inputs = {}
		for slot = 1, Profile.PlayerCount do
			if goalTick then
				inputs[slot] = celebrate(context, slot)
			elseif slot > TEAM_SIZE then
				inputs[slot] = defend(context, slot - TEAM_SIZE)
			elseif action and action.by == slot then
				if action.kind == "dribble" then
					inputs[slot] = dribble(context, players[slot], action)
				else
					inputs[slot] = strike(context, players[slot], action, tick - actionStart >= (action.wait or 0))
				end
			else
				inputs[slot] = support(context, slot)
			end
		end

		local startX = ball.x
		local startY = ball.y
		local _, events = Core.stepWorld(world, inputs)
		local kickMask = 0
		for _, event in ipairs(events) do
			local slot = nil
			local kicked = event.kind == "kick" and event.targetId == "ball"
			if kicked then
				slot = event.playerId
				kickMask = bit32.bor(kickMask, bit32.lshift(1, slot - 1))
			elseif event.kind == "discContact" then
				if event.discA == "ball" then
					slot = event.discB
				elseif event.discB == "ball" then
					slot = event.discA
				end
			end
			if type(slot) == "number" and not goalTick then
				table.insert(touches, { tick = tick, slot = slot, kick = kicked })
				if slot > TEAM_SIZE then
					report.opponentTouches = report.opponentTouches + 1
				elseif slot ~= expected and not (slot == lastKicker and tick - kicks[#kicks].tick < 6) then
					report.strayTouches = report.strayTouches + 1
				end
				if kicked then
					table.insert(kicks, { tick = tick, slot = slot })
					if action and slot == action.by and action.kind ~= "dribble" then
						if action.kind == "pass" then
							passes = passes + 1
						end
						lastKicker = slot
						context.actionIndex = context.actionIndex + 1
						report.completed = report.completed + 1
						actionStart = tick
						local following = play.actions[context.actionIndex]
						if following then
							expected = following.by
						end
					end
				end
			end
		end

		if not goalTick and action and action.kind == "dribble" and context.actionIndex <= #play.actions
			and play.actions[context.actionIndex] == action
			and length(ball.x - action.x, ball.y - action.y) < (action.radius or 26) then
			context.actionIndex = context.actionIndex + 1
			report.completed = report.completed + 1
			actionStart = tick
			local following = play.actions[context.actionIndex]
			if following then
				expected = following.by
			end
		end

		if not goalTick then
			for slot = TEAM_SIZE + 1, Profile.PlayerCount do
				local gap = length(players[slot].x - ball.x, players[slot].y - ball.y)
				report.closestOpponent = math.min(report.closestOpponent, gap)
			end
			if startX < GOAL_X and ball.x >= GOAL_X then
				local alpha = (GOAL_X - startX) / (ball.x - startX)
				if math.abs(startY + (ball.y - startY) * alpha) <= GOAL_HALF then
					goalTick = tick
					context.scorer = lastKicker or play.actions[1].by
				end
			end
		end

		capture(kickMask)
		if options and options.stopOnFailure and not goalTick
			and (report.opponentTouches > 0 or report.strayTouches > 0 or tick - actionStart > 260) then
			break
		end
		if goalTick and tick - goalTick >= CELEBRATION_TICKS then
			break
		end
	end

	report.goal = goalTick ~= nil
	report.actions = #play.actions
	report.goalTick = goalTick
	report.scorer = context.scorer
	return {
		play = play,
		frames = frames,
		kicks = kicks,
		touches = touches,
		goalTick = goalTick,
		passes = passes,
		tickRate = TICK_RATE,
		duration = (#frames - 1) / TICK_RATE,
		report = report,
		radius = { player = baseline.player.radius, ball = baseline.ball.radius },
	}
end

local cache = {}

function Preview.getReplay(Core, Profile, Reference, Plays, index)
	assert(type(Plays) == "table" and #Plays > 0, "a playbook is required")
	local wrapped = (index - 1) % #Plays + 1
	local play = Plays[wrapped]
	if not cache[play] then
		cache[play] = Preview.simulate(Core, Profile, Reference, play)
	end
	return cache[play]
end

local TRAIL_LENGTH = 14

-- Interpolated render pose at `elapsed` seconds. A mirrored play is the same simulation shown from the
-- other side: x is flipped and the attacking discs wear blue, so both teams get their highlights.
function Preview.sample(replay, elapsed, output)
	assert(type(replay) == "table" and type(replay.frames) == "table", "a built physics replay is required")
	local frames = replay.frames
	local position = clamp(elapsed * replay.tickRate, 0, #frames - 1)
	local first = math.floor(position) + 1
	local alpha = position - math.floor(position)
	local a = frames[first]
	local b = frames[math.min(first + 1, #frames)]
	local mirrored = replay.play.mirror == true
	local flip = 1
	if mirrored then
		flip = -1
	end
	output = output or { players = {}, ball = {}, trail = {} }

	local recentKicks = 0
	for index = math.max(1, first - 6), first do
		recentKicks = bit32.bor(recentKicks, frames[index][19])
	end
	for slot = 1, TEAM_SIZE * 2 do
		local shown = slot
		if mirrored then
			shown = (slot - 1 + TEAM_SIZE) % (TEAM_SIZE * 2) + 1
		end
		local actor = output.players[shown]
		if not actor then
			actor = {}
			output.players[shown] = actor
		end
		actor.id = shown
		actor.label = tostring((shown - 1) % TEAM_SIZE + 1)
		actor.team = "red"
		if shown > TEAM_SIZE then
			actor.team = "blue"
		end
		actor.radius = replay.radius.player
		actor.visible = true
		actor.x = flip * (a[slot * 2 - 1] + (b[slot * 2 - 1] - a[slot * 2 - 1]) * alpha)
		actor.y = a[slot * 2] + (b[slot * 2] - a[slot * 2]) * alpha
		actor.kicking = bit32.band(recentKicks, bit32.lshift(1, slot - 1)) ~= 0
	end
	local ball = output.ball
	ball.x = flip * (a[17] + (b[17] - a[17]) * alpha)
	ball.y = a[18] + (b[18] - a[18]) * alpha
	ball.radius = replay.radius.ball
	ball.visible = true

	local trail = output.trail
	for step = 1, TRAIL_LENGTH do
		local index = first - step * 3
		local dot = trail[step]
		if not dot then
			dot = {}
			trail[step] = dot
		end
		if index >= 1 then
			local sample = frames[index]
			dot.x, dot.y = flip * sample[17], sample[18]
			dot.visible = length(dot.x - ball.x, dot.y - ball.y) > replay.radius.ball
			dot.strength = 1 - step / (TRAIL_LENGTH + 1)
		else
			dot.visible = false
		end
	end
	output.passes = a[20]
	output.goal = replay.goalTick ~= nil and position >= replay.goalTick
	return output
end

-- Playlist timeline: short title hold, the move, and a fade before the next one.
local Show = {}
Show.__index = Show
local INTRO_SECONDS = 0.9
local FADE_SECONDS = 0.35

function Preview.newShow(Core, Profile, Reference, Plays)
	return setmetatable({
		core = Core,
		profile = Profile,
		reference = Reference,
		plays = Plays,
		index = 1,
		clock = 0,
		pose = { players = {}, ball = {}, trail = {} },
		replay = Preview.getReplay(Core, Profile, Reference, Plays, 1),
	}, Show)
end

-- Builds the following play ahead of time so the cut between two moves never stalls a frame.
function Show:prepareNext()
	Preview.getReplay(self.core, self.profile, self.reference, self.plays, self.index + 1)
end

function Show:select(index)
	self.index = (index - 1) % #self.plays + 1
	self.clock = 0
	self.replay = Preview.getReplay(self.core, self.profile, self.reference, self.plays, self.index)
end

function Show:advance(dt)
	self.clock = self.clock + clamp(dt, 0, 0.1)
	local total = INTRO_SECONDS + self.replay.duration + FADE_SECONDS
	local changed = false
	if self.clock >= total then
		self:select(self.index + 1)
		changed = true
		total = INTRO_SECONDS + self.replay.duration + FADE_SECONDS
	end
	local pose = Preview.sample(self.replay, self.clock - INTRO_SECONDS, self.pose)
	-- cover: 1 hides the pitch, 0 shows it.
	local cover = 0
	if self.clock < FADE_SECONDS then
		cover = 1 - self.clock / FADE_SECONDS
	elseif self.clock > total - FADE_SECONDS then
		cover = (self.clock - (total - FADE_SECONDS)) / FADE_SECONDS
	end
	return pose, {
		index = self.index,
		count = #self.plays,
		title = self.replay.play.title,
		caption = self.replay.play.caption,
		team = self.replay.play.mirror and "blue" or "red",
		passes = pose.passes,
		goal = pose.goal,
		cover = clamp(cover, 0, 1),
		changed = changed,
	}
end

return Preview
