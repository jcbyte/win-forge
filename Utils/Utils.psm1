# Export constants for repo details
$Repo = [PSCustomObject]@{
  Name     = "win-forge"
  LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.win-forge"
  Dir      = (Get-Item $PSScriptRoot).Parent.FullName
}
Export-ModuleMember -Variable Repo

# Creates a new temporary directory and returns its path
function New-TemporaryDirectory {
  $TmpDir = [System.IO.Path]::GetTempPath()
  $Name = (New-Guid).ToString("N") # ? HIghly unlikely change of collision
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

# Sequentially invoke given scripts from a parent directory
# $Scripts = { File:string; Title:string; RefreshPath?:boolean }[]
function Invoke-ScriptPipeline([string]$ParentDir, [PSCustomObject[]]$Scripts) {
  # todo could this take a "reset" parameter??
  foreach ($Step in $Steps) {
    Write-Host "`n⚡ $($Step.Title)" -ForegroundColor Cyan
    $ScriptFile = Join-Path $ParentDir $Step.File
    & $ScriptFile -Cred $Cred
  
    # Refresh PATH from the systems environment variables if required
    if ($Step.RefreshPath) { Sync-Path }
  }
}

# Install WinGet packages unattended
# $Package = {Id:string; Title?:string; Override?:string}
function Install-WinGetUnattended([PSCustomObject]$Package) {
  Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
  Write-Host " Installing " -NoNewline
  if ($Package.Title) { Write-Host $Package.Title -ForegroundColor Cyan }
  else { Write-Host $Package.Id -ForegroundColor Cyan }

  # Add override to command if set
  $WinGetCmd = "winget install -e --id $($Package.Id) --silent --accept-source-agreements --accept-package-agreements --source winget"
  if ($Package.Override) { $WinGetCmd += " --override `"$($Package.Override)`"" }

  # Perform the install
  Invoke-Expression $WinGetCmd
}
