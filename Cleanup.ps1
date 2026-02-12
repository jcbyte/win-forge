# Perform cleanup actions after setup completes (or fails)
# Removes the temporary cloned repository

Import-Module (Join-Path $PSScriptRoot "Utils")

Write-Host "🧹" -NoNewline -ForegroundColor Blue
Write-Host " Performing Cleanup" -ForegroundColor Cyan

# Remove the cloned repository to cleanup
if ((Test-Path $Repo.LocalDir)) {
  Remove-Item $Repo.LocalDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Wait for user input before closing
Write-Host "🔄️ A restart is recommended!" -ForegroundColor Yellow
Write-Host "Press Enter to Exit..." -NoNewline -ForegroundColor DarkGray
Read-Host
