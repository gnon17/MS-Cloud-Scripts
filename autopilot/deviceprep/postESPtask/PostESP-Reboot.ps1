$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"
#$proc = "appidpolicyconverter"
New-Item $tempdir -ItemType Directory -Force
New-Item $taskdir -ItemType File -Name ESP-TaskComplete -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose
disable-scheduledtask -taskname PostESP-Script -ErrorAction SilentlyContinue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Script
start-sleep -Seconds 2
Restart-Computer -Force -Verbose