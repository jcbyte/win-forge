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

Exit
# todo which parts below do we need


# Set constants
$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"
$SETUP_SCRIPT_NAME = "Setup.ps1"
$SETUP_SCRIPT_URL = "https://raw.githubusercontent.com/jcbyte/$REPO_NAME/main/$SETUP_SCRIPT_NAME"

if (-not $Dev) {
  # Import utils module though github
  $UTILS_MODULE_URL = "https://raw.githubusercontent.com/jcbyte/$REPO_NAME/main/Utils/Utils.psm1"
  $UtilModuleCode = Invoke-RestMethod $UTILS_MODULE_URL
  Invoke-Expression $UtilModuleCode
}
else {
  # Use local Utils modules
  $RepoDir = Split-Path -Parent $PSCommandPath
  Import-Module (Join-Path $RepoDir "Utils")
}

# Check if the script is running as administrator; if not, relaunch it with elevation
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  $CmdPath = $PSCommandPath
  # If the script is running directly from memory (`irm`), download it to a temporary file, this should never happen in Dev
  if (-not $CmdPath) {
    $TempSetupDir = New-TemporaryDirectory
    $TempSetupFile = Join-Path $TempSetupDir $SETUP_SCRIPT_NAME
    Invoke-RestMethod $SETUP_SCRIPT_URL -OutFile $TempSetupFile
    $CmdPath = $TempSetupFile
  }

  # Relaunch the script with elevated privileges
  $ArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $CmdPath)
  if ($Dev) { $ArgList += "-Dev" } # Forward `Dev` switch
  Start-Process -FilePath PowerShell.exe -ArgumentList $ArgList -Verb RunAs

  Exit
}

# Todo can i run a separate user/elevated processes

# Install Git early to clone the repo
Install-WinGetUnattended ([PSCustomObject]@{ Id = "Git.Git"; Title = "Git" })

# Refresh PATH to use Git
Sync-Path

if (-not $Dev) {
  # Clone repository
  Write-Host "Cloning '$REPO_NAME' repository"
  $RepoDir = New-TemporaryDirectory
  git clone "$REPO_URL" "$RepoDir" --quiet
}
else {
  # If in Dev use local repo, this is already set above in dev mode
  Write-Host "Using local '$RepoDir' repository"
}

# Execute the setup pipeline
$SetupPipelineScript = Join-Path $RepoDir "Pipeline.ps1"
& $SetupPipelineScript $RepoDir

# Indicate success/failure
if ($?) {
  Write-Host "`nSetup Script Succeeded" -ForegroundColor Green
}
else {
  Write-Host "`nSetup Script Failed" -ForegroundColor Red
}

# Wait for user input before closing
Write-Host "Press Enter to Exit..." -NoNewline
[Console]::ReadKey() | Out-Null
