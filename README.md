# win-forge

> Very unfinished, much draft

```
irm https://raw.githubusercontent.com/jcbyte/win-forge/refs/heads/main/Setup.ps1 | iex
```

> Dev: For testing (no cache):

```
irm "https://raw.githubusercontent.com/jcbyte/win-forge/refs/heads/main/Setup.ps1?nocache=$(Get-Random)" | iex
```

## Installs

### Daily Software

- Google Chrome
- Spotify
- WhatsApp
- Discord
- Steam

### Development

- Git
- VSCode
- Docker Desktop
- Powershell (Modern)
- Oh My Posh

### Tools

- 7-Zip
- Everything
- Google Drive
- PowerToys
- LocalSend
- Unified Remote
- Chrome Remote Desktop
- Windhawk

### Languages

- Node.js (NVM)
- Python (Python Install Manager)
- Rust (Rustup)
- Java (JDK 25)

## Todo

`Setup.ps1`

- Single script to install

`ConfigureWindows.ps1`

- Debloat + Configure Windows (https://github.com/Raphire/Win11Debloat)
- Install WSL + Ubuntu

`InstallPackages.ps1`

- Install winget Apps
- Install Office

`ConfigurePackages.ps1`

- Configure pwsh (Oh My Posh, Ghost Text)
- Configure Git
- Configure PowerToys
- Configure Windhawk (Better file sizes in Explorer details, Taskbar Volume Control)
- Configure Spotify (Ad Removal)
- Check if needing config? (7-Zip, Everything, LocalSend, Unified Remote, Chrome Remote Desktop)

`InstallDev.ps1`

- Install Node.js
- Install Python
- Install Rust? How does rustup work?

`PostSetup.ps1`

- Activate Windows+Office (https://massgrave.dev/)
- Sign In (Chrome, Spotify, WhatsApp, Discord, Steam, VSCode, Docker Desktop, Google Drive)
- Mention Driver Software (NVIDIA , Afterburner, Razer Chroma, iCUE, Armoury Crate)
