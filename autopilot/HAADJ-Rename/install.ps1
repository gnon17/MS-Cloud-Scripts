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
If ($fullserial.Length -gt 9) {
    Write-Output "Full Serial Number is longer than 10 characters. Using the first 9 characters of the serial in the PC name"
    Rename-Computer -NewName "HYB-$shortserial" -DomainCredential $creds -verbose
}
Else {
    Write-Output "Serial Number is shorter than 10 Characters. Using entire serial number in PC name"
    Rename-Computer -NewName "HYB-$fullserial" -DomainCredential $creds -verbose
}