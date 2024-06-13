$tempdir = "c:\temp"
New-Item $tempdir -ItemType Directory -Force

#Grab the action scripts
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/deviceprep/postESPtask/Reboot-Event4725.xml" -OutFile .\Post-ESP-Reboot.ps1
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/deviceprep/postESPtask/PostESP-Reboot-Notification.ps1" -OutFile .\Post-ESP-Reboot-Notification.ps1

#Grab the ScheduledTask XMLs
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/deviceprep/postESPtask/Reboot-Event4725.xml" -OutFile .\Post-ESP-Reboot.xml.xml
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/deviceprep/postESPtask/PostESP-Reboot-Notification.ps1" -OutFile .\PostESP-Reboot-Notification.ps1

#Move the action scripts and register the tasks
Copy-Item ".\Post-ESP-Reboot.ps1" -Destination $tempdir -Force
Copy-Item ".\toast.ps1" -Destination $tempdir -Force
Register-ScheduledTask -xml (Get-Content '.\Post-ESP-Reboot.xml' | Out-String) -TaskName "Post-ESP-Reboot" -Force
Register-ScheduledTask -xml (Get-Content '.\Post-ESP-Reboot-Notification.xml' | Out-String) -TaskName "Post-ESP-Reboot-Notification" -Force