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

# Enable Oh My Posh with custom theme
Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Enabling" -NoNewline
Write-Host " Oh My Posh" -ForegroundColor Cyan

$PwshProfile = Join-path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
$ProfileLocation = Split-Path -Path $PwshProfile
$ThemeDistLocation = Join-Path $ProfileLocation "PoshThemes"
$ThemeDist = Join-Path $ThemeDistLocation "joel.omp.json"
$ThemeSrc = Join-Path $Repo.Dir "config\joel.omp.json"
if (-not (Test-Path $ProfileLocation)) { New-Item -ItemType Directory -Path $ProfileLocation -Force | Out-Null }
if (-not (Test-Path $ThemeDistLocation)) { New-Item -ItemType Directory -Path $ThemeDistLocation -Force | Out-Null }
Copy-Item -Path $ThemeSrc -Destination $ThemeDist -Force
Add-Content -Path $PwshProfile -Value "oh-my-posh init pwsh --config `"$ThemeDist`" | Invoke-Expression"

# todo Terminal settings with real WSL configuration

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

# Configure PowerToys

Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Configuring" -NoNewline
Write-Host " PowerToys" -ForegroundColor Cyan

$PowerToysDSCFile = Join-Path $Repo.Dir "config/powertoys-dsc-config.json"
$PowerToysRestore = Get-Content $PowerToysDSCFile | ConvertFrom-Json

# Get PowerToys DSC
$PowerToysDSCExec = "$env:ProgramFiles\PowerToys\PowerToys.DSC.exe"

# Restore each modules settings
# ! Note: Command Pallette (CmdPal) is not configurable though DSC yet
foreach ($Module in $PowerToysRestore.PSObject.Properties) {
  $ModuleInput = $Module.Value | ConvertTo-Json -Depth 10 -Compress
  # ? Note: DSC Tool internal JSON reader does weird things with quotes so we format them like this
  $FormattedModuleInput = $ModuleInput -replace '"', '"""'
  & $PowerToysDSCExec set --resource "settings" --module $Module.Name --input $FormattedModuleInput | Out-Null
}

# Configure Windhawk

Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Configuring" -NoNewline
Write-Host " Windhawk" -ForegroundColor Cyan

# Expand the archive into a temporary folder
$WindhawkArchive = Join-Path $Repo.Dir "config/windhawk-config-archive.zip"
$TempWindhawkConfig = New-TemporaryDirectory
Expand-Archive -Path $WindhawkArchive -DestinationPath $WindhawkConfig

# Copy the mods into the windhawk folder
$WindhawkDir = "$env:PROGRAMDATA\Windhawk"
$CollectedModsDir = Join-Path $TempWindhawkConfig "Mods"
Copy-Item "$CollectedModsDir\Engine\Mods" -Destination "$WindhawkDir\Engine\Mods" -Recurse -Force
Copy-Item "$CollectedModsDir\ModsSource" -Destination "$WindhawkDir\ModsSource" -Recurse -Force

# Copy the registry back
$CollectedRegDir = Join-Path $TempWindhawkConfig "Reg"
reg import "$CollectedRegDir\Engine-Mods.reg" | Out-Null
reg import "$CollectedRegDir\ENgine-ModsWritable.reg" | Out-Null

# Cleanup the created temporary folder
Remove-Item $TempWindhawkConfig -Recurse -Force -ErrorAction SilentlyContinue

# todo verify that this windhawk works


# Todo Check if needing config? (7-Zip, Everything, LocalSend, Unified Remote, Chrome Remote Desktop, afterburner, corsiar)
# ? When installing CRDH: "Notes: This is the hosting component for Chrome Remote Desktop. After installation, follow the instructions at https://remotedesktop.google.com/ to get connected."
