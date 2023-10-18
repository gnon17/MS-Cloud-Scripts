$TeamsWVDRegValue = get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" | Select -expandproperty "IsWVDEnvironment" -ErrorAction SilentlyContinue 
$path = "c:\temp"
$TempDir = Test-Path $path
$teamsmsidest = "c:\temp\teamsinstaller.msi"
$TeamsDownload = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"

#Check for WVD Registry Values and add if values does not exist
If (($TeamsWVDRegValue -eq $null) -or ($TeamsWVDRegValue -eq "0")) {
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force
}
else {
write-host "Registry Values are correct for AVD environment"
}

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}

#Remove Teams MWI and install newest verison
$TeamsMWIGUID = get-package -name 'Teams Machine-Wide Installer' | select -ExpandProperty FastPackageReference
start-process msiexec.exe -ArgumentList "/x $TeamsMWIGUID /qn /norestart" -verbose -wait
start-BitsTransfer -Source $TeamsDownload -Destination $teamsmsidest
start-process msiexec.exe -ArgumentList "/i $teamsmsidest ALLUSER=1 ALLUSERS=1 /qn" -verbose -wait

Remove-Item -Path $teamsmsidest