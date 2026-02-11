# Package Installation Stage
# Installs common software, development tools, and languages using WinGet.

param(
  [string[]]$Extras
)

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# List of WinGet packages to install
$Packages = @(
  # Daily Software
  [PSCustomObject]@{Id = "Google.Chrome"; Title = "Google Chrome" },
  # [PSCustomObject]@{Id = "Spotify.Spotify"; Title = "Spotify"; }, # ? Spotify install requires unprivileged session
  [PSCustomObject]@{Id = "Discord.Discord"; Title = "Discord"; Scope = "user" }, # ? This will request admin, and then open
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
  [PSCustomObject]@{Id = "Git.Git"; Title = "Git" },
  [PSCustomObject]@{Id = "Microsoft.VisualStudioCode"; Title = "Visual Studio Code" },
  [PSCustomObject]@{Id = "Docker.DockerDesktop"; Title = "Docker Desktop" },
  [PSCustomObject]@{Id = "Microsoft.PowerShell"; Title = "Modern Powershell" },
  [PSCustomObject]@{Id = "JanDeDobbeleer.OhMyPosh"; Title = "Oh My Posh"; Scope = "user" },
  # Languages
  [PSCustomObject]@{Id = "Microsoft.VisualStudio.2022.BuildTools"; Title = "Visual Studio BuildTools 2022 & Core C++ Toolchain";
    Override = "--wait --quiet --norestart --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CoreBuildTools --add Microsoft.VisualStudio.Component.Windows11SDK.26100" 
  } # ? This will always install BuildTools 2022, and Windows SDK (10.0.26100)
  [PSCustomObject]@{Id = "CoreyButler.NVMforWindows"; Title = "NVM"; Scope = "user" },
  [PSCustomObject]@{Id = "Python.PythonInstallManager"; Title = "Python Install Manager" },
  [PSCustomObject]@{Id = "Rustlang.Rustup"; Title = "Rust Toolchain"; Scope = "none" },
  [PSCustomObject]@{Id = "Oracle.JDK.25"; Title = "Java JDK 25" } # ? This will always install JDK 25 
)

# For each extra, add its package if it needs to be installed
foreach ($Extra in $Extras) {
  switch ($Extra) {
    # ! Nvidia App is currently not within the WinGet repository
    # ! https://github.com/microsoft/winget-pkgs/discussions/200910
    # "NvidiaApp" { }
    "MSIAfterburner" { $Packages += [PSCustomObject]@{Id = "Guru3D.Afterburner"; Title = "MSI Afterburner" } }
    # ! Razer Synapse cannot be installed Unattended
    # "RazerSynapse4" { } 
    "CorsairICUE5" { $Packages += [PSCustomObject]@{Id = "Corsair.iCUE.5"; Title = "Corsair iCUE 5" } }
    "OpenRGB" { $Packages += [PSCustomObject]@{Id = "OpenRGB.OpenRGB"; Title = "OpenRGB" } }
  }
}

foreach ($Package in $Packages) { Install-WinGetUnattended $Package }

# Synchronise the PATH, as installs may have effected it
Sync-Path
