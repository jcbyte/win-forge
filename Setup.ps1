# Setup Script for Win-Forge
# Downloads and extracts the full repository, then runs individual Admin and User setup scripts
# Can be run in Dev mode using local modules using `-Dev` switch

param (
  [switch]$Dev
)

$REPO_NAME = "win-forge"
$REPO_ARCHIVE_URL = "https://github.com/jcbyte/$REPO_NAME/archive/refs/heads/main.zip"

if (-not $Dev) {
  Write-Host "Cloning" -NoNewline
  Write-Host " $REPO_NAME" -ForegroundColor Cyan

  # Download the full repo and save it in temp files
  $OutputZip = Join-Path $env:TEMP "$REPO_NAME-main.zip"
  Invoke-WebRequest -Uri $REPO_ARCHIVE_URL -OutFile $OutputZip

  # Create/empty the known local path for the repo
  $LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.$REPO_NAME"
  if (Test-Path $LocalDir) { Remove-Item $LocalDir -Recurse -Force }
  else { New-Item -ItemType Directory -Path $LocalDir | Out-Null }

  Write-Host "Extracting" -NoNewline
  Write-Host " $REPO_NAME" -ForegroundColor Cyan

  # Extract the repository 
  Expand-Archive $OutputZip $LocalDir
  $RepoDir = Join-Path $LocalDir "$REPO_NAME-main"

  # Remove the temporary repo archive
  Remove-Item $OutputZip
}
else {
  # If in Dev use local repo
  $RepoDir = Split-Path -Parent $PSCommandPath
  Write-Host "Using local '$RepoDir' repository" -ForegroundColor Yellow
}

Write-Host "Running Setup Scripts"

try {
  # Try to run admin setup (with UAC prompt)
  $AdminSetup = Join-Path $RepoDir "AdminSetup.ps1"
  $AdminArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $AdminSetup)
  # Start-Process will fail with `InvalidOperationException` if permission is not given
  Start-Process -FilePath PowerShell.exe -ArgumentList $AdminArgList -Verb RunAs

  # If the admin script was started, run the user setup with current privilege (this may be admin)
  $UserSetup = Join-Path $RepoDir "UserSetup.ps1"
  $UserArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $UserSetup)
  Start-Process -FilePath PowerShell.exe -ArgumentList $UserArgList
}
catch <#[System.InvalidOperationException]#> {
  Write-Host "Failed to gain Admin Privilege" -ForegroundColor Red

  # Perform Cleanup
  $CleanupScript = Join-Path $RepoDir "Cleanup.ps1"
  & $CleanupScript
}

# todo these two processes need to communicate with each-other


