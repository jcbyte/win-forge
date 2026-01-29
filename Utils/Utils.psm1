function New-TemporaryDirectory {
  $TmpDir = [System.IO.Path]::GetTempPath()
  $Name = (New-Guid).ToString("N")
  $Path = Join-Path $TmpDir $Name
  New-Item -ItemType Directory -Path $Path | Out-Null
  return $Path
}

function Sync-Path {
  $MachinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
  $UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
  $env:PATH = "$MachinePath;$UserPath"
}