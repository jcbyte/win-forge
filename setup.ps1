$wingetPath = ".\winget"

# Package Installation though WinGet
Get-ChildItem -Path $wingetPath -File | ForEach-Object { 
  winget configure -f $_.FullName 
}