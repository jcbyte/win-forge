# todo doc

Write-Host "🛠️" -NoNewline -ForegroundColor Blue
Write-Host " Configuring" -NoNewline
Write-Host " WSL" -ForegroundColor Cyan

wsl --set-default-version 2

# Install Ubuntu on WSL
wsl --install Ubuntu-24.04 # ? This will always install Ubuntu 24.04 LTS 
