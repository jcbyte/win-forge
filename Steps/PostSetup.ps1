# Post Setup

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Todo ([string]$Title, [string]$ActionText, [ScriptBlock]$Action ) {
  Write-Host "   $Title" -NoNewline -ForegroundColor Yellow

  if ($Action -ne $null) {
    # Throw is provided an action without description
    if (-not $ActionText) {
      Throw "ActionText is required when Action is provided."
    }
    
    # If action is provided, ask for confirmation
    Write-Host " - $ActionText [y?]" -NoNewline -ForegroundColor DarkGray

    $Key = [Console]::ReadKey($true)
    if ($Key.Key -in @('y', 'Y')) {
      Write-Host "`r   $Title" -ForegroundColor DarkGray 
      & $Action
    }
  }
  else {
    # Otherwise wait for any key to be pressed to confirm
    [Console]::ReadKey() | Out-Null

  }

  Write-Host "`r✅ $Title" -ForegroundColor DarkGray 
}

# Remind user to Activate Windows, using advanced MAS Troubleshooting if required
Write-Todo "Activate Windows (and Office)" "Open troubleshooting: https://massgrave.dev/" { irm https://get.activated.win | iex }

# Remind User to Sign In to installed Applications
Write-Todo "Sign In to Chrome"
Write-Todo "Sign In to Spotify"
Write-Todo "Sign In to Steam"
Write-Todo "Sign In to VSCode"

# Todo could these be installed automatically if approving (winget again)
Write-Todo "Install Driver Software (NVIDIA, Afterburner, Razer Synapse, iCUE, Armoury Crate)"
