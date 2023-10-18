$path = "c:\temp"
$TempDir = Test-Path $path
$Cx64dest = "$path\C++Redistributablex64.exe"
$Cx64Download = "https://aka.ms/vs/17/release/vc_redist.x64.exe"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
#Download and Install
start-BitsTransfer -Source $Cx64Download -Destination $Cx64dest
start-process $Cx64dest /quiet -wait
remove-item $Cx64dest
