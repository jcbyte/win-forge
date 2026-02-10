# Post-Setup Tasks
# Guides the user through remaining manual configuration steps though interactive prompts

param(
  [PSCustomObject[]]$ExtraPostPrompts
)

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# Remind user to Activate Windows, using advanced MAS Troubleshooting if required
Write-Prompt "Activate Windows (and Office)" { Invoke-RestMethod https://get.activated.win | Invoke-Expression } "Open troubleshooting: https://massgrave.dev/" 

# Remind User to Sign In to installed Applications
Write-Prompt "Sign In to Chrome" { Start-Process chrome } "Open Chrome"
Write-Prompt "Sign In to Spotify"
Write-Prompt -Question "Customise Spotify Client" { Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/SpotX/refs/heads/main/run.ps1') } -new_theme" } "Use SpotX: https://github.com/SpotX-Official/SpotX"
Write-Prompt "Sign In to Discord"
Write-Prompt "Sign In to Steam"
Write-Prompt "Sign In to Google Drive"
Write-Prompt "Configure PowerToys Command Pallette" { Start-Process powertoys } "Open PowerToys"
Write-Prompt "Enable Chrome Remote Desktop" { Start-Process chrome '--new-window https://remotedesktop.google.com/access' } "Open https://remotedesktop.google.com/access"
Write-Prompt "Sign In to Docker Desktop"
Write-Prompt "Sign In to VS Code" { code } "Open VS Code"

foreach ($ExtraPrompt in $ExtraPostPrompts) { Write-Prompt @ExtraPrompt }
