$taskdir = "C:\programdata\toast"
Copy-Item ".\TriggerToast-DownloadsFolder.ps1" -Destination $taskdir -Force
Register-ScheduledTask -xml (Get-Content '.\Toast-DownloadsFolder.xml' | Out-String) -TaskName "Toast-DownloadsFolder" -Force