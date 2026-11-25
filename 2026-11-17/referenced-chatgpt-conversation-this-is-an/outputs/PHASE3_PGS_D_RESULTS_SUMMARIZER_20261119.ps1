$ErrorActionPreference = 'Stop'
$OutputDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RawPath = Join-Path $OutputDir 'PHASE3_PGS_D_FULL_GRID_RAW_20261119.txt'
$RepeatPath = Join-Path $OutputDir 'PHASE3_PGS_D_FULL_GRID_REPEAT_20261119.txt'
$ResultsPath = Join-Path $OutputDir 'PHASE3_PGS_D_FULL_GRID_RESULTS_20261119.json'
$rawHash = (Get-FileHash -LiteralPath $RawPath -Algorithm SHA256).Hash.ToLowerInvariant()
$repeatHash = (Get-FileHash -LiteralPath $RepeatPath -Algorithm SHA256).Hash.ToLowerInvariant()
$rows = [System.Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines($RawPath)) {
    if (-not $line.StartsWith('row|')) { continue }
    $x = $line.Split('|')
    $rows.Add([pscustomobject]@{
        index=[int]$x[1]; angleDeg=[double]$x[2]; vx0=[double]$x[3]; vy0=[double]$x[4]
        restitution=[double]$x[5]; constraints=[int]$x[6]; order=$x[7]; iterations=[int]$x[8]; relaxation=[double]$x[9]
        gamma=[double]$x[10]; originalTargets=$x[11]; projectedTargets=$x[12]; pgsImpulses=$x[13]
        pgsVx=[double]$x[14]; pgsVy=[double]$x[15]; pgsPostNormalVelocities=$x[16]
        pgsKktResidual=[double]$x[17]; originalTargetResidual=[double]$x[18]; pgsEnergyDelta=[double]$x[19]
        pgsConverged=[bool]::Parse($x[20]); projectedObjectiveOnlySuccess=[bool]::Parse($x[21])
        oracleGamma=[double]$x[22]; oracleImpulses=$x[23]; oracleVx=[double]$x[24]; oracleVy=[double]$x[25]
        oracleKktResidual=[double]$x[26]; oracleEnergyDelta=[double]$x[27]
        gammaError=[double]$x[28]; velocityError=[double]$x[29]
    })
}
$byBudget = @($rows | Group-Object iterations | ForEach-Object {
    $g=$_.Group; [pscustomobject]@{iterations=[int]$_.Name;total=$g.Count;converged=(@($g|Where-Object pgsConverged)).Count;failed=(@($g|Where-Object {-not $_.pgsConverged})).Count}
})
$byRelaxation = @($rows | Group-Object relaxation | ForEach-Object {
    $g=$_.Group; [pscustomobject]@{relaxation=[double]$_.Name;total=$g.Count;converged=(@($g|Where-Object pgsConverged)).Count;failed=(@($g|Where-Object {-not $_.pgsConverged})).Count}
})
$byAngle = @($rows | Group-Object angleDeg | ForEach-Object {
    $g=$_.Group; [pscustomobject]@{angleDeg=[double]$_.Name;total=$g.Count;converged=(@($g|Where-Object pgsConverged)).Count;failed=(@($g|Where-Object {-not $_.pgsConverged})).Count}
})
$selected = @($rows | Where-Object {
    ($_.angleDeg -eq 179.94 -and $_.vx0 -eq 20 -and $_.vy0 -eq -10 -and $_.restitution -eq .5 -and $_.constraints -eq 2 -and $_.order -eq 'canonical' -and $_.iterations -eq 128 -and $_.relaxation -eq 1) -or
    ($_.angleDeg -eq 180 -and $_.vx0 -eq 20 -and $_.vy0 -eq 0 -and $_.restitution -eq 1 -and $_.constraints -eq 2 -and $_.order -eq 'canonical' -and $_.iterations -eq 128 -and $_.relaxation -eq 1) -or
    ($_.angleDeg -eq 90 -and $_.vx0 -eq 20 -and $_.vy0 -eq 0 -and $_.restitution -eq .5 -and $_.constraints -eq 2 -and $_.order -eq 'canonical' -and $_.iterations -eq 128 -and $_.relaxation -eq 1)
})
$pairs = @{}
foreach ($r in $rows) {
    $key = '{0:R}|{1:R}|{2:R}|{3:R}|{4}|{5}|{6:R}' -f $r.angleDeg,$r.vx0,$r.vy0,$r.restitution,$r.constraints,$r.iterations,$r.relaxation
    if (-not $pairs.ContainsKey($key)) { $pairs[$key]=@{} }
    $pairs[$key][$r.order]=$r
}
$statusChanges=0; $residualDifferences=0; $maxResidualDelta=0.0
foreach($p in $pairs.Values) {
    if($p.ContainsKey('canonical') -and $p.ContainsKey('reverseIds')) {
        if($p.canonical.pgsConverged -ne $p.reverseIds.pgsConverged){$statusChanges++}
        $d=[Math]::Abs($p.canonical.pgsKktResidual-$p.reverseIds.pgsKktResidual)
        if($d -gt 1e-12){$residualDifferences++};$maxResidualDelta=[Math]::Max($maxResidualDelta,$d)
    }
}
$converged=@($rows|Where-Object pgsConverged)
$result=[ordered]@{
    schemaVersion=1
    runtime=[ordered]@{name='Official standalone Luau CLI';version='0.747';exeSha256='ff0acf7d2df9d38e30c85ee9fe698efd756a920496c84ea848b74d0e2082e958';analyzer='luau-analyze 0.747';physicalRobloxTest=$false;NodeExecution=$false}
    method=[ordered]@{implementation='Isolated PGS-D clone';targetProjection='Maximum gamma on individual-target ray with LCP complementarity and kinetic passivity';gammaSelector='Exhaustive active-set affine-interval selector';impulseSolve='Projected Gauss-Seidel on selected D target';oracle='Independently coded exhaustive active-set D projection and LCP check';tolerance=1e-8}
    grid=[ordered]@{cases=$rows.Count;anglesDeg=@(90,120,150,170,175,179,179.94,180);velocities=@(@(20,0),@(20,-10),@(0,-10));restitutions=@(0,.5,1);constraintCounts=@(1,2,3,4);orders=@('canonical','reverseIds');iterations=@(16,32,64,128);relaxations=@(.5,.8,1,1.2,1.5)}
    totals=[ordered]@{converged=$converged.Count;failed=$rows.Count-$converged.Count;failedWithFeasiblePassiveOracle=(@($rows|Where-Object {-not $_.pgsConverged -and $_.oracleKktResidual -le 1e-8 -and $_.oracleEnergyDelta -le 1e-7})).Count;projectionOracleMissing=(@($rows|Where-Object {$_.oracleGamma -is [double] -and [double]::IsNaN($_.oracleGamma)})).Count;oracleKktViolations=(@($rows|Where-Object oracleKktResidual -gt 1e-8)).Count;oraclePositiveEnergy=(@($rows|Where-Object oracleEnergyDelta -gt 1e-7)).Count;maxGammaError=($rows|Measure-Object gammaError -Maximum).Maximum;gammaErrorOver1eMinus8=(@($rows|Where-Object gammaError -gt 1e-8)).Count;maxVelocityError=($rows|Measure-Object velocityError -Maximum).Maximum;convergedStateMismatch=(@($converged|Where-Object velocityError -gt 1e-6)).Count;convergedEnergyPositive=(@($converged|Where-Object pgsEnergyDelta -gt 1e-7)).Count;incompletePositiveEnergy=(@($rows|Where-Object {-not $_.pgsConverged -and $_.pgsEnergyDelta -gt 1e-7})).Count;reducedTargetConvergence=(@($converged|Where-Object originalTargetResidual -gt 1e-8)).Count;maxPgsKktResidual=($rows|Measure-Object pgsKktResidual -Maximum).Maximum;maxOriginalTargetResidual=($rows|Measure-Object originalTargetResidual -Maximum).Maximum;maxOracleKktResidual=($rows|Measure-Object oracleKktResidual -Maximum).Maximum;maxOracleEnergyDelta=($rows|Measure-Object oracleEnergyDelta -Maximum).Maximum;allRowsWithReducedGamma=(@($rows|Where-Object gamma -lt (1-1e-8))).Count;allRowsGammaZero=(@($rows|Where-Object gamma -le 1e-8)).Count;rawSha256=$rawHash;repeatSha256=$repeatHash;byteIdentical=($rawHash -eq $repeatHash)}
    byIteration=$byBudget;byRelaxation=$byRelaxation;byAngle=$byAngle
    orderSensitivity=[ordered]@{pairedConfigurationCount=$pairs.Count;convergenceStatusChanges=$statusChanges;residualDifferencesOver1eMinus12=$residualDifferences;maximumResidualDifference=$maxResidualDelta;inputArrayPermutationIsStable=$true}
    focusedRows=$selected
    fullPrecisionRecordFile='PHASE3_PGS_D_FULL_GRID_RAW_20261119.txt'
}
$json=$result|ConvertTo-Json -Depth 10
[IO.File]::WriteAllText($ResultsPath,$json,[Text.UTF8Encoding]::new($false))
Write-Output "rows=$($rows.Count) rawSha256=$rawHash repeatSha256=$repeatHash byteIdentical=$($rawHash -eq $repeatHash)"
