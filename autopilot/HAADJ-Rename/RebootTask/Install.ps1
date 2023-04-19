#
$tempdir = "c:\temp"
New-Item $tempdir -ItemType Directory -Force
Copy-Item ".\PostESP-Script.ps1" -Destination $tempdir -Force
Register-ScheduledTask -xml (Get-Content '.\PostESP-Script.xml' | Out-String) -TaskName "PostESP-Script" -Force
