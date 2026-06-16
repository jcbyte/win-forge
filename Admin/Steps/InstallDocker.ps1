# Docker Installation Stage
# Installs Docker Desktop using WinGet.

Import-Module (Join-Path $PSScriptRoot "..\..\Utils")

# Install docker
# This is done separately, as WSL must be enabled before it can be installed
Install-WinGetUnattended ([PSCustomObject]@{ Id = "Docker.DockerDesktop"; Title = "Docker Desktop"; Scope = "machine" })

# Synchronise the PATH, as installs may have effected it
Sync-Path
