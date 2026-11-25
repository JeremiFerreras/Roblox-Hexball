local Suite={}
local ClassicStadium2D=require(script.Parent:WaitForChild("ClassicStadium2D"))
local MatchRules2D=require(script.Parent:WaitForChild("MatchRules2D"))
local PredictionLab2D=require(game:GetService("ReplicatedStorage").HaxballLab:WaitForChild("PredictionLab2D"))
local StadiumProfile2D=require(game:GetService("ReplicatedStorage").HaxballLab:WaitForChild("StadiumReference2D"))
local function near(a,b,tolerance)
    return math.abs(a-b)<=tolerance
end
local function finite(n)
    return type(n)=="number" and n==n and math.abs(n)<1e12
end
local function addResult(report,name,fn)
    local ok,value=pcall(fn)
    table.insert(report.tests,{
        name=name,passed=ok and value.passed==true,
        detail=ok and value.detail or tostring(value),
    })
end

function Suite.Run(P)
    local report={tickRate=P.Config.tickRate,tests={}}
    addResult(report,"horizontal_free_acceleration_120_ticks",function()
        local s=P.newState();s.player.x=-200;s.player.y=100
        local vx,x=0,-200
        local maxX,maxV=0,0
        for i=1,120 do
            local before=vx+P.Config.playerAcceleration
            x+=before;vx=before*P.Config.playerDamping
            P.step(s,{x=1,y=0,kick=false})
            maxX=math.max(maxX,math.abs(s.player.x-x))
            maxV=math.max(maxV,math.abs(s.player.vx-vx))
        end
        return {passed=maxX<=1e-9 and maxV<=1e-9,detail=string.format("samples=120 maxPositionError=%.3g maxVelocityError=%.3g finalSpeed=%.9f",maxX,maxV,math.abs(vx))}
    end)
    addResult(report,"diagonal_normalization_120_ticks",function()
        local s=P.newState();s.player.x=-200;s.player.y=-150;s.ball.x=300
        local vx,vy,x,y=0,0,-200,-150
        local ux,uy=1/math.sqrt(2),1/math.sqrt(2)
        local maxError=0
        for i=1,120 do
            local nx,ny=vx+P.Config.playerAcceleration*ux,vy+P.Config.playerAcceleration*uy
            x+=nx;y+=ny;vx,vy=nx*P.Config.playerDamping,ny*P.Config.playerDamping
            P.step(s,{x=1,y=1,kick=false})
            maxError=math.max(maxError,math.abs(s.player.x-x),math.abs(s.player.y-y),math.abs(s.player.vx-vx),math.abs(s.player.vy-vy))
        end
        local speed=math.sqrt(s.player.vx*s.player.vx+s.player.vy*s.player.vy)
        return {passed=maxError<=1e-9 and near(speed,2.382103866679,1e-9),detail=string.format("samples=120 maxStateError=%.3g finalSpeed=%.9f",maxError,speed)}
    end)
    addResult(report,"release_damping_30_ticks",function()
        local s=P.newState();s.player.x=-200;s.player.y=100
        for i=1,120 do P.step(s,{x=1,y=0}) end
        local expectedV,expectedX=s.player.vx,s.player.x
        for i=1,30 do expectedX+=expectedV;expectedV*=P.Config.playerDamping;P.step(s,{x=0,y=0}) end
        local xError,vError=math.abs(s.player.x-expectedX),math.abs(s.player.vx-expectedV)
        return {passed=xError<=1e-9 and vError<=1e-9,detail=string.format("samples=30 positionError=%.3g velocityError=%.3g",xError,vError)}
    end)
    addResult(report,"ball_damping_120_ticks",function()
        local s=P.newState();s.player.x=-200;s.player.y=100;s.ball.vx=2
        local x,v=0,2
        for i=1,120 do x+=v;v*=P.Config.ballDamping;P.step(s,{x=0,y=0}) end
        local xError,vError=math.abs(s.ball.x-x),math.abs(s.ball.vx-v)
        return {passed=xError<=1e-9 and vError<=1e-9,detail=string.format("samples=120 positionError=%.3g velocityError=%.3g",xError,vError)}
    end)
    addResult(report,"kick_range_and_impulse",function()
        local s=P.newState();s.player.x=-27
        local accepted=P.tryKick(s,1,0)
        return {passed=accepted and near(s.ball.vx,5,1e-12) and near(s.player.vx,0,1e-12),detail=string.format("accepted=%s ballVx=%.9f playerVx=%.9f",tostring(accepted),s.ball.vx,s.player.vx)}
    end)
    addResult(report,"fast_player_ball_crossing",function()
        local s=P.newState();s.player.x=-40;s.player.vx=100
        local _,info=P.step(s,{x=0,y=0})
        local c=info.lastPlayerBallContact
        local ok=c~=nil and info.playerBallContacts>0 and near(c.normalSpeedBefore,-100,1e-8) and near(c.impulse,100,1e-8) and c.penetration<=2
        return {passed=ok,detail=string.format("substeps=%d contacts=%d contactSubstep=%s penetration=%.6f impulse=%.9f",info.substeps,info.playerBallContacts,tostring(c and c.substep),c and c.penetration or -1,c and c.impulse or -1)}
    end)
    addResult(report,"fast_diagonal_player_ball_contact",function()
        local s=P.newState();s.player.x=-40;s.player.y=-40;s.player.vx=100;s.player.vy=100
        local _,info=P.step(s,{x=0,y=0})
        local c=info.lastPlayerBallContact
        local expected=-1/math.sqrt(2)
        local ok=c~=nil and near(c.normalX,expected,1e-8) and near(c.normalY,expected,1e-8) and c.penetration<=0.5
        return {passed=ok,detail=string.format("substeps=%d normal=(%.6f,%.6f) penetration=%.6f impulse=%.6f",info.substeps,c and c.normalX or 0,c and c.normalY or 0,c and c.penetration or -1,c and c.impulse or -1)}
    end)
    addResult(report,"multiple_ball_wall_bounces_in_one_tick",function()
        local s=P.newState();s.player.y=100;s.ball.vx=3000
        local _,info=P.step(s,{x=0,y=0})
        local xError,vError=math.abs(s.ball.x+172.5),math.abs(s.ball.vx-742.5)
        local ok=info.ballWallBounces==2 and xError<=1e-8 and vError<=1e-8
        return {passed=ok,detail=string.format("bounces=%d substeps=%d x=%.9f vx=%.9f xError=%.3g vError=%.3g",info.ballWallBounces,info.substeps,s.ball.x,s.ball.vx,xError,vError)}
    end)
    addResult(report,"swept_player_pair_crossing",function()
        local s=P.newState();s.player.x=-40;s.player.vx=80;s.player2.x=40;s.player2.vx=-80
        local _,c=P.stepPlayerPair(s)
        local ok=c~=nil and c.swept==true and near(c.impactFraction,0.3125,1e-12) and near(c.impulse,240,1e-9)
        return {passed=ok,detail=string.format("swept=%s toi=%.9f impulse=%.9f",tostring(c and c.swept),c and c.impactFraction or -1,c and c.impulse or -1)}
    end)
    addResult(report,"symmetric_two_player_ball_collision",function()
        local s=P.newState();s.player.x=-32;s.player.vx=2;s.player2.x=32;s.player2.vx=-2
        local a,b
        local residual=math.huge
        for tick=1,12 do
            local _,impacts,_,stepResidual=P.stepThreeBody(s,24)
            residual=stepResidual
            a=impacts["player1-ball"] or a
            b=impacts["player2-ball"] or b
            if a and b then break end
        end
        if not a or not b then
            return {passed=false,detail="no paired contact within 12 ticks"}
        end
        local impulseError=math.abs(a.impulseTotal-b.impulseTotal)
        local velocityError=math.abs(s.player.vx+s.player2.vx)+math.abs(s.ball.vx)
        local ok=impulseError<=1e-3 and residual<=1e-3 and velocityError<=1e-3 and s.player.vx<0 and s.player2.vx>0
        return {passed=ok,detail=string.format("tick=%d impulses=(%.9f,%.9f) impulseError=%.3g residual=%.3g velocitySymmetryError=%.3g",s.tick,a.impulseTotal,b.impulseTotal,impulseError,residual,velocityError)}
    end)
    addResult(report,"three_disc_overlap_resolution",function()
        local s=P.newState();s.player.x=-14;s.player2.x=14
        local _,_,_,residual=P.stepThreeBody(s,24)
        local ok=finite(residual) and residual<=1e-3
        return {passed=ok,detail=string.format("firstTickResidual=%.9g",residual)}
    end)
    addResult(report,"coincident_player_centers",function()
        local s=P.newState();s.player.x=0;s.player2.x=0
        P.stepPlayerPair(s)
        local separation=math.abs(s.player.x-s.player2.x)
        local ok=near(separation,30,1e-9) and finite(s.player.x) and finite(s.player2.x)
        return {passed=ok,detail=string.format("positions=(%.9f,%.9f) separation=%.9f",s.player.x,s.player2.x,separation)}
    end)

    local Core=P.MatchCore
    addResult(report,"core_fixed_tick_integration_order",function()
        local w=Core.newWorld()
        Core.addDisc(w,{id=1,kind="player",x=0,y=0,radius=15,invMass=1,damping=0.96,acceleration=0.1})
        Core.stepWorld(w,{[1]={x=1,y=0}})
        local d=w.discs[1]
        local expectedX=0.1
        local expectedV=0.096
        return {passed=near(d.x,expectedX,1e-12) and near(d.vx,expectedV,1e-12),detail=string.format("tick=%d x=%.12f vx=%.12f",w.tick,d.x,d.vx)}
    end)
    addResult(report,"core_diagonal_input_normalization",function()
        local w=Core.newWorld()
        Core.addDisc(w,{id=1,kind="player",radius=15,invMass=1,damping=1,acceleration=0.1})
        Core.stepWorld(w,{[1]={x=1,y=1}})
        local d=w.discs[1]
        local expected=0.1/math.sqrt(2)
        return {passed=near(d.vx,expected,1e-12) and near(d.vy,expected,1e-12),detail=string.format("vx=%.12f vy=%.12f",d.vx,d.vy)}
    end)
    addResult(report,"core_disc_collision_product_restitution",function()
        local w=Core.newWorld({fieldHalfWidth=1000,fieldHalfHeight=1000})
        Core.addDisc(w,{id=1,kind="player",x=-9,vx=1,radius=10,invMass=1,damping=1,bCoef=0.5})
        Core.addDisc(w,{id=2,kind="ball",x=9,vx=-1,radius=10,invMass=1,damping=1,bCoef=0.5})
        Core.stepWorld(w,{})
        local a,b=w.discs[1],w.discs[2]
        local expectedA,expectedB=-0.25,0.25
        return {passed=near(a.vx,expectedA,1e-12) and near(b.vx,expectedB,1e-12) and #w.events==1,detail=string.format("vx=(%.12f,%.12f) contactEvents=%d",a.vx,b.vx,#w.events)}
    end)
    addResult(report,"core_collision_masks_exclude_pair",function()
        local w=Core.newWorld({fieldHalfWidth=1000,fieldHalfHeight=1000})
        Core.addDisc(w,{id=1,x=-9,vx=1,radius=10,invMass=1,damping=1,collisionGroup=1,collisionMask=1})
        Core.addDisc(w,{id=2,x=9,vx=-1,radius=10,invMass=1,damping=1,collisionGroup=2,collisionMask=2})
        Core.stepWorld(w,{})
        return {passed=#w.events==0 and w.discs[1].x==-8 and w.discs[2].x==8,detail=string.format("contacts=%d positions=(%.3f,%.3f)",#w.events,w.discs[1].x,w.discs[2].x)}
    end)
    addResult(report,"core_kick_edge_only_once",function()
        local w=Core.newWorld()
        Core.addDisc(w,{id=1,kind="player",x=-20,radius=15,invMass=1,damping=1,kickStrength=5,kickback=0,kickRangeExtra=4})
        Core.addDisc(w,{id=2,kind="ball",x=0,radius=10,invMass=1,damping=1,kickable=true})
        Core.stepWorld(w,{[1]={x=0,y=0,kick=true}})
        local first=w.discs[2].vx
        local firstKickEvent=w.events[1] and w.events[1].kind=="kick"
        Core.stepWorld(w,{[1]={x=0,y=0,kick=true}})
        local second=w.discs[2].vx
        local repeatedKickEvent=false
        for _,event in ipairs(w.events) do if event.kind=="kick" then repeatedKickEvent=true end end
        return {passed=near(first,5,1e-12) and near(second,5,1e-12) and firstKickEvent and not repeatedKickEvent,detail=string.format("ballVx=%.3f->%.3f kickEventFirst=%s repeated=%s",first,second,tostring(firstKickEvent),tostring(repeatedKickEvent))}
    end)
    addResult(report,"core_ten_player_classic_world_600_ticks",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=0.99,bCoef=0.5,kickable=true,collisionGroup=ClassicStadium2D.Groups.ball})
        local geometry=ClassicStadium2D.install(Core,w)
        local positions={{-80,0},{-150,-54},{-150,-18},{-150,18},{-150,54},{150,-72},{150,-36},{150,0},{150,36},{150,72}}
        local red,blue=0,0
        for i=1,10 do
            local team=i<=5 and "red" or "blue"
            if team=="red" then red+=1 else blue+=1 end
            local p=positions[i]
            Core.addDisc(w,{id=i,kind="player",team=team,x=p[1],y=p[2],radius=15,invMass=0.5,damping=0.96,bCoef=0.5,acceleration=0.1,kickAcceleration=0.07,kickStrength=5,kickback=0,collisionGroup=team=="red" and ClassicStadium2D.Groups.red or ClassicStadium2D.Groups.blue,collisionMask=require(game:GetService("ReplicatedStorage").HaxballLab.StadiumReference2D).CollisionMasks.player})
        end
        local totalEvents,maxSubsteps=0,0
        local valid=true
        for tick=1,600 do
            local inputs={}
            for i=1,10 do inputs[i]={x=math.sin(tick*0.013+i),y=math.cos(tick*0.017-i),kick=(tick%97==1)} end
            local _,tickEvents,substeps=Core.stepWorld(w,inputs)
            totalEvents+=#tickEvents
            maxSubsteps=math.max(maxSubsteps,substeps)
        end
        valid=w.tick==600 and #w.discs==15 and red==5 and blue==5 and geometry.planes==6 and geometry.segments==14 and geometry.posts==4 and totalEvents>0
        for _,d in ipairs(w.discs) do
            valid=valid and finite(d.x) and finite(d.y) and finite(d.vx) and finite(d.vy)
            if d.kind=="player" then valid=valid and math.abs(d.x)<=405 and math.abs(d.y)<=185 end
        end
        local ball=w.discById["string:ball"]
        valid=valid and math.abs(ball.x)<=410 and math.abs(ball.y)<=190
        return {passed=valid,detail=string.format("ticks=%d players=%d red=%d blue=%d discs=%d events=%d maxSubsteps=%d finite=%s",w.tick,red+blue,red,blue,#w.discs,totalEvents,maxSubsteps,tostring(valid))}
    end)
    addResult(report,"core_dense_ten_disc_overlap_relaxes",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id=0,kind="ball",radius=10,invMass=1,damping=0.99,kickable=true})
        for i=1,10 do
            Core.addDisc(w,{id=i,kind="player",x=((i-1)%5)*8-16,y=(i<=5 and -4 or 4),radius=15,invMass=0.5,damping=0.96})
        end
        local initialMax,finalMax=0,0
        local valid=true
        for tick=1,120 do
            Core.stepWorld(w,{})
            local maxOverlap=0
            for i=1,#w.discs-1 do
                for j=i+1,#w.discs do
                    local a,b=w.discs[i],w.discs[j]
                    local overlap=a.radius+b.radius-math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)
                    maxOverlap=math.max(maxOverlap,overlap)
                    valid=valid and finite(a.x) and finite(a.y) and finite(a.vx) and finite(a.vy)
                end
            end
            if tick==1 then initialMax=maxOverlap end
            if tick==120 then finalMax=maxOverlap end
        end
        local ok=valid and initialMax>20 and finalMax<=1e-3
        return {passed=ok,detail=string.format("ticks=120 initialMaxOverlap=%.6f finalMaxOverlap=%.3g finite=%s",initialMax,finalMax,tostring(valid))}
    end)
    addResult(report,"core_replay_deterministic",function()
        local function run()
            local w=Core.newWorld()
            Core.addDisc(w,{id=1,kind="player",x=-30,radius=15,invMass=0.5,damping=0.96,acceleration=0.1})
            Core.addDisc(w,{id=2,kind="ball",radius=10,invMass=1,damping=0.99,kickable=true})
            for tick=1,240 do Core.stepWorld(w,{[1]={x=tick%30<15 and 1 or -1,y=tick%40<20 and 0.5 or -0.5,kick=tick%61==1}}) end
            return Core.snapshot(w)
        end
        local a,b=run(),run()
        local exact=a.tick==b.tick and #a.discs==#b.discs
        for i=1,#a.discs do
            for _,key in ipairs({"x","y","vx","vy"}) do exact=exact and a.discs[i][key]==b.discs[i][key] end
        end
        return {passed=exact,detail=string.format("ticks=%d discs=%d exact=%s",a.tick,#a.discs,tostring(exact))}
    end)
    addResult(report,"core_boundary_clamp_and_bounce",function()
        local w=Core.newWorld({fieldHalfWidth=50,fieldHalfHeight=50})
        Core.addDisc(w,{id=1,kind="ball",x=35,vx=20,radius=10,invMass=1,damping=1,bCoef=0.5})
        Core.stepWorld(w,{})
        local d=w.discs[1]
        return {passed=near(d.x,35,1e-12) and near(d.vx,-10,1e-12),detail=string.format("x=%.3f vx=%.3f",d.x,d.vx)}
    end)
    addResult(report,"core_kick_windup_uses_kick_damping",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id=1,kind="player",radius=15,invMass=1,damping=0.9,kickDamping=0.5,acceleration=0.1,kickAcceleration=0.07})
        Core.addDisc(w,{id=2,kind="ball",x=200,radius=10,invMass=1,damping=1,kickable=true})
        Core.stepWorld(w,{[1]={x=1,y=0,kick=true}})
        local d=w.discById["number:1"]
        return {passed=near(d.x,0.07,1e-12) and near(d.vx,0.035,1e-12),detail=string.format("x=%.3f vx=%.3f",d.x,d.vx)}
    end)
    addResult(report,"core_successful_kick_restores_normal_acceleration",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id=1,kind="player",x=-20,radius=15,invMass=1,damping=0.9,kickDamping=0.5,acceleration=0.1,kickAcceleration=0.07,kickStrength=5})
        Core.addDisc(w,{id=2,kind="ball",radius=10,invMass=1,damping=1,kickable=true})
        Core.stepWorld(w,{[1]={x=1,y=0,kick=true}})
        local p,b=w.discById["number:1"],w.discById["number:2"]
        return {passed=near(p.x,-19.95,1e-12) and near(p.vx,0.09,1e-12) and near(b.vx,5,1e-12),detail=string.format("playerX=%.3f playerVx=%.3f ballVx=%.3f postKickOverlapCorrection=0.050",p.x,p.vx,b.vx)}
    end)
    addResult(report,"core_insertion_order_is_preserved",function()
        local w=Core.newWorld()
        Core.addDisc(w,{id=9,radius=10,invMass=1})
        Core.addDisc(w,{id=1,radius=10,invMass=1})
        Core.addDisc(w,{id=5,radius=10,invMass=1})
        return {passed=w.discs[1].id==9 and w.discs[2].id==1 and w.discs[3].id==5,detail=string.format("ids=%s,%s,%s",tostring(w.discs[1].id),tostring(w.discs[2].id),tostring(w.discs[3].id))}
    end)
    addResult(report,"core_segment_endpoint_cap",function()
        local w=Core.newWorld({useBounds=false})
        Core.addSegment(w,{id="post",x1=-10,y1=0,x2=10,y2=0})
        Core.addDisc(w,{id=1,kind="ball",x=13,radius=10,invMass=1,damping=1})
        Core.stepWorld(w,{})
        local d=w.discById["number:1"]
        local endpointDistance=math.sqrt((d.x-10)^2+d.y^2)
        local event=w.events[1]
        return {passed=near(endpointDistance,10,1e-9) and event and event.kind=="segmentContact",detail=string.format("endpointDistance=%.9f event=%s",endpointDistance,tostring(event and event.kind))}
    end)
    addResult(report,"core_static_plane_contact",function()
        local w=Core.newWorld({useBounds=false})
        Core.addPlane(w,{id="left",normalX=1,normalY=0,offset=-20,bCoef=0.5})
        Core.addDisc(w,{id=1,kind="ball",x=-15,vx=-5,radius=10,invMass=1,damping=1,bCoef=0.5})
        Core.stepWorld(w,{})
        local d=w.discs[1]
        local event=w.events[1]
        return {passed=near(d.x,-10,1e-12) and near(d.vx,1.25,1e-12) and event and event.kind=="planeContact",detail=string.format("x=%.3f vx=%.3f planeEvent=%s",d.x,d.vx,tostring(event and event.kind))}
    end)
    addResult(report,"core_static_segment_contact",function()
        local w=Core.newWorld({useBounds=false})
        Core.addSegment(w,{id="touchline",x1=-10,y1=0,x2=10,y2=0,bCoef=0.5})
        Core.addDisc(w,{id=1,kind="ball",x=0,y=8,vy=-2,radius=10,invMass=1,damping=1,bCoef=0.5})
        Core.stepWorld(w,{})
        local d=w.discs[1]
        local event=w.events[1]
        return {passed=near(d.y,10,1e-12) and near(d.vy,0.5,1e-12) and event and event.kind=="segmentContact",detail=string.format("y=%.3f vy=%.3f segmentEvent=%s",d.y,d.vy,tostring(event and event.kind))}
    end)
    addResult(report,"core_curved_segment_uses_arc_radius",function()
        local w=Core.newWorld({useBounds=false})
        Core.addSegment(w,{id="quarterArc",x1=0,y1=0,x2=10,y2=10,curveDegrees=90,bCoef=0.5})
        local cx,cy=0,10
        local ux,uy=math.sqrt(0.5),-math.sqrt(0.5)
        Core.addDisc(w,{id="testBall",kind="ball",x=cx+ux*11.3,y=cy+uy*11.3,vx=-ux,vy=-uy,radius=1,invMass=1,damping=1,bCoef=0.5})
        Core.stepWorld(w,{})
        local d=w.discById["string:testBall"]
        local radial=math.sqrt((d.x-cx)^2+(d.y-cy)^2)
        local event=w.events[1]
        return {passed=radial>=11-1e-9 and radial<=11.2 and event and event.kind=="segmentContact" and near(d.vx*ux+d.vy*uy,0.25,1e-9),detail=string.format("arcRadius=%.9f outwardSpeed=%.9f event=%s",radial,d.vx*ux+d.vy*uy,tostring(event and event.kind))}
    end)
    addResult(report,"classic_stadium_geometry_and_ball_only_boundary",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id="ball",kind="ball",y=165,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball})
        local counts=ClassicStadium2D.install(Core,w)
        Core.addDisc(w,{id="player",kind="player",y=195,radius=15,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.player})
        Core.stepWorld(w,{})
        local ball=w.discById["string:ball"]
        local player=w.discById["string:player"]
        local ballAreaHit,outerPlayerHit=false,false
        for _,event in ipairs(w.events) do
            if event.kind=="planeContact" and event.geometryId=="classic:ballArea:top" then ballAreaHit=true end
            if event.kind=="planeContact" and event.geometryId=="classic:outer:top" and event.discId=="player" then outerPlayerHit=true end
        end
        local ok=counts.planes==6 and counts.segments==14 and counts.posts==4 and #w.discs==6 and near(ball.y,160,1e-9) and near(player.y,185,1e-9) and ballAreaHit and outerPlayerHit
        return {passed=ok,detail=string.format("planes=%d segments=%d posts=%d ballY=%.3f playerY=%.3f ballArea=%s outerPlayer=%s",counts.planes,counts.segments,counts.posts,ball.y,player.y,tostring(ballAreaHit),tostring(outerPlayerHit))}
    end)
    addResult(report,"classic_goal_mouth_ball_hits_net_without_tunneling",function()
        local w=Core.newWorld({useBounds=false})
        local ball=Core.addDisc(w,{id="ball",kind="ball",x=350,y=0,vx=20,radius=10,invMass=1,damping=0.99,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball})
        ClassicStadium2D.install(Core,w)
        local contactTick,contactX,contactVx,contactSubsteps
        for tick=1,5 do
            local _,events=Core.stepWorld(w,{})
            for _,event in ipairs(events) do
                if event.kind=="segmentContact" and event.geometryId=="classic:goalNet:right:back" then
                    contactTick,contactX,contactVx,contactSubsteps=tick,ball.x,ball.vx,w.lastSubsteps
                end
            end
        end
        local ok=contactTick==3 and contactVx<0 and contactX<400 and contactX>370 and contactSubsteps>=4 and finite(ball.x) and finite(ball.vx)
        return {passed=ok,detail=string.format("contactTick=%s contactX=%.6f contactVx=%.6f finalX=%.6f finalVx=%.6f contactSubsteps=%s",tostring(contactTick),contactX or -1,contactVx or -1,ball.x,ball.vx,tostring(contactSubsteps))}
    end)
    addResult(report,"classic_field_trace_detects_goal_crossing",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id="ball",kind="ball",x=340,y=0,vx=12,radius=10,invMass=1,damping=0.99,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball,traceMotion=true})
        ClassicStadium2D.install(Core,w)
        local goal
        for tick=1,5 do
            Core.stepWorld(w,{})
            goal=MatchRules2D.findGoalCrossing(w.motionSegments,"ball")
            if goal then goal.tick=tick;break end
        end
        return {passed=goal~=nil and goal.tick==3 and goal.side=="right" and goal.team=="red" and math.abs(goal.y)<64,detail=string.format("goal=%s side=%s team=%s y=%.3f",tostring(goal~=nil),goal and goal.side or "-",goal and goal.team or "-",goal and goal.y or -999)}
    end)
    addResult(report,"classic_goalpost_collides_with_player",function()
        local w=Core.newWorld({useBounds=false})
        Core.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=1,collisionGroup=ClassicStadium2D.Groups.ball})
        ClassicStadium2D.install(Core,w)
        Core.addDisc(w,{id="player",kind="player",x=-356,y=64,vx=-1,radius=15,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.player})
        Core.stepWorld(w,{})
        local player=w.discById["string:player"]
        local post=w.discById["string:classic:post:left:upper"]
        local distance=math.sqrt((player.x-post.x)^2+(player.y-post.y)^2)
        local found=false
        for _,event in ipairs(w.events) do if event.kind=="discContact" and (event.discA=="player" or event.discB=="player") then found=true end end
        return {passed=found and near(distance,23,1e-9) and player.vx>0,detail=string.format("playerPostDistance=%.9f bounced=%s",distance,tostring(player.vx>0))}
    end)
    addResult(report,"goal_crossing_awards_opposite_team_and_interpolates",function()
        local right=MatchRules2D.findGoalCrossing({{discId="ball",x0=368,y0=-10,x1=372,y1=10,substep=2,substeps=3}})
        local left=MatchRules2D.findGoalCrossing({{discId="ball",x0=-368,y0=0,x1=-372,y1=0,substep=1,substeps=2}})
        local outside=MatchRules2D.findGoalCrossing({{discId="ball",x0=368,y0=70,x1=372,y1=70,substep=1,substeps=1}})
        local ok=right and right.team=="red" and right.side=="right" and near(right.y,0,1e-12) and left and left.team=="blue" and left.side=="left" and outside==nil
        return {passed=ok,detail=string.format("right=%s/%s y=%.3f left=%s/%s outside=%s",right and right.side or "-",right and right.team or "-",right and right.y or -999,left and left.side or "-",left and left.team or "-",tostring(outside~=nil))}
    end)
    addResult(report,"goal_pause_resets_ball_and_ten_player_positions",function()
        local match=MatchRules2D.newMatch()
        local score={red=0,blue=0}
        local ball={x=371,y=3,vx=8,vy=2}
        local players={}
        local spawns={}
        for i=1,10 do
            players[i]={x=i*3,y=-i,vx=1,vy=2,kickHeld=true,kickArmed=true,kickCooldown=4}
            spawns[i]={x=(i<=5 and -100 or 100),y=(i-1)*4}
        end
        MatchRules2D.beginGoalPause(match,score,{team="red",side="right",x=370,y=3,tick=7},ball,players,2)
        local paused=match.phase=="goalPause" and score.red==1 and ball.vx==0 and players[1].vx==0
        local doneEarly=MatchRules2D.advancePause(match)
        local ready=MatchRules2D.advancePause(match)
        MatchRules2D.resetKickoff(ball,players,spawns)
        MatchRules2D.resume(match)
        local exact=ball.x==0 and ball.y==0 and players[10].x==100 and players[10].y==36 and players[10].kickArmed==false and players[10].kickCooldown==0
        return {passed=paused and not doneEarly and ready and exact and match.phase=="playing" and score.red==1,detail=string.format("phase=%s redScore=%d pauseComplete=%s resetAllTen=%s",match.phase,score.red,tostring(ready),tostring(exact))}
    end)
    addResult(report,"kickoff_countdown_locks_until_complete",function()
        local match=MatchRules2D.newMatch()
        match.phase="goalPause"
        MatchRules2D.beginKickoff(match,"blue",2)
        local firstDone=MatchRules2D.advanceKickoff(match)
        local stillLocked=match.phase=="kickoff" and match.remainingTicks==1 and match.kickoffTeam=="blue"
        local done=MatchRules2D.advanceKickoff(match)
        MatchRules2D.resume(match)
        local wrongTeam=MatchRules2D.completeKickoff(match,"red")
        local assignmentPreserved=match.kickoffTeam=="blue"
        local correctTeam=MatchRules2D.completeKickoff(match,"blue")
        local ok=not firstDone and stillLocked and done and match.phase=="playing" and assignmentPreserved and not wrongTeam and correctTeam and match.kickoffTeam==nil
        return {passed=ok,detail=string.format("phase=%s countdownComplete=%s wrongTeamRejected=%s correctTeamAccepted=%s",match.phase,tostring(done),tostring(not wrongTeam),tostring(correctTeam))}
    end)
    addResult(report,"micro_prediction_uses_fixed_tick_player_kinematics",function()
        local predicted=PredictionLab2D.predict({x=0,y=0,vx=0,vy=0},{x=1,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=0.96,kickDamping=0.96},2)
        return {passed=near(predicted.x,0.296,1e-12) and near(predicted.vx,0.18816,1e-12) and #predicted.path==2,detail=string.format("ticks=%d x=%.6f vx=%.6f",predicted.ticks,predicted.x,predicted.vx)}
    end)
    addResult(report,"micro_prediction_forecasts_ball_contact_without_applying_it",function()
        local predicted=PredictionLab2D.predict({x=-30,y=0,vx=4,vy=0},{x=0,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=1,kickDamping=1},2)
        local contact=PredictionLab2D.firstContact(predicted.path,15,{{id="ball",kind="ball",x=0,y=0,radius=10}})
        return {passed=contact~=nil and contact.kind=="ball" and contact.tick==2 and predicted.x==-22,detail=string.format("forecast=%s tick=%s predictedX=%.3f",tostring(contact and contact.kind),tostring(contact and contact.tick),predicted.x)}
    end)
    addResult(report,"last_touch_records_physical_actor_and_overwrites_in_event_order",function()
        local match=MatchRules2D.newMatch()
        local first=MatchRules2D.recordTouch(match,2,"red",10,"contact")
        local second=MatchRules2D.recordTouch(match,7,"blue",10,"kick")
        local invalid=MatchRules2D.recordTouch(match,11,"green",11,"contact")
        local ok=first and second and not invalid and match.lastTouch.playerId==7 and match.lastTouch.team=="blue" and match.lastTouch.tick==10 and match.lastTouch.kind=="kick"
        return {passed=ok,detail=string.format("actor=%s team=%s tick=%s kind=%s invalidRejected=%s",tostring(match.lastTouch and match.lastTouch.playerId),tostring(match.lastTouch and match.lastTouch.team),tostring(match.lastTouch and match.lastTouch.tick),tostring(match.lastTouch and match.lastTouch.kind),tostring(not invalid))}
    end)
    addResult(report,"kickoff_rejects_wrong_team_kick_only",function()
        local match=MatchRules2D.newMatch()
        match.phase="playing"
        match.kickoffTeam="blue"
        local redInput,redBlocked=MatchRules2D.filterKickoffInput(match,"red",{x=1,y=0,kick=true})
        local blueInput,blueBlocked=MatchRules2D.filterKickoffInput(match,"blue",{x=-1,y=0,kick=true})
        local redMask=MatchRules2D.kickoffCollisionMask(match,"red",0xFFFFFFFF,2)
        local blueMask=MatchRules2D.kickoffCollisionMask(match,"blue",0xFFFFFFFF,2)
        local redBallCollision=bit32.band(redMask,2)~=0
        local blueBallCollision=bit32.band(blueMask,2)~=0
        local ok=redBlocked and redInput.kick==false and redInput.x==1 and not blueBlocked and blueInput.kick==true and redBallCollision and blueBallCollision
        return {passed=ok,detail=string.format("opponentKickInputBlocked=%s assignedKickAllowed=%s movementPreserved=%s redBallCollision=%s blueBallCollision=%s",tostring(redBlocked and not redInput.kick),tostring(not blueBlocked and blueInput.kick),tostring(redInput.x==1),tostring(redBallCollision),tostring(blueBallCollision))}
    end)
    addResult(report,"core_rejects_nonfinite_specs",function()
        local ok=pcall(function() Core.newDisc({id=1,x=0/0,radius=10,invMass=1}) end)
        return {passed=not ok,detail="NaN spec rejected="..tostring(not ok)}
    end)

    addResult(report,"classic_reference_profile_is_frozen_and_complete",function()
        local w=Core.newWorld({useBounds=false})
        local counts=ClassicStadium2D.install(Core,w)
        local ok=StadiumProfile2D.Metadata.sourceCommit=="4b9724f49fe0ff87ad3f111eb91b208020d96d73" and counts.planes==6 and counts.segments==14 and counts.posts==4 and StadiumProfile2D.Bounds.spanWidth==840 and StadiumProfile2D.Bounds.spanHeight==400 and StadiumProfile2D.PlayArea.width==740 and StadiumProfile2D.PlayArea.height==340
        return {passed=ok,detail=string.format("commit=%s geometry=%d/%d/%d bounds=%dx%d playable=%dx%d",StadiumProfile2D.Metadata.sourceCommit,counts.planes,counts.segments,counts.posts,StadiumProfile2D.Bounds.spanWidth,StadiumProfile2D.Bounds.spanHeight,StadiumProfile2D.PlayArea.width,StadiumProfile2D.PlayArea.height)}
    end)
    addResult(report,"classic_kickoff_collision_masks_select_reference_arc",function()
        local flags=StadiumProfile2D.CollisionGroups
        local base=StadiumProfile2D.CollisionMasks.player
        local match=MatchRules2D.newMatch();match.phase="kickoff";match.kickoffTeam="red"
        local redMask=MatchRules2D.kickoffCollisionMask(match,"red",base,flags.ball)
        local blueMask=MatchRules2D.kickoffCollisionMask(match,"blue",base,flags.ball)
        local redKickoff=bit32.band(redMask,flags.redKO)~=0 and bit32.band(redMask,flags.blueKO)==0
        local blueDuringRed=bit32.band(blueMask,flags.redKO)~=0 and bit32.band(blueMask,flags.blueKO)==0 and bit32.band(blueMask,flags.ball)~=0
        match.kickoffTeam="blue"
        local blueKickoffMask=MatchRules2D.kickoffCollisionMask(match,"blue",base,flags.ball)
        local blueKickoff=bit32.band(blueKickoffMask,flags.blueKO)~=0 and bit32.band(blueKickoffMask,flags.ball)~=0
        local redDuringBlueMask=MatchRules2D.kickoffCollisionMask(match,"red",base,flags.ball)
        local redDuringBlue=bit32.band(redDuringBlueMask,flags.blueKO)~=0 and bit32.band(redDuringBlueMask,flags.ball)~=0
        return {passed=redKickoff and blueDuringRed and blueKickoff and redDuringBlue,detail=string.format("redKOActive=%s blueDuringRedHasBall=%s blueKOActive=%s redDuringBlueHasBall=%s",tostring(redKickoff),tostring(blueDuringRed),tostring(blueKickoff),tostring(redDuringBlue))}
    end)

    addResult(report,"classic_pinned_hbs_geometry_values",function()
        local p=StadiumProfile2D
        local plane=p.Geometry.planes
        local seg=p.Geometry.segments
        local redArc,blueArc
        for _,s in ipairs(seg) do
            if s.id=="classic:kickoff:circleRedKO" then redArc=s end
            if s.id=="classic:kickoff:circleBlueKO" then blueArc=s end
        end
        local ok=p.StadiumProperties.width==420 and p.StadiumProperties.height==200 and p.StadiumProperties.spawnDistance==170
            and p.StadiumProperties.bg.width==370 and p.StadiumProperties.bg.height==170 and p.StadiumProperties.bg.kickOffRadius==75
            and plane[1].id=="classic:ballArea:bottom" and plane[1].normalY==1 and plane[1].offset==-170 and plane[1].bCoef==1 and plane[1].collisionMask==p.CollisionGroups.ball
            and plane[3].id=="classic:outer:bottom" and plane[3].normalY==1 and plane[3].offset==-200 and plane[3].bCoef==0.1
            and plane[5].id=="classic:outer:left" and plane[5].normalX==1 and plane[5].offset==-420 and plane[5].bCoef==0.1
            and seg[1].x1==-370 and seg[1].y1==170 and seg[1].x2==-370 and seg[1].y2==64 and seg[1].collisionMask==p.CollisionGroups.ball
            and seg[5].x1==-380 and seg[5].y1==-64 and seg[5].x2==-400 and seg[5].y2==-44 and seg[5].curveDegrees==-90
            and seg[7].curveDegrees==-90 and seg[7].collisionMask==p.CollisionGroups.ball
            and seg[11].x1==0 and seg[11].y1==200 and seg[11].x2==0 and seg[11].y2==75 and seg[11].collisionGroup==p.CollisionGroups.kickoffBarrier
            and redArc and redArc.curveDegrees==-180 and redArc.collisionGroup==p.CollisionGroups.redKO and redArc.collisionMask==p.CollisionMasks.kickoffBarrier
            and blueArc and blueArc.curveDegrees==180 and blueArc.collisionGroup==p.CollisionGroups.blueKO and blueArc.collisionMask==p.CollisionMasks.kickoffBarrier
            and p.Geometry.posts[1].x==-370 and p.Geometry.posts[1].y==64 and p.Geometry.posts[1].radius==8 and p.Geometry.posts[1].bCoef==0.5
            and p.Goals.leftX==-370 and p.Goals.rightX==370 and p.Goals.halfHeight==64
        return {passed=ok,detail=string.format("frozen HBS values checked: properties, planes, net arcs, kickoff arcs, posts and goal lines; redArc=%s blueArc=%s",tostring(redArc and redArc.curveDegrees),tostring(blueArc and blueArc.curveDegrees))}
    end)
    addResult(report,"classic_collision_matrix_matches_hbs_flags",function()
        local f=StadiumProfile2D.CollisionGroups
        local masks=StadiumProfile2D.CollisionMasks
        local function can(aGroup,aMask,bGroup,bMask)
            return bit32.band(aGroup,bMask)~=0 and bit32.band(bGroup,aMask)~=0
        end
        local ballGroup,ballMask=f.ball,masks.all
        local playerMask=masks.player
        local wallGroup,wallMask=f.wall,masks.all
        local postGroup,postMask=f.post,masks.all
        local barrierGroup,barrierMask=f.kickoffBarrier,masks.kickoffBarrier
        local redKOmask=bit32.bor(playerMask,f.redKO)
        local blueKOmask=bit32.bor(playerMask,f.blueKO)
        local ok=can(f.red,playerMask,ballGroup,ballMask) and can(f.blue,playerMask,ballGroup,ballMask)
            and can(f.red,playerMask,f.blue,playerMask)
            and can(f.red,playerMask,wallGroup,wallMask) and can(f.blue,playerMask,postGroup,postMask)
            and can(ballGroup,ballMask,wallGroup,wallMask) and can(ballGroup,ballMask,postGroup,postMask)
            and not can(f.red,playerMask,barrierGroup,barrierMask)
            and can(f.red,redKOmask,barrierGroup,barrierMask) and can(f.blue,blueKOmask,barrierGroup,barrierMask)
            and not can(ballGroup,ballMask,barrierGroup,barrierMask)
        return {passed=ok,detail=string.format("red/blue-ball, red-blue, player-wall/post, ball-wall/post and kickoff off/on compatibility verified; postMask=%d",postMask)}
    end)
    addResult(report,"classic_wall_and_post_ball_response",function()
        local w=Core.newWorld({useBounds=false})
        local ball=Core.addDisc(w,{id="ball",kind="ball",x=-355,y=64,vx=-2,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=StadiumProfile2D.CollisionGroups.ball})
        ClassicStadium2D.install(Core,w)
        Core.stepWorld(w,{})
        local post=w.discById["string:classic:post:left:upper"]
        local postEvent=false
        for _,event in ipairs(w.events) do
            if event.kind=="discContact" and (event.discA=="ball" or event.discB=="ball") then postEvent=true end
        end
        local postDistance=math.sqrt((ball.x-post.x)^2+(ball.y-post.y)^2)
        local wallWorld=Core.newWorld({useBounds=false})
        local wallBall=Core.addDisc(wallWorld,{id="wallBall",kind="ball",y=165,vy=2,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=StadiumProfile2D.CollisionGroups.ball})
        ClassicStadium2D.install(Core,wallWorld)
        Core.stepWorld(wallWorld,{})
        local wallEvent=false
        for _,event in ipairs(wallWorld.events) do
            if event.kind=="planeContact" and event.geometryId=="classic:ballArea:top" then wallEvent=true end
        end
        local ok=post.invMass==0 and post.radius==8 and post.bCoef==0.5 and post.collisionMask==StadiumProfile2D.CollisionMasks.all
            and postEvent and postDistance>=18-1e-9 and ball.vx>0 and wallEvent and wallBall.y<=160+1e-9 and wallBall.vy<0
        return {passed=ok,detail=string.format("postDistance=%.6f ballVx=%.6f wallY=%.6f wallVy=%.6f postContact=%s wallContact=%s",postDistance,ball.vx,wallBall.y,wallBall.vy,tostring(postEvent),tostring(wallEvent))}
    end)
    addResult(report,"classic_kickoff_arc_contacts_both_teams_and_deactivates",function()
        local CoreLocal=Core
        local function run(team,kickoffActive)
            local w=CoreLocal.newWorld({useBounds=false,maxSubsteps=128})
            CoreLocal.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=1,collisionGroup=StadiumProfile2D.CollisionGroups.ball,collisionMask=StadiumProfile2D.CollisionMasks.all})
            ClassicStadium2D.install(CoreLocal,w)
            local match=MatchRules2D.newMatch()
            match.phase=kickoffActive and "kickoff" or "playing"
            match.kickoffTeam=kickoffActive and team or nil
            local x,vx=team=="red" and 100 or -100,team=="red" and -20 or 20
            local mask=MatchRules2D.kickoffCollisionMask(match,team,StadiumProfile2D.CollisionMasks.player,StadiumProfile2D.CollisionGroups.ball)
            local group=team=="red" and StadiumProfile2D.CollisionGroups.red or StadiumProfile2D.CollisionGroups.blue
            local player=CoreLocal.addDisc(w,{id="player",kind="player",team=team,x=x,y=0,vx=vx,radius=15,invMass=0.5,damping=1,bCoef=0.5,collisionGroup=group,collisionMask=mask})
            local hit
            for _=1,5 do
                CoreLocal.stepWorld(w,{})
                for _,event in ipairs(w.events) do
                    if event.kind=="segmentContact" and string.find(event.geometryId,"kickoff:circle") then hit=event.geometryId end
                end
            end
            return {hit=hit,mask=mask,vx=player.vx}
        end
        local redOn=run("red",true)
        local blueOn=run("blue",true)
        local redOff=run("red",false)
        local blueOff=run("blue",false)
        local ok=redOn.hit=="classic:kickoff:circleRedKO" and blueOn.hit=="classic:kickoff:circleBlueKO"
            and redOn.mask==47 and blueOn.mask==55 and redOn.vx>0 and blueOn.vx<0
            and redOff.hit==nil and blueOff.hit==nil and redOff.mask==39 and blueOff.mask==39
        return {passed=ok,detail=string.format("redOn=%s redMask=%d blueOn=%s blueMask=%d offHits=%s/%s",tostring(redOn.hit),redOn.mask,tostring(blueOn.hit),blueOn.mask,tostring(redOff.hit),tostring(blueOff.hit))}
    end)
    addResult(report,"classic_goal_line_edge_and_duplicate_guard",function()
        local inside=MatchRules2D.findGoalCrossing({{discId="ball",x0=369,y0=63.9,x1=371,y1=63.9}})
        local outside=MatchRules2D.findGoalCrossing({{discId="ball",x0=369,y0=64.1,x1=371,y1=64.1}})
        local reverse=MatchRules2D.findGoalCrossing({{discId="ball",x0=371,y0=0,x1=369,y1=0}})
        local match=MatchRules2D.newMatch()
        local score={red=0,blue=0}
        MatchRules2D.beginGoalPause(match,score,{team=inside and inside.team,side=inside and inside.side,x=inside and inside.x,y=inside and inside.y}, {vx=0,vy=0}, {}, 2)
        local duplicateOk=not pcall(function()
            MatchRules2D.beginGoalPause(match,score,{team=inside.team,side=inside.side,x=inside.x,y=inside.y},{vx=0,vy=0},{},2)
        end)
        local ok=inside~=nil and inside.team=="red" and outside==nil and reverse==nil and duplicateOk and score.red==1 and score.blue==0
        return {passed=ok,detail=string.format("insideY=%.1f scores=%s outsideRejected=%s reverseRejected=%s duplicateRejected=%s",inside and inside.y or -999,tostring(inside~=nil),tostring(outside==nil),tostring(reverse==nil),tostring(duplicateOk))}
    end)
    report.passed=0
    report.failed=0
    for _,test in ipairs(report.tests) do
        if test.passed then report.passed+=1 else report.failed+=1 end
    end
    report.total=#report.tests
    report.allPassed=report.failed==0
    return report
end

return Suite
