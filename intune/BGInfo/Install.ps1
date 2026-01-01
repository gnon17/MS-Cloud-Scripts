$Dest = "$env:ProgramData\BGInfo"
New-Item -ItemType Directory -Path $Dest -Force | Out-Null
Copy-Item ".\bginfo\*" -Destination $Dest -Force

$TaskName = "BGInfo-Logon"
$Trigger  = New-ScheduledTaskTrigger -AtLogOn
$Action   = New-ScheduledTaskAction -Execute "C:\ProgramData\BGInfo\Bginfo64.exe" -Argument "C:\ProgramData\BGInfo\hostname.bgi /silent /nolicprompt /timer 0"
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Principal $Principal -Settings $Settings -Force | Out-Null