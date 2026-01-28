# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  # $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -ArgumentList "-File `"$PSCommandPath`" -NoProfile -ExecutionPolicy Bypass" -Verb Runas
  Exit
}


$REPO_NAME = "win-forge"
$REPO_URL = "https://github.com/jcbyte/$REPO_NAME.git"

function New-TemporaryDirectory {
  $tmp = [System.IO.Path]::GetTempPath()
  $name = (New-Guid).ToString("N")
  $path = Join-Path $tmp $name
  New-Item -ItemType Directory -Path $path
  return $path
}

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
