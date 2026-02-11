# win-forge

<!-- todo write readme -->

> Very unfinished, much draft

```
irm https://raw.githubusercontent.com/jcbyte/win-forge/main/Setup.ps1 | iex
```

> Dev: For testing (no cache):

```
irm "https://raw.githubusercontent.com/jcbyte/win-forge/main/Setup.ps1?nocache=$(Get-Random)" | iex
```

## Installs

### Daily Software

- Google Chrome
- Spotify
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

# Todo

- Verify WSL success on a machine with virtualisation
- Verify Docker install works (failed due to WSL previously)
- Verify NVM works (failed previously)
- Verify scope="none" works as intended (untested)
- Verify MSI Afterburner configuration (untested)
- Verify OpenRGB configuration (untested)
- Create Windows Terminal Config with WSL
