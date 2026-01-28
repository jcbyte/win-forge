# Install Packages though WinGet and separately

$WinGetPackages = @(
  # Daily Software
  [PSCustomObject]@{Id = "Google.Chrome"; Title = "Google Chrome" },
  [PSCustomObject]@{Id = "Spotify.Spotify"; Title = "Spotify" },
  [PSCustomObject]@{Id = "WhatsApp.WhatsApp"; Title = "WhatsApp" },
  [PSCustomObject]@{Id = "Discord.Discord"; Title = "Discord" },
  [PSCustomObject]@{Id = "Valve.Steam"; Title = "Steam" },
  # Tools
  [PSCustomObject]@{Id = "7zip.7zip"; Title = "7-Zip" },
  [PSCustomObject]@{Id = "voidtools.Everything"; Title = "Everything Search" },
  [PSCustomObject]@{Id = "Google.Drive"; Title = "Google Drive" },
  [PSCustomObject]@{Id = "Microsoft.PowerToys"; Title = "Microsoft PowerToys" },
  [PSCustomObject]@{Id = "LocalSend.LocalSend"; Title = "LocalSend" },
  [PSCustomObject]@{Id = "UnifiedIntents.UnifiedRemote"; Title = "Unified Remote" },
  [PSCustomObject]@{Id = "Google.ChromeRemoteDesktop"; Title = "Chrome Remote Desktop" },
  [PSCustomObject]@{Id = "RamenSoftware.Windhawk"; Title = "Windhawk" },
  # Dev Software/Tools
  # [PSCustomObject]@{Id = "Git.Git"; Title = "Git" }, # ? This is installed within `Setup.ps1`
  [PSCustomObject]@{Id = "Microsoft.VisualStudioCode"; Title = "Visual Studio Code" },
  [PSCustomObject]@{Id = "Docker.DockerDesktop"; Title = "Docker Desktop" },
  [PSCustomObject]@{Id = "Microsoft.PowerShell"; Title = "Modern Powershell" },
  [PSCustomObject]@{Id = "JanDeDobbeleer.OhMyPosh"; Title = "Oh My Posh" },
  # Languages
  [PSCustomObject]@{Id = "CoreyButler.NVMforWindows"; Title = "NVM" },
  [PSCustomObject]@{Id = "Python.PythonInstallManager"; Title = "Python Install Manager" },
  [PSCustomObject]@{Id = "Rustlang.Rustup"; Title = "Rust toolchain via Rustup" }, # todo is this correct name
  [PSCustomObject]@{Id = "Oracle.JDK.25"; Title = "Java JDK 25" }  # ? This will always install JDK 25
)

foreach ($Package in $WinGetPackages) {
  Write-Host "Installing $($Package.Title)"
  winget install -e --id $Package.Id --silent --accept-source-agreements --accept-package-agreements
}

# Todo Install Office
