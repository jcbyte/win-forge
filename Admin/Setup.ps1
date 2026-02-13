# Performs privileged (admin-level) setup tasks done in `/steps`
# Signals with the user script, allowing safe continuation and system restart
# Handles system restart when needed, resuming execution automatically
# Performs cleanup after all setup stages complete.

param (
  [int]$ResumeStep = 0
)

Import-Module (Join-Path $PSScriptRoot "..\Utils")

function Invoke-Cleanup {
  # Perform cleanup and stop the script (host)
  $CleanupScript = Join-Path $Repo.Dir "Cleanup.ps1"
  & $CleanupScript
  Exit
}

$ExtrasPath = Join-Path $Repo.Dir ".extras-config.xml"

# Perform first time steps
if ($ResumeStep -eq 0) {
  # Communicate with client script
  Import-Module (Join-Path $PSScriptRoot "..\IPC")

  # Get Event handles shared between user and admin setup scripts
  $UserReady = Get-GlobalEventHandle("UserReady")
  $AdminReady = Get-GlobalEventHandle("AdminReady")
  $UserAck = Get-GlobalEventHandle("UserAck")
  $UserDone = Get-GlobalEventHandle("UserDone")

  Write-Host "⏳ Waiting for user setup..." -ForegroundColor Yellow

  # Ensure the user setup script is ready so that we don't perform admin setup without user setup (causing side effects)
  if ($UserReady.WaitOne(60000)) {
    Write-Host "✅ User setup is ready!" -ForegroundColor Green
  }
  else {
    Write-Host "❌ User setup did not become ready in time!" -NoNewline -ForegroundColor Red
    Write-Host " (Timeout)" -ForegroundColor DarkGray

    Invoke-Cleanup
  }

  Write-Host "🧩" -NoNewline -ForegroundColor DarkCyan
  Write-Host "Pick Additional Software:" -ForegroundColor Cyan

  # Ask which extra packages should be included
  $Extras = @()
  Write-Prompt -Question "Nvidia App" { $script:Extras += "NvidiaApp" }
  Write-Prompt -Question "MSI Afterburner" { $script:Extras += "MSIAfterburner" }
  Write-Prompt -Question "Razer Synapse 4" { $script:Extras += "RazerSynapse4" }
  Write-Prompt -Question "Corsair iCUE 5" { $script:Extras += "CorsairICUE5" }
  Write-Prompt -Question "OpenRGB" { $script:Extras += "OpenRGB" }
  
  # Save them in a file so they are not lost when restarting
  $Extras | ConvertTo-Json -Compress | Out-File $ExtrasPath

  # Notify user setup script that we are ready as this could've taken some time answering questions
  Write-Host "📢 Notifying user setup that we are ready" -ForegroundColor Yellow
  $AdminReady.Set() | Out-Null

  # Ensure that the user setup script is still active so that we don't perform admin setup without user setup (causing side effects)
  if (-not $UserAck.WaitOne(5000)) {
    Write-Host "❌ User setup did not respond" -NoNewline -ForegroundColor Red
    Write-Host " (Timeout)" -ForegroundColor DarkGray

    Invoke-Cleanup
  }
}
else {
  Write-Host "▶️ Continuing $($Repo.Name) Setup" -ForegroundColor Magenta

  # Load the extra packages from the file
  $Extras = Get-Content $ExtrasPath | ConvertFrom-Json
}

# Execute each stage of the admin setup
$StepsPath = Join-Path $PSScriptRoot "Steps"
$SetupSteps = @(
  [PSCustomObject]@{File = "ConfigureWindows.ps1"; Title = "Configuring Windows" },
  [PSCustomObject]@{File = "EnableWSL.ps1"; Title = "Enabling WSL"; PostScript = {
      # After this script, we must restart the computer
      param([int]$i)

      # Ensure the user script has completed before we restart the computer
      Write-Host "⏳ Ensuring user script has completed" -ForegroundColor Yellow
      if ($UserDone.WaitOne(180000)) {
        Write-Host "✅ User script has completed" -ForegroundColor Green
      }
      else {
        # ? This could fail if user setup takes substantially longer than admin setup to this point, if so we could increase timeout
        Write-Host "❌ User script did not complete in time" -ForegroundColor Red
        Write-Host "⚠️ This is unusual, and may have caused side effects" -ForegroundColor Red
        
        # Perform cleanup and stop the script (host)
        $CleanupScript = Join-Path $Repo.Dir "Cleanup.ps1"
        & $CleanupScript
        Exit
      }

      Write-Host "🔄️ Restarting System" -ForegroundColor Magenta
      
      # Restart the computer and running this script afterwards continuing from the next stage
      New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "ResumeSetup" -Value "PowerShell -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ResumeStep $($i + 1)" -PropertyType String -Force
      Restart-Computer -Force
      # Stop continued execution
      Exit 
    };
  }
  [PSCustomObject]@{File = "ConfigureWSL.ps1"; Title = "Configure WSL" },
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Installing Packages"; Args = @{"Extras" = $Extras } },
  [PSCustomObject]@{File = "InstallOffice.ps1"; Title = "Installing Office" },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configuring Packages"; Args = @{"Extras" = $Extras } },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Installing Languages" },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Performing Post Setup"; Args = @{"Extras" = $Extras } }
)
Invoke-ScriptPipeline $StepsPath $SetupSteps $ResumeStep

Write-Host "✅ Setup Complete" -ForegroundColor Green

# Perform cleanup
Invoke-Cleanup
