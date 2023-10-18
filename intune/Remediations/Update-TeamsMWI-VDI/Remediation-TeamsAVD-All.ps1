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
$TeamsWVDRegValue = get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" | Select -expandproperty "IsWVDEnvironment" -ErrorAction SilentlyContinue 

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

#Check for WVD Registry Values and add if values does not exist
If (($null -eq $TeamsWVDRegValue) -or ($TeamsWVDRegValue -eq "0")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force
    }
    else {
    write-host "Registry Values are correct for AVD environment"
    }

#Compare C++ Redistributable x64 Version
If ($Cx64InstalledVersion -lt $Cx64NewVersion) {
start-process $Cx64dest /quiet -wait
}

#Compare C++ Redistributable x86 Version
If ($Cx86InstalledVersion -lt $Cx86NewVersion) {
start-process $Cx86dest /quiet -wait
}

#Compare WebRTC Version
if ($WebRTCVersion -lt $WebRTCMSIVersion) {
start-process msiexec.exe -ArgumentList "/i $WebRTCDestination /qn" -wait
}

#Compare Teams Version
If ($TeamsMWIVersion -lt $TeamsMSIVersion) {
start-process msiexec.exe -ArgumentList "/i $teamsmsidest ALLUSER=1 ALLUSERS=1 /qn" -verbose -wait
}

#Clean up installer files
Remove-Item -Path $Cx64dest
Remove-Item -Path $Cx86dest
Remove-Item -Path $teamsmsidest
Remove-Item -Path $WebRTCDestination