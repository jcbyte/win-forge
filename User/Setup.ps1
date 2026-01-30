# todo doc

Import-Module (Join-Path $PSScriptRoot "..\Utils")

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

# # If the script is running as Admin, we need to relaunch it as user level
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

$ServerReady = Get-EventHandle("ServerReady")
$ClientReady = Get-EventHandle("ClientReady")
$ClientDone = Get-EventHandle("ClientDone")

$ClientReady.Set();
if ($ServerReady.WaitOne(30000)) {
  Write-Host "server ready"
}
else {
  Write-Error "Client did not ready in time"
}

Start-Sleep 3  # simulate work

$ClientDone.Set()


[Console]::ReadKey() | Out-Null
Exit