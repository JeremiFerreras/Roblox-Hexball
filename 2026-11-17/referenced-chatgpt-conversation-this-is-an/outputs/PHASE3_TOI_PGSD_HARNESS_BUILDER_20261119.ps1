$ErrorActionPreference = 'Stop'
$OutDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Join-Path $OutDir 'PHASE3_TOI_EXPERIMENTAL_HARNESS_20261119.luau'
$PGSDPath = Join-Path $OutDir 'PHASE3_PGS_D_ISOLATED_20261119.luau'
$DestPath = Join-Path $OutDir 'PHASE3_TOI_PGSD_EXPERIMENTAL_HARNESS_20261119.luau'
$s = [IO.File]::ReadAllText($BasePath)
$pgs = [IO.File]::ReadAllText($PGSDPath).Trim()

$embed = @"
local PGSD_SOURCE=[====[
$pgs
]====]
local pgsdModule=Instance.new("ModuleScript");pgsdModule.Name="Phase3PGSD";pgsdModule.Source=PGSD_SOURCE;pgsdModule.Parent=ServerStorage
"@
$anchor='local Profile = require(profileClone)'
if (-not $s.Contains($anchor)) { throw 'Profile require anchor missing' }
$s=$s.Replace($anchor,$anchor+"`n"+$embed.TrimEnd())
$s=$s.Replace('local function Core.stepWorld(world, inputs)' , 'local function Core.stepWorld(world, inputs)')
$s=$s.Replace('if v.props=="node" then for _,p in ipairs(w.planes)do if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 end end end','if v.props=="node" then for _,p in ipairs(w.planes)do if string.find(p.id,"classic:outer:",1,true)==1 then p.bCoef=0 elseif string.find(p.id,"classic:ballArea:",1,true)==1 then p.bCoef=1 end end end')
$anchor=@'
function Core.stepWorld(world, inputs)
    assert(type(world)=="table" and type(world.discs)=="table","invalid world")
'@.TrimEnd()
$replacement=@'
function Core.stepWorld(world, inputs)
    assert(type(world)=="table" and type(world.discs)=="table","invalid world")
    local PGSD=require(game:GetService("ServerStorage"):WaitForChild("Phase3PGSD"))
'@.TrimEnd()
$s=$s.Replace($anchor,$replacement)
$s=$s.Replace('local stats={candidateTests=0,validCandidates=0,discardedMask=0,discardedSeparating=0,discardedOutOfRange=0,iterations=0,eventLimit=false,zeroTimeEvents=0,curvedArcTests=0}',
'local stats={candidateTests=0,validCandidates=0,discardedMask=0,discardedSeparating=0,discardedOutOfRange=0,iterations=0,eventLimit=false,zeroTimeEvents=0,curvedArcTests=0,incomplete=false,strategies={pgsD=0,cInelastic=0,sequentialInelastic=0,pairResolver=0,pairPGSD=0,pairInelastic=0,failed=0},manifoldEvents=0}')
$s=$s.Replace('while remaining>timeEps and stats.iterations<maxEvents do','while remaining>timeEps and stats.iterations<maxEvents and not stats.incomplete do')
$old=@'
        local disc=best.disc
        local candidateList={};for _,c in ipairs(candidates)do candidateList[#candidateList+1]={toi=c.t,kind=c.kind,geometryId=c.geometry and c.geometry.id or nil,discId=c.disc and c.disc.id or nil,discA=c.a and c.a.id or nil,discB=c.b and c.b.id or nil,normalX=c.nx,normalY=c.ny}end
        local hitRecord={toi=best.t,timeRemainingBefore=beforeRemaining,timeRemainingAfter=remaining,kind=best.kind,geometryId=best.geometry and best.geometry.id or nil,discId=disc and disc.id or nil,discA=best.a and best.a.id or nil,discB=best.b and best.b.id or nil,normalX=best.nx,normalY=best.ny,candidateCount=#candidates,candidates=candidateList,pre=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil,orderMode=world.config.toiOrder}
        if best.kind=="pair" then
            hitRecord.pairPre={a=pre[keyOf(best.a.id)],b=pre[keyOf(best.b.id)]}
            local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            best.a.x-=best.nx*posSlop*.5;best.a.y-=best.ny*posSlop*.5;best.b.x+=best.nx*posSlop*.5;best.b.y+=best.ny*posSlop*.5
            local con=resolveDiscPair(best.a,best.b)
            if con then
                con.kind="discContact";con.tick=world.tick+1;con.discA=best.a.id;con.discB=best.b.id
                local key="pair:"..keyOf(best.a.id)..":"..keyOf(best.b.id);eventKeys[key]=con;table.insert(events,con)
                hitRecord.penetration=con.penetration;hitRecord.impulse=con.impulse
            end
            hitRecord.pairPost={a={x=best.a.x,y=best.a.y,vx=best.a.vx,vy=best.a.vy},b={x=best.b.x,y=best.b.y,vx=best.b.vx,vy=best.b.vy}}
        elseif best.kind=="plane" or best.kind=="segment" then
            local correction=math.max(best.penetration or 0,posSlop)
            local g=best.geometry
            local normalVelocity=disc.vx*best.nx+disc.vy*best.ny
            local impulse=0
            if normalVelocity<0 then local change=-(1+disc.bCoef*g.bCoef)*normalVelocity;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            disc.x+=best.nx*correction;disc.y+=best.ny*correction
            local kind=best.kind=="plane" and "planeContact" or "segmentContact"
            local ev={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=g.id,normalX=best.nx,normalY=best.ny,penetration=0,impulse=impulse}
            table.insert(events,ev);hitRecord.impulse=impulse;hitRecord.penetration=0
        else
            disc.x=disc.x+best.nx*posSlop;disc.y=disc.y+best.ny*posSlop
            local vn=disc.vx*best.nx+disc.vy*best.ny
            local impulse=0;if vn<0 then local change=-(1+disc.bCoef)*vn;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            hitRecord.impulse=impulse;hitRecord.penetration=0
            local ev={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=1,side=best.side,impulse=impulse};table.insert(events,ev)
        end
        hitRecord.post=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil
'@
$new=@'
        local disc=best.disc
        local candidateList={};for _,c in ipairs(candidates)do candidateList[#candidateList+1]={toi=c.t,kind=c.kind,geometryId=c.geometry and c.geometry.id or nil,discId=c.disc and c.disc.id or nil,discA=c.a and c.a.id or nil,discB=c.b and c.b.id or nil,normalX=c.nx,normalY=c.ny}end
        local hitRecord={toi=best.t,timeRemainingBefore=beforeRemaining,timeRemainingAfter=remaining,kind=best.kind,geometryId=best.geometry and best.geometry.id or nil,discId=disc and disc.id or nil,discA=best.a and best.a.id or nil,discB=best.b and best.b.id or nil,normalX=best.nx,normalY=best.ny,candidateCount=#candidates,candidates=candidateList,pre=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil,orderMode=world.config.toiOrder}
        if best.kind=="pair" then
            hitRecord.pairPre={a=pre[keyOf(best.a.id)],b=pre[keyOf(best.b.id)]}
            local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            best.a.x-=best.nx*posSlop*.5;best.a.y-=best.ny*posSlop*.5;best.b.x+=best.nx*posSlop*.5;best.b.y+=best.ny*posSlop*.5
            local con=resolveDiscPair(best.a,best.b)
            if con then
                con.kind="discContact";con.tick=world.tick+1;con.discA=best.a.id;con.discB=best.b.id;con.solverStrategy="existing-pair-resolver"
                local key="pair:"..keyOf(best.a.id)..":"..keyOf(best.b.id);eventKeys[key]=con;table.insert(events,con)
                hitRecord.penetration=con.penetration;hitRecord.impulse=con.impulse;stats.strategies.pairResolver+=1
            end
            hitRecord.pairPost={a={x=best.a.x,y=best.a.y,vx=best.a.vx,vy=best.a.vy},b={x=best.b.x,y=best.b.y,vx=best.b.vx,vy=best.b.vy}}
        elseif world.config.experimentalPGSD and (best.kind=="plane" or best.kind=="segment") then
            local maxSpeed=math.sqrt(disc.vx*disc.vx+disc.vy*disc.vy)
            local spatialTol=disc.radius*1e-5
            local simultaneousTol=math.max(timeEps,spatialTol/math.max(1,maxSpeed))
            local rows,seen={},{}
            local function addManifoldRow(kind,g,nx,ny,penetration)
                local sid=tostring(g.id);if seen[sid]then return end
                local n=math.sqrt(nx*nx+ny*ny);if n<=1e-12 then return end
                seen[sid]=true;local surfaceB=g.bCoef==nil and 1 or g.bCoef
                rows[#rows+1]={surfaceId=sid,nx=nx/n,ny=ny/n,restitution=disc.bCoef*surfaceB,geometry=g,kind=kind,penetration=penetration or 0}
            end
            -- Include geometrically touching surfaces even when their incoming normal
            -- velocity was separating: resolving one contact may make an adjacent one closing.
            for _,c in ipairs(candidates)do if c.disc==disc and (c.kind=="plane" or c.kind=="segment") and math.abs(c.t-best.t)<=simultaneousTol then addManifoldRow(c.kind,c.geometry,c.nx,c.ny,c.penetration) end end
            for _,g in ipairs(world.planes)do if collisionAllowed(disc,g)then local gap=disc.x*g.normalX+disc.y*g.normalY-g.offset-disc.radius;if gap<=spatialTol then addManifoldRow("plane",g,g.normalX,g.normalY,math.max(0,-gap))end end end
            for _,g in ipairs(world.segments)do if collisionAllowed(disc,g)then local _,_,dist,nx,ny=closestOnSegment(g,disc.x,disc.y);local gap=dist-disc.radius;if gap<=spatialTol then addManifoldRow("segment",g,nx,ny,math.max(0,-gap))end end end
            table.sort(rows,function(a,b)return a.surfaceId<b.surfaceId end)
            stats.manifoldEvents+=1
            local vx0,vy0=disc.vx,disc.vy;local energy0=.5*(vx0*vx0+vy0*vy0)/disc.invMass
            local solve=PGSD.solve({id=disc.id,vx=vx0,vy=vy0,invMass=disc.invMass},rows,{iterations=128,relaxation=1,tolerance=1e-8})
            local chosen,solverStrategy,usedGamma,attempts=nil,nil,nil,{{strategy="PGS-D",ok=solve.ok,residual=solve.residualKKT,gamma=solve.gamma,reason=solve.reason}}
            local energyTol=math.max(1e-8,energy0*1e-10)
            if solve.ok and solve.energyDelta<=energyTol then chosen={lambda=solve.lambda,state=solve.post,residual=solve.residualKKT,energyDelta=solve.energyDelta,targets=solve.projectedTargets,originalTargets=solve.originalTargets};solverStrategy="PGS-D";usedGamma=solve.gamma;stats.strategies.pgsD+=1 end
            if not chosen then
                local zero=table.create(#rows,0);local c=PGSD.activeSetLcp(vx0,vy0,disc.invMass,rows,zero)
                local cOk=c.ok and c.state.energyDelta<=energyTol
                attempts[#attempts+1]={strategy="C-inelastic",ok=cOk,residual=c.residual,energyDelta=c.state and c.state.energyDelta or nil,reason=c.reason}
                if cOk then chosen={lambda=c.lambda,state=c.state,residual=c.residual,energyDelta=c.state.energyDelta,targets=zero,originalTargets=solve.originalTargets};solverStrategy="C-inelastic";usedGamma=0;stats.strategies.cInelastic+=1 end
            end
            if not chosen then
                local svx,svy=vx0,vy0;local sums=table.create(#rows,0);local passRes=math.huge
                for sweep=1,8 do for i,c in ipairs(rows)do local vn=svx*c.nx+svy*c.ny;if vn<0 then local impulse=-vn/disc.invMass;sums[i]+=impulse;svx+=c.nx*impulse*disc.invMass;svy+=c.ny*impulse*disc.invMass end end
                    passRes=0;for _,c in ipairs(rows)do passRes=math.max(passRes,math.max(0,-(svx*c.nx+svy*c.ny)))end
                end
                local energy=.5*(svx*svx+svy*svy)/disc.invMass-energy0
                local seqOk=passRes<=1e-6 and energy<=energyTol and svx==svx and svy==svy and math.abs(svx)<math.huge and math.abs(svy)<math.huge
                attempts[#attempts+1]={strategy="bounded-sequential-inelastic",ok=seqOk,residual=passRes,energyDelta=energy,sweeps=8}
                if seqOk then chosen={lambda=sums,state={vx=svx,vy=svy},residual=passRes,energyDelta=energy,targets=zero,originalTargets=solve.originalTargets};solverStrategy="bounded-sequential-inelastic";usedGamma=0;stats.strategies.sequentialInelastic+=1 end
            end
            if not chosen then
                stats.incomplete=true;stats.strategies.failed+=1;stats.incompleteReason="all-manifold-strategies-failed";stats.unconsumedTime=remaining
                hitRecord.solver={attempts=attempts,chosen="failed",timeUnconsumed=remaining,spatialTolerance=spatialTol,simultaneousTolerance=simultaneousTol}
            else
                disc.vx=chosen.state.vx;disc.vy=chosen.state.vy
                local maxPen=0
                for pass=1,8 do
                    for _,c in ipairs(rows)do local nx,ny=c.nx,c.ny;local gap
                        if c.kind=="plane"then gap=disc.x*nx+disc.y*ny-c.geometry.offset-disc.radius
                        else local qx,qy,dist,nnx,nny=closestOnSegment(c.geometry,disc.x,disc.y);nx,ny=nnx,nny;gap=dist-disc.radius end
                        if gap < -posSlop then local correction=-gap+posSlop;disc.x+=nx*correction;disc.y+=ny*correction end
                    end
                end
                for _,c in ipairs(rows)do local gap;if c.kind=="plane"then gap=disc.x*c.nx+disc.y*c.ny-c.geometry.offset-disc.radius else local _,_,dist=closestOnSegment(c.geometry,disc.x,disc.y);gap=dist-disc.radius end;maxPen=math.max(maxPen,math.max(0,-gap))end
                if maxPen>math.max(5*posSlop,spatialTol)then
                    stats.incomplete=true;stats.strategies.failed+=1;stats.incompleteReason="positional-residual-after-manifold";stats.unconsumedTime=remaining
                end
                local impulseTotal=0;local contactRecords={}
                for i,c in ipairs(rows)do local vn0=vx0*c.nx+vy0*c.ny;local vn1=disc.vx*c.nx+disc.vy*c.ny;local lambda=chosen.lambda[i] or 0;impulseTotal+=lambda
                    local surfaceB=c.geometry.bCoef==nil and 1 or c.geometry.bCoef
                    local rec={surfaceId=c.surfaceId,geometryKind=c.kind,normalX=c.nx,normalY=c.ny,bCoefBody=disc.bCoef,bCoefSurface=surfaceB,ePair=c.restitution,originalTarget=solve.originalTargets[i],projectedTarget=solve.projectedTargets[i],gamma=usedGamma,impulse=lambda,normalVelocityBefore=vn0,normalVelocityAfter=vn1,kktResidual=chosen.residual,solverStrategy=solverStrategy,originalRestitutionSatisfied=solverStrategy=="PGS-D" and solve.originalTargetResidual<=1e-8,penetrationAfter=maxPen}
                    contactRecords[#contactRecords+1]=rec
                    local ev={kind=c.kind=="plane" and "planeContact" or "segmentContact",tick=world.tick+1,discId=disc.id,geometryId=c.geometry.id,normalX=c.nx,normalY=c.ny,penetration=maxPen,impulse=lambda,solverStrategy=solverStrategy,gamma=usedGamma,originalRestitutionSatisfied=rec.originalRestitutionSatisfied,normalVelocityBefore=vn0,normalVelocityAfter=vn1}
                    table.insert(events,ev)
                end
                hitRecord.impulse=impulseTotal;hitRecord.penetration=maxPen;hitRecord.solver={attempts=attempts,chosen=solverStrategy,gamma=usedGamma,energyBefore=energy0,energyAfter=.5*(disc.vx*disc.vx+disc.vy*disc.vy)/disc.invMass,energyDelta=.5*(disc.vx*disc.vx+disc.vy*disc.vy)/disc.invMass-energy0,projectedKktResidual=chosen.residual,originalTargetResidual=solve.originalTargetResidual,originalRestitutionSatisfied=solverStrategy=="PGS-D" and solve.originalTargetResidual<=1e-8,contacts=contactRecords,spatialTolerance=spatialTol,simultaneousTolerance=simultaneousTol,positionCorrectionSweeps=8}
            end
        elseif best.kind=="plane" or best.kind=="segment" then
            local correction=math.max(best.penetration or 0,posSlop);local g=best.geometry;local normalVelocity=disc.vx*best.nx+disc.vy*best.ny;local impulse=0
            if normalVelocity<0 then local change=-(1+disc.bCoef*g.bCoef)*normalVelocity;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            disc.x+=best.nx*correction;disc.y+=best.ny*correction;local kind=best.kind=="plane" and "planeContact" or "segmentContact"
            local ev={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=g.id,normalX=best.nx,normalY=best.ny,penetration=0,impulse=impulse};table.insert(events,ev);hitRecord.impulse=impulse;hitRecord.penetration=0
        else
            disc.x=disc.x+best.nx*posSlop;disc.y=disc.y+best.ny*posSlop;local vn=disc.vx*best.nx+disc.vy*best.ny;local impulse=0
            if vn<0 then local change=-(1+disc.bCoef)*vn;disc.vx+=best.nx*change;disc.vy+=best.ny*change;impulse=change/disc.invMass end
            hitRecord.impulse=impulse;hitRecord.penetration=0;local ev={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=1,side=best.side,impulse=impulse};table.insert(events,ev)
        end
        hitRecord.post=disc and {x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy} or nil
'@
$pairBranch=@'
        if best.kind=="pair" and world.config.experimentalPGSD then
            local a,b=best.a,best.b;local nlen=math.sqrt(best.nx*best.nx+best.ny*best.ny);if nlen<1e-12 then best.nx,best.ny=-1,0 else best.nx,best.ny=best.nx/nlen,best.ny/nlen end
            local nx,ny=best.nx,best.ny;local invTotal=a.invMass+b.invMass;local rvx,rvy=a.vx-b.vx,a.vy-b.vy
            local surfaceA=a.bCoef==nil and 1 or a.bCoef;local surfaceB=b.bCoef==nil and 1 or b.bCoef;local pairRest=surfaceA*surfaceB
            local rows={{surfaceId="pair:"..keyOf(a.id)..":"..keyOf(b.id),nx=nx,ny=ny,restitution=pairRest}}
            local e0=.5*(rvx*rvx+rvy*rvy)/math.max(invTotal,1e-30);local solve=PGSD.solve({id="pair",vx=rvx,vy=rvy,invMass=invTotal},rows,{iterations=128,relaxation=1,tolerance=1e-8})
            local chosen,strategy,gamma=nil,nil,nil;local attempts={{strategy="PGS-D-pair",ok=solve.ok,residual=solve.residualKKT,gamma=solve.gamma,reason=solve.reason}};local energyTol=math.max(1e-8,e0*1e-10)
            if solve.ok and solve.energyDelta<=energyTol then chosen={lambda=solve.lambda,post=solve.post,residual=solve.residualKKT,energyDelta=solve.energyDelta};strategy="PGS-D-pair";gamma=solve.gamma;stats.strategies.pairPGSD+=1 end
            if not chosen then local zero={0};local c=PGSD.activeSetLcp(rvx,rvy,invTotal,rows,zero);local good=c.ok and c.state.energyDelta<=energyTol;attempts[#attempts+1]={strategy="C-inelastic-pair",ok=good,residual=c.residual,reason=c.reason};if good then chosen={lambda=c.lambda,post=c.state,residual=c.residual,energyDelta=c.state.energyDelta};strategy="C-inelastic-pair";gamma=0;stats.strategies.pairInelastic+=1 end end
            if not chosen then local vn=rvx*nx+rvy*ny;local j=vn<0 and -vn/math.max(invTotal,1e-30) or 0;local px,py=rvx+nx*j*invTotal,rvy+ny*j*invTotal;local de=.5*(px*px+py*py)/math.max(invTotal,1e-30)-e0;local good=de<=energyTol and px==px and py==py and math.abs(px)<math.huge and math.abs(py)<math.huge;attempts[#attempts+1]={strategy="bounded-sequential-inelastic-pair",ok=good,energyDelta=de};if good then chosen={lambda={j},post={vx=px,vy=py},residual=math.max(0,-(px*nx+py*ny)),energyDelta=de};strategy="bounded-sequential-inelastic-pair";gamma=0;stats.strategies.pairInelastic+=1 end end
            if not chosen then stats.incomplete=true;stats.incompleteReason="pair-manifold-strategies-failed";stats.unconsumedTime=remaining;stats.strategies.failed+=1;hitRecord.solver={attempts=attempts,chosen="failed",timeUnconsumed=remaining}
            else
                local j=chosen.lambda[1]or 0;a.vx+=nx*j*a.invMass;a.vy+=ny*j*a.invMass;b.vx-=nx*j*b.invMass;b.vy-=ny*j*b.invMass
                local dx,dy=b.x-a.x,b.y-a.y;local dist=math.sqrt(dx*dx+dy*dy);local penetration=math.max(0,a.radius+b.radius-dist);local correction=math.max(posSlop,penetration)
                if invTotal>0 then a.x+=nx*correction*a.invMass/invTotal;a.y+=ny*correction*a.invMass/invTotal;b.x-=nx*correction*b.invMass/invTotal;b.y-=ny*correction*b.invMass/invTotal end
                local vn0=rvx*nx+rvy*ny;local vn1=(a.vx-b.vx)*nx+(a.vy-b.vy)*ny;local restOk=strategy=="PGS-D-pair" and solve.originalTargetResidual<=1e-8
                local ev={kind="discContact",tick=world.tick+1,discA=a.id,discB=b.id,normalX=nx,normalY=ny,penetration=penetration,impulse=j,solverStrategy=strategy,gamma=gamma,relativeVelocityBefore=vn0,relativeVelocityAfter=vn1,originalRestitutionSatisfied=restOk};table.insert(events,ev)
                hitRecord.impulse=j;hitRecord.penetration=penetration;hitRecord.pairPre={a=pre[keyOf(a.id)],b=pre[keyOf(b.id)]};hitRecord.pairPost={a={x=a.x,y=a.y,vx=a.vx,vy=a.vy},b={x=b.x,y=b.y,vx=b.vx,vy=b.vy}}
                hitRecord.solver={chosen=strategy,gamma=gamma,energyBefore=e0,energyAfter=e0+chosen.energyDelta,energyDelta=chosen.energyDelta,projectedKktResidual=chosen.residual,originalTargetResidual=solve.originalTargetResidual,originalRestitutionSatisfied=restOk,attempts=attempts,contacts={{surfaceId=rows[1].surfaceId,nx=nx,ny=ny,ePair=pairRest,impulse=j,normalVelocityBefore=vn0,normalVelocityAfter=vn1,solverStrategy=strategy}}}
            end
        elseif best.kind=="pair" then
'@
$new=$new.Replace('        if best.kind=="pair" then',$pairBranch.TrimEnd())
if (-not $s.Contains($old)) { throw 'TOI resolver block anchor not found' }
$s=$s.Replace($old,$new)
$oldTail=@'
if remaining>timeEps then
        if stats.iterations>=maxEvents then stats.eventLimit=true end
        for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*remaining;d.y+=d.vy*remaining end end
        remaining=0
    end
'@.TrimEnd()
$newTail=@'
if remaining>timeEps and not stats.incomplete then
        if stats.iterations>=maxEvents then stats.eventLimit=true;stats.incomplete=true;stats.incompleteReason="event-limit";stats.unconsumedTime=remaining end
        if not stats.incomplete then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then d.x+=d.vx*remaining;d.y+=d.vy*remaining end end;remaining=0 end
    end
'@.TrimEnd()
$s=$s.Replace($oldTail,$newTail)
$s=$s.Replace($newTail,'if stats.eventLimit and not stats.incomplete then stats.incomplete=true;stats.incompleteReason=stats.iterations>=maxEvents and "event-limit" or "zero-time-event-limit";stats.unconsumedTime=remaining end' + "`n" + $newTail)
$oldDamp=@'
    for _,d in ipairs(world.discs) do
        if d.enabled and d.invMass>0 then
            local damp=(d.kind=="player" and d.kickArmed) and d.kickDamping or d.damping
            d.vx=(d.vx+d.gravityX)*damp; d.vy=(d.vy+d.gravityY)*damp
        end
    end
    world.tick+=1
'@.TrimEnd()
$newDamp=@'
    if not stats.incomplete then for _,d in ipairs(world.discs) do if d.enabled and d.invMass>0 then local damp=(d.kind=="player" and d.kickArmed) and d.kickDamping or d.damping;d.vx=(d.vx+d.gravityX)*damp;d.vy=(d.vy+d.gravityY)*damp end end end
    world.tick+=1
'@.TrimEnd()
$s=$s.Replace($oldDamp,$newDamp)
$variantAnchor=' {id="F_TOI_node",engine="toi",order="node",props="node"},'
if (-not $s.Contains($variantAnchor)) { throw 'Variant anchor missing' }
$variants=@'
 {id="G_TOI_PGSD_core",engine="toiPGSD",order="core",props="core"},
 {id="H_TOI_PGSD_hbs",engine="toiPGSD",order="core",props="node"},
'@
$s=$s.Replace($variantAnchor,$variantAnchor+"`n"+$variants.TrimEnd())
$s=$s.Replace('if v.engine=="t1" then Core=T1 elseif v.engine=="toi" then Core=TOI end','if v.engine=="t1" then Core=T1 elseif v.engine=="toi" or v.engine=="toiPGSD" then Core=TOI end')
$s=$s.Replace('toiOrder=v.order})','toiOrder=v.order,experimentalPGSD=v.engine=="toiPGSD"})')
$s=$s.Replace('local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order,experimentalPGSD=v.engine=="toiPGSD"})', 'local w=Core.newWorld({useBounds=false,maxSubsteps=64,forceSinglePass=true,temporalMode="fullTickBeforeContacts",toiOrder=v.order,experimentalPGSD=v.engine=="toiPGSD"})' + "`n" + ' if v.engine=="toiPGSD" then w.config.experimentalPGSD=true end')
$s=$s.Replace('rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or {},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,stepCostSeconds=stepCost,iterations=iterations,before=before}','rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or {},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,stepCostSeconds=stepCost,iterations=iterations,before=before};if w.toiStats and w.toiStats.incomplete then break end')
$s=$s.Replace('rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before}end','rows[#rows+1]={tick=tick,state=fullState(w),contacts=contacts,toiTrace=w.toiTrace or{},toiStats=w.toiStats or nil,costSeconds=w.toiCostSeconds or nil,iterations=n,before=before};if w.toiStats and w.toiStats.incomplete then break end end')
$s=$s.Replace('local Core=v.engine=="core" and require(sourceCoreScript) or v.engine=="t1" and T1 or TOI','local Core=v.engine=="core" and require(sourceCoreScript) or v.engine=="t1" and T1 or TOI')
$s=$s.Replace('toiModule:Destroy();t1Module:Destroy();profileClone:Destroy()','toiModule:Destroy();t1Module:Destroy();profileClone:Destroy();pgsdModule:Destroy()')
$s=$s.Replace('world.tick+=1;world.events=events;world.lastSubsteps=stats.iterations','if not stats.incomplete then world.tick+=1 end;world.events=events;world.lastSubsteps=stats.iterations')
$s=$s.Replace('if gap < -posSlop or vn < -velEps then addCandidate(candidates,{t=0,kind="plane"','if gap < -(world.config.experimentalPGSD and 2*posSlop or posSlop) or vn < -velEps then addCandidate(candidates,{t=0,kind="plane"')
$s=$s.Replace('if initialGap < -posSlop or vn < -velEps then hitT=0','if initialGap < -(world.config.experimentalPGSD and 2*posSlop or posSlop) or vn < -velEps then hitT=0')
[IO.File]::WriteAllText($DestPath,$s,[Text.UTF8Encoding]::new($false))
Write-Output "Created $DestPath bytes=$((Get-Item $DestPath).Length)"
