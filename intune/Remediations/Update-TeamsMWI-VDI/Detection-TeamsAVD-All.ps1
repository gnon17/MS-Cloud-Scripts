#Set Variables
$path = "c:\temp"
$TempDir = Test-Path $path
$teamsmsidest = "c:\temp\teamsinstaller.msi"
$TeamsDownload = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
$WebRTCDownload = "https://aka.ms/msrdcwebrtcsvc/msi"
$WebRTCDestination = "c:\temp\WebRTC.msi"
$Cx64dest = "c:\temp\C++Redistributablex64.exe"
$Cx64Download = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$Cx86dest = "c:\temp\C++Redistributablex86.exe"
$Cx86Download = "https://aka.ms/vs/17/release/vc_redist.x86.exe"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}

#Download latest installers
start-BitsTransfer -Source $TeamsDownload -Destination $teamsmsidest
Invoke-Webrequest -Uri $WebRTCDownload -OutFile $WebRTCDestination
start-BitsTransfer -Source $Cx64Download -Destination $Cx64dest
start-BitsTransfer -Source $Cx86Download -Destination $Cx86dest

#Get Version of installed TeamsMWI and newest MSI
$TeamsMWIVersion = get-package -name 'Teams Machine-Wide Installer' | select -ExpandProperty Version -ErrorAction SilentlyContinue
$TeamsMSI = get-applockerfileinformation -path $teamsmsidest | Select -expandproperty Publisher
$TeamsMSIVersion = $TeamsMSI.BinaryVersion

#Get Version of Installed WebRTC and newest MSI
$WebRTCVersion = Get-Package -name 'Remote Desktop WebRTC Redirector Service' | Select-Object -ExpandProperty Version -ErrorAction SilentlyContinue
$WebRTCMSI = get-applockerfileinformation -path $WebRTCDestination | Select -expandproperty Publisher
$WebRTCMSIVersion = $WebRTCMSI.BinaryVersion

#Get Version of installed C++ Redistributable x64 and newest installer
$Cx64InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x64)*' | select -ExpandProperty Version -ErrorAction SilentlyContinue
$Cx64NewVersion = (Get-Item $Cx64dest).VersionInfo.FileVersionRaw

#Get Version of installed C++ Redistributable x86 and newest installer
$Cx86InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x86)*' | select -ExpandProperty Version -ErrorAction SilentlyContinue
$Cx86NewVersion = (Get-Item $Cx86dest).VersionInfo.FileVersionRaw

#Clean up installer files
Remove-Item -Path $Cx64dest
Remove-Item -Path $Cx86dest
Remove-Item -Path $teamsmsidest
Remove-Item -Path $WebRTCDestination

#Compare Teams Version
If ($TeamsMWIVersion -ge $TeamsMSIVersion) {
$detectteams = "0"
}
Else {
$detectteams = "1"
}

#Compare WebRTC Version
if ($WebRTCVersion -ge $WebRTCMSIVersion) {
$detectWebRTC = "0"
}
Else {
$detectWebRTC = "1"
}

#Compare C++ Redistributable x64 Version
If ($Cx64InstalledVersion -ge $Cx64NewVersion) {
$detectCx64 = "0"
}
Else {
$detectCx64 = "1"
}

#Compare C++ Redistributable x86 Version
If ($Cx86InstalledVersion -ge $Cx86NewVersion) {
$detectCx86 = "0"
}
Else {
$detectCx86 = "1"
}

#Detect if any apps are out of date
If (($detectteams -eq "1") -or ($detectWebRTC -eq "1") -or ($detectCx64 -eq "1") -or ($detectCx86 -eq "1")) {
    Write-output "One of the programs is out of date or not installed"
    Exit 1
}
else {
    Write-output "Teams and pre-requisites are up to date"
    Exit 0
}