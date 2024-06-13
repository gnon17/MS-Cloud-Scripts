$tempdir = "C:\temp"
New-Item $tempdir -ItemType Directory -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose
disable-scheduledtask -taskname Post-ESP-Reboot -ErrorAction SilentlyContinue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Reboot -Confirm:$false
Restart-Computer -Force -Verbose