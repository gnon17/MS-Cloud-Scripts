$tempdir = "c:\temp"
New-Item $tempdir -ItemType Directory -Force
Copy-Item ".\restartspooler.ps1" -Destination $tempdir -Force
Register-ScheduledTask -xml (Get-Content '.\RestartPrintSpooler.xml' | Out-String) -TaskName "Restart-Spooler-hourly" -Force