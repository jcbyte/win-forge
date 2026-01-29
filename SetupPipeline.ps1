param(
  [string]$RepoDir
)

$StepsPath = Join-Path $RepoDir "Steps"

# Execute each stage of the setup
$SetupSteps = @(
  [PSCustomObject]@{File = "ConfigureWindows.ps1"; Title = "Configure Windows" },
  [PSCustomObject]@{File = "InstallPackages.ps1"; Title = "Install Packages" },
  [PSCustomObject]@{File = "ConfigurePackages.ps1"; Title = "Configure Packages" },
  [PSCustomObject]@{File = "InstallLang.ps1"; Title = "Install Languages" },
  [PSCustomObject]@{File = "PostSetup.ps1"; Title = "Post Setup" }
)

Write-Host "Performing Setup"
foreach ($Step in $SetupSteps) {
  Write-Host "Performing Step: $($Step.Title)"
  $ScriptFile = Join-Path $StepsPath $Step.File
  & $ScriptFile
}
