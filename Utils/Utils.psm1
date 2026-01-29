# Creates a new temporary directory and returns its path
function New-TemporaryDirectory {
  $TmpDir = [System.IO.Path]::GetTempPath()
  $Name = (New-Guid).ToString("N")
  $Path = Join-Path $TmpDir $Name
  New-Item -ItemType Directory -Path $Path | Out-Null
  return $Path
}

# Sync the systems PATH back to our environments path
function Sync-Path {
  $MachinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
  $UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
  $env:PATH = "$MachinePath;$UserPath"
}