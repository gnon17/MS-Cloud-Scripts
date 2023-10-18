$path = "c:\temp"
$TempDir = Test-Path $path
$Cx86dest = "c:\temp\C++Redistributablex86.exe"
$Cx86Download = "https://aka.ms/vs/17/release/vc_redist.x86.exe"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
start-BitsTransfer -Source $Cx86Download -Destination $Cx86dest

#Get Version of installed C++ Redistributable x86 and newest install
$Cx86InstalledVersion = get-package -name '*Microsoft Visual C++ 2015-2022 Redistributable (x86)*' | select -ExpandProperty Version
$Cx86NewVersion = (Get-Item $Cx86dest).VersionInfo.FileVersionRaw

#Compare C++ Redistributable x86 Version
If ($Cx86InstalledVersion -ge $Cx86NewVersion) {
Write-Output "C++ Redistributable x86 is running the latest version"
#exit 0
}
Else {
Write-Output "C++ Redistributable x86 needs to be updated"
#exit 1
}

Remove-Item -Path $Cx86dest