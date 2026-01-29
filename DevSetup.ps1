# Get Admin Privileges
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Start-Process -FilePath PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  Exit
}

# Call Main Script in local repo
$RepoDir = Split-Path -Parent $PSCommandPath
$SetupPipelineScript = Join-Path $RepoDir "SetupPipeline.ps1"
& $SetupPipelineScript $RepoDir

# Indicate success/failure
if ($?) {
  Write-Host "`n✅ Setup Script Succeeded" -ForegroundColor Green
}
else {
  Write-Host "`n❌ Setup Script Failed" -ForegroundColor Red
}

Write-Host "Press Enter to Exit..." -NoNewline
[Console]::ReadKey() | Out-Null

# todo could my DevSetup just be a parameter into regular setup?
