-- Deterministic 2D match core.
-- Logical coordinates use Haxball stadium units. One call to stepWorld is one fixed game tick.
-- Collision order follows the explicit disc insertion order: dynamic pairs, then static geometry per disc.
local Core = {}

local DEFAULTS = {
    tickRate = 60,
    solverMode = "adaptive", -- Explicit compatibility option: haxballDiscrete. 
    playerAcceleration = 0.1,
    playerKickAcceleration = 0.07,
    playerDamping = 0.96,
    playerKickDamping = 0.96,
    ballDamping = 0.99,
    defaultBounce = 0.5,
    maxSubsteps = 64,
    kickRangeExtra = 4,
    kickCooldownTicks = 2,
    fieldHalfWidth = 420,
    fieldHalfHeight = 200,
}

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < 1e12
end

local function validMask(value)
    return finite(value) and value >= 0 and value <= 0xFFFFFFFF and math.floor(value) == value
end

local function idKey(id)
    return typeof(id) .. ":" .. tostring(id)
end

function Core.newWorld(config)
    config = config or {}
    local settings = table.clone(DEFAULTS)
    for key, value in pairs(config) do
        settings[key] = value
    end
    assert(finite(settings.tickRate) and settings.tickRate > 0, "tickRate must be positive")
    assert(finite(settings.fieldHalfWidth) and settings.fieldHalfWidth > 0, "fieldHalfWidth must be positive")
    assert(finite(settings.fieldHalfHeight) and settings.fieldHalfHeight > 0, "fieldHalfHeight must be positive")
    assert(finite(settings.maxSubsteps) and settings.maxSubsteps>=1 and settings.maxSubsteps<=256 and math.floor(settings.maxSubsteps)==settings.maxSubsteps, "maxSubsteps must be an integer from 1 to 256")
    assert(settings.solverMode == "adaptive" or settings.solverMode == "haxballDiscrete", "unknown solverMode")
    return {
        tick = 0,
        config = settings,
        discs = {},
        discById = {},
        events = {},
        planes = {},
        segments = {},
        geometryById = {},
        referenceGeometry = nil,
        useBounds = settings.useBounds ~= false,
        lastSubsteps = 0,
        motionSegments = {},
    }
end

function Core.newDisc(spec)
    assert(type(spec) == "table", "disc spec must be a table")
    assert(spec.id ~= nil and (type(spec.id)=="number" or type(spec.id)=="string"), "disc id must be a number or string")
    local disc = {
        id = spec.id,
        kind = spec.kind or "disc",
        team = spec.team,
        x = spec.x or 0,
        y = spec.y or 0,
        vx = spec.vx or 0,
        vy = spec.vy or 0,
        gravityX = spec.gravityX or 0,
        gravityY = spec.gravityY or 0,
        radius = spec.radius or 10,
        invMass = spec.invMass == nil and 1 or spec.invMass,
        damping = spec.damping == nil and 1 or spec.damping,
        bCoef = spec.bCoef == nil and DEFAULTS.defaultBounce or spec.bCoef,
        collisionGroup = spec.collisionGroup == nil and 1 or spec.collisionGroup,
        collisionMask = spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
        acceleration = spec.acceleration or DEFAULTS.playerAcceleration,
        kickAcceleration = spec.kickAcceleration or DEFAULTS.playerKickAcceleration,
        kickDamping = spec.kickDamping == nil and (spec.damping or DEFAULTS.playerDamping) or spec.kickDamping,
        kickStrength = spec.kickStrength or 0,
        kickback = spec.kickback or 0,
        kickRangeExtra = spec.kickRangeExtra == nil and DEFAULTS.kickRangeExtra or spec.kickRangeExtra,
        kickable = spec.kickable == true,
        kickHeld = false,
        kickArmed = false,
        kickCooldown = 0,
        maxSpeed = spec.maxSpeed,
        enabled = spec.enabled ~= false,
        traceMotion = spec.traceMotion == true,
    }
    for _, key in ipairs({"x","y","vx","vy","gravityX","gravityY","radius","invMass","damping","bCoef","acceleration","kickAcceleration","kickDamping","kickStrength","kickback","kickRangeExtra"}) do
        assert(finite(disc[key]), "disc field must be finite: " .. key)
    end
    assert(disc.radius > 0, "disc radius must be positive")
    assert(disc.invMass >= 0, "inverse mass cannot be negative")
    assert(disc.damping >= 0 and disc.kickDamping >= 0, "damping cannot be negative")
    assert(validMask(disc.collisionGroup) and validMask(disc.collisionMask), "collision flags must be unsigned 32-bit integers")
    if disc.maxSpeed ~= nil then
        assert(finite(disc.maxSpeed) and disc.maxSpeed > 0, "maxSpeed must be positive")
    end
    return disc
end

function Core.addDisc(world, spec)
    assert(type(world) == "table" and type(world.discs) == "table", "invalid world")
    local disc = Core.newDisc(spec)
    local key = idKey(disc.id)
    assert(world.discById[key] == nil, "duplicate disc id: " .. tostring(disc.id))
    world.discById[key] = disc
    -- Insertion order is the solver order; build worlds in their intended physical order.
    table.insert(world.discs, disc)
    return disc
end

function Core.addPlane(world, spec)
    assert(type(spec) == "table" and spec.id ~= nil, "plane id is required")
    local nx, ny = spec.normalX, spec.normalY
    assert(finite(nx) and finite(ny), "plane normal must be finite")
    local length = math.sqrt(nx*nx+ny*ny)
    assert(length > 1e-12, "plane normal cannot be zero")
    local plane = {
        id=spec.id, normalX=nx/length, normalY=ny/length,
        offset=spec.offset or 0, bCoef=spec.bCoef == nil and 0.5 or spec.bCoef,
        collisionGroup=spec.collisionGroup == nil and 1 or spec.collisionGroup,
        collisionMask=spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
    }
    assert(finite(plane.offset) and finite(plane.bCoef), "plane values must be finite")
    assert(validMask(plane.collisionGroup) and validMask(plane.collisionMask), "plane collision flags must be unsigned 32-bit integers")
    local key="plane:"..idKey(plane.id)
    assert(not world.geometryById[key], "duplicate plane id")
    world.geometryById[key]=true
    table.insert(world.planes,plane)
    return plane
end

local function segmentArcData(x1,y1,x2,y2,curveDegrees)
    if math.abs(curveDegrees)<1e-9 then return nil end
    assert(math.abs(curveDegrees)<360, "segment curve must be between -360 and 360 degrees")
    local dx,dy=x2-x1,y2-y1
    local chord=math.sqrt(dx*dx+dy*dy)
    local sweep=math.rad(curveDegrees)
    local half=sweep*0.5
    local offset
    if math.abs(math.abs(curveDegrees)-180)<1e-8 then
        offset=0
    else
        local tangent=math.tan(half)
        assert(math.abs(tangent)>1e-12, "invalid curved segment")
        offset=chord/(2*tangent)
    end
    local midX,midY=(x1+x2)*0.5,(y1+y2)*0.5
    local leftX,leftY=-dy/chord,dx/chord
    local centerX,centerY=midX+leftX*offset,midY+leftY*offset
    local radius=math.sqrt((x1-centerX)^2+(y1-centerY)^2)
    assert(finite(radius) and radius>1e-9, "invalid curved segment radius")
    return {centerX=centerX,centerY=centerY,radius=radius,startAngle=math.atan2(y1-centerY,x1-centerX),sweep=sweep}
end

function Core.addSegment(world, spec)
    assert(type(spec) == "table" and spec.id ~= nil, "segment id is required")
    local segment = {
        id=spec.id, x1=spec.x1, y1=spec.y1, x2=spec.x2, y2=spec.y2,
        bCoef=spec.bCoef == nil and 0.5 or spec.bCoef,
        collisionGroup=spec.collisionGroup == nil and 1 or spec.collisionGroup,
        collisionMask=spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
        twoSided=spec.twoSided ~= false,
        kickoffOnly=spec.kickoffOnly == true,
        curveDegrees=spec.curveDegrees or spec.curve or 0,
    }
    for _, key in ipairs({"x1","y1","x2","y2","bCoef","curveDegrees"}) do
        assert(finite(segment[key]), "segment field must be finite: "..key)
    end
    assert(validMask(segment.collisionGroup) and validMask(segment.collisionMask), "segment collision flags must be unsigned 32-bit integers")
    local dx,dy=segment.x2-segment.x1,segment.y2-segment.y1
    assert(dx*dx+dy*dy>1e-16, "segment endpoints must differ")
    local key="segment:"..idKey(segment.id)
    assert(not world.geometryById[key], "duplicate segment id")
    world.geometryById[key]=true
    segment.arc=segmentArcData(segment.x1,segment.y1,segment.x2,segment.y2,segment.curveDegrees)
    table.insert(world.segments,segment)
    return segment
end

local function collisionAllowed(a, b)
    return bit32.band(a.collisionGroup, b.collisionMask) ~= 0
        and bit32.band(b.collisionGroup, a.collisionMask) ~= 0
end

local function applyInputAndKick(world, inputs, events)
    local cfg = world.config
    for _, player in ipairs(world.discs) do
        if player.enabled and player.kind == "player" then
            local input = inputs[player.id] or inputs[idKey(player.id)] or {}
            if type(input) ~= "table" then input = {} end
            local ix = finite(input.x) and input.x or 0
            local iy = finite(input.y) and input.y or 0
            local magnitude = math.sqrt(ix*ix + iy*iy)
            if magnitude > 1 then ix, iy = ix/magnitude, iy/magnitude end

            local kickHeld = input.kick == true
            if kickHeld and not player.kickHeld then
                player.kickArmed = true
            elseif not kickHeld then
                player.kickArmed = false
            end
            player.kickHeld = kickHeld
            if player.kickCooldown > 0 then player.kickCooldown -= 1 end

            if player.kickArmed and player.kickCooldown <= 0 then
                for _, target in ipairs(world.discs) do
                    if target.enabled and target.kickable and target.invMass > 0 then
                        local dx, dy = target.x-player.x, target.y-player.y
                        local distance = math.sqrt(dx*dx+dy*dy)
                        local extra = player.kickRangeExtra
                        if distance > 0 and distance-player.radius-target.radius < extra then
                            local nx, ny = dx/distance, dy/distance
                            target.vx += nx*player.kickStrength*target.invMass
                            target.vy += ny*player.kickStrength*target.invMass
                            player.vx -= nx*player.kickback*player.invMass
                            player.vy -= ny*player.kickback*player.invMass
                            player.kickArmed = false
                            player.kickCooldown = cfg.kickCooldownTicks
                            table.insert(events, {kind="kick", tick=world.tick+1, playerId=player.id, targetId=target.id, normalX=nx, normalY=ny})
                            break
                        end
                    end
                end
            end

            local accel = player.kickArmed and player.kickAcceleration or player.acceleration
            player.vx += ix*accel
            player.vy += iy*accel
            if player.maxSpeed then
                local speed = math.sqrt(player.vx*player.vx+player.vy*player.vy)
                if speed > player.maxSpeed then
                    local scale = player.maxSpeed/speed
                    player.vx *= scale
                    player.vy *= scale
                end
            end
        end
    end
end

local function integrate(world)
    for _, disc in ipairs(world.discs) do
        if disc.enabled and disc.invMass > 0 then
            disc.x += disc.vx
            disc.y += disc.vy
            local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping
            disc.vx = (disc.vx+disc.gravityX)*damping
            disc.vy = (disc.vy+disc.gravityY)*damping
        end
    end
end

local function resolveBoundsForDisc(world, disc, events, eventKeys)
    if not world.useBounds or not disc.enabled or disc.invMass<=0 then return end
    local cfg=world.config
    local minX,maxX=-cfg.fieldHalfWidth+disc.radius,cfg.fieldHalfWidth-disc.radius
    local minY,maxY=-cfg.fieldHalfHeight+disc.radius,cfg.fieldHalfHeight-disc.radius
    local bounceCount=0
    if disc.x<minX then disc.x=minX;if disc.vx<0 then disc.vx=-disc.vx*disc.bCoef;bounceCount+=1 end
    elseif disc.x>maxX then disc.x=maxX;if disc.vx>0 then disc.vx=-disc.vx*disc.bCoef;bounceCount+=1 end end
    if disc.y<minY then disc.y=minY;if disc.vy<0 then disc.vy=-disc.vy*disc.bCoef;bounceCount+=1 end
    elseif disc.y>maxY then disc.y=maxY;if disc.vy>0 then disc.vy=-disc.vy*disc.bCoef;bounceCount+=1 end end
    if bounceCount>0 then
        local key="boundary:"..idKey(disc.id)
        local event=eventKeys[key]
        if event then event.count+=bounceCount
        else
            event={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=bounceCount}
            eventKeys[key]=event
            table.insert(events,event)
        end
    end
end

local function resolveDiscPair(a, b, reference)
    local dx, dy = a.x-b.x, a.y-b.y
    local d2 = dx*dx+dy*dy
    local radii = a.radius+b.radius
    if d2 > radii*radii then return nil end
    if d2 == 0 and reference then return nil end

    local distance, nx, ny
    if d2 > 1e-16 then
        distance = math.sqrt(d2)
        nx, ny = dx/distance, dy/distance
    else
        -- Deterministic fallback for coincident centers. Original Haxball behavior
        -- at exact coincidence must still be verified against an official oracle.
        distance = 0
        nx, ny = -1, 0
    end

    local overlap = radii-distance
    local invSum = a.invMass+b.invMass
    if invSum <= 0 then return nil end
    local mf = a.invMass/invSum
    local shareA = overlap*mf
    a.x += nx*shareA
    a.y += ny*shareA
    local shareB = overlap-shareA
    b.x -= nx*shareB
    b.y -= ny*shareB

    local normalSpeedBefore=nx*(a.vx-b.vx)+ny*(a.vy-b.vy)
    local normalVelocity=normalSpeedBefore
    local impulseMagnitude = 0
    if normalVelocity < 0 then
        -- Haxball-style restitution uses the product of disk bounce coefficients.
        normalVelocity *= (a.bCoef*b.bCoef+1)
        local changeA = mf*normalVelocity
        a.vx -= nx*changeA
        a.vy -= ny*changeA
        local changeB = normalVelocity-changeA
        b.vx += nx*changeB
        b.vy += ny*changeB
        impulseMagnitude = math.abs(normalVelocity)/invSum
    end
    return {normalX=nx,normalY=ny,penetration=overlap,normalSpeedBefore=normalSpeedBefore,impulse=impulseMagnitude}
end

local function resolveStaticGeometryForDisc(world, disc, events, eventKeys)
    if not disc.enabled or disc.invMass<=0 then return end
    local function collide(geometry, kind, nx, ny, penetration)
        if not collisionAllowed(disc,geometry) or penetration<=0 then return end
        disc.x+=nx*penetration
        disc.y+=ny*penetration
        local normalVelocity=disc.vx*nx+disc.vy*ny
        local impulse=0
        if normalVelocity<0 then
            local change=-(1+disc.bCoef*geometry.bCoef)*normalVelocity
            disc.vx+=nx*change
            disc.vy+=ny*change
            impulse=change/disc.invMass
        end
        local key=kind..":"..idKey(disc.id)..":"..idKey(geometry.id)
        local event=eventKeys[key]
        if event then
            event.penetration=math.max(event.penetration,penetration)
            event.impulse=math.max(event.impulse,impulse)
        else
            event={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=geometry.id,normalX=nx,normalY=ny,penetration=penetration,impulse=impulse}
            eventKeys[key]=event
            table.insert(events,event)
        end
    end

    for _,plane in ipairs(world.planes) do
        local signed=disc.x*plane.normalX+disc.y*plane.normalY-plane.offset
        local penetration=disc.radius-signed
        if penetration>0 then collide(plane,"planeContact",plane.normalX,plane.normalY,penetration) end
    end
    for _,segment in ipairs(world.segments) do
        local qx,qy
        if segment.arc then
            local arc=segment.arc
            local angle=math.atan2(disc.y-arc.centerY,disc.x-arc.centerX)
            local delta=arc.sweep>=0 and ((angle-arc.startAngle)%(2*math.pi)) or ((arc.startAngle-angle)%(2*math.pi))
            if delta<=math.abs(arc.sweep)+1e-9 then
                qx=arc.centerX+arc.radius*math.cos(angle)
                qy=arc.centerY+arc.radius*math.sin(angle)
            else
                local dStart=(disc.x-segment.x1)^2+(disc.y-segment.y1)^2
                local dEnd=(disc.x-segment.x2)^2+(disc.y-segment.y2)^2
                if dStart<=dEnd then qx,qy=segment.x1,segment.y1 else qx,qy=segment.x2,segment.y2 end
            end
        else
            local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
            local length2=sx*sx+sy*sy
            local t=math.clamp(((disc.x-segment.x1)*sx+(disc.y-segment.y1)*sy)/length2,0,1)
            qx,qy=segment.x1+t*sx,segment.y1+t*sy
        end
        local dx,dy=disc.x-qx,disc.y-qy
        local distance2=dx*dx+dy*dy
        if distance2<disc.radius*disc.radius then
            local distance,nx,ny
            if distance2>1e-16 then
                distance=math.sqrt(distance2);nx,ny=dx/distance,dy/distance
            elseif segment.arc then
                local arc=segment.arc
                local angle=arc.startAngle+arc.sweep*0.5
                nx,ny=math.cos(angle),math.sin(angle)
                distance=0
            else
                local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
                local length=math.sqrt(sx*sx+sy*sy)
                nx,ny=-sy/length,sx/length
                if not segment.twoSided and (disc.x-segment.x1)*nx+(disc.y-segment.y1)*ny<0 then nx,ny=-nx,-ny end
            end
            local allowed=segment.arc~=nil or segment.twoSided
            if not allowed then
                local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
                local length=math.sqrt(sx*sx+sy*sy)
                allowed=(disc.x-segment.x1)*(-sy/length)+(disc.y-segment.y1)*(sx/length)>=-1e-9
            end
            if allowed then collide(segment,"segmentContact",nx,ny,disc.radius-(distance or 0)) end
        end
    end
end

-- Exact ordered static contact policy for the pinned Node-Haxball 2.3.0
-- compatibility profile. Geometry is numeric reference data, not Roblox objects.
function Core.setReferenceGeometry(world, geometry)
    assert(world.config.solverMode == "haxballDiscrete", "reference geometry requires discrete mode")
    world.referenceGeometry=geometry
end

local function resolveReferenceGeometry(world, d, events)
    local geo=world.referenceGeometry
    if not geo or not d.enabled or d.invMass==0 then return end
    local function response(g,nx,ny,penetration,kind)
        d.x+=nx*penetration; d.y+=ny*penetration
        local vn=d.vx*nx+d.vy*ny
        if vn<0 then
            local change=vn*(d.bCoef*g.bCoef+1)
            d.vx-=nx*change; d.vy-=ny*change
            table.insert(events,{kind=kind,tick=world.tick+1,discId=d.id,geometryId=g.id})
        end
    end
    for _,g in ipairs(geo.planes) do
        if collisionAllowed(d,g) then
            local p=g.offset-(g.normalX*d.x+g.normalY*d.y)+d.radius
            if p>0 then response(g,g.normalX,g.normalY,p,"planeContact") end
        end
    end
    for _,g in ipairs(geo.segments) do
        if not collisionAllowed(d,g) then continue end
        local nx,ny,distance
        if g.curveF then
            nx=d.x-g.centerX;ny=d.y-g.centerY
            local inside=g.v1NormalX*nx+g.v1NormalY*ny>0 and g.v0NormalX*nx+g.v0NormalY*ny>0
            if inside==(g.curveF<=0) then continue end
            local length=math.sqrt(nx*nx+ny*ny)
            if length==0 then continue end
            distance=length-g.arcRadius;nx/=length;ny/=length
        else
            local sx,sy=g.x2-g.x1,g.y2-g.y1
            if (d.x-g.x1)*sx+(d.y-g.y1)*sy<=0 or (d.x-g.x2)*sx+(d.y-g.y2)*sy>=0 then continue end
            nx,ny=g.normalX,g.normalY
            distance=nx*(d.x-g.x2)+ny*(d.y-g.y2)
        end
        local bias=g.bias or 0
        if bias==0 then
            if distance<0 then distance=-distance;nx=-nx;ny=-ny end
        else
            if bias<0 then bias=-bias;distance=-distance;nx=-nx;ny=-ny end
            if distance < -bias then continue end
        end
        if distance<d.radius then response(g,nx,ny,d.radius-distance,"segmentContact") end
    end
    for _,g in ipairs(geo.vertices) do
        if collisionAllowed(d,g) then
            local nx,ny=d.x-g.x,d.y-g.y
            local distance2=nx*nx+ny*ny
            if distance2>0 and distance2<=d.radius*d.radius then
                local length=math.sqrt(distance2)
                response(g,nx/length,ny/length,d.radius-length,"vertexContact")
            end
        end
    end
end

function Core.stepWorld(world, inputs)
    assert(type(world) == "table" and type(world.discs) == "table", "invalid world")
    inputs = inputs or {}
    local events,eventKeys = {},{}
    world.motionSegments={}
    local traceStarts={}
    if world.config.solverMode=="haxballDiscrete" then
        for _,disc in ipairs(world.discs) do
            if disc.traceMotion then traceStarts[disc.id]={x=disc.x,y=disc.y} end
        end
    end
    applyInputAndKick(world, inputs, events)

    local maxSpeed,minRadius=0,math.huge
    for _,disc in ipairs(world.discs) do
        if disc.enabled and disc.invMass>0 then
            maxSpeed=math.max(maxSpeed,math.sqrt(disc.vx*disc.vx+disc.vy*disc.vy))
            minRadius=math.min(minRadius,disc.radius)
        end
    end
    local substeps=1
    if minRadius<math.huge then
        local maxDistance=math.max(0.5,minRadius*0.5)
        substeps=math.clamp(math.ceil(maxSpeed/maxDistance),1,world.config.maxSubsteps)
    end
    local reference = world.config.solverMode == "haxballDiscrete"
    if reference then substeps=1 end
    world.lastSubsteps=substeps

    -- Adaptive microsteps reduce discrete tunneling while preserving one input,
    -- gravity, and damping application per logical tick.
    for substep=1,substeps do
        for _,disc in ipairs(world.discs) do
            if disc.enabled and disc.invMass>0 then
                local startX,startY=disc.x,disc.y
                disc.x+=disc.vx/substeps
                disc.y+=disc.vy/substeps
                if disc.traceMotion then
                    table.insert(world.motionSegments,{discId=disc.id,x0=startX,y0=startY,x1=disc.x,y1=disc.y,substep=substep,substeps=substeps})
                end
            end
        end

        -- The reference advances every position, damps velocities, then resolves contacts.
        if reference then
            for _,disc in ipairs(world.discs) do
                if disc.enabled and disc.invMass>0 then
                    local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping
                    disc.vx=(disc.vx+disc.gravityX)*damping
                    disc.vy=(disc.vy+disc.gravityY)*damping
                end
            end
        end
        -- Preserve declared solver order inside each microstep.
        for i=1,#world.discs do
            local a=world.discs[i]
            if a.enabled then
                for j=i+1,#world.discs do
                    local b=world.discs[j]
                    if b.enabled and (a.invMass>0 or b.invMass>0) and collisionAllowed(a,b) then
                        local contact=resolveDiscPair(a,b,reference)
                        if contact then
                            local key="pair:"..idKey(a.id)..":"..idKey(b.id)
                            local existing=eventKeys[key]
                            if existing then
                                existing.penetration=math.max(existing.penetration,contact.penetration)
                                existing.impulse=math.max(existing.impulse,contact.impulse)
                            else
                                contact.kind="discContact"
                                contact.tick=world.tick+1
                                contact.discA=a.id
                                contact.discB=b.id
                                eventKeys[key]=contact
                                table.insert(events,contact)
                            end
                        end
                    end
                end
                resolveBoundsForDisc(world,a,events,eventKeys)
                if reference and world.referenceGeometry then
                    resolveReferenceGeometry(world,a,events)
                else
                    resolveStaticGeometryForDisc(world,a,events,eventKeys)
                end
            end
        end
    end

    -- Adaptive mode retains its historical post-contact velocity update.
    if not reference then
    for _,disc in ipairs(world.discs) do
        if disc.enabled and disc.invMass>0 then
            local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping
            disc.vx=(disc.vx+disc.gravityX)*damping
            disc.vy=(disc.vy+disc.gravityY)*damping
        end
    end

    end
    if reference then
        -- Goal crossing uses the completed, corrected tick, like the reference.
        world.motionSegments={}
        for _,disc in ipairs(world.discs) do
            local start=traceStarts[disc.id]
            if start then table.insert(world.motionSegments,{discId=disc.id,x0=start.x,y0=start.y,x1=disc.x,y1=disc.y,substep=1,substeps=1}) end
        end
    end
    world.tick += 1
    world.events = events
    return world, events, substeps
end

function Core.snapshot(world)
    local discs = table.create(#world.discs)
    for index, disc in ipairs(world.discs) do
        discs[index] = {
            id=disc.id, kind=disc.kind, team=disc.team, x=disc.x, y=disc.y,
            vx=disc.vx, vy=disc.vy, radius=disc.radius, invMass=disc.invMass,
            damping=disc.damping, bCoef=disc.bCoef, collisionGroup=disc.collisionGroup,
            collisionMask=disc.collisionMask, kickCooldown=disc.kickCooldown,
        }
    end
    return {tick=world.tick, tickRate=world.config.tickRate, substeps=world.lastSubsteps, discs=discs, events=table.clone(world.events)}
end

return Core
