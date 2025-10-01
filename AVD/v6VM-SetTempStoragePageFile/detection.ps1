$path = "C:\mem\SetPageFileOnStartup_v6vm.ps1"
$task = Get-ScheduledTask -taskname "Set Page File on Startup"
$file = Test-Path $path
If ($file -and $task) {
    Write-Output "Found the task and file"
    exit 0
}
else {
    Write-Output "Task or file not detected"
    exit 1
}