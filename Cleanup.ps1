$REPO_NAME = "win-forge"
$LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.$REPO_NAME"
$RepoDir = Join-Path $LocalDir "$REPO_NAME-main"

# Remove the cloned repository to cleanup
if ((Test-Path $LocalDir)) {
  Write-Host "del $LocalDir"
  Remove-Item $LocalDir -Recurse -Force -ErrorAction SilentlyContinue
}