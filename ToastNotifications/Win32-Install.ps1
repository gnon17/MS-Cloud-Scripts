$toastdir = "c:\programdata\toast"
New-Item -Path $toastdir -ItemType "Directory" -Force
Copy-Item ".\toastscript.cmd" -Destination $toastdir -Force
Copy-Item ".\notificationXML.xml" -Destination $toastdir -Force
Copy-Item ".\button1-downloads.ps1" -Destination $toastdir -Force
Copy-Item ".\button2-gridview.ps1" -Destination $toastdir -Force
Copy-Item ".\button3-delete.ps1" -Destination $toastdir -Force
Copy-Item ".\smb.png" -Destination $toastdir -Force
Copy-Item ".\smbnewbanner.png" -Destination $toastdir -Force

New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT
$RegPath = "HKCR:\powershell\shell\open\command"
$command = "c:\ProgramData\Toast\ToastScript.cmd %1"
$defaulticon = "HKCR:\powershell\defaulticon\"
New-Item $regpath -Force
New-Item $defaulticon -force
New-ItemProperty -Path HKCR:\powershell -Name "URL Protocol" -Force
Set-ItemProperty -Path $RegPath -Name '(Default)' -Value $command -Force
Set-ItemProperty -Path $defaulticon -Name '(Default)' -Value 'powershell.exe,1' -Force
Set-ItemProperty -Path HKCR:\powershell -Name '(Default)' -Value 'URL:PowerShell Protocol' -Force