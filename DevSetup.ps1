$RepoDir = (Get-Location).Path
$SetupPipelineScript = Join-Path $RepoDir "SetupPipeline.ps1"
& $SetupPipelineScript $RepoDir
