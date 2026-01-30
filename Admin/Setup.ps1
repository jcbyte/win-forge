Import-Module (Join-Path $PSScriptRoot "..\IPC")

$ClientReady = Get-GlobalEventHandle("ClientReady")
$ServerAck = Get-GlobalEventHandle("ServerAck")
$ClientDone = Get-GlobalEventHandle("ClientDone")

Write-Host "⏳ Waiting for user setup..." -ForegroundColor Yellow

if ($ClientReady.WaitOne(30000)) {
  Write-Host "✅ user setup is ready!" -ForegroundColor Green
  $ServerAck.Set() | Out-Null
}
else {
  Write-Host "❌ user setup did not become ready in time!" -NoNewline -ForegroundColor Red
  Write-Host " (Timeout)" -ForegroundColor DarkGray
  Exit
}

# todo work here

Write-Host "⏳ Ensuring user script has completed" -ForegroundColor Yellow

if ($ClientDone.WaitOne(120000)) {
  Write-Host "✅ User script has completed" -ForegroundColor Green
}
else {
  Write-Host "❌ User script did not complete in time" -ForegroundColor Red
  Write-Host "⚠️ This is unusual, and may have caused side effects" -ForegroundColor Red
  Exit
}

# todo work after user completes here





# todo remove after dev
[Console]::ReadKey() | Out-Null