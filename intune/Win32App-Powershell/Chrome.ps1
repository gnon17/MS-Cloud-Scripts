#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID

#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\apps" -Name "Chrome" -ItemType Directory -Force
$downloadcache = new-item -Path ".\" -Name "Downloaded" -ItemType Directory -Force
$downloadsource = 'https://dl.google.com/tag/s/appguid%253D%257B8A69D345-D564-463C-AFF1-A69D9E530F96%257D%2526iid%253D%257BBEF3DB5A-5C0B-4098-B932-87EC614379B7%257D%2526lang%253Den%2526browser%253D4%2526usagestats%253D1%2526appname%253DGoogle%252520Chrome%2526needsadmin%253Dtrue%2526ap%253Dx64-stable-statsdef_1%2526brand%253DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip?_ga%3D2.8891187.708273100.1528207374-1188218225.1527264447'
$filename = "ChromeEnterprise.zip"
$downloaddestination = $downloadcache
Start-BitsTransfer -Source $downloadsource -Destination $downloadcache\$filename | Out-Null

#Extract chrome enterprise archive and move MSI installer to $appfolder directory for consistency
Expand-Archive -LiteralPath $downloadcache\ChromeEnterprise.zip -DestinationPath $downloadcache
Move-Item -Path $downloadcache\Installers\GoogleChromeStandaloneEnterprise64.msi -Destination $appfolder

#logo download
$logoURL = "https://logos-world.net/wp-content/uploads/2020/08/Google-Chrome-Logo-700x394.png"
$LogoFileName = "chrome.png"
Invoke-WebRequest -Uri $logoURL -D -OutFile $appfolder\$LogoFileName

#Create the intunewin file from source and destination variables
$Source = $appfolder
$SetupFile = "GoogleChromeStandaloneEnterprise64.msi"
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -Verbose
$IntuneWinFile = $CreateAppPackage.Path

#Get intunewin file Meta data and assign intunewin file location variable
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


#Names Application, description and publisher info
$Displayname = "Google Chrome"
$Description = "Google Chrome x64"
$Publisher = "Google"


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