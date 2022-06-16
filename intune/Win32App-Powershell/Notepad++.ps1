#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\apps" -Name "Notepad++" -ItemType Directory -Force
$downloadsource = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.3.3/npp.8.3.3.Installer.x64.exe'
$filename = "Notepad++.exe"
$downloaddestination = $appfolder
Start-BitsTransfer -Source $downloadsource -Destination $downloaddestination\$filename | Out-Null

#logo download
$logoURL = "https://upload.wikimedia.org/wikipedia/commons/0/0f/Notepad%2B%2B_Logo.png?20121112030109"
$LogoFileName = "Notepad++.png"
Invoke-WebRequest -Uri $logoURL -D -OutFile $downloaddestination\$LogoFileName

#Create the intunewin file from source and destination variables
$Source = $appfolder
$SetupFile = $filename
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -Verbose


#Get intunewin file Meta data and assign intunewin file location variable
$IntuneWinFile = $CreateAppPackage.Path
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


#Names Application, description and publisher info
$Displayname = "Notepad++"
$Description = "Notepad++ x64"
$Publisher = "Notepad++"


# Create File exists detection rule
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder notepad++.exe -Path "C:\Program Files\Notepad++\" -Check32BitOn64System $false -DetectionType "exists"


#Create Requirement Rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedOperatingSystem 1909
 

#Create a cool Icon from an image file (if you want)
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

#Install and Uninstall Commands
$InstallCommandLine = "Notepad++.exe /S"
$UninstallCommandLine = "C:\Program Files\Notepad++\uninstall.exe /S"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose