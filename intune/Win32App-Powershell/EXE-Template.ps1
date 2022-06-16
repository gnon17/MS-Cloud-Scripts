#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\" -Name "FOLDERNAME" -ItemType Directory -Force
$downloadsource = 'DOWNLOAD URL FOR THE EXE FILE'
$filename = "NAME OF DOWNLOADED FILE. i.e. - CHROME.EXE"
$downloaddestination = $appfolder
Start-BitsTransfer -Source $downloadsource -Destination $downloaddestination\$filename

#Icon/logo download if desired
$logoURL = "DOWNLOAD URL FOR THE EXE FILE"
$LogoFileName = "NAME THE DOWNLOADED IMAGE FILE. I.E - CHROME.PNG"
Invoke-WebRequest -Uri $logoURL -D -OutFile $downloaddestination\$LogoFileName

#Create the intunewin file from source and destination variables and assign IntuneWin file location variable
$Source = $appfolder
$SetupFile = $filename
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -ErrorAction Ignore -Verbose
$IntuneWinFile = $CreateAppPackage.Path

#Names Application, description and publisher info as it appears in MEM - Examples below
$Displayname = "Firefox"
$Description = "Firefox x64"
$Publisher = "Mozilla"

# Create File exists detection rule - Modify where your file and filepath are located. If you are using an MSI wrapped EXE (like adobe acrobat reader) you can use MSI product code detection. See MSI template for syntax. 
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder Firefox.exe -Path "C:\Program Files\Mozilla Firefox\" -Check32BitOn64System $false -DetectionType "exists"

#Create Requirement Rule (32/64 bit and minimum Windows Version)
$ArchitectureRequired = "x64"
$MinimumOSBuild = "1909"
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture $ArchitectureRequired -MinimumSupportedOperatingSystem $MinimumOSBuild
 

#Create a cool Icon from the downloaded image file (if you want) - comment out lines if you don't want or can't find an image file
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

#Install and Uninstall Commands - This may differ between EXEs. Check for silent install switches. 
$InstallCommandLine = "Firefox_Latest.exe /S"
$UninstallCommandLine = "C:\Program Files\Mozilla Firefox\uninstall\helper.exe /S"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose