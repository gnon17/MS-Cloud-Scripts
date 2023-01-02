$taskdir = "C:\WINDOWS\System32\Tasks"
Copy-Item ".\BL2GoToAAD.ps1" -Destination $taskdir -Force
Register-ScheduledTask -xml (Get-Content '.\BL2GOEscrowtoAAD.xml' | Out-String) -TaskName "BL2GOEscrowtoAAD" -Force