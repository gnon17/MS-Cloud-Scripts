$path = "c:\temp"
$TempDir = Test-Path $path
$teamsmsidest = "c:\temp\teamsinstaller.msi"
$TeamsDownload = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
start-BitsTransfer -Source $TeamsDownload -Destination $teamsmsidest

#Get Version of installed TeamsMWI and newest MSI
$TeamsMWIVersion = get-package -name 'Teams Machine-Wide Installer' | select -ExpandProperty Version
$TeamsMSI = get-applockerfileinformation -path $teamsmsidest | Select -expandproperty Publisher
$TeamsMSIVersion = $TeamsMSI.BinaryVersion

#Compare Teams Version
If ($TeamsMWIVersion -ge $TeamsMSIVersion) {
Write-Output "Teams is running the latest version"
exit 0
}
Else {
Write-Output "Teams needs to be updated"
exit 1
}

Remove-Item -Path $teamsmsidest