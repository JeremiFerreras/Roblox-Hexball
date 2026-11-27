local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(ReplicatedStorage:WaitForChild("SimpleSoccerGame"):WaitForChild("StadiumReference2D"))
local Physics2D = {}
Physics2D.MatchCore = require(script.Parent:WaitForChild("PhysicsCore2D"))

local P = Profile.PhysicsBaseline.active
local Solver = Profile.PhysicsBaseline.labSolver
Physics2D.Config = {
    tickRate = Profile.Simulation.tickRate.value,
    playerRadius = P.player.radius,
    playerInvMass = P.player.invMass,
    playerDamping = P.player.damping,
    playerBounce = P.player.bounce,
    playerAcceleration = P.player.acceleration,
    playerKickAcceleration = P.player.kickAcceleration,
    playerKickDamping = P.player.kickDamping,
    ballRadius = P.ball.radius,
    ballInvMass = P.ball.invMass,
    ballDamping = P.ball.damping,
    ballBounce = P.ball.bounce,
    kickStrength = P.player.kickStrength,
    kickback = P.player.kickback,
    kickRangeExtra = P.kickRangeExtra,
    fieldHalfWidth = Profile.Bounds.halfWidth,
    fieldHalfHeight = Profile.Bounds.halfHeight,
    collisionIterations = Solver.collisionIterations,
    maxCollisionSubsteps = Solver.maxSubsteps,
    collisionSubstepRadiusFraction = Solver.substepRadiusFraction,
}

local C = Physics2D.Config
local function clampMagnitude(x, y, maxMagnitude)
    local m = math.sqrt(x*x + y*y)
    if m > maxMagnitude and m > 0 then
        local scale = maxMagnitude / m
        return x * scale, y * scale
    end
    return x, y
end

local function newPlayer(id, x, y)
    return {
        id=id, x=x, y=y, vx=0, vy=0,
        radius=C.playerRadius, invMass=C.playerInvMass,
        damping=C.playerDamping, bounce=C.playerBounce,
    }
end

function Physics2D.newState()
    return {
        tick = 0,
        player = newPlayer(1, -80, 0),
        player2 = newPlayer(2, 0, 0),
        ball = { id=3, x=0, y=0, vx=0, vy=0, radius=C.ballRadius, invMass=C.ballInvMass, damping=C.ballDamping, bounce=C.ballBounce },
        score = { red = 0, blue = 0 },
    }
end

local function resolveDiscs(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    local d2 = dx*dx + dy*dy
    local radii = a.radius + b.radius
    if d2 > radii*radii then return nil end

    local d = math.sqrt(d2)
    local nx, ny
    if d > 1e-8 then
        nx, ny = dx/d, dy/d
    else
        local aId, bId = a.id or 1, b.id or 2
        nx, ny = aId <= bId and -1 or 1, 0
    end

    local penetration = math.max(0, radii - d)
    local invSum = a.invMass + b.invMass
    if invSum <= 0 then
        return {
            normalX=nx, normalY=ny, penetration=penetration,
            correctionA=0, correctionB=0, normalSpeedBefore=0, impulse=0,
        }
    end

    local moveA = penetration * (a.invMass / invSum)
    local moveB = penetration * (b.invMass / invSum)
    a.x, a.y = a.x + nx*moveA, a.y + ny*moveA
    b.x, b.y = b.x - nx*moveB, b.y - ny*moveB

    local rvx, rvy = a.vx - b.vx, a.vy - b.vy
    local normalSpeed = rvx*nx + rvy*ny
    local impulse = 0
    if normalSpeed < 0 then
        local restitution = math.min(a.bounce, b.bounce)
        impulse = -(1 + restitution) * normalSpeed / invSum
        a.vx, a.vy = a.vx + nx*impulse*a.invMass, a.vy + ny*impulse*a.invMass
        b.vx, b.vy = b.vx - nx*impulse*b.invMass, b.vy - ny*impulse*b.invMass
    end

    return {
        normalX=nx, normalY=ny, penetration=penetration,
        correctionA=moveA, correctionB=moveB,
        normalSpeedBefore=normalSpeed, impulse=impulse,
    }
end
Physics2D.resolveDiscs = resolveDiscs

local function wall(d, halfW, halfH)
    local minX, maxX = -halfW + d.radius, halfW - d.radius
    local minY, maxY = -halfH + d.radius, halfH - d.radius
    if d.x < minX then d.x = minX; if d.vx < 0 then d.vx = -d.vx*d.bounce end end
    if d.x > maxX then d.x = maxX; if d.vx > 0 then d.vx = -d.vx*d.bounce end end
    if d.y < minY then d.y = minY; if d.vy < 0 then d.vy = -d.vy*d.bounce end end
    if d.y > maxY then d.y = maxY; if d.vy > 0 then d.vy = -d.vy*d.bounce end end
end

local function advanceAxis(position,velocity,minBound,maxBound,dt,bounce)
    local remaining=dt
    local hits=0
    local guard=0
    while remaining>1e-9 and guard<256 do
        guard+=1
        local timeToWall=math.huge
        if velocity>1e-9 then
            timeToWall=(maxBound-position)/velocity
        elseif velocity< -1e-9 then
            timeToWall=(minBound-position)/velocity
        end
        if timeToWall< -1e-8 then
            if position<minBound then position=minBound else position=maxBound end
            timeToWall=0
        end
        if timeToWall>remaining or timeToWall==math.huge then
            position+=velocity*remaining
            remaining=0
        else
            position+=velocity*timeToWall
            remaining-=timeToWall
            position=velocity>0 and maxBound or minBound
            velocity=-velocity*bounce
            hits+=1
            if math.abs(velocity)<=1e-9 then velocity=0; remaining=0 end
        end
    end
    if remaining>1e-9 then position+=velocity*remaining end
    return position,velocity,hits
end

function Physics2D.step(state, input)
    state.tick+=1
    local p,b=state.player,state.ball
    local ix,iy=clampMagnitude(input.x or 0,input.y or 0,1)
    local accel=input.kick and C.playerKickAcceleration or C.playerAcceleration
    p.vx,p.vy=p.vx+ix*accel,p.vy+iy*accel

    local relX,relY=p.vx-b.vx,p.vy-b.vy
    local maxTravel=math.max(
        math.sqrt(p.vx*p.vx+p.vy*p.vy),
        math.sqrt(b.vx*b.vx+b.vy*b.vy),
        math.sqrt(relX*relX+relY*relY)
    )
    local featureSize=math.max(0.5,math.min(p.radius,b.radius)*C.collisionSubstepRadiusFraction)
    local substeps=math.clamp(math.ceil(maxTravel/featureSize),1,C.maxCollisionSubsteps)
    local info={substeps=substeps,playerBallContacts=0,ballWallBounces=0,playerWallBounces=0,lastPlayerBallContact=nil}
    local dt=1/substeps
    local minPX,maxPX=-C.fieldHalfWidth+p.radius,C.fieldHalfWidth-p.radius
    local minPY,maxPY=-C.fieldHalfHeight+p.radius,C.fieldHalfHeight-p.radius
    local minBX,maxBX=-C.fieldHalfWidth+b.radius,C.fieldHalfWidth-b.radius
    local minBY,maxBY=-C.fieldHalfHeight+b.radius,C.fieldHalfHeight-b.radius

    for substep=1,substeps do
        local localPlayerX,localPlayerY,localBallX,localBallY
        p.x,p.vx,localPlayerX=advanceAxis(p.x,p.vx,minPX,maxPX,dt,p.bounce)
        p.y,p.vy,localPlayerY=advanceAxis(p.y,p.vy,minPY,maxPY,dt,p.bounce)
        b.x,b.vx,localBallX=advanceAxis(b.x,b.vx,minBX,maxBX,dt,b.bounce)
        b.y,b.vy,localBallY=advanceAxis(b.y,b.vy,minBY,maxBY,dt,b.bounce)
        info.playerWallBounces+=localPlayerX+localPlayerY
        info.ballWallBounces+=localBallX+localBallY

        local contact=resolveDiscs(p,b)
        if contact and (contact.penetration>0 or contact.impulse>0) then
            info.playerBallContacts+=1
            info.lastPlayerBallContact={
                normalX=contact.normalX,normalY=contact.normalY,
                penetration=contact.penetration,correctionPlayer=contact.correctionA,
                correctionBall=contact.correctionB,normalSpeedBefore=contact.normalSpeedBefore,
                impulse=contact.impulse,substep=substep,
            }
        end
    end

    p.vx,p.vy=p.vx*p.damping,p.vy*p.damping
    b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
    return state,info
end

function Physics2D.stepPlayerPair(state)
    state.tick += 1
    local a, b = state.player, state.player2
    local ax, ay, avx, avy = a.x, a.y, a.vx, a.vy
    local bx, by, bvx, bvy = b.x, b.y, b.vx, b.vy

    a.x, a.y = ax+avx, ay+avy
    b.x, b.y = bx+bvx, by+bvy

    local dx,dy=a.x-b.x,a.y-b.y
    local radiusSum=a.radius+b.radius
    if dx*dx+dy*dy <= radiusSum*radiusSum then
        a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
        b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
        wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
        wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
        return state,resolveDiscs(a,b)
    end

    local rx, ry = ax-bx, ay-by
    local rvx, rvy = avx-bvx, avy-bvy
    local qa = rvx*rvx+rvy*rvy
    local qb = 2*(rx*rvx+ry*rvy)
    local qc = rx*rx+ry*ry-radiusSum*radiusSum
    local discriminant = qb*qb-4*qa*qc
    if qc > 0 and qa > 1e-12 and qb < 0 and discriminant >= 0 then
        local hitTime = (-qb-math.sqrt(discriminant))/(2*qa)
        if hitTime >= 0 and hitTime <= 1 then
            a.x, a.y = ax+avx*hitTime, ay+avy*hitTime
            b.x, b.y = bx+bvx*hitTime, by+bvy*hitTime
            a.vx, a.vy, b.vx, b.vy = avx, avy, bvx, bvy
            local contact=resolveDiscs(a,b)
            if contact then
                local remaining=1-hitTime
                a.x,a.y=a.x+a.vx*remaining,a.y+a.vy*remaining
                b.x,b.y=b.x+b.vx*remaining,b.y+b.vy*remaining
                a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
                b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
                wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
                wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
                contact.swept=true
                contact.impactFraction=hitTime
            end
            return state,contact
        end
    end

    a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
    b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
    wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
    wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
    return state,nil
end

function Physics2D.stepThreeBody(state, iterationCount)
    state.tick += 1
    local p1,p2,ball=state.player,state.player2,state.ball
    for _,disc in {p1,p2,ball} do
        disc.x,disc.y=disc.x+disc.vx,disc.y+disc.vy
        disc.vx,disc.vy=disc.vx*disc.damping,disc.vy*disc.damping
        wall(disc,C.fieldHalfWidth,C.fieldHalfHeight)
    end

    local pairs={
        {key="player1-player2",a=p1,b=p2},
        {key="player1-ball",a=p1,b=ball},
        {key="player2-ball",a=p2,b=ball},
    }
    local iterations=math.clamp(iterationCount or C.collisionIterations,1,24)
    local initialNormalSpeeds={}
    local contactPairs={}
    local impacts={}
    for _,pair in ipairs(pairs) do
        local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
        local d2=dx*dx+dy*dy
        local radii=pair.a.radius+pair.b.radius
        local d=math.sqrt(d2)
        local nx,ny
        if d>1e-8 then
            nx,ny=dx/d,dy/d
        else
            local aId,bId=pair.a.id or 1,pair.b.id or 2
            nx,ny=aId<=bId and -1 or 1,0
        end
        local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
        initialNormalSpeeds[pair.key]=vn
        if d2<=radii*radii then
            table.insert(contactPairs,pair)
            impacts[pair.key]={
                maxPenetration=math.max(0,radii-d),correctionA=0,correctionB=0,
                normalX=nx,normalY=ny,normalSpeedBefore=vn,
                impulseTotal=0,peakImpulseIncrement=0,lastImpulse=0,resolutionCount=0,
            }
        end
    end

    local positionIterations=0
    for iteration=1,iterations do
        positionIterations=iteration
        local deltas={}
        for _,disc in {p1,p2,ball} do deltas[disc]={x=0,y=0} end
        local maxPenetration=0
        for _,pair in ipairs(pairs) do
            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
            local distance=math.sqrt(dx*dx+dy*dy)
            local radii=pair.a.radius+pair.b.radius
            if distance<radii then
                local nx,ny
                if distance>1e-8 then nx,ny=dx/distance,dy/distance
                else
                    local aId,bId=pair.a.id or 1,pair.b.id or 2
                    nx,ny=aId<=bId and -1 or 1,0
                end
                local penetration=radii-distance
                maxPenetration=math.max(maxPenetration,penetration)
                local invSum=pair.a.invMass+pair.b.invMass
                if invSum>0 then
                    local ca=penetration*(pair.a.invMass/invSum)
                    local cb=penetration*(pair.b.invMass/invSum)
                    local da,db=deltas[pair.a],deltas[pair.b]
                    da.x+=nx*ca; da.y+=ny*ca
                    db.x-=nx*cb; db.y-=ny*cb
                    local impact=impacts[pair.key]
                    if impact then
                        impact.maxPenetration=math.max(impact.maxPenetration,penetration)
                        impact.correctionA=math.max(impact.correctionA,ca)
                        impact.correctionB=math.max(impact.correctionB,cb)
                        impact.normalX,impact.normalY=nx,ny
                    end
                end
            end
        end
        for disc,delta in deltas do disc.x+=delta.x; disc.y+=delta.y end
        if maxPenetration<=1e-5 then break end
    end

    local velocityIterations=0
    local accumulated={}
    local targets={}
    for _,pair in ipairs(contactPairs) do
        accumulated[pair.key]=0
        local vn=initialNormalSpeeds[pair.key]
        targets[pair.key]=vn<0 and -math.min(pair.a.bounce,pair.b.bounce)*vn or 0
    end
    for iteration=1,iterations do
        velocityIterations=iteration
        local maxViolation=0
        for orderIndex=1,#contactPairs do
            local pairIndex=iteration%2==1 and orderIndex or (#contactPairs-orderIndex+1)
            local pair=contactPairs[pairIndex]
            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
            local distance=math.sqrt(dx*dx+dy*dy)
            local nx,ny
            if distance>1e-8 then nx,ny=dx/distance,dy/distance
            else
                local aId,bId=pair.a.id or 1,pair.b.id or 2
                nx,ny=aId<=bId and -1 or 1,0
            end
            local invSum=pair.a.invMass+pair.b.invMass
            if invSum>0 then
                local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
                local target=targets[pair.key] or 0
                local oldTotal=accumulated[pair.key]
                local newTotal=math.max(0,oldTotal+(target-vn)/invSum)
                local delta=newTotal-oldTotal
                if math.abs(delta)>1e-12 then
                    accumulated[pair.key]=newTotal
                    pair.a.vx+=nx*delta*pair.a.invMass
                    pair.a.vy+=ny*delta*pair.a.invMass
                    pair.b.vx-=nx*delta*pair.b.invMass
                    pair.b.vy-=ny*delta*pair.b.invMass
                    local impact=impacts[pair.key]
                    if impact then
                        impact.impulseTotal=newTotal
                        impact.lastImpulse=delta
                        impact.peakImpulseIncrement=math.max(impact.peakImpulseIncrement,math.abs(delta))
                        impact.resolutionCount+=1
                        impact.normalX,impact.normalY=nx,ny
                    end
                end
            end
        end
        for _,pair in ipairs(contactPairs) do
            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
            local distance=math.sqrt(dx*dx+dy*dy)
            local nx,ny
            if distance>1e-8 then nx,ny=dx/distance,dy/distance
            else
                local aId,bId=pair.a.id or 1,pair.b.id or 2
                nx,ny=aId<=bId and -1 or 1,0
            end
            local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
            maxViolation=math.max(maxViolation,math.max(0,(targets[pair.key] or 0)-vn))
        end
        if maxViolation<=1e-6 then break end
    end

    local residuals={}
    local maxResidual=0
    for _,pair in ipairs(pairs) do
        local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
        local distance=math.sqrt(dx*dx+dy*dy)
        local residual=math.max(0,pair.a.radius+pair.b.radius-distance)
        residuals[pair.key]=residual
        maxResidual=math.max(maxResidual,residual)
    end
    return state,impacts,residuals,maxResidual,math.max(positionIterations,velocityIterations)
end

function Physics2D.tryKick(state, facingX, facingY)
    local p, b = state.player, state.ball
    local dx, dy = b.x - p.x, b.y - p.y
    local d = math.sqrt(dx*dx + dy*dy)
    if d > p.radius + b.radius + C.kickRangeExtra then return false end
    if d > 1e-8 then dx, dy = dx/d, dy/d else dx, dy = facingX, facingY end
    if dx*dx + dy*dy < 1e-8 then dx, dy = 1, 0 end
    b.vx, b.vy = b.vx + dx*C.kickStrength, b.vy + dy*C.kickStrength
    p.vx, p.vy = p.vx - dx*C.kickback, p.vy - dy*C.kickback
    return true
end

return Physics2D