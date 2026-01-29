# Windows Configuration and De-bloating
# todo doc

Write-Host "🛠️ Configuring and Debloating Windows using" -NoNewline
Write-Host " Win11Debloat" -NoNewline -ForegroundColor Cyan
Write-Host " (https://github.com/Raphire/Win11Debloat)" -ForegroundColor DarkGray

$WindowsConfigSwitches = @(
  "DisableTelemetry", "DisableSuggestions", "DisableEdgeAds",
  "DisableDesktopSpotlight", "DisableLockscreenTips",
  "DisableBing", "DisableCopilot", "DisableRecall", "DisableEdgeAI", "DisableNotepadAI",
  "RevertContextMenu", "DisableStickyKeys",
  "ShowHiddenFolders", "ShowKnownFileExt",
  "EnableDarkMode",
  "CombineTaskbarAlways", "CombineMMTaskbarAlways", "MMTaskbarModeActive",
  "HideSearchTb", "HideTaskview", "HideChat", "EnableEndTask", "EnableLastActiveClick",
  "HideHome", "HideGallery", "ExplorerToThisPC"
)
$WindowsConfigParams = @{}
$WindowsConfigSwitches | ForEach-Object { $WindowsConfigParams[$_] = $true }

$RemoveApps = @(
  # Default removal - Microsoft apps
  "Clipchamp.Clipchamp",
  "Microsoft.3DBuilder",
  "Microsoft.549981C3F5F10", # Cortana app
  "Microsoft.BingFinance",
  "Microsoft.BingFoodAndDrink",
  "Microsoft.BingHealthAndFitness",
  "Microsoft.BingNews",
  "Microsoft.BingSports",
  "Microsoft.BingTranslator",
  "Microsoft.BingTravel",
  "Microsoft.Copilot",
  "Microsoft.Messaging",
  "Microsoft.MicrosoftJournal",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftPowerBIForWindows",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.MixedReality.Portal",
  "Microsoft.NetworkSpeedTest",
  "Microsoft.News",
  "Microsoft.Office.OneNote",
  "Microsoft.Office.Sway",
  "Microsoft.OneConnect",
  "Microsoft.Print3D",
  "Microsoft.SkypeApp",
  "Microsoft.Todos",
  "Microsoft.Windows.DevHome",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.WindowsMaps",
  "Microsoft.WindowsSoundRecorder",
  "Microsoft.XboxApp",
  "Microsoft.ZuneVideo",
  "MicrosoftCorporationII.MicrosoftFamily",
  "MicrosoftTeams",
  "MSTeams",
  # Default removal - Third party apps
  "ActiproSoftwareLLC",
  "AdobeSystemsIncorporated.AdobePhotoshopExpress",
  "Amazon.com.Amazon",
  "AmazonVideo.PrimeVideo",
  "Asphalt8Airborne ",
  "AutodeskSketchBook",
  "CaesarsSlotsFreeCasino",
  "COOKINGFEVER",
  "CyberLinkMediaSuiteEssentials",
  "DisneyMagicKingdoms",
  "Disney",
  "DrawboardPDF",
  "Duolingo-LearnLanguagesforFree",
  "EclipseManager",
  "Facebook",
  "FarmVille2CountryEscape",
  "fitbit",
  "Flipboard",
  "HiddenCity",
  "HULULLC.HULUPLUS",
  "iHeartRadio",
  "Instagram",
  "king.com.BubbleWitch3Saga",
  "king.com.CandyCrushSaga",
  "king.com.CandyCrushSodaSaga",
  "LinkedInforWindows",
  "MarchofEmpires",
  "Netflix",
  "NYTCrossword",
  "OneCalendar",
  "PandoraMediaInc",
  "PhototasticCollage",
  "PicsArt-PhotoStudio",
  "Plex",
  "PolarrPhotoEditorAcademicEdition",
  "Royal Revolt",
  "Shazam",
  "Sidia.LiveWallpaper",
  "SlingTV",
  "Spotify",
  "TikTok",
  "TuneInRadio",
  "Twitter",
  "Viber",
  "WinZipUniversal",
  "Wunderlist",
  "XING",
  # Not default removal
  "Microsoft.MSPaint",
  "Microsoft.OneDrive",
  "Microsoft.People",
  "Microsoft.RemoteDesktop",
  "Microsoft.Whiteboard",
  "Microsoft.windowscommunicationsapps"
)
$RemoveAppsList = $RemoveApps -join ","

# Configure and Debloat Windows using `Win11Debloat` (https://github.com/Raphire/Win11Debloat)
$Win11Debloat = Invoke-RestMethod "https://debloat.raphi.re/"
& ([scriptblock]::Create($Win11Debloat)) -Silent @WindowsConfigParams -RemoveApps -Apps $RemoveAppsList
# Windows Configurations



# Todo Install WSL + Ubuntu