$file1 = Test-Path "C:\ProgramData\Toast\ToastScript.cmd"
$file2 = Test-Path "C:\ProgramData\Toast\NotificationXML.xml"
$file3 = Test-Path "C:\ProgramData\Toast\Button1-Downloads.ps1"
$file4 = Test-Path "C:\ProgramData\Toast\Button2-Gridview.ps1"
$file5 = Test-Path "C:\ProgramData\Toast\Button3-Delete.ps1"
$file6 = Test-Path "C:\ProgramData\Toast\smb.png"
$file7 = Test-Path "C:\ProgramData\Toast\smbnewbanner.png"

New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT
$reg1 = Get-ItemPropertyValue "HKCR:\PowerShell" -Name "(Default)"
$reg2 = Get-ItemPropertyValue "HKCR:\PowerShell\defaulticon" -Name "(Default)"
$reg3 = Get-ItemPropertyValue "HKCR:\PowerShell\shell\open\command" -Name "(Default)"

If (((( $file1 -and $file2 -and $file3 -and $file4 -and $file5 -and $file6 -and $file7 -eq 'True' ) -and ($reg1 -eq "URL:PowerShell Protocol")) -and ($reg2 -eq "powershell.exe,1")) -and ($reg3 -eq "C:\ProgramData\toast\ToastScript.cmd %1"))
{
    Write-Output "Files and Reg values exist"
    exit 0
}
else {
    Write-Output "Missing Files or Registry Values"
    exit 1
}