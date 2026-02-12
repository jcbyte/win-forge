# Configure Packages
# Post-install configuration for apps and tools
# The script applies custom settings, profiles, and themes saved in the `/config` directory
# Will configure extras installed via $Extras parameter

param(
  [string[]]$Extras
)

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# Package Configurations:
# - Google Chrome - In PostSetup
# - Spotify - In PostSetup
# - Discord - In PostSetup
# - Steam - In PostSetup
# - 7-Zip - No Configuration
# - Everything - Configured Here
# - Google Drive - In PostSetup
# - PowerToys - Configured Here + In PostSetup
# - LocalSend - No Configuration
# - Unified Remote - No Configuration
# - Chrome Remote Desktop - In PostSetup
# - Windhawk - Configured Here
# - Git = Configured Here
# - Visual Studio Code - In PostSetup
# - Docker Desktop - In PostSetup
# - Windows Terminal - Configured Here
# - Modern Powershell - Configured Here
# - Oh My Posh - Configured Here 
# - Visual Studios 2022 Build Tools - No Configuration
# - NVM - In InstallLang
# - Python Install Manager - In InstallLang
# - Rustup - No Configuration
# - JDK 25 - In InstallLang
# - NVIDIA App - In PostSetup
# - MSI Afterburner - Configured Here
# - Razer Synapse 4 - In PostSetup
# - Corsair iCUE 5 - No Configuration
# - OpenRGB - Configured Here

$GIT_NAME = "Joel Cutler"
$GIT_EMAIL = "joelcutler108@gmail.com"

# Configure Everything

Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Configuring" -NoNewline
Write-Host " Everything" -ForegroundColor Cyan

$EverythingConfigFile = Join-Path $Repo.Dir "config/everything-config.ini"
$EverythingExec = "$env:PROGRAMFILES\Everything\Everything.exe"

& $EverythingExec -install-config $EverythingConfigFile

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

$TerminalSettingsDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$TerminalSettingsSrc = Join-Path $Repo.Dir "config\windows-terminal.settings.json"
Copy-Item -Path $TerminalSettingsSrc -Destination $TerminalSettingsDest -Force

# Enable Oh My Posh with custom theme
Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
Write-Host " Enabling" -NoNewline
Write-Host " Oh My Posh" -ForegroundColor Cyan

$PwshProfile = Join-path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
$ProfileLocation = Split-Path -Path $PwshProfile
$ThemeDestLocation = Join-Path $ProfileLocation "PoshThemes"
$ThemeDest = Join-Path $ThemeDestLocation "joel.omp.json"
$ThemeSrc = Join-Path $Repo.Dir "config\joel.omp.json"
if (-not (Test-Path $ProfileLocation)) { New-Item -ItemType Directory -Path $ProfileLocation -Force | Out-Null }
if (-not (Test-Path $ThemeDestLocation)) { New-Item -ItemType Directory -Path $ThemeDestLocation -Force | Out-Null }
Copy-Item -Path $ThemeSrc -Destination $ThemeDest -Force
Add-Content -Path $PwshProfile -Value "oh-my-posh init pwsh --config `"$ThemeDest`" | Invoke-Expression"

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
$PowerToysDSCExec = "$env:PROGRAMFILES\PowerToys\PowerToys.DSC.exe"

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
Expand-Archive -Path $WindhawkArchive -DestinationPath $TempWindhawkConfig

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

# For each extra, configure it if required
foreach ($Extra in $Extras) {
  switch ($Extra) {
    # "NvidiaApp" { }
    "MSIAfterburner" {
      Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
      Write-Host " Configuring" -NoNewline
      Write-Host " MSI Afterburner" -ForegroundColor Cyan
      
      # Install Module for working with ini files
      Install-PackageProvider -Name NuGet -Force | Out-Null
      Install-Module PSIni -Force | Out-Null
      Import-Module PSIni

      $CustomMsiAfterburnerConfig = Join-Path $Repo.Dir "config/msi-afterburner-config.cfg"
      $PROGRAMFILES86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
      $MsiAfterburnerConfig = "$PROGRAMFILES86\MSI Afterburner\MSIAfterburner.cfg"

      # Load our config extra config and the existing
      $CustomConfig = Import-Ini -Path $CustomMsiAfterburnerConfig
      $Config = Import-Ini -Path $MsiAfterburnerConfig

      # Modify the config with our custom config
      foreach ($Section in $CustomConfig.Keys) {
        if (-not $Config.Contains($Section)) {
          $Config[$Section] = @{}
        }

        # Update each key within the section
        foreach ($Key in $CustomConfig[$Section].Keys) {
          $Config[$Section][$Key] = $CustomConfig[$Section][$Key]
        }
      }

      # Write back the modified content
      Export-Ini -InputObject $Config -Path $MsiAfterburnerConfig
    }
    # "RazerSynapse4" { } 
    # "CorsairICUE5" { }
    "OpenRGB" {
      Write-Host "🛠️" -NoNewline -ForegroundColor DarkCyan
      Write-Host " Configuring" -NoNewline
      Write-Host " OpenRGB" -ForegroundColor Cyan
      
      $OpenRgbData = Join-Path $env:APPDATA "OpenRGB"
      $OpenRgbSettingsSrc = Join-Path $Repo.Dir "config/openrgb-settings.json"
      $OpenRgbSettingsDest = Join-Path $OpenRgbData "OpenRGB.json"
      $OpenRgbProfileSrc = Join-Path $Repo.Dir "config/openrgb-profile.PurpleCat.orp"
      $OpenRgbProfileDest = Join-Path $OpenRgbData "PurpleCat.orp"

      # Copy settings and profile from config
      Copy-Item -Path $OpenRgbSettingsSrc -Destination $OpenRgbSettingsDest -Force
      Copy-Item -Path $OpenRgbProfileSrc -Destination $OpenRgbProfileDest -Force

      # Start OpenRGB selecting the copied profile
      $OpenRgbExec = "$env:PROGRAMFILES\OpenRGB\OpenRGB.exe"
      & $OpenRgbExec --startminimized --profile $OpenRgbProfileDest
    }
  }
}
