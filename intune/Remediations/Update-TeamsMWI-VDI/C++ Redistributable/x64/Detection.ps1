$path = "c:\temp"
$TempDir = Test-Path $path
$Cx64dest = "c:\temp\C++Redistributablex64.exe"
$Cx64Download = "https://aka.ms/vs/17/release/vc_redist.x64.exe"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
start-BitsTransfer -Source $Cx64Download -Destination $Cx64dest

#Get Version of installed C++ Redistributable x64 and newest install
$Cx64InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x64)*' | select -ExpandProperty Version
$Cx64NewVersion = (Get-Item $Cx64dest).VersionInfo.FileVersionRaw

#Compare C++ Redistributable x64 Version
If ($Cx64InstalledVersion -ge $Cx64NewVersion) {
Write-Output "C++ Redistributable x64 is running the latest version"
exit 0
}
Else {
Write-Output "C++ Redistributable x64 needs to be updated"
exit 1
}

Remove-Item -Path $Cx64dest