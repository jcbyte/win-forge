# Setup Script for Win-Forge
# Ensures elevated privileges, installs Git early and downloads the repository
# Can be run in Dev mode using local modules using `-Dev` switch

param (
  [switch]$Dev
)

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
