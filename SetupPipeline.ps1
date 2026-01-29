param(
  [string]$RepoDir
)

# Get credentials for underprivileged operations
function Get-Cred([string]$Username, [int]$Count = 0) {
  # Try up to 3 times before failing
  if ($Count -ge 3) { return $null }

  # Ask the user for their credentials
  $Password = Read-Host "🔒 Password" -AsSecureString
  $Cred = [PSCredential]::new($Username, $Password)

  try {
    Start-Process -FilePath PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Exit`"" -Credential $Cred -Wait -WindowStyle Hidden -ErrorAction Stop
    # If the `Start`Process` proceeds the credentials are valid

    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
    [Console]::Write(" " * [Console]::WindowWidth)
    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
    
    Write-Host "✅ Password: ********" -ForegroundColor Green

    return $Cred
  }
  catch {
    # If the `Start`Process` fails its because the credentials are invalid, so retry getting them
    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
    [Console]::Write(" " * [Console]::WindowWidth)
    [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)

    Write-Host "❌ Password: ********" -ForegroundColor Red

    return Get-Cred $Username ($Count + 1)
  }
}

Write-Host "User credentials required for underprivileged operations" -ForegroundColor DarkGray
Write-Host "👤 Enter Password for $($env:USERNAME):" -ForegroundColor Yellow
$Cred = Get-Cred $env:USERNAME
if (-not $Cred) { Exit 1 }

Read-Host "sd"
Exit

$StepsPath = Join-Path $RepoDir "Steps"

# Execute each stage of the setup
$SetupSteps = @(
  [PSCustomObject]@{File = "ConfigureWindows.ps1"; Title = "Configure Windows" },
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Install Packages" },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configure Packages" },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Install Languages" },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Post Setup" }
)

Write-Host "Performing Setup"
foreach ($Step in $SetupSteps) {
  Write-Host "Performing Step: $($Step.Title)"
  $ScriptFile = Join-Path $StepsPath $Step.File
  & $ScriptFile -Cred $Cred
}
