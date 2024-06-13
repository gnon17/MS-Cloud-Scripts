$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"

New-Item $tempdir -ItemType Directory -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose

Start-ScheduledTask -TaskName "Post-ESP-Reboot-Notification"
Start-Sleep -Seconds 21

disable-scheduledtask -taskname PostESP-Reboot -ErrorAction SilentlyContinue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Reboot -Confirm:$false
disable-scheduledtask -taskname Post-ESP-Reboot-Notification -Erroraction Continue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Reboot-Notification -Confirm:$false

Remove-Item $tempdir\toast.ps1 -force

Restart-Computer -Force -Verbose
