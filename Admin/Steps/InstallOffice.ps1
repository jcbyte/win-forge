# Installs Office using Office Deployment Tool

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

$ODTUrl = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
$TempSetupDir = New-TemporaryDirectory
$ODTExe = Join-Path $TempSetupDir "setup.exe"
# Use local configuration file for office version
# ? This configuration will always install Office 2024 LTSC (Word, PowerPoint, Excel)
$OfficeConfiguration = Join-Path $RepoDir "config\OfficeConfiguration.xml"

# Download ODT tool and install ("configure") though file
Write-Host "Installing Office 2024 LTSC (Word, PowerPoint, Excel)"
Start-BitsTransfer -Source $ODTUrl -Destination $ODTExe
& $ODTExe /configure $OfficeConfiguration
