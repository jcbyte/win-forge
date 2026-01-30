# todo doc

Import-Module (Join-Path $PSScriptRoot "..\Utils")
Import-Module (Join-Path $PSScriptRoot "..\IPC")

# Get Event handles shared between user and admin setup scripts
$ClientReady = Get-GlobalEventHandle("ClientReady")
$ServerAck = Get-GlobalEventHandle("ServerAck")
$ClientDone = Get-GlobalEventHandle("ClientDone")

Write-Host "⏳ Waiting for user setup..." -ForegroundColor Yellow

# Ensure the user setup script is ready so that we don't perform admin setup without user setup (causing side effects)
if ($ClientReady.WaitOne(30000)) {
  Write-Host "✅ user setup is ready!" -ForegroundColor Green
  # Ensure the user setup we have not timed out yet
  $ServerAck.Set() | Out-Null
}
else {
  Write-Host "❌ user setup did not become ready in time!" -NoNewline -ForegroundColor Red
  Write-Host " (Timeout)" -ForegroundColor DarkGray
  Exit
}


# Execute each stage of the admin setup
$StepsPath = Join-Path $PSScriptRoot "Steps"
$SetupSteps = @(
  [PSCustomObject]@{File = "ConfigureWindows.ps1"; Title = "Configuring Windows" },
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Installing Packages"; RefreshPath = $true },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configuring Packages" },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Installing Languages"; RefreshPath = $true },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Performing Post Setup" }
)

foreach ($Step in $SetupSteps) {
  Write-Host "`n⚡ $($Step.Title)" -ForegroundColor Cyan
  $ScriptFile = Join-Path $StepsPath $Step.File
  & $ScriptFile -Cred $Cred

  # Refresh PATH from the systems environment variables if required
  if ($Step.RefreshPath) { Sync-Path }
}

# Ensure the user script has completed before we restart the computer
Write-Host "⏳ Ensuring user script has completed" -ForegroundColor Yellow
if ($ClientDone.WaitOne(120000)) {
  Write-Host "✅ User script has completed" -ForegroundColor Green
}
else {
  # ? This could fail if user setup takes substantially longer than admin setup to this point, if so we could increase timeout
  Write-Host "❌ User script did not complete in time" -ForegroundColor Red
  Write-Host "⚠️ This is unusual, and may have caused side effects" -ForegroundColor Red
  Exit
}

# todo restart and continue setup, for wsl

# todo work after user completes here

# todo cleanup when exiting