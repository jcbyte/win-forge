Import-Module (Join-Path $PSScriptRoot "..\IPC")

$ServerReady = Get-EventHandle("ServerReady")
$ClientReady = Get-EventHandle("ClientReady")
$ClientDone = Get-EventHandle("ClientDone")

Write-Host "wairting"

if ($ClientReady.WaitOne(30000)) {
  $ServerReady.Set();
  Write-Host "Client ready"
}
else {
  Write-Error "Client did not ready in time"
}

if ($ClientDone.WaitOne(30000)) {
  Write-Host "Client done, server continuing..."
}
else {
  Write-Error "Client did not finish in time"
}



[Console]::ReadKey() | Out-Null
