New-Item -Path "c:\" -Name "temp" -ItemType "directory" -Force
Start-Transcript -Path "C:\temp\rename.txt"
$fullserial = Get-WmiObject win32_bios | select-object -expandproperty "Serialnumber"
$shortserial = $fullserial.SubString(0,9)
$AESKeyFilePath = "aeskey.txt"
$SecurePwdFilePath = "credpassword.txt"
$user = "ganlab\renamer"
$AESKey = Get-Content -Path $AESKeyFilePath
$pwdTxt = Get-Content -Path $SecurePwdFilePath
$securePass = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $securePass
$battery = Get-WmiObject Win32_Battery
If (($fullserial.Length -gt 9) -and ($battery -eq $null)) {
    Write-Output "Full Serial Number is longer than 10 characters and device is a desktop. Using DT- prefix and first 9 characters of the serial in the PC name"
    Rename-Computer -NewName "DT-$shortserial" -DomainCredential $creds -verbose
}
If (($fullserial.Length -gt 9) -and ($battery -ne $null)) {
    Write-Output "Full Serial Number is longer than 10 characters and device is a laptop. Using LT- prefix and first 9 characters of the serial in the PC name"
    Rename-Computer -NewName "LT-$shortserial" -DomainCredential $creds -verbose
}
If (($fullserial.Length -lt 9) -and ($battery -eq $null)) {
    Write-Output "Full Serial Number is less than than 10 characters and device is a desktop. Using DT- prefix and full serial number"
    Rename-Computer -NewName "DT-$fullserial" -DomainCredential $creds -verbose
}
If (($fullserial.Length -lt 9) -and ($battery -ne $null)) {
    Write-Output "Full Serial Number is less than than 10 characters and device is a laptop. Using LT- prefix and full serial number"
    Rename-Computer -NewName "LT-$fullserial" -DomainCredential $creds -verbose
}