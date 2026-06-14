# Package Installation Stage
# Installs common software, development tools, and languages using WinGet.

Import-Module (Join-Path $PSScriptRoot "..\Utils")

# List of WinGet packages to install
$Packages = @(
  # Daily Software
  [PSCustomObject]@{Id = "Google.Chrome"; Title = "Google Chrome"; Scope = "user" },
  [PSCustomObject]@{Id = "Spotify.Spotify"; Title = "Spotify"; Scope = "user" },
  [PSCustomObject]@{Id = "Discord.Discord"; Title = "Discord"; Scope = "user" }, # ? This will request admin, and then open
  [PSCustomObject]@{Id = "Valve.Steam"; Title = "Steam"; Scope = "user" },
  # Tools
  [PSCustomObject]@{Id = "Google.GoogleDrive"; Title = "Google Drive"; Scope = "user" },
  # Dev Software/Tools
  [PSCustomObject]@{Id = "Microsoft.VisualStudioCode"; Title = "Visual Studio Code"; Scope = "user" },
  [PSCustomObject]@{Id = "JanDeDobbeleer.OhMyPosh"; Title = "Oh My Posh"; Scope = "user" },
  # Languages
  [PSCustomObject]@{Id = "CoreyButler.NVMforWindows"; Title = "NVM"; Scope = "user" },
  [PSCustomObject]@{Id = "Python.PythonInstallManager"; Title = "Python Install Manager"; Scope = "user" }
)

foreach ($Package in $Packages) { Install-WinGetUnattended $Package }

# Synchronise the PATH, as installs may have effected it
Sync-Path
