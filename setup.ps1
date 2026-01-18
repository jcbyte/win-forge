$wingetPath = ".\winget"

# Package Installation though WinGet
Get-ChildItem -Path $wingetPath -File | ForEach-Object { 
  winget configure -f $_.FullName 
}

# ? is this how i should run my other files?
./wsl/setup_wsl.ps1