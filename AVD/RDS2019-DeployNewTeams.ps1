$path = "c:\temp"
$TempDir = Test-Path $path

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}

#Starting Transcript
Start-Transcript -Path $path\NewTeamsScript.log

#Variables
$teamsinstalldest = "c:\temp\MSTeams-x64.msix"
$TeamsDownload = "https://go.microsoft.com/fwlink/?linkid=2196106"
$WebRTCDownload = "https://aka.ms/msrdcwebrtcsvc/msi"
$WebRTCDestination = "c:\temp\WebRTC.msi"
$Cx64dest = "c:\temp\C++Redistributablex64.exe"
$Cx64Download = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$Cx86dest = "c:\temp\C++Redistributablex86.exe"
$Cx86Download = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
$webview2bootstrapper = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
$webview2bootstrapperdsest = "c:\temp\MicrosoftEdgeWebview2Setup.exe"
$TeamsWVDRegValue = get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" | Select -expandproperty "IsWVDEnvironment" -ErrorAction SilentlyContinue
$SideLoadValue = get-itemproperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" | Select -expandproperty "AllowAllTrustedApps" -ErrorAction SilentlyContinue

#Download latest installers
Write-Host -ForegroundColor Green "Downloading latest installers for New Teams, WebRTC, and C++ Redistributables"
start-BitsTransfer -Source $TeamsDownload -Destination $teamsinstalldest
Invoke-Webrequest -Uri $WebRTCDownload -OutFile $WebRTCDestination
start-BitsTransfer -Source $Cx64Download -Destination $Cx64dest
start-BitsTransfer -Source $Cx86Download -Destination $Cx86dest
start-BitsTransfer -Source $webview2bootstrapper -Destination $webview2bootstrapperdsest


###Remove Classic Teams###
Write-Host -ForegroundColor Green "Removing Classic Teams if it is installed"
Start-Sleep 1
$TeamsMWIGUID = get-package -name 'Teams Machine-Wide Installer' | select -ExpandProperty FastPackageReference -ErrorAction SilentlyContinue
If ($TeamsMWIGUID) {
start-process msiexec.exe -ArgumentList "/x $TeamsMWIGUID /qn /norestart" -verbose -wait
}
else {
Write-Host -ForegroundColor Yellow "Classic Teams was not detected. Continuing..."
start-sleep 1
}

#Check for Sideloading Reg Value
Write-Host -ForegroundColor Green "Checking if trusted app sideloading is enabled"
If (($null -eq $SideLoadValue) -or ($SideLoadValue -eq "0")) {
    write-host -ForegroundColor Yellow "Sideloading is disabled. Enabling sideloading"
    start-sleep 1
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowAllTrustedApps -PropertyType DWORD -Value 1 -Force
    }
    else {
    write-host -ForegroundColor Yellow "Sideloading is enabled"
    }

#Check for WVD Registry Values and add if values does not exist
Write-Host -ForegroundColor Green "Checking for proper registry values and adding if they do not exist"
If (($null -eq $TeamsWVDRegValue) -or ($TeamsWVDRegValue -eq "0")) {
    write-host -ForegroundColor Yellow "Registry Value missing. Adding correct value for IsWVDEnvironment"
    start-sleep 1
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force
    }
    else {
    write-host -ForegroundColor Yellow "Registry Values are correct for AVD environment"
    }

#Get Version of Installed WebRTC and newest MSI
$WebRTCVersion = Get-Package -name 'Remote Desktop WebRTC Redirector Service' | Select-Object -ExpandProperty Version -ErrorAction Ignore
$WebRTCMSI = get-applockerfileinformation -path $WebRTCDestination | Select -expandproperty Publisher
$WebRTCMSIVersion = $WebRTCMSI.BinaryVersion

#Get Version of installed C++ Redistributable x64 and newest installer
$Cx64InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x64)*' | select -ExpandProperty Version -ErrorAction Ignore
$Cx64NewVersion = (Get-Item $Cx64dest).VersionInfo.FileVersionRaw

#Get Version of installed C++ Redistributable x86 and newest installer
$Cx86InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x86)*' | select -ExpandProperty Version -ErrorAction Ignore
$Cx86NewVersion = (Get-Item $Cx86dest).VersionInfo.FileVersionRaw

$webviewinstalled = Get-Package -Name 'Microsoft Edge Webview2 Runtime'

#Install/Update Apps if they're dated or don't exist
Write-Host -ForegroundColor Green "Checking for app installs and versions. Updating/Installing Pre-reqs"

#Checking for webtime2 runtime
If ($null -eq $webviewinstalled) {
    Write-Host -ForegroundColor Yellow "Edge Webview Runtime is not installed. Installing latest version"
    start-process $webview2bootstrapperdsest -Wait
}

#Compare C++ Redistributable x64 Version
If ($Cx64InstalledVersion -lt $Cx64NewVersion) {
start-process $Cx64dest -ArgumentList "/quiet /norestart" -wait
Write-Host -ForegroundColor Yellow "C++ Redistributable x64 updated to the latest Version"
}
else {
Write-Host -ForegroundColor Yellow "C++ Redistributable x64 is already on the latest Version"
}

#Compare C++ Redistributable x86 Version
If ($Cx86InstalledVersion -lt $Cx86NewVersion) {
start-process $Cx86dest -ArgumentList "/quiet /norestart" -wait
Write-Host -ForegroundColor Yellow "C++ Redistributable x86 updated to the latest Version"
}
else {
Write-Host -ForegroundColor Yellow "C++ Redistributable x86 is already on the latest Version"
}

#Compare WebRTC Version
if ($WebRTCVersion -lt $WebRTCMSIVersion) {
start-process msiexec.exe -ArgumentList "/i $WebRTCDestination /qn" -wait
Write-Host -ForegroundColor Yellow "WebRTC updated to the latest Version"
}
else {
Write-Host -ForegroundColor Yellow "WebRTC is already on the latest Version"
}

#Install New Teams
Write-Host -ForegroundColor Green "All pre-requisite software installed and updated. Installing New Teams Client"
& Dism /Online /Add-ProvisionedAppxPackage /PackagePath:$teamsinstalldest /SkipLicense

#Clean up installer files
Remove-Item -Path $Cx64dest
Remove-Item -Path $Cx86dest
Remove-Item -Path $teamsinstalldest
Remove-Item -Path $WebRTCDestination
Remove-Item -Path $webview2bootstrapperdsest
Write-Host -ForegroundColor Green "Script finished"

Stop-Transcript