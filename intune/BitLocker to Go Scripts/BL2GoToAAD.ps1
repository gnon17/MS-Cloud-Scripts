$USBDrives = Get-WmiObject -Class Win32_logicaldisk | where {$_.DriveType -eq "2"} | Select-Object DeviceID
foreach ($DeviceID in $USBDrives)
{
$BLV = Get-BitLockerVolume -MountPoint $DeviceID.DeviceID
BackupToAAD-BitLockerKeyProtector -MountPoint $DeviceID.DeviceID -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId -ErrorAction Continue
}