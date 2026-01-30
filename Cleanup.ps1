$REPO_NAME = "win-forge"
$LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.$REPO_NAME"
$RepoDir = Join-Path $LocalDir "$REPO_NAME-main"

# todo how do i share these variables around (and Dev)

# Remove the cloned repository to cleanup
if ((Test-Path $LocalDir)) {
  Write-Host "del $LocalDir"
  Remove-Item $LocalDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Wait for user input before closing
Write-Host "Press Enter to Exit..." -NoNewline
[Console]::ReadKey() | Out-Null
