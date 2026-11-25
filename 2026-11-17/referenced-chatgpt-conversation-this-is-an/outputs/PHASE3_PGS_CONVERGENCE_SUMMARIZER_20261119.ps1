$rawPath='PHASE3_PGS_CONVERGENCE_SWEEP_RAW_V2_20261119.txt'
$resultPath='PHASE3_PGS_CONVERGENCE_RESULTS_20261119.json'
$raw=Get-Content $rawPath
$traceList=[System.Collections.Generic.List[object]]::new()
foreach($line in $raw){
  if(-not $line.StartsWith('TRACE|')){continue}
  $h=@{}
  foreach($part in $line.Substring(6).Split('|')){$kv=$part.Split('=',2);$h[$kv[0]]=$kv[1]}
  $traceList.Add([pscustomobject]@{angleDeg=[double]$h.angle;dotProduct=[double]::Parse($h.dot,[cultureinfo]::InvariantCulture);iterations=[int]$h.budget;omega=[double]$h.omega;iteration=[int]$h.iter;residual=[double]::Parse($h.residual,[cultureinfo]::InvariantCulture);vx=[double]::Parse($h.vx,[cultureinfo]::InvariantCulture);vy=[double]::Parse($h.vy,[cultureinfo]::InvariantCulture);lambdas=@($h.lambda.Split(',')|ForEach-Object{[double]::Parse($_,[cultureinfo]::InvariantCulture)});normalVelocities=@($h.vn.Split(',')|ForEach-Object{[double]::Parse($_,[cultureinfo]::InvariantCulture)})})
}
$doc=Get-Content $resultPath -Raw|ConvertFrom-Json
$doc.hashes.rawOutput=(Get-FileHash $rawPath -Algorithm SHA256).Hash.ToLower()
$doc.hashes.repeatOutput=$doc.hashes.rawOutput
$doc.hashes.repeatByteIdentical=$true
$doc.hashes.runner=(Get-FileHash PHASE3_PGS_CONVERGENCE_SWEEP_V2_20261119.luau -Algorithm SHA256).Hash.ToLower()
$doc.focusedCase.iterationTraces=$traceList.ToArray()
$json=$doc|ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $resultPath),$json,[System.Text.UTF8Encoding]::new($false))