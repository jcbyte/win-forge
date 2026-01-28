# Install Dev

# Install and use latest Node.js LTS
Write-Host "Installing Latest Node.js LTS"
nvm install lts
nvm use lts

# Install latest Python3
Write-Host "Installing Latest Python 3"
py install 3
# Add pythons global shortcuts directory to PATH
$PythonBin = "$env:LOCALAPPDATA\Python\bin"
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = "$path;$PythonBin"
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
