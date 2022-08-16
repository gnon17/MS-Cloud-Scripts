$tempdir = "c:\temp"
New-Item $tempdir -ItemType Directory -Force
Copy-Item ".\SilentCMD.vbs" -Destination $tempdir -Force
Copy-Item ".\TeamsBackgroundSync.cmd" -Destination $tempdir -Force
Register-ScheduledTask -xml (Get-Content '.\TeamsBackgroundSync.xml' | Out-String) -TaskName "TeamsBackgroundSync" -Force