param(
  [string]$RepoDir
)

Import-Module Utils

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
Write-Host "👤 Enter Password for $($env:USERNAME):" -ForegroundColor Yellow
$Cred = Get-Cred $env:USERNAME
if (-not $Cred) { Exit 1 }

$StepsPath = Join-Path $RepoDir "Steps"

# Execute each stage of the setup
$SetupSteps = @(
  [PSCustomObject]@{File = "ConfigureWindows.ps1"; Title = "Configure Windows" },
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Install Packages"; RefreshPath = $true },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configure Packages" },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Install Languages"; RefreshPath = $true },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Post Setup" }
)

Write-Host "Performing Setup"
foreach ($Step in $SetupSteps) {
  Write-Host "Performing Step: $($Step.Title)"
  $ScriptFile = Join-Path $StepsPath $Step.File
  & $ScriptFile -Cred $Cred

  # Refresh PATH from the systems environment variables if required
  if ($Step.RefreshPath) { Sync-Path }
}
