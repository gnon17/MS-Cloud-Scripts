$path = "c:\temp"
$TempDir = Test-Path $path
$Cx86dest = "$path\C++Redistributablex86.exe"
$Cx86Download = "https://aka.ms/vs/17/release/vc_redist.x86.exe"

#Check for Temp Directory and create if it does not exist
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
start-BitsTransfer -Source $Cx86Download -Destination $Cx86dest
start-process $Cx86dest /quiet -wait
remove-item $Cx86dest