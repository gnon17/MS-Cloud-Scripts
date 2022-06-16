#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\apps" -Name "Acrobat_Reader_DC" -ItemType Directory -Force
$downloadsource = 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2200120085/AcroRdrDC2200120085_en_US.exe'
$filename = "AcroReaderDC.exe"
$downloaddestination = $appfolder
Start-BitsTransfer -Source $downloadsource -Destination $downloaddestination\$filename | Out-Null

#logo download
$logoURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Adobe_Acrobat_Reader_icon_%282020%29.svg/512px-Adobe_Acrobat_Reader_icon_%282020%29.svg.png?20210606082922"
$LogoFileName = "AdobeReader.png"
Invoke-WebRequest -Uri $logoURL -D -OutFile $downloaddestination\$LogoFileName

#Create the intunewin file from source and destination variables
$Source = $appfolder
$SetupFile = $filename
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -Verbose


#Get intunewin file Meta data and assign intunewin file location variable
$IntuneWinFile = $CreateAppPackage.Path
### Uncomment this if its an MSI $IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


#Names Application, description and publisher info
$Displayname = "Adobe Acrobat Reader DC"
$Description = "32-bit"
$Publisher = "Adobe"


# Create File exists detection rule
$DetectionRule = New-IntuneWin32AppDetectionRuleMSI -ProductCode {AC76BA86-7AD7-1033-7B44-AC0F074E4100}


#Create Requirement Rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedOperatingSystem 1909
 

#Create a cool Icon from an image file (if you want)
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

#Install and Uninstall Commands
$InstallCommandLine = "AcroReaderDC.exe /sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
$UninstallCommandLine = "msiexec /x {AC76BA86-7AD7-1033-7B44-AC0F074E4100}"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose