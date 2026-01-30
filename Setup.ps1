# Setup Script for Win-Forge
# Downloads and extracts the full repository, then runs individual Admin and User setup scripts
# Can be run in Dev mode using local modules using `-Dev` switch

param (
  [switch]$Dev
)

# * Must ensure these are synchronised with the values in `Utils\Utils.psm1`
$RepoName = "win-forge"
$RepoLocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.win-forge"
$RepoDir = $null # ? This is defined later dynamically
# This script cannot import the module as it must be standalone

$REPO_ARCHIVE_URL = "https://github.com/jcbyte/$RepoName/archive/refs/heads/main.zip"

if (-not $Dev) {
  Write-Host "Cloning" -NoNewline
  Write-Host " $RepoName" -ForegroundColor Cyan

  # Download the full repo and save it in temp files
  $OutputZip = Join-Path $env:TEMP "$RepoName-main.zip"
  Invoke-WebRequest -Uri $REPO_ARCHIVE_URL -OutFile $OutputZip

  # Create/empty the known local path for the repo
  if (Test-Path $RepoLocalDir) { Remove-Item $RepoLocalDir -Recurse -Force }
  else { New-Item -ItemType Directory -Path $RepoLocalDir | Out-Null }

  Write-Host "Extracting" -NoNewline
  Write-Host " $RepoName" -ForegroundColor Cyan

  # Extract the repository 
  Expand-Archive $OutputZip $RepoLocalDir
  $RepoDir = Join-Path $RepoLocalDir "$RepoName-main"

  # Remove the temporary repo archive
  Remove-Item $OutputZip
}
else {
  # If in Dev use local repo
  $RepoDir = $PSScriptRoot
  Write-Host "Using local '$RepoDir' repository" -ForegroundColor Yellow
}

Write-Host "Running Setup Scripts"

try {
  # Try to run admin setup (with UAC prompt)
  $AdminSetup = Join-Path $RepoDir "Admin\Setup.ps1"
  $AdminArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $AdminSetup)
  # Start-Process will fail with `InvalidOperationException` if permission is not given
  Start-Process -FilePath PowerShell.exe -ArgumentList $AdminArgList -Verb RunAs

  # If the admin script was started, run the user setup with current privilege (this may be admin)
  $UserSetup = Join-Path $RepoDir "User\Setup.ps1"
  $UserArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $UserSetup)
  Start-Process -FilePath PowerShell.exe -ArgumentList $UserArgList
}
catch <#[System.InvalidOperationException]#> {
  Write-Host "Failed to gain Admin Privilege" -ForegroundColor Red

  # Perform Cleanup
  $CleanupScript = Join-Path $RepoDir "Cleanup.ps1"
  & $CleanupScript
}
