$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"
New-Item $tempdir -ItemType Directory -Force
New-Item $taskdir -ItemType File -Name ESP-TaskComplete -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose
disable-scheduledtask -taskname PostESP-Reboot -ErrorAction SilentlyContinue -Verbose
#Unregister-ScheduledTask -TaskName PostESP-Reboot -Confirm:$false

$Balloon = New-Object System.Windows.Forms.NotifyIcon
$Balloon.Icon = [System.Drawing.SystemIcons]::Information
$Balloon.BalloonTipText = "Your computer will reboot in 20 seconds to finish initial configuration."
$Balloon.BalloonTipTitle = "Reboot Notification"
$Balloon.BalloonTipIcon = "Warning"
$Balloon.Visible = $true
$Balloon.ShowBalloonTip(20000)

Start-Sleep -Seconds 20

Restart-Computer -Force -Verbose
