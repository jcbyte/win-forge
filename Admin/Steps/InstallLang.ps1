# Development Environment Setup
# Installs and configures latest languages from version managers

# Install and use latest Node.js LTS
Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
Write-Host "Installing " -NoNewline
Write-Host "Latest Node.js LTS" -ForegroundColor Cyan

$env:NVM_HOME = [Environment]::GetEnvironmentVariable("NVM_HOME", "User")
$env:NVM_SYMLINK = [Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User")
$NvmExec = "$env:NVM_HOME\nvm.exe"

& $NvmExec install lts
& $NvmExec use lts

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


# Find installed Java location
$JdkRoot = "$env:PROGRAMFILES\Java"
$JdkPath = Get-ChildItem $JdkRoot -Directory | Where-Object { $_.Name -like "jdk-25*" }
$JavaHome = $JdkPath.FullName

# Set Java system variables
setx JAVA_HOME $JavaHome /M | Out-Null
$JavaBin = "$JavaHome\bin"
$Path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$NewPath = "$Path;$JavaBin"
[Environment]::SetEnvironmentVariable("PATH", $NewPath, "Machine")
