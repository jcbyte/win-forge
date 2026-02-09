# Export constants for repo details
Set-Variable -Name Repo -Value ([PSCustomObject]@{
    Name     = "win-forge"
    LocalDir = Join-Path $env:LOCALAPPDATA "jcbyte.win-forge"
    Dir      = (Get-Item $PSScriptRoot).Parent.FullName
  })
Export-ModuleMember -Variable Repo

# Creates a new temporary directory and returns its path
function New-TemporaryDirectory {
  $TmpDir = [System.IO.Path]::GetTempPath()
  $Name = (New-Guid).ToString("N") # ? HIghly unlikely change of collision
  $Path = Join-Path $TmpDir $Name
  New-Item -ItemType Directory -Path $Path | Out-Null
  return $Path
}
Export-ModuleMember -Function New-TemporaryDirectory

# Sync the systems PATH back to our environments path
function Sync-Path {
  $MachinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
  $UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
  $env:PATH = "$MachinePath;$UserPath"
}

# Sequentially invoke given scripts from a parent directory
# $Scripts = { File:string; Title:string; RefreshPath?:boolean; Args?:hashtable; PostScript?:ScriptBlock }[]
function Invoke-ScriptPipeline([string]$ParentDir, [PSCustomObject[]]$Scripts, [int]$StartAt = 0) {
  for ($i = $StartAt; $i -lt $Scripts.Count; $i++) {
    $Script = $Scripts[$i];

    Write-Host "`n⚡ $($Script.Title)" -ForegroundColor Cyan
    $ScriptFile = Join-Path $ParentDir $Script.File
    $ScriptArgs = if ($Script.Args) { $Script.Args } else { @{} }
    & $ScriptFile @ScriptArgs
  
    # Refresh PATH from the systems environment variables if required
    if ($Script.RefreshPath) { Sync-Path }

    # Perform the PostScript if provided
    if ($Script.PostScript) { & $Script.PostScript $i }
  }
}
Export-ModuleMember -Function Invoke-ScriptPipeline

# Install WinGet packages unattended
# $Package = {Id:string; Title?:string; Override?:string}
function Install-WinGetUnattended([PSCustomObject]$Package) {
  Write-Host "🔷" -NoNewline -ForegroundColor DarkCyan
  Write-Host " Installing " -NoNewline
  if ($Package.Title) { Write-Host $Package.Title -ForegroundColor Cyan }
  else { Write-Host $Package.Id -ForegroundColor Cyan }

  # Add override to command if set
  $WinGetCmd = "winget install -e --id $($Package.Id) --silent --accept-source-agreements --accept-package-agreements --source winget --scope machine"
  # todo test all packages with scope machine
  if ($Package.Override) { $WinGetCmd += " --override `"$($Package.Override)`"" }

  # Perform the install
  Invoke-Expression $WinGetCmd
}
Export-ModuleMember -Function Install-WinGetUnattended

# Write a todo/question prompt awaiting user response
# Default as a "todo", can become a "Question" using the switch
function Write-Prompt ([string]$Title, [scriptblock]$Action = $null, [string]$ActionText = $null, [switch]$Question) {
  Write-Host "   $Title" -NoNewline -ForegroundColor Yellow

  if ($Question) {
    Write-Host " [y/n]" -NoNewline -ForegroundColor DarkGray
  }
  elseif ($Action) {
    if ($ActionText) {
      Write-Host " - $ActionText" -NoNewline -ForegroundColor DarkGray
    }
    Write-Host " [y?]" -NoNewline -ForegroundColor DarkGray
  }

  # Wait for a key to be pressed and check if it is an accept key
  $Key = [Console]::ReadKey($true)
  $AcceptAction = $Key.Key -in @('y', 'Y')

  if ($Question) {
    if ($AcceptAction) {
      Write-Host "`r⏳" -NoNewline
      Write-Host " $Title" -NoNewline -ForegroundColor DarkGray 
      
      & $Action

      Write-Host "`r✅" -NoNewline -ForegroundColor Green
      Write-Host " $Title" 
    }
    else {
      Write-Host "`r❌" -NoNewline -ForegroundColor Red
      Write-Host " $Title" 
    }
  }
  else {
    if ($AcceptAction) {
      Write-Host "`r⏳" -NoNewline
      Write-Host " $Title" -NoNewline -ForegroundColor DarkGray 

      & $Action
    }

    Write-Host "`r✅" -NoNewline -ForegroundColor Green
    Write-Host " $Title" 
  }
}
Export-ModuleMember -Function Write-Prompt
