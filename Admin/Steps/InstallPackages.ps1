# Package Installation Stage
# Installs common software, development tools, and languages using WinGet.

param(
  [string[]]$Extras
)

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# List of WinGet packages to install
$Packages = @(
  # Tools
  [PSCustomObject]@{Id = "7zip.7zip"; Title = "7-Zip"; Scope = "machine" },
  [PSCustomObject]@{Id = "voidtools.Everything"; Title = "Everything Search"; Scope = "machine" },
  [PSCustomObject]@{Id = "Microsoft.PowerToys"; Title = "Microsoft PowerToys"; Scope = "machine" }, # ? This will open
  [PSCustomObject]@{Id = "LocalSend.LocalSend"; Title = "LocalSend"; Scope = "machine" },
  [PSCustomObject]@{Id = "UnifiedIntents.UnifiedRemote"; Title = "Unified Remote"; Scope = "machine" },
  [PSCustomObject]@{Id = "Google.ChromeRemoteDesktopHost"; Title = "Chrome Remote Desktop"; Scope = "machine" },
  [PSCustomObject]@{Id = "RamenSoftware.Windhawk"; Title = "Windhawk"; Scope = "machine" },
  # Dev Software/Tools
  [PSCustomObject]@{Id = "Git.Git"; Title = "Git"; Scope = "machine" },
  #? Docker.DockerDesktop, is installed later as WSL must be enabled
  [PSCustomObject]@{Id = "Microsoft.WindowsTerminal"; Title = "Windows Terminal"; Scope = "machine" },
  [PSCustomObject]@{Id = "Microsoft.PowerShell"; Title = "Modern Powershell"; Scope = "machine" },
  # Languages
  [PSCustomObject]@{Id = "Microsoft.VisualStudio.2022.BuildTools"; Title = "Visual Studio BuildTools 2022 & Core C++ Toolchain"; Scope = "machine";
    Override = "--wait --quiet --norestart --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CoreBuildTools --add Microsoft.VisualStudio.Component.Windows11SDK.26100" 
  } # ? This will always install BuildTools 2022, and Windows SDK (10.0.26100)
  [PSCustomObject]@{Id = "Rustlang.Rustup"; Title = "Rust Toolchain"; Scope = "none" } # ? This must be installed after installing MSVC Build Tools
  [PSCustomObject]@{Id = "CoreyButler.NVMforWindows"; Title = "NVM"; Scope = "machine" },
  [PSCustomObject]@{Id = "Oracle.JDK.25"; Title = "Java JDK 25"; Scope = "machine" } # ? This will always install JDK 25 
)

# For each extra, add its package if it needs to be installed
foreach ($Extra in $Extras) {
  switch ($Extra) {
    # "NvidiaApp" { } # ! Nvidia App is currently not within the WinGet repository (https://github.com/microsoft/winget-pkgs/discussions/200910)
    "MSIAfterburner" { $Packages += [PSCustomObject]@{Id = "Guru3D.Afterburner"; Title = "MSI Afterburner" } }
    # "RazerSynapse4" { } # ! Razer Synapse cannot be installed Unattended
    "CorsairICUE5" { $Packages += [PSCustomObject]@{Id = "Corsair.iCUE.5"; Title = "Corsair iCUE 5" } }
    "OpenRGB" { $Packages += [PSCustomObject]@{Id = "OpenRGB.OpenRGB"; Title = "OpenRGB" } }
  }
}

foreach ($Package in $Packages) { Install-WinGetUnattended $Package }

# Synchronise the PATH, as installs may have effected it
Sync-Path
