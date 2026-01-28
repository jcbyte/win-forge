# Set constants
$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"
$SETUP_SCRIPT_NAME = "Setup.ps1"
$SETUP_SCRIPT_URL = "https://raw.githubusercontent.com/jcbyte/$REPO_NAME/refs/heads/main/$SETUP_SCRIPT_NAME"

# Creates a new temporary directory and returns its path
function New-TemporaryDirectory {
  $tmp = [System.IO.Path]::GetTempPath()
  $name = (New-Guid).ToString("N")
  $path = Join-Path $tmp $name
  New-Item -ItemType Directory -Path $path | Out-Null
  return $path
}

# Check if the script is running as administrator; if not, relaunch it with elevation
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  $cmdPath = $PSCommandPath
  # If the script is running directly from memory (`irm`), download it to a temporary file
  if (-not $cmdPath) {
    $tempSetupDir = New-TemporaryDirectory
    $tempSetupFile = Join-Path $tempSetupDir $SETUP_SCRIPT
    Invoke-RestMethod $SETUP_SCRIPT_URL -OutFile $tempSetupFile
    $cmdPath = $tempSetupFile
  }

  # Relaunch the script with elevated privileges
  Start-Process -FilePath PowerShell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$cmdPath`"" -Verb Runas
  Exit
}

Read-Host "We Are Admin!"
# todo below





# Install Git early to clone the repo
winget install -e --id Git.Git

$tempDir = New-TemporaryDirectory
Set-Location "$tempDir"
git clone "$REPO_URL"

$repoDir = Join-Path $tempDir $REPO_NAME
if (-not (Test-Path $repoDir)) {
  Write-Error "Failed to fetch Repo!"
  exit 1
}
Set-Location "$repoDir"

# Execute

# Set-ExecutionPolicy Bypass -Scope Process -Force

.\ConfigureWindows.ps1
.\InstallPackages.ps1
.\ConfigurePackages.ps1
.\InstallDev.ps1
.\PostSetup.ps1

Read-Host "Hold Until Enter"
