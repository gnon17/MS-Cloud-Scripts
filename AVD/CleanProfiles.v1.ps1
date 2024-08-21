#Delete user profile script#
############################

#Starting Transcript and checking for transcript directory
$path = "c:\temp"
$TempDir = Test-Path $path
If ($TempDir -eq $False) {
    New-Item -ItemType Directory -Path C:\Temp -Force
}
else {
    write-host "Temp Directory Already Exists"
}
Start-Transcript -Path $path\ProfileCleanup.log

#Sets local user profiles to keep and deletes other profiles
$keep = @('Administrator','NetworkService','LocalService','SystemProfile','defaultuser0')
$Profiles = Get-CimInstance -Class Win32_userProfile | Where-Object {$_.Localpath.split('\')[-1] -notin $keep}
$List = $Profiles.LocalPath
Write-Host -ForegroundColor Green "The following local profiles will be removed:`
 $list"
Try {
Get-CimInstance -Class Win32_userProfile | Where-Object {$_.Localpath.split('\')[-1] -notin $keep} | Remove-CimInstance -Verbose -ErrorAction Continue
}
Catch {
Write-Host $_
}

#Clean up local_ folders from Users Directory
Write-Host -ForegroundColor Green "Profiles have been removed, cleaning up old local FSLogix folders"
Invoke-WebRequest -Uri "https://github.com/gnon17/MS-Cloud-Scripts/raw/main/SetACL.exe" -OutFile C:\Temp\SetACL.exe
$localfolders = Get-Childitem "c:\users" | Where Name -match "local_"
Write-Host -ForegroundColor Green "Found the following leftover local folders: `
$localfolders"
Write-Host -ForegroundColor Yellow "Deleting leftover local folders"
Try {
ForEach ($localfolder in $localfolders) {
C:\Temp\SetACL.exe -on $localfolder.FullName -ot file -actn setowner -ownr "n:administrators"
C:\Temp\SetACL.exe -on $localfolder.FullName -ot file -actn ace -ace "n:administrators;p:full" -actn rstchldrn -rst DACL
Remove-Item -Path $localfolder.FullName -Recurse -ErrorAction Continue
}}
Catch {
Write-Host $_
}
Write-Host -ForegroundColor Green "Script Complete"
Remove-Item $path\SetACL.exe -Force
Stop-Transcript