# Setup Script which should be run, to gain elevated privileges and download the repository

param (
  [switch]$Dev
)

# Set constants
$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"
$SETUP_SCRIPT_NAME = "Setup.ps1"
$SETUP_SCRIPT_URL = "https://raw.githubusercontent.com/jcbyte/$REPO_NAME/refs/heads/main/$SETUP_SCRIPT_NAME"

# Creates a new temporary directory and returns its path
function New-TemporaryDirectory {
  $TmpDir = [System.IO.Path]::GetTempPath()
  $Name = (New-Guid).ToString("N")
  $Path = Join-Path $TmpDir $Name
  New-Item -ItemType Directory -Path $Path | Out-Null
  return $Path
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
Write-Host "Installing Git"
winget install -e --id Git.Git --silent --accept-source-agreements --accept-package-agreements --source winget


if (-not $Dev) {
  # Clone repository
  Write-Host "Cloning '$REPO_NAME' repository"
  $RepoDir = New-TemporaryDirectory
  git clone "$REPO_URL" "$RepoDir" --quiet
}
else {
  # If in Dev use local repo
  $RepoDir = Split-Path -Parent $PSCommandPath
  Write-Host "Using local '$RepoDir' repository"
}

# Execute the setup pipeline
$SetupPipelineScript = Join-Path $RepoDir "Pipeline.ps1"
& $SetupPipelineScript $RepoDir

# Indicate success/failure
if ($?) {
  Write-Host "`n✅ Setup Script Succeeded" -ForegroundColor Green
}
else {
  Write-Host "`n❌ Setup Script Failed" -ForegroundColor Red
}

# Wait for user input before closing
Write-Host "Press Enter to Exit..." -NoNewline
[Console]::ReadKey() | Out-Null
