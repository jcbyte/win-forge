# Development Environment Setup
# Installs and configures latest languages from version managers

# Install and use latest Node.js LTS
Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
Write-Host "Installing " -NoNewline
Write-Host "Latest Node.js LTS" -ForegroundColor Cyan
nvm install lts
nvm use lts

# Install latest Python3
Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
Write-Host "Installing " -NoNewline
Write-Host "Latest Python 3" -ForegroundColor Cyan
py install 3
# Add pythons global shortcuts directory to PATH
$PythonBin = "$env:LOCALAPPDATA\Python\bin"
$Path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$NewPath = "$Path;$PythonBin"
[Environment]::SetEnvironmentVariable("PATH", $NewPath, "Machine")

# Set Java system variables
# todo find correct jdk location (dynamically?)
$JavaHome = "C:\Program Files\Java\jdk-25.0.2"
setx JAVA_HOME $JavaHome /M | Out-Null
$JavaBin = "$JavaHome\bin"
$Path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$NewPath = "$Path;$JavaBin"
[Environment]::SetEnvironmentVariable("PATH", $NewPath, "Machine")
