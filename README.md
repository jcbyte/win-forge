# win-forge

A set of PowerShell scripts and configuration files to bootstrap a Windows workstation with developer tools, common apps, and personal configuration.

## Usage

Run the setup script from a PowerShell prompt:

```powershell
irm https://raw.githubusercontent.com/jcbyte/win-forge/main/Setup.ps1 | iex
```

This will clone the repo and begin setup scripts.

## Setup Result

### Installed Application

These scripts automate installing a custom list of apps and configuring them.

- **Daily apps**: Chrome, Spotify, Discord, Steam, Office 2024 (Word, PowerPoint, Excel)
- **Utilities**: 7-Zip, Everything, Google Drive PowerToys, LocalSend, Unified Remote, Chrome Remote Desktop, Windhawk
- **Developer tools**: Git, VS Code, Docker Desktop, modern PowerShell, Oh My Posh, Visual Studios 2022 Build Tools
- **Languages**: Node.js (nvm), Python (Python Install Manager), Rust, Java (JDK 25)
- **Optional Software**: NVIDIA App, MSI Afterburner, Razer Synapse 4, Corsair iCUE 5, OpenRGB

### Configuration Applied

- Oh My Posh: custom theme applied and enabled in modern PowerShell
- Windows Terminal: configured with preferred styling
- Git: configured with name, email, and preferred settings
- PowerToys: configured from a backup created using `tools/BackupPowerToysConfiguration.ps1`
- Windhawk: configured with mods from a backup created using `tools/BackupWindhawkMods.ps1`
- MSI Afterburner: configured with desired settings
- OpenRGB: configured with a custom profile and desired settings

Apps requiring manual sign-in or additional configuration will prompt the user at the end of the setup.

## Requirements & Notes

- Windows 11 with administrative access.
- Internet access for downloads.
- For WSL/Docker: virtualization enabled in firmware and WSL2 available.

## Development

To run the setup scripts locally from the repository (without cloning):

```powershell
.\Setup.ps1 -Dev
```

### Repository Structure

- `Admin/` : Setup scripts run in an elevated terminal.
- `User/` : Setup scripts run in a user terminal.
- `config/` : Configuration files for apps (PowerToys, Windows Terminal, OpenRGB, Office, etc.).
- `tools/` : Utility scripts for backing.
- `Utils/`, `IPC/` : PowerShell modules used across scripts.

## License

[Apache License 2.0](LICENSE)
