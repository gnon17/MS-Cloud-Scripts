$profilelist = "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$loggedonuser = Get-Ciminstance -ClassName Win32_ComputerSystem | Select-Object UserName
$loggedonusername = $loggedonuser.username
$userwithoutdomain = $loggedonusername -replace "^.*?\\"
#CD $ProfileList
$GetSID = Get-ChildItem -Path $profilelist -rec -ea SilentlyContinue | % { if((get-itemproperty -Path $_.PsPath) -match "$userwithoutdomain") { $_.PsPath} }
$SID = $GetSID -replace "^.*?list\\"
#====================================================#
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$RegPath = "HKU:\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$WallPaperStyleValue = Get-ItemPropertyValue $RegPath -Name WallPaperStyle
If ($WallPaperStyleValue -eq 0){
Write-Output "Detected"
Exit 0
}
Else {
exit 1
}