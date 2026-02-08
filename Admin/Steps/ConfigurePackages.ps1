# Configure Packages
# todo

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

$GIT_NAME = "Joel Cutler"
$GIT_EMAIL = "joelcutler108@gmail.com"

# Configure PowerShell with Oh My Posh

# Install FiraCode Nerd Font
Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Installing" -NoNewline
Write-Host " FiraCode Nerd Font" -ForegroundColor Cyan
oh-my-posh font install FiraCode

# Copy Windows Terminal Settings
Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Configuring" -NoNewline
Write-Host " Windows Terminal" -ForegroundColor Cyan

$TerminalSettingsDist = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$TerminalSettingsSrc = Join-Path $Repo.Dir "config\windows-terminal.settings.json"
Copy-Item -Path $TerminalSettingsSrc -Destination $TerminalSettingsDist -Force
# todo check that the guids are fine being overwritten

# Enable Oh My Posh with custom theme
Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Enabling" -NoNewline
Write-Host " Oh My Posh" -ForegroundColor Cyan

# todo need to check if $PROFILE will be correct in this context
# C:\Users\vjoel\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
$ProfileLocation = Split-Path -Path $PROFILE
$ThemeDist = Join-Path $ProfileLocation "PoshThemes\joel.omp.json"
$ThemeSrc = Join-Path $Repo.Dir "config\joel.omp.json"
Copy-Item -Path $ThemeSrc -Destination $ThemeDist -Force
Add-Content -Path $PROFILE -Value "oh-my-posh init pwsh --config `"$ThemeDist`" | Invoke-Expression"

# todo check ghost texts work, and check Ubuntu also exists in the terminal

# Configure Git

Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Configuring" -NoNewline
Write-Host " Git" -ForegroundColor Cyan

git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global fetch.prune true
git config --global fetch.pruneTags true


# Todo Configure PowerToys
# Todo Configure Windhawk (Better file sizes in Explorer details, Taskbar Volume Control)
# Todo Configure Spotify (SpotX/BlockTHeSpot, should these be included?)
# Todo Check if needing config? (7-Zip, Everything, LocalSend, Unified Remote, Chrome Remote Desktop)

# ? When installing CRDH: "Notes: This is the hosting component for Chrome Remote Desktop. After installation, follow the instructions at https://remotedesktop.google.com/ to get connected."