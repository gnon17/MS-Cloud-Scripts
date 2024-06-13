$NamePrefix = "SMB-"
$fullserial = Get-WmiObject win32_bios | select-object -expandproperty "Serialnumber"
If ($fullserial.length -gt 10) {
$shortserial = $fullserial.SubString(0,10)
}
$full = ($NamePrefix) + ($FullSerial)
$short = ($NamePrefix)+($ShortSerial)

Try {
If ($fullserial.Length -le 11) {
Rename-Computer -NewName $full
}
else {
rename-computer -NewName $short
}
}
Catch {
Write-Host $_
}