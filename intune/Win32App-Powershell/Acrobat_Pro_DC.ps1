#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\apps" -Name "AcrobatProDC" -ItemType Directory -Force
$downloadcache = new-item -Path ".\" -Name "Downloaded" -ItemType Directory -Force
$downloadsource = 'https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip'
$filename = "AcrobatProDC.zip"
$downloaddestination = $downloadcache
Start-BitsTransfer -Source $downloadsource -Destination $downloadcache\$filename | Out-Null

#Extract chrome enterprise archive and move MSI installer to $appfolder directory for consistency
Expand-Archive -LiteralPath $downloadcache\AcrobatProDC.zip -DestinationPath $downloadcache
#Move-Item -Path $downloadcache\Installers\GoogleChromeStandaloneEnterprise64.msi -Destination $appfolder

#logo download
$logoURL = "https://logowik.com/content/uploads/images/adobe-acrobat-pro-dc2512.jpg"
$LogoFileName = "AcrobatPro.jpg"
Invoke-WebRequest -Uri $logoURL -D -OutFile $appfolder\$LogoFileName

#Create the intunewin file from source and destination variables
$Source = "$downloadcache\Adobe Acrobat"
$SetupFile = "AcroPro.msi"
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -Verbose
$IntuneWinFile = $CreateAppPackage.Path

#Get intunewin file Meta data and assign intunewin file location variable
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


#Names Application, description and publisher info
$Displayname = "Acrobat Pro DC"
$Description = "Acobe Acrobat Pro DC"
$Publisher = "Adobe"


# Create File exists detection rule - Retrieve MSI code if you don't have it. Alternate method commented below to use File existence. MSIs are recommended to use Product Code. 
$DetectionRule = New-IntuneWin32AppDetectionRuleMSI -ProductCode $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode
#$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder Firefox.exe -Path "C:\Program Files\Mozilla Firefox\" -Check32BitOn64System $false -DetectionType "exists"

#Create Requirement Rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedOperatingSystem 1909
 

#Create a cool Icon from an image file (if you want)
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

###Install and Uninstall Commands - not needed for MSI installs
#$InstallCommandLine = "7zipX64.exe /S"
#$UninstallCommandLine = "%systemdrive%\Program Files\7-Zip\Uninstall.exe"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -Icon $Icon -Verbose
