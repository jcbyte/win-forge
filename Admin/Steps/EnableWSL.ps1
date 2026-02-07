# todo doc

Write-Host "🐧" -NoNewline -ForegroundColor Blue
Write-Host " Installing" -NoNewline
Write-Host " WSL" -ForegroundColor Cyan

# Install WSL
wsl --install
# todo do i need to enable these or does wsl do it already
# dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart