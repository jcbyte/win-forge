
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Start-Process -FilePath PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  Exit
}

$RepoDir = Split-Path -Parent $PSCommandPath
$SetupPipelineScript = Join-Path $RepoDir "SetupPipeline.ps1"
& $SetupPipelineScript $RepoDir
