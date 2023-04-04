$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"
New-Item $tempdir -ItemType Directory -Force
New-Item $taskdir -ItemType File -Name ESP-TaskComplete -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt"
start-sleep -Seconds 15
write-output "Waiting for the cloud experience host broker process to complete..."
wait-process "wwahost" -Verbose
Write-Output "Process ended. Restarting Workstation"
disable-scheduledtask -taskname PostESP-Script
Restart-Computer -Force