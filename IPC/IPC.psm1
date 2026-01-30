
Import-Module (Join-Path $PSScriptRoot "..\Utils")

# Open or create a global event handle with a specified name
function Get-GlobalEventHandle([string]$Name) {
  # Set security policy so any privilege level has access
  $AllowEveryone = [System.Security.AccessControl.EventWaitHandleAccessRule]::new(
    "Everyone",
    [System.Security.AccessControl.EventWaitHandleRights]::FullControl,
    [System.Security.AccessControl.AccessControlType]::Allow
  )
  $Security = New-Object System.Security.AccessControl.EventWaitHandleSecurity
  $Security.AddAccessRule($AllowEveryone)

  # Create a global handle name
  $HandleName = "Global\$($Repo.Name)_$Name"

  # Open or create a event handle object
  return [System.Threading.EventWaitHandle]::new(
    $false,
    [System.Threading.EventResetMode]::ManualReset,
    $HandleName,
    [ref]$false,
    $security
  )
}
