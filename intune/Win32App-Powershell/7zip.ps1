#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\apps" -Name "7zip" -ItemType Directory -Force
$downloadsource = 'https://www.7-zip.org/a/7z2107-x64.exe'
$filename = "7zipX64.exe"
$downloaddestination = $appfolder
Invoke-WebRequest -Uri $downloadsource -Outfile $downloaddestination\$filename | Out-Null

#logo download
$logoURL = "https://www.7-zip.org/7ziplogo.png"
$LogoFileName = "7zipLogo.png"
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
$Displayname = "7-Zip"
$Description = "7-Zip x64 v21.07"
$Publisher = "7-Zip"


# Create File exists detection rule
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder 7z.exe -Path "C:\Program Files\7-Zip\" -Check32BitOn64System $false -DetectionType "exists"


#Create Requirement Rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedOperatingSystem 1909
 

#Create a cool Icon from an image file (if you want)
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

#Install and Uninstall Commands
$InstallCommandLine = "7zipX64.exe /S"
$UninstallCommandLine = "%systemdrive%\Program Files\7-Zip\Uninstall.exe /S"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose