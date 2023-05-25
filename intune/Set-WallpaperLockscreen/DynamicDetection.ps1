$BackgroundImageURL = 'https://yourstorageaccount.blob.core.windows.net/wallpaper/background.jpg'
$LockscreenImageURL = 'https://yourstorageaccount.blob.core.windows.net/wallpaper/lockscreen.jpg'
$ImageDestinationFolder = "C:\temp\images\temp"
$Backgroundimage = "$ImageDestinationFolder\background.jpg"
$LockScreenImage = "$ImageDestinationFolder\Lockscreen.jpg"

#Create Temp Image Directory
md $ImageDestinationFolder -erroraction silentlycontinue

#download images
Start-BitsTransfer -Source $BackgroundImageURL -Destination "$Backgroundimage"
Start-BitsTransfer -Source $LockscreenImageURL -Destination "$LockScreenimage"

#Get Timestamps from downloaded images. This checks to see if there have been updates
$blobbackground = Get-ItemProperty "$backgroundimage" | Select-Object -ExpandProperty LastWriteTime
$bloblockscreen = Get-ItemProperty "$lockscreenimage" | Select-Object -ExpandProperty LastWriteTime

#Checks last modified timestamp of the current files and looks for correct registry values
$backgrounddate = Get-ItemProperty "C:\TEMP\images\background.jpg" | Select-Object -ExpandProperty LastWriteTime
$lockscreendate = Get-ItemProperty "C:\TEMP\images\lockscreen.jpg" | Select-Object -ExpandProperty LastWriteTime

$reg1 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImagePath"
$reg2 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImageStatus"
$reg3 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImageUrl"
$reg4 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImagePath"
$reg5 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageStatus"
$reg6 = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageUrl"

#cleanup temp dir
Remove-Item -Path $ImageDestinationFolder -Recurse -Force

If (($lockscreendate -eq $bloblockscreen) -and ($backgrounddate -eq $blobbackground) -and ($reg2 -and $reg5 -eq $true) -and ($reg1 -and $reg3 -eq "C:\temp\images\background.jpg") -and ($reg4 -and $reg6 -eq "C:\temp\images\lockscreen.jpg"))
{
    Write-Output "Detected"
    exit 0
}
else {
    Write-Output "Image files outdated or missing Registry Values"
    exit 1
}