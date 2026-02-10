# Installs Office using Office Deployment Tool

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

$ODTUrl = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
$TempSetupDir = New-TemporaryDirectory
$ODTExe = Join-Path $TempSetupDir "setup.exe"
# Use local configuration file for office version
# ? This configuration will always install Office 2024 LTSC (Word, PowerPoint, Excel)
$OfficeConfiguration = Join-Path $Repo.Dir "config\office-configuration.xml"

Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
Write-Host " Installing" -NoNewline
Write-Host " Office 2024 LTSC" -NoNewline -ForegroundColor Cyan
Write-Host " (Word, PowerPoint, Excel)" -ForegroundColor DarkGray

# Download ODT tool and install ("configure") though file
Start-BitsTransfer -Source $ODTUrl -Destination $ODTExe
& $ODTExe /configure $OfficeConfiguration
