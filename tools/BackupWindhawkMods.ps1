# Tool for creating an archive of the current Windhawk mods
# This can then be used to restore it when setting up a new device

Import-Module (Join-Path $PSScriptRoot "..\Utils")

$ArchiveFile = "windhawk-config-archive.zip"

$TempDir = New-TemporaryDirectory

$WindhawkDir = "$env:PROGRAMDATA\Windhawk"
$CollectedModsDir = Join-Path $TempDir "Mods"
Copy-Item "$WindhawkDir\Engine\Mods" -Destination "$CollectedModsDir\Engine\Mods" -Recurse -Force
Copy-Item "$WindhawkDir\ModsSource" -Destination "$CollectedModsDir\ModsSource" -Recurse -Force

$CollectedRegDir = Join-Path $TempDir "Reg"
New-Item -Path $CollectedRegDir -ItemType Directory -Force | Out-Null
reg export "HKLM\SOFTWARE\Windhawk\Engine\Mods" "$CollectedRegDir\Engine-Mods.reg" /y | Out-Null
reg export "HKLM\SOFTWARE\Windhawk\Engine\ModsWritable" "$CollectedRegDir\ENgine-ModsWritable.reg" /y | Out-Null

$Items = Get-ChildItem -Path $TempDir -Force | ForEach-Object { $_.FullName }
Compress-Archive -Path $Items -DestinationPath $ArchiveFile -Force
