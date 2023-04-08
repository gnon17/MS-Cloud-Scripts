$tempdir = "C:\temp"
$taskdir = "C:\windows\system32\Tasks"
$proc = "appidpolicyconverter"
New-Item $tempdir -ItemType Directory -Force
New-Item $taskdir -ItemType File -Name ESP-TaskComplete -Force
Start-Transcript -Path "C:\temp\post-esp-task.txt" -Verbose
start-sleep -Seconds 5
Write-Host "Waiting for process to start..."
while ($true) {
    $getprocess = Get-Process $proc -ErrorAction SilentlyContinue
    if ($getprocess -ne $null) {
        Write-Host "$proc has started."
        Wait-Process -Name $proc -Verbose
        break
    }
    Start-Sleep -Milliseconds 150
}
Write-Host "Process has ended. Restarting Workstation" -Verbose
disable-scheduledtask -taskname PostESP-Script -ErrorAction SilentlyContinue -Verbose
start-sleep -Seconds 5
Restart-Computer -Force -Verbose
