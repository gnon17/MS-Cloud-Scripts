Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for transcript"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\umbrellacertinstall.log -Force

$Cert = Get-ChildItem -path Cert:\LocalMachine\Root | Where Thumbprint -eq c5091132e9adf8ad3e33932ae60a5c8fa939e824

If ($cert) {
Write-Output "Cisco Umbrella Root Certificate is already installed"
}
Else {
Try {
#Download and Install Certificate
Write-Host "Checking for temp directory..." -ForegroundColor Green
$tempdir = "c:\temp\certfile"
$DirExists = Test-Path $tempdir
If ($DirExists -ne $True) {
New-Item -Path "C:\temp" -Name "certfile" -ItemType Directory
}
$certURL = "https://d36u8deuxga9bo.cloudfront.net/certificates/Cisco_Umbrella_Root_CA.cer"
Start-BitsTransfer $certURL -destination $tempdir
Import-Certificate -FilePath $tempdir\Cisco_Umbrella_Root_CA.cer -CertStoreLocation Cert:\LocalMachine\Root
Remove-Item -Path $tempdir -Recurse -Force
}
Catch {
	Write-Host -ForegroundColor Red "Error while downloading and installing certificate. See log at c:\temp\umbrellacertinstall.log"
	Write-Host -ForegroundColor Red $_
}
}
Stop-Transcript