Unregister-ScheduledTask -TaskName TeamsBackgroundSync -Confirm:$false
Remove-Item -Path C:\temp\SilentCMD.vbs -Force
Remove-Item -Path C:\temp\TeamsBackgroundSync.cmd -Force