$path = "c:\temp"
$TempDir = Test-Path $path
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-output "Temp Directory Already Exists"
}
Invoke-WebRequest -Uri "https://github.com/gnon17/MS-Cloud-Scripts/raw/main/SetACL.exe" -OutFile C:\Temp\SetACL.exe
C:\Temp\SetACL.exe -on "C:\windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc" -ot file -actn setowner -ownr "n:administrators"
C:\Temp\SetACL.exe -on "C:\windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc" -ot file -actn ace -ace "n:administrators;p:full" -actn rstchldrn -rst DACL
Remove-Item "C:\windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc" -recurse -force
Remove-Item $path\SetACL.exe