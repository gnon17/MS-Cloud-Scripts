Add-Type -AssemblyName System.Windows.Forms
$Balloon = New-Object System.Windows.Forms.NotifyIcon
$Balloon.Icon = [System.Drawing.SystemIcons]::Information
$Balloon.BalloonTipText = "Your computer will reboot in 20 seconds to finish initial configuration."
$Balloon.BalloonTipTitle = "Reboot Notification"
$Balloon.BalloonTipIcon = "Warning"
$Balloon.Visible = $true
$Balloon.ShowBalloonTip(20000)
