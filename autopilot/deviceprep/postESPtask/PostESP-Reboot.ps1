$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"
New-Item $tempdir -ItemType Directory -Force
New-Item $taskdir -ItemType File -Name ESP-TaskComplete -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose
disable-scheduledtask -taskname PostESP-Reboot -ErrorAction SilentlyContinue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Reboot -Confirm:$false
Restart-Computer -Force -Verbose
