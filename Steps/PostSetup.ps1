# Post Setup

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Todo ([string]$Title) {
  Write-Host "   $Title " -NoNewline -ForegroundColor Yellow
  [Console]::ReadKey() | Out-Null
  Write-Host "`r✅ $Title" -ForegroundColor DarkGray 
}

# Todo could this run "automatically" if approving
Write-Todo "Activate Windows (and Office), for troubleshooting: ``irm https://get.activated.win | iex``"

Write-Todo "Sign In to Chrome"
Write-Todo "Sign In to Spotify"
Write-Todo "Sign In to WhatsApp"
Write-Todo "Sign In to Steam"
Write-Todo "Sign In to VSCode"

# Todo could these be installed automatically if approving (winget again)
Write-Todo "Install Driver Software (NVIDIA, Afterburner, Razer Synapse, iCUE, Armoury Crate)"
