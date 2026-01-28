# Post Setup

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Todo ([string]$Title, [string]$ActionText = $null, [ScriptBlock]$Action = $null) {
  Write-Host "   $Title " -NoNewline -ForegroundColor Yellow
  [Console]::ReadKey() | Out-Null
  Write-Host "`r✅ $Title" -ForegroundColor DarkGray 
}

function Write-Todo-Action ([string]$Title, [string]$ActionText, [ScriptBlock]$Action ) {
  Write-Host "   $Title" -NoNewline -ForegroundColor Yellow
  Write-Host " - $ActionText [y?]" -NoNewline -ForegroundColor DarkGray

  $key = [Console]::ReadKey($true)
  if ($key.Key -in @('y', 'Y')) {
    Write-Host "`r   $Title" -ForegroundColor DarkGray 
    & $Action
  }

  Write-Host "`r✅ $Title" -ForegroundColor DarkGray 
}

# Remind user to Activate Windows, using advanced MAS Troubleshooting if required
Write-Todo-Action "Activate Windows (and Office)" "Start troubleshooting: https://massgrave.dev/" {
  irm https://get.activated.win | iex
}

# Remind User to Sign In to installed Applications
Write-Todo "Sign In to Chrome"
Write-Todo "Sign In to Spotify"
Write-Todo "Sign In to WhatsApp"
Write-Todo "Sign In to Steam"
Write-Todo "Sign In to VSCode"

# Todo could these be installed automatically if approving (winget again)
Write-Todo "Install Driver Software (NVIDIA, Afterburner, Razer Synapse, iCUE, Armoury Crate)"
