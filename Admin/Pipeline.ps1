# Setup Pipeline Orchestrator
# Collects user credentials and executes setup steps in sequence

param(
  [string]$RepoDir
)
# Todo move these into admin setup

Import-Module (Join-Path $RepoDir "Utils")

# Get credentials for underprivileged operations
function Get-Cred([string]$Username, [int]$MaxAttempts = 3) {
  # Try a limited number of attempts before failing
  for ($i = 0; $i -lt $MaxAttempts; $i++) {
    $Password = Read-Host "🔒 Password" -AsSecureString
    $Cred = [PSCredential]::new($Username, $Password)

    # If the `Start`Process` proceeds the credentials are valid
    try {
      Start-Process -FilePath PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Exit`"" -Credential $Cred -Wait -WindowStyle Hidden -ErrorAction Stop
      return $Cred
    }
    catch {
      $Cred = $null
    }
    finally {
      # THis will always run (for UI) even after returning
      [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
      [Console]::Write(" " * [Console]::WindowWidth)
      [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)

      if ($Cred) { Write-Host "✅ Password: ********" -ForegroundColor Green }
      else { Write-Host "❌ Password: ********" -ForegroundColor Red }
    }
  }

  return $null
}

Write-Host "User credentials required for underprivileged operations" -ForegroundColor DarkGray
Write-Host "👤 Enter Password for " -NoNewline -ForegroundColor Cyan
Write-Host $env:USERNAME -NoNewline -ForegroundColor DarkCyan
Write-Host ":" -ForegroundColor Cyan
$Cred = Get-Cred $env:USERNAME
if (-not $Cred) { Exit 1 }

# Execute each stage of the setup
$StepsPath = Join-Path $RepoDir "Steps"
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
