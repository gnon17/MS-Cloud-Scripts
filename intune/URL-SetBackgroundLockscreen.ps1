New-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP -Force

#Variable Creation
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$BackgroundImageURL = 'https:\\yourimageurl'
$LockscreenImageURL = 'https:\\yourimageurl'
$ImageDestinationFolder = "c:\MDM"
$Backgroundimage = "$ImageDestinationFolder\background.jpg"
$LockScreenImage = "$ImageDestinationFolder\LockScreen.jpg"

#Create image directory
md $ImageDestinationFolder -erroraction silentlycontinue

#Download image file
Start-BitsTransfer -Source $BackgroundImageURL -Destination "$Backgroundimage"
Start-BitsTransfer -Source $LockscreenImageURL -Destination "$LockScreenimage"

#Lockscreen Registry Keys
New-ItemProperty -Path $RegPath -Name LockScreenImagePath -Value $LockScreenImage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImageUrl -Value $LockScreenImage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null

#Background Wallpaper Registry Keys
New-ItemProperty -Path $RegPath -Name DesktopImagePath -Value $backgroundimage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImageUrl -Value $backgroundimage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null