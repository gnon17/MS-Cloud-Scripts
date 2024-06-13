$tempdir = "c:\temp"
New-Item $tempdir -ItemType Directory -Force

#Grab the action scripts
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/APv2-PostESPReboot/Event4725/Post-ESP-Reboot.ps1" -OutFile .\Post-ESP-Reboot.ps1
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/APv2-PostESPReboot/Event4725/Toast.ps1" -OutFile .\toast.ps1

#Grab the ScheduledTask XMLs
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/APv2-PostESPReboot/Event4725/Post-ESP-Reboot.xml" -OutFile .\Post-ESP-Reboot.xml
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/autopilot/APv2-PostESPReboot/Event4725/Post-ESP-Reboot-Notification.xml" -OutFile .\Post-ESP-Reboot-Notification.xml

#Move the action scripts and register the tasks
Copy-Item ".\Post-ESP-Reboot.ps1" -Destination $tempdir -Force
Copy-Item ".\toast.ps1" -Destination $tempdir -Force
Register-ScheduledTask -xml (Get-Content '.\Post-ESP-Reboot.xml' | Out-String) -TaskName "Post-ESP-Reboot" -Force
Register-ScheduledTask -xml (Get-Content '.\Post-ESP-Reboot-Notification.xml' | Out-String) -TaskName "Post-ESP-Reboot-Notification" -Force