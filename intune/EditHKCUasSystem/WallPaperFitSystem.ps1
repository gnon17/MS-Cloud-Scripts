$profilelist = "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$loggedonuser = Get-Ciminstance -ClassName Win32_ComputerSystem | Select-Object UserName
$loggedonusername = $loggedonuser.username
$userwithoutdomain = $loggedonusername -replace "^.*?\\"
$GetSID = Get-ChildItem -Path $profilelist -rec -ea SilentlyContinue | % { if((get-itemproperty -Path $_.PsPath) -match "$userwithoutdomain") { $_.PsPath} }
$SID = $GetSID -replace "^.*?list\\"
#====================================================#
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$RegPath = "HKU:\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$WallPaperFit = "0"
# 0 - center
# 1 - tile
# 2 - stretch
# 3 - fit
# 4 - fill
# 5 - span
New-Item $regpath -Force
New-ItemProperty -Path $RegPath -Name WallPaperStyle -Value $WallPaperFit -PropertyType String -Force | Out-Null
