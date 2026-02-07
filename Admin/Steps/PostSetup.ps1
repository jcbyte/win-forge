# Post-Setup Tasks
# Guides the user through remaining manual configuration steps though interactive prompts

param(
  [PSCustomObject[]]$ExtraPackages
)

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# Remind user to Activate Windows, using advanced MAS Troubleshooting if required
Write-Prompt "Activate Windows (and Office)" { Invoke-RestMethod https://get.activated.win | Invoke-Expression } "Open troubleshooting: https://massgrave.dev/" 

# Remind User to Sign In to installed Applications
Write-Prompt "Sign In to Chrome"
Write-Prompt "Sign In to Spotify"
Write-Prompt "Sign In to Steam"
Write-Prompt "Sign In to VSCode"

foreach ($ExtraPackage in $ExtraPackages) { Write-Prompt "Configure $($ExtraPackage.Title)" }
