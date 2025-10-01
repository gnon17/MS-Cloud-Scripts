Copy-Item -Path ".\SetPageFileOnStartup_v6vm.ps1" -Destination "C:\mem\" -Force

$TaskName   = "Set Page File on Startup"
$ScriptPath = "C:\mem\SetPageFileOnStartup_v6vm.ps1"
$TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Force