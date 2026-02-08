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
  $ExtraPackages = @()
  $ExtraPostPrompts = @()
  Write-Prompt -Question "Install Nvidia App" { 
    # ! Nvidia App is currently not within the WinGet repository
    # ! https://github.com/microsoft/winget-pkgs/discussions/200910
    $script:ExtraPostPrompts += , @("Manually install Nvidia App", { Start-Process chrome '--new-window https://www.nvidia.com/en-eu/software/nvidia-app/' }, "Open Download Page")
    $script:ExtraPostPrompts += , @("Install Graphics Drivers from Nvidia App")
  }
  Write-Prompt -Question "Install MSI Afterburner" { 
    $script:ExtraPackages += [PSCustomObject]@{Id = "Guru3D.Afterburner"; Title = "MSI Afterburner" }
  }
  Write-Prompt -Question "Install Razer Synapse 4" { 
    # ? This will open, and will always install Synapse 4
    $script:ExtraPackages += [PSCustomObject]@{Id = "RazerInc.RazerInstaller.Synapse4"; Title = "Razer Synapse 4" }
    $script:ExtraPostPrompts += , @("Sign In and Configure Razer Synapse 4")
  }
  Write-Prompt -Question "Install Corsair iCUE 5" { 
    # ? This will always install iCUE 5
    $script:ExtraPackages += [PSCustomObject]@{Id = "Corsair.iCUE.5"; Title = "Corsair iCUE 5" }
    $script:ExtraPostPrompts += , @("Configure iCUE 5")
  }
  Write-Prompt -Question "Install OpenRGB" {
    $script:ExtraPackages += [PSCustomObject]@{Id = "OpenRGB.OpenRGB"; Title = "OpenRGB" }
    $script:ExtraPostPrompts += , @("Configure OpenRGB")
  }
  
  # Save them in a file so they are not lost when restarting
  $Extras = [PSCustomObject]@{
    Packages    = $ExtraPackages
    PostPrompts = $ExtraPostPrompts
  }
  $Extras | Export-Clixml -Path $ExtrasPath

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
  $Extras = Import-Clixml -Path $ExtrasPath

  # Re-hydrate ScriptBlocks
  foreach ($Prompt in $Extras.PostPrompts) {
    # If there is a second item and it's a string rebuild it as a ScriptBlock
    if ($Prompt.Count -ge 2 -and $Prompt[1] -is [string]) {
      $Prompt[1] = [ScriptBlock]::Create($Prompt[1].Trim())
    }
  }
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
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Installing Packages"; Args = @{"ExtraPackages" = $Extras.Packages }; RefreshPath = $true },
  [PSCustomObject]@{File = "InstallOffice.ps1"; Title = "Installing Office" },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configuring Packages" },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Installing Languages"; RefreshPath = $true },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Performing Post Setup"; Args = @{"ExtraPostPrompts" = $Extras.PostPrompts } }
)
Invoke-ScriptPipeline $StepsPath $SetupSteps $ResumeStep

Write-Host "✅ Setup Complete" -ForegroundColor Green

# Perform cleanup
Invoke-Cleanup
