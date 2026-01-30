$REPO_NAME = "win-forge"
$LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.$REPO_NAME"
$RepoDir = Join-Path $LocalDir "$REPO_NAME-main"

# todo how do i share these variables around (and Dev)

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
  Write-Host "THis script is running as Admin, User credentials are required for underprivileged operations" -ForegroundColor DarkGray
  Write-Host "👤 Enter Password for " -NoNewline -ForegroundColor Cyan
  Write-Host $env:USERNAME -NoNewline -ForegroundColor DarkCyan
  Write-Host ":" -ForegroundColor Cyan

  # Get user credentials
  $Cred = Get-Cred $env:USERNAME
  if (-not $Cred) { Exit 1 }

  # Restart the script with user privilege
  $UserSetup = Join-Path $RepoDir "UserSetup.ps1"
  $ArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $UserSetup)
  Start-Process -FilePath PowerShell.exe -ArgumentList $ArgList -Credential $Cred
  Exit
}


Write-Host "I should be running in user (but could be admin)!!"

[Console]::ReadKey() | Out-Null
Exit