local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local lab=ReplicatedStorage:WaitForChild("HaxballLab")
local remotes=lab.Remotes
local inputRemote=remotes.Input
local snapshotRemote=remotes.Snapshot
local commandRemote=remotes.DebugCommand
local PredictionLab2D=require(lab:WaitForChild("PredictionLab2D"))
local StadiumProfile2D=require(lab:WaitForChild("StadiumReference2D"))
local inputContext=ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("HaxballGameplay")
local moveAction=inputContext:WaitForChild("Move")
local kickAction=inputContext:WaitForChild("Kick")
local field=workspace:WaitForChild("HaxballLab")
local playerDisc=field:WaitForChild("PlayerDisc")
local playerDisc2=field:WaitForChild("PlayerDisc2")
local ballDisc=field:WaitForChild("BallDisc")
local debugLine=field:WaitForChild("DebugLine")
local pairDebugLine=field:WaitForChild("PairDebugLine")
local ballP2DebugLine=field:WaitForChild("BallP2DebugLine")

local playerVisuals={[1]=playerDisc,[2]=playerDisc2}
for playerId=3,10 do
    local visual=Instance.new("Part")
    visual.Name="PlayerDisc"..playerId
    visual.Shape=Enum.PartType.Ball
    visual.Size=playerDisc.Size
    visual.Anchored=true
    visual.CanCollide=false
    visual.CanTouch=false
    visual.CanQuery=false
    visual.CastShadow=false
    visual.Material=playerDisc.Material
    visual.Parent=field
    playerVisuals[playerId]=visual
end
local predictionGhost=Instance.new("Part")
predictionGhost.Name="PredictionGhost"
predictionGhost.Shape=Enum.PartType.Ball
predictionGhost.Size=playerDisc.Size
predictionGhost.Anchored=true
predictionGhost.CanCollide=false
predictionGhost.CanTouch=false
predictionGhost.CanQuery=false
predictionGhost.CastShadow=false
predictionGhost.Material=Enum.Material.Neon
predictionGhost.Color=Color3.fromRGB(255,220,70)
predictionGhost.Transparency=1
predictionGhost.Parent=field

local Presentation=StadiumProfile2D.Presentation
local SCALE=Presentation.studsPerUnit
local function toWorld(logicalX,logicalY)
    local origin=Presentation.logicalOrigin
    local worldOrigin=Presentation.worldOrigin
    local visualY=Presentation.invertLogicalY and -1 or 1
    return Vector3.new(worldOrigin.x+(logicalX-origin.x)*SCALE,Presentation.floorY,worldOrigin.z+visualY*(logicalY-origin.y)*SCALE)
end
camera.CameraType=Enum.CameraType.Scriptable
camera.CFrame=CFrame.new(0,340,0)*CFrame.Angles(-math.pi/2,0,0)
camera.FieldOfView=35

local gui=Instance.new("ScreenGui")
gui.Name="HaxballLabDebug"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel")
label.Size=UDim2.fromOffset(500,190)
label.Position=UDim2.fromOffset(14,14)
label.BackgroundTransparency=0.18
label.BackgroundColor3=Color3.fromRGB(15,20,25)
label.TextColor3=Color3.new(1,1,1)
label.Font=Enum.Font.Code
label.TextSize=14
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Top
label.Text="Haxball lab | WASD move | X kick"
label.Parent=gui
local predictionLabel=Instance.new("TextLabel")
predictionLabel.Name="NetworkPredictionDebug"
predictionLabel.Size=UDim2.fromOffset(370,72)
predictionLabel.Position=UDim2.new(1,-384,0,14)
predictionLabel.BackgroundTransparency=0.18
predictionLabel.BackgroundColor3=Color3.fromRGB(15,20,25)
predictionLabel.TextColor3=Color3.fromRGB(255,235,150)
predictionLabel.Font=Enum.Font.Code
predictionLabel.TextSize=13
predictionLabel.TextXAlignment=Enum.TextXAlignment.Left
predictionLabel.TextYAlignment=Enum.TextYAlignment.Top
predictionLabel.TextWrapped=true
predictionLabel.Text="Predicción experimental | input delay 0 ms"
predictionLabel.Parent=gui
local calibrationLabel=Instance.new("TextLabel")
calibrationLabel.Name="StadiumCalibrationDebug"
calibrationLabel.Size=UDim2.fromOffset(760,82)
calibrationLabel.Position=UDim2.fromOffset(14,466)
calibrationLabel.BackgroundTransparency=0.18
calibrationLabel.BackgroundColor3=Color3.fromRGB(15,20,25)
calibrationLabel.TextColor3=Color3.fromRGB(190,225,255)
calibrationLabel.Font=Enum.Font.Code
calibrationLabel.TextSize=12
calibrationLabel.TextXAlignment=Enum.TextXAlignment.Left
calibrationLabel.TextYAlignment=Enum.TextYAlignment.Top
calibrationLabel.TextWrapped=true
local meta=StadiumProfile2D.Metadata
local bounds=StadiumProfile2D.Bounds
local playArea=StadiumProfile2D.PlayArea
local goals=StadiumProfile2D.Goals
local activePhysics=StadiumProfile2D.PhysicsBaseline.active
local replayPhysics=StadiumProfile2D.PhysicsBaseline.replayCandidate
calibrationLabel.Text=string.format("REFERENCE %s | HBS %s\nLogical %dx%d | play area %dx%d | goal opening %d | geometry 6P/14S/4D\nVisual %.2f studs/unit only | player values match independent replay candidate\nBall active vs replay Small: invMass %.2f/%.2f, bounce %.2f/%.2f | official comparison pending",meta.name,string.sub(meta.sourceCommit,1,12),bounds.spanWidth,bounds.spanHeight,playArea.width,playArea.height,goals.openingWidth,SCALE,activePhysics.ball.invMass,replayPhysics.ball.invMass,activePhysics.ball.bounce,replayPhysics.ball.bounce)
calibrationLabel.Parent=gui

local function makeButton(name,text,x,width,y)
    local button=Instance.new("TextButton")
    button.Name=name
    button.Size=UDim2.fromOffset(width,30)
    button.Position=UDim2.fromOffset(x,y)
    button.BackgroundColor3=Color3.fromRGB(35,55,70)
    button.TextColor3=Color3.new(1,1,1)
    button.Font=Enum.Font.GothamMedium
    button.TextSize=13
    button.Text=text
    button.Parent=gui
    return button
end
local resetButton=makeButton("ResetScenario","Reiniciar",14,92,212)
local kickSetupButton=makeButton("KickScenario","Preparar patada",112,122,212)
local wallSetupButton=makeButton("WallScenario","Probar pared",240,102,212)
local recordButton=makeButton("RecordingToggle","Pausar registro",348,120,212)
local headOnButton=makeButton("PairHeadOn","Choque frontal",14,132,248)
local obliqueButton=makeButton("PairOblique","Choque oblicuo",152,132,248)
local overlapButton=makeButton("PairOverlap","Centros coincidentes",290,178,248)
local crowdOverlapButton=makeButton("CrowdOverlap","Trío solapado",14,132,284)
local crowdApproachButton=makeButton("CrowdApproach","Dos al balón",152,132,284)
local fastCrossingButton=makeButton("FastCrossing","Cruce rápido",290,132,284)
local fastBallButton=makeButton("FastBall","Jugador-balón rápido",14,142,320)
local speedRunButton=makeButton("SpeedRun","Velocidad constante",14,152,356)
local regressionButton=makeButton("RegressionSuite","Ejecutar pruebas",174,160,356)
local fastDiagonalButton=makeButton("FastDiagonal","Diagonal rápida",162,132,320)
local multiWallButton=makeButton("MultiWall","Rebotes múltiples",300,160,320)
local goalTestButton=makeButton("GoalTest","Tiro a gol",14,120,392)
local latencyButtons={}
for index,delayMs in ipairs({0,50,100,150,200,300,500}) do
    latencyButtons[delayMs]=makeButton("InputDelay"..delayMs,delayMs==0 and "Delay 0" or (tostring(delayMs).." ms"),14+(index-1)*70,66,428)
end
resetButton.Activated:Connect(function() commandRemote:FireServer("reset") end)
kickSetupButton.Activated:Connect(function() commandRemote:FireServer("setupKick") end)
wallSetupButton.Activated:Connect(function() commandRemote:FireServer("setupWall") end)
recordButton.Activated:Connect(function() commandRemote:FireServer("toggleRecording") end)
headOnButton.Activated:Connect(function() commandRemote:FireServer("setupPairHeadOn") end)
obliqueButton.Activated:Connect(function() commandRemote:FireServer("setupPairOblique") end)
overlapButton.Activated:Connect(function() commandRemote:FireServer("setupPairOverlap") end)
crowdOverlapButton.Activated:Connect(function() commandRemote:FireServer("setupCrowdOverlap") end)
crowdApproachButton.Activated:Connect(function() commandRemote:FireServer("setupCrowdApproach") end)
fastCrossingButton.Activated:Connect(function() commandRemote:FireServer("setupPairFastCrossing") end)
fastBallButton.Activated:Connect(function() commandRemote:FireServer("setupBallFastCrossing") end)
speedRunButton.Activated:Connect(function() commandRemote:FireServer("setupSpeedRun") end)
regressionButton.Activated:Connect(function() commandRemote:FireServer("runRegressionSuite") end)
fastDiagonalButton.Activated:Connect(function() commandRemote:FireServer("setupBallFastDiagonal") end)
multiWallButton.Activated:Connect(function() commandRemote:FireServer("setupMultiWall") end)
goalTestButton.Activated:Connect(function() commandRemote:FireServer("setupGoalTest") end)

local latest,previous
local snapshotAge=0
local lastSentX,lastSentY,lastSentKick=0,0,false
local syntheticInputDelayMs=0
local delayedInputQueue={}
local function setSyntheticInputDelay(delayMs)
    syntheticInputDelayMs=delayMs
    table.clear(delayedInputQueue)
    lastSentX,lastSentY,lastSentKick=nil,nil,nil
    for value,button in pairs(latencyButtons) do
        button.BackgroundColor3=value==delayMs and Color3.fromRGB(130,95,30) or Color3.fromRGB(35,55,70)
    end
end
for delayMs,button in pairs(latencyButtons) do
    button.Activated:Connect(function() setSyntheticInputDelay(delayMs) end)
end
local function readAction(action,fallback)
    local ok,value=pcall(function() return action:GetState() end)
    if not ok then return fallback end
    if typeof(value)=="Vector2" or typeof(value)=="boolean" then return value end
    if type(value)=="table" and value.Value~=nil then return value.Value end
    return fallback
end
snapshotRemote.OnClientEvent:Connect(function(s)
    previous,latest=latest,s
    snapshotAge=0
end)

local function renderLine(part,a,b,color,visible)
    local delta=b-a
    local length=delta.Magnitude
    part.Transparency=visible and 0.2 or 1
    if visible and length>0.05 then
        part.Size=Vector3.new(.18,.18,length)
        part.CFrame=CFrame.lookAt((a+b)*.5,b)
        part.Color=color
    end
end

RunService.RenderStepped:Connect(function(dt)
    snapshotAge+=dt
    local move=readAction(moveAction,Vector2.zero)
    if typeof(move)~="Vector2" then move=Vector2.zero end
    local kick=readAction(kickAction,false)==true
    local now=os.clock()
    if move.X~=lastSentX or move.Y~=lastSentY or kick~=lastSentKick then
        lastSentX,lastSentY,lastSentKick=move.X,move.Y,kick
        local packet={x=move.X,y=move.Y,kick=kick}
        if syntheticInputDelayMs<=0 then
            inputRemote:FireServer(packet.x,packet.y,packet.kick)
        else
            table.insert(delayedInputQueue,{due=now+syntheticInputDelayMs/1000,packet=packet})
        end
    end
    while delayedInputQueue[1] and delayedInputQueue[1].due<=now do
        local queued=table.remove(delayedInputQueue,1).packet
        inputRemote:FireServer(queued.x,queued.y,queued.kick)
    end
    if not latest then return end

    local predictedState,predictedContact
    local predictionTicks=math.clamp(math.ceil(syntheticInputDelayMs*60/1000),0,24)
    if syntheticInputDelayMs>0 and latest.coreMode and latest.matchPhase=="playing" and latest.predictionParams then
        predictedState=PredictionLab2D.predict(latest.player,{x=move.X,y=move.Y,kick=kick},latest.predictionParams,predictionTicks)
        local targets={}
        for _,disc in ipairs(latest.players or {}) do
            if disc.playerId~=1 then table.insert(targets,{id=disc.playerId,kind="player",x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy,radius=disc.radius}) end
        end
        table.insert(targets,{id="ball",kind="ball",x=latest.ball.x,y=latest.ball.y,vx=latest.ball.vx,vy=latest.ball.vy,radius=latest.ball.radius})
        predictedContact=PredictionLab2D.firstContact(predictedState.path,latest.player.radius or 15,targets)
        local lead=math.sqrt((predictedState.x-latest.player.x)^2+(predictedState.y-latest.player.y)^2)
        local forecast=predictedContact and string.format("%s %s in %d ticks",predictedContact.kind=="ball" and "BALL" or "PLAYER",tostring(predictedContact.targetId),predictedContact.tick) or "no predicted contact"
        predictionGhost.Position=toWorld(predictedState.x,predictedState.y)
        predictionGhost.Transparency=0.38
        predictionLabel.Text=string.format("SIMULATED INPUT DELAY %d ms | horizon %d ticks\nGhost lead %.2f units | ball gap %.2f\nForecast: %s | server touch now: %s",syntheticInputDelayMs,predictionTicks,lead,latest.separation,forecast,tostring(latest.touchingBall))
    else
        predictionGhost.Transparency=1
        predictionLabel.Text=syntheticInputDelayMs>0 and string.format("Input delay %d ms | prediction active in 5v5 core only",syntheticInputDelayMs) or "Predicción experimental | input delay 0 ms"
    end

    local alpha=math.clamp(snapshotAge*60,0,1)
    local a=previous and previous.tick<latest.tick and previous or latest
    local function lerp(disc,axis)
        return a[disc][axis]+(latest[disc][axis]-a[disc][axis])*alpha
    end
    local p1=toWorld(lerp("player","x"),lerp("player","y"))
    local p2=toWorld(lerp("player2","x"),lerp("player2","y"))
    local ball=toWorld(lerp("ball","x"),lerp("ball","y"))
    playerDisc.Position=p1
    playerDisc2.Position=p2
    local extraDiscMode=latest.pairMode or latest.crowdMode
    if latest.players and #latest.players>0 then
        for slot,disc in ipairs(latest.players) do
            local previousDisc=a.players and a.players[slot]
            local px=previousDisc and (previousDisc.x+(disc.x-previousDisc.x)*alpha) or disc.x
            local py=previousDisc and (previousDisc.y+(disc.y-previousDisc.y)*alpha) or disc.y
            local visual=playerVisuals[slot]
            if visual then
                visual.Position=toWorld(px,py)
                visual.Transparency=0
                visual.Color=disc.team=="red" and Color3.fromRGB(238,90,80) or Color3.fromRGB(75,155,255)
            end
        end
        for slot=#latest.players+1,#playerVisuals do
            if playerVisuals[slot] then playerVisuals[slot].Transparency=1 end
        end
    else
        for slot=2,#playerVisuals do
            if playerVisuals[slot] then playerVisuals[slot].Transparency=slot==2 and (extraDiscMode and 0 or 1) or 1 end
        end
    end
    ballDisc.Transparency=latest.pairMode and 1 or 0
    renderLine(debugLine,p1,ball,latest.touchingBall and Color3.fromRGB(70,255,130) or Color3.fromRGB(255,220,70),not latest.pairMode)
    renderLine(pairDebugLine,p1,p2,latest.touchingPlayers and Color3.fromRGB(70,255,130) or Color3.fromRGB(80,220,255),extraDiscMode)
    renderLine(ballP2DebugLine,p2,ball,latest.touchingPlayer2Ball and Color3.fromRGB(70,255,130) or Color3.fromRGB(255,110,90),latest.crowdMode)

    local m=latest.metrics
    local lastTouchLine=latest.lastTouch and string.format("Last: %s #%d (%s)",string.upper(latest.lastTouch.team),latest.lastTouch.playerId,latest.lastTouch.kind) or "Last: -" 
    local p2Line=(latest.players and #latest.players>0) and string.format("Roster: %d | RED %d / BLUE %d | %s",latest.playerCount,latest.redCount,latest.blueCount,lastTouchLine) or ((latest.pairMode or latest.crowdMode) and string.format("P2: (%.2f, %.2f) speed %.2f | %s",latest.player2.x,latest.player2.y,latest.player2.speed,lastTouchLine) or ("P2: inactive | "..lastTouchLine))
    local ballLine=latest.pairMode and "Ball: inactive in player-pair test" or string.format("Ball: (%.2f, %.2f) speed %.2f",latest.ball.x,latest.ball.y,latest.ball.speed)
    local contactLine=latest.crowdMode and string.format("Separations P1-P2 %.2f | P1-ball %.2f | P2-ball %.2f",latest.playerSeparation,latest.separation,latest.player2BallSeparation) or (latest.pairMode and string.format("P1-P2: %.2f | contacts: %d",latest.playerSeparation,m.playerContacts) or string.format("P1-ball: %.2f | contacts: %d | ball walls: %d",latest.separation,m.ballContacts,m.ballWallBounces))
    local diagnosticsLine=latest.crowdMode and string.format("3D %d contacts | peak overlap %.3f | residual %.4f/max %.4f | iter %d/%d",m.crowdContacts,m.crowdPeakPenetration,m.crowdLastResidualPenetration,m.crowdWorstResidualPenetration,m.crowdLastSolverIterations,m.crowdMaxSolverIterations) or string.format("Max penetration %.3f | correction %.3f | impulse %.3f | substeps %d/%d | suite %s",m.maxPlayerPenetration,m.maxPlayerCorrection,m.lastPlayerImpulse,m.lastCollisionSubsteps,m.maxCollisionSubsteps,m.regressionRan and string.format("%d/%d",m.regressionPassed,m.regressionTotal) or "pendiente")
    local matchStatus=latest.matchPhase=="goalPause" and string.format("GOAL PAUSE %d",latest.pauseTicksRemaining) or (latest.matchPhase=="kickoff" and string.format("KICKOFF %s %d",string.upper(latest.kickoffTeam or "-"),latest.pauseTicksRemaining) or (latest.kickoffTeam and ("WAIT KICK "..string.upper(latest.kickoffTeam)) or "PLAYING"))
    local matchLine=string.format("Score RED %d - %d BLUE | %s",latest.score.red,latest.score.blue,matchStatus)
    label.Text=string.format(
        "Haxball lab | WASD move | X kick\nTick: %d | t=%.2f s | %s\n%s\nKicks: %d attempts / %d accepted (last %d)\nP1: (%.2f, %.2f) speed %.2f\n%s\n%s\n%s\n%s\n%s | samples %d",
        latest.tick,latest.gameTime,latest.crowdMode and "THREE-DISC TEST" or (latest.pairMode and "PAIR TEST" or (latest.coreMode and ("CORE v1 | owner "..tostring(latest.ownerUserId or "-")) or (latest.legacyMode and "LEGACY CCD TEST" or ("owner "..tostring(latest.ownerUserId or "-"))))),
        matchLine,
        m.kickAttempts,m.successfulKicks,m.lastKickSuccessTick,
        latest.player.x,latest.player.y,latest.player.speed,
        p2Line,ballLine,contactLine,diagnosticsLine,
        latest.recording and "recording" or "paused",latest.historySamples or 0
    )
    recordButton.Text=latest.recording and "Pausar registro" or "Reanudar registro"
end)
