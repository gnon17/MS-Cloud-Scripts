$toastdir = c:\programdata\toast
Remove-Item -Path "$toastdir\toastscript.cmd" -Force
Remove-Item -Path "$toastdir\notificationXML.xml" -Force
Remove-Item -Path "$toastdir\button1-downloads.ps1" -Force
Remove-Item -Path "$toastdir\button2-gridview.ps1" -Force
Remove-Item -Path "$toastdir\button3-delete.ps1" -Force

New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT
Remove-Item -Path "HKCR:\powershell" -Recurse -Force