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

# Install WinGet packages unattended
# $Package = {Id:string; Title?:string; Privilege?:string; Override?:string}
# User credentials in $Cred are required when installing with "user" privilege
function Install-WinGetUnattended([PSCustomObject]$Package, [PSCredential]$Cred = $null) {
  Write-Host "🔷 Installing " -NoNewline
  if ($Package.Title) { Write-Host $Package.Title -ForegroundColor Cyan }
  else { Write-Host $Package.Id -ForegroundColor Cyan }

  # Add override to command if set
  $WinGetCmd = "winget install -e --id $($Package.Id) --silent --accept-source-agreements --accept-package-agreements --source winget"
  if ($Package.Override) { $WinGetCmd += " --override `"$($Package.Override)`"" }

  # Default to admin privilege unless explicitly set
  $Privilege = $Package.Privilege
  if (-not $Privilege) { $Privilege = "admin" }

  switch ($Privilege) {
    "admin" {
      # Perform the install in this elevated shell
      Invoke-Expression $WinGetCmd
    }
    "user" { 
      if ($Cred) {
        # Perform the install in a new shell with user permission
        $ArgList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $WinGetCmd)
        Start-Process -FilePath PowerShell.exe -ArgumentList $ArgList -Credential $Cred -Wait
      }
      else {
        Write-Host "Install requires user privilege, not given (ignoring)" -ForegroundColor Red
      }
    }
  }
}
