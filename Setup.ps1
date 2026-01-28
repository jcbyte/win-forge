Read-Host "Continue"



function New-TemporaryDirectory {
  $tmp = [System.IO.Path]::GetTempPath()
  $name = (New-Guid).ToString("N")
  $path = Join-Path $tmp $name
  New-Item -ItemType Directory -Path $path
  return $path
}

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {

  $tempSetupDir = New-TemporaryDirectory
  $tempSetupFile = Join-Path $tempSetupDir "Setup.ps1"
  Invoke-RestMethod "https://raw.githubusercontent.com/jcbyte/win-forge/refs/heads/main/Setup.ps1" -OutFile "$tempSetupFile"

  Start-Process -FilePath PowerShell.exe -ArgumentList "-NoExit -File `"$tempSetupFile`" -NoProfile -ExecutionPolicy Bypass" -Verb Runas
  Read-Host "Hold Until Enter here? $tempSetupFile"
  Exit
}

Read-Host "This is admin..."

$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"



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
