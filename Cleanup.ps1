# todo doc

Import-Module (Join-Path $PSScriptRoot "Utils")

# Remove the cloned repository to cleanup
if ((Test-Path $Repo.LocalDir)) {
  Write-Host "del $($Repo.LocalDir)"
  Remove-Item $Repo.LocalDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Wait for user input before closing
Write-Host "Press Enter to Exit..." -NoNewline
[Console]::ReadKey() | Out-Null
