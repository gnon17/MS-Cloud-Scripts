#Check for Teams Backgrounds Directory and create if it doesn't exist
Write-Host "Checking for Teams background directory..." -ForegroundColor Green
$BackgroundDir = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"
$DirExists = Test-Path $BackgroundDir
If ($DirExists -ne $True) {
New-Item -Path "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads" -Name Uploads -ItemType Directory
}

#Checks for Az.Storage module and installs if it doesn't exist
Write-Host "Checking for Az.Storage Module..." -ForegroundColor Green
$azstoragemodule = Get-Module -name Az.Storage
if ($azstoragemodule -eq $null) {
install-module az.storage -scope currentuser -Force
}

#Variables for blob connection and download
$BlobURL = "https://<YOURSTORAGEACCOUNT>.blob.core.windows.net/"
$container = 'backgrounds'
$storageaccount = New-AzStorageContext -Anonymous -BlobEndpoint $BlobURL
$blobs = Get-AzStorageBlob -Container $container -Context $storageaccount
foreach ($blob in $blobs)
{
Get-AzStorageBlobContent -Container $container -Blob $blob.Name -Destination $BackgroundDir -Context $storageaccount -Force
}
