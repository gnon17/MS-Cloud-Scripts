#CreateRegKey
New-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP -Force

#Variable Creation
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$ImageDestinationFolder = "c:\MDM"
$BackgroundFile = "background.jpg"
$LockscreenFile = "lockscreen.jpg"
$BackgroundImage = "$ImageDestinationFolder\$BackgroundFile"
$LockScreenImage = "$ImageDestinationFolder\$LockscreenFile"

#Create image directory
md $ImageDestinationFolder -erroraction silentlycontinue

#Move Files to local directory
Copy-Item -Path .\$BackgroundFile -Destination $ImageDestinationFolder
Copy-Item -Path .\$LockscreenFile -Destination $ImageDestinationFolder

#Lockscreen Registry Keys
New-ItemProperty -Path $RegPath -Name LockScreenImagePath -Value $LockScreenImage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImageUrl -Value $LockScreenImage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null

#Background Wallpaper Registry Keys
New-ItemProperty -Path $RegPath -Name DesktopImagePath -Value $Backgroundimage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImageUrl -Value $Backgroundimage -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null