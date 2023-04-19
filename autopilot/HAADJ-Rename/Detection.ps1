$pcname = Get-ItemPropertyValue -Path HKLM:\System\CurrentControlSet\Control\ComputerName\ComputerName\ -Name ComputerName
$fullserial = Get-WmiObject win32_bios | select-object -expandproperty Serialnumber
$shortserial = $fullserial.SubString(0,9)
If (($pcname -eq "HYB-$ShortSerial") -or ($pcname -eq "HYB-$fullserial")) {
Write-Host "PC has been properly renamed"
#exit 0
}
Else
{
Write-Host "There was an issue renaming the PC. The PC name is $PCname. Exiting"
#Exit 1
}