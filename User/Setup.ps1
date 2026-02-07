# Performs underprivileged (user-level) setup tasks
# Ensures credentials are provided if the script is running as Admin
# Signals with the admin script, allowing safe continuation and system restart

Import-Module (Join-Path $PSScriptRoot "..\Utils")

# CHeck if the current shell is at privileged level
function Test-IsAdmin {
  $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
  $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
  return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

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

# If the script is running as Admin, we need to relaunch it as user level
if (Test-IsAdmin) {
  Write-Host "This script is running as Admin, User credentials are required for underprivileged operations" -ForegroundColor DarkGray
  Write-Host "👤 Enter Password for " -NoNewline -ForegroundColor Cyan
  Write-Host $env:USERNAME -NoNewline -ForegroundColor DarkCyan
  Write-Host ":" -ForegroundColor Cyan

  # Get user credentials
  $Cred = Get-Cred $env:USERNAME
  if (-not $Cred) { Exit 1 }

  # Restart the script with user privilege
  $ArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath)
  Start-Process -FilePath PowerShell.exe -ArgumentList $ArgList -Credential $Cred
  Exit
}

Import-Module (Join-Path $PSScriptRoot "..\IPC")

# Get Event handles shared between user and admin setup scripts
$ClientReady = Get-GlobalEventHandle("ClientReady")
$ServerAck = Get-GlobalEventHandle("ServerAck")
$ClientDone = Get-GlobalEventHandle("ClientDone")

# Notify admin setup script that we are ready as this could've taken some time if we had to sign in.
Write-Host "📢 Notifying admin setup that we are ready" -ForegroundColor Yellow
$ClientReady.Set() | Out-Null
# Ensure that the admin setup script is still active so that we don't perform user setup without admin setup (causing side effects)
if (-not $ServerAck.WaitOne(5000)) {
  Write-Host "❌ Admin setup did not respond, possible timeout" -ForegroundColor Red
  Exit
}

# Do user setup here:

# Install spotify as it requires a underprivileged session
# $SpotifyPackage = [PSCustomObject]@{Id = "Spotify.Spotify"; Title = "Spotify"; }
# Install-WinGetUnattended $SpotifyPackage

# Notify admin setup that we have completed, allowing restarting
Write-Host "✅ User setup completed" -ForegroundColor Green
$ClientDone.Set() | Out-Null
