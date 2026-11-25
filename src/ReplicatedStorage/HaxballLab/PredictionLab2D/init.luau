-- Client-only free-motion micro-prediction for isolated latency experiments.
-- Predicted contacts are forecasts, never authoritative collision results.
local Prediction = {}

local function clampInput(x,y)
    x=type(x)=="number" and x or 0
    y=type(y)=="number" and y or 0
    local magnitude=math.sqrt(x*x+y*y)
    if magnitude>1 then return x/magnitude,y/magnitude end
    return x,y
end

function Prediction.predict(state,input,params,ticks)
    assert(type(state)=="table" and type(input)=="table" and type(params)=="table","state, input, and params are required")
    ticks=math.clamp(math.floor(tonumber(ticks) or 0),0,24)
    local x,y,vx,vy=state.x,state.y,state.vx,state.vy
    local ix,iy=clampInput(input.x,input.y)
    local path=table.create(ticks)
    for tick=1,ticks do
        local acceleration=input.kick and params.kickAcceleration or params.acceleration
        vx+=ix*acceleration
        vy+=iy*acceleration
        if params.maxSpeed then
            local speed=math.sqrt(vx*vx+vy*vy)
            if speed>params.maxSpeed then
                local scale=params.maxSpeed/speed
                vx*=scale
                vy*=scale
            end
        end
        x+=vx
        y+=vy
        local damping=input.kick and params.kickDamping or params.damping
        vx*=damping
        vy*=damping
        path[tick]={tick=tick,x=x,y=y,vx=vx,vy=vy}
    end
    return {x=x,y=y,vx=vx,vy=vy,path=path,ticks=ticks}
end

function Prediction.firstContact(path,playerRadius,targets)
    for _,sample in ipairs(path or {}) do
        for _,target in ipairs(targets or {}) do
            local tx=target.x+(target.vx or 0)*sample.tick
            local ty=target.y+(target.vy or 0)*sample.tick
            local dx,dy=sample.x-tx,sample.y-ty
            local distance=math.sqrt(dx*dx+dy*dy)
            if distance<=playerRadius+(target.radius or 0) then
                return {tick=sample.tick,targetId=target.id,kind=target.kind,distance=distance}
            end
        end
    end
    return nil
end

return Prediction
