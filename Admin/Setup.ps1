
# Create a pipe for IPC between admin and user setups
$PipeName = "TestPipe"

# Allow user access to pipe, as the client (User\Setup) will be underprivileged
$PipeSecurity = [System.IO.Pipes.PipeSecurity]::new()
$PipeSecurity.AddAccessRule([System.IO.Pipes.PipeAccessRule]::new(
    "Everyone",
    [System.IO.Pipes.PipeAccessRights]::FullControl,
    [System.Security.AccessControl.AccessControlType]::Allow
  ))

$PipeServer = [System.IO.Pipes.NamedPipeServerStream]::new(
  $PipeName,
  [System.IO.Pipes.PipeDirection]::In,
  1,
  [System.IO.Pipes.PipeTransmissionMode]::Byte,
  [System.IO.Pipes.PipeOptions]::None,
  0,
  0,
  $PipeSecurity
)

Write-Host "Waiting for client..."
$PipeServer.WaitForConnection()
Write-Host "Client connected."

# Create a reader for incoming messages
$Reader = [System.IO.StreamReader]::new($PipeServer)

# Read lines until client disconnects
while (($Line = $Reader.ReadLine()) -ne $null) {
  Write-Host "Received from client: $Line" # todo wait for a ready message
}

# Clean up pipe
$Reader.Close()
$PipeServer.Dispose()






[Console]::ReadKey() | Out-Null
