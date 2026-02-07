# Installs and enables Windows Subsystem for Linux
# A system restart is required before WSL can be used

Write-Host "🐧" -NoNewline -ForegroundColor Blue
Write-Host " Installing" -NoNewline
Write-Host " WSL" -ForegroundColor Cyan

# ? These features are enabled upon performing `wsl --install`
# dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

# Install WSL
wsl --install
