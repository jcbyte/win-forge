# Package Installation Stage
# Installs common software, development tools, and languages using WinGet.
# Will install Office via ODT.

param(
  [PSCredential]$Cred
)

Import-Module (Join-Path $RepoDir "Utils")

# List of WinGet packages to install
$WinGetPackages = @(
  # Daily Software
  [PSCustomObject]@{Id = "Google.Chrome"; Title = "Google Chrome" },
  [PSCustomObject]@{Id = "Spotify.Spotify"; Title = "Spotify"; Privilege = "user" }, # ? Spotify install requires unprivileged session
  [PSCustomObject]@{Id = "Discord.Discord"; Title = "Discord" }, # ? This will request admin, and then open
  [PSCustomObject]@{Id = "Valve.Steam"; Title = "Steam" },
  # Tools
  [PSCustomObject]@{Id = "7zip.7zip"; Title = "7-Zip" },
  [PSCustomObject]@{Id = "voidtools.Everything"; Title = "Everything Search" },
  [PSCustomObject]@{Id = "Google.GoogleDrive"; Title = "Google Drive" },
  [PSCustomObject]@{Id = "Microsoft.PowerToys"; Title = "Microsoft PowerToys" }, # ? This will open
  [PSCustomObject]@{Id = "LocalSend.LocalSend"; Title = "LocalSend" },
  [PSCustomObject]@{Id = "UnifiedIntents.UnifiedRemote"; Title = "Unified Remote" },
  [PSCustomObject]@{Id = "Google.ChromeRemoteDesktopHost"; Title = "Chrome Remote Desktop" },
  [PSCustomObject]@{Id = "RamenSoftware.Windhawk"; Title = "Windhawk" },
  # Dev Software/Tools
  # [PSCustomObject]@{Id = "Git.Git"; Title = "Git" }, # ? This is installed within `Setup.ps1`
  [PSCustomObject]@{Id = "Microsoft.VisualStudioCode"; Title = "Visual Studio Code" },
  [PSCustomObject]@{Id = "Docker.DockerDesktop"; Title = "Docker Desktop" },
  [PSCustomObject]@{Id = "Microsoft.PowerShell"; Title = "Modern Powershell" },
  [PSCustomObject]@{Id = "JanDeDobbeleer.OhMyPosh"; Title = "Oh My Posh" },
  # Languages
  [PSCustomObject]@{Id = "Microsoft.VisualStudio.2022.BuildTools"; Title = "Visual Studio BuildTools 2022 & Core C++ Toolchain";
    Override = "--wait --quiet --norestart --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CoreBuildTools --add Microsoft.VisualStudio.Component.Windows11SDK.26100" 
  } # ? This will always install BuildTools 2022, and Windows SDK (10.0.26100)
  [PSCustomObject]@{Id = "CoreyButler.NVMforWindows"; Title = "NVM" },
  [PSCustomObject]@{Id = "Python.PythonInstallManager"; Title = "Python Install Manager" },
  [PSCustomObject]@{Id = "Rustlang.Rustup"; Title = "Rust Toolchain" },
  [PSCustomObject]@{Id = "Oracle.JDK.25"; Title = "Java JDK 25" } # ? This will always install JDK 25 
)

foreach ($Package in $WinGetPackages) { Install-WinGetUnattended $Package $Cred }

# Install Office using Office Deployment Tool

$ODTUrl = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
$TempSetupDir = New-TemporaryDirectory
$ODTExe = Join-Path $TempSetupDir "setup.exe"
# ? This configuration will always install Office 2024 LTSC (Word, PowerPoint, Excel)
$OfficeConfiguration = Join-Path $RepoDir "config\OfficeConfiguration.xml"

Write-Host "Installing Office 2024 LTSC (Word, PowerPoint, Excel)"
Start-BitsTransfer -Source $ODTUrl -Destination $ODTExe
& $ODTExe /configure $OfficeConfiguration
