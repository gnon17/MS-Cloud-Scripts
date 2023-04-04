$PostESPTask = Test-Path "C:\windows\system32\tasks\PostESP-Script"
$PostESPFile = Test-Path "C:\windows\system32\tasks\ESP-TaskComplete"
##Unregister-ScheduledTask -TaskName PostESP-Script -ErrorAction SilentlyContinue
If (($PostESPTask -eq $true) -or ($PostESPFile -eq $true)) {
    Write-Host "Detected"
    Exit 0
}
else {
    Exit 1
}
