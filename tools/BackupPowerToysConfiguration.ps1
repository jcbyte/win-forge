# Tool for recording the state of the current PowerToys Configuration
# This can then be used to restore it when setting up a new device

$ConfigFile = "powertoys-dsc-config.json"
$PowerToysDSCExec = "$env:ProgramFiles\PowerToys\PowerToys.DSC.exe"

$Backup = @{}

# Get settings from each module
# ? The `App` module contains Global config (including which modules are enabled)
$Modules = & $PowerToysDSCExec modules --resource 'settings'
foreach ($Module in $Modules) {
  $Config = & $PowerToysDSCExec export --resource 'settings' --module $Module | ConvertFrom-Json
  $Backup[$Module] = $Config
}

# Save backup
$Backup | ConvertTo-Json -Depth 20 -Compress | Out-File $ConfigFile
