$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"
$SETUP_SCRIPT_NAME = "Setup.ps1"
$SETUP_IRM = "https://raw.githubusercontent.com/jcbyte/$REPO_NAME/refs/heads/main/$SETUP_SCRIPT_NAME"

# Create and return path to a new temporary directory
function New-TemporaryDirectory {
  $tmp = [System.IO.Path]::GetTempPath()
  $name = (New-Guid).ToString("N")
  $path = Join-Path $tmp $name
  New-Item -ItemType Directory -Path $path | Out-Null
  return $path
}

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  # If the script is purley in memory (i.e. from `irm`) then download the script
  $cmdPath = $PSCommandPath
  if (-not $cmdPath) {
    $tempSetupDir = New-TemporaryDirectory
    $tempSetupFile = Join-Path $tempSetupDir $SETUP_SCRIPT_NAME
    Invoke-RestMethod $SETUP_IRM -OutFile $tempSetupFile
    $cmdPath = $tempSetupFile
  }

  # Run the script with elevated privileges
  Start-Process -FilePath PowerShell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$cmdPath`"" -Verb Runas
  Exit
}

Read-Host "This is admin..."





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
