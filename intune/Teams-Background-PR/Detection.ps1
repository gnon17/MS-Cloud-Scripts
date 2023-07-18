#Checks for Az.Storage module and installs if it doesn't exist
Write-Host "Checking for Az.Storage Module..." -ForegroundColor Green 
$azstoragemodule = Get-Module -name Az.Storage
if ($azstoragemodule -eq $null) {
Install-PackageProvider -Scope CurrentUser -Name NuGet -MinimumVersion 2.8.5.201 -Force
install-module az.storage -scope currentuser -Force
}

#Connects to storage account and pulls background image file names
$BlobURL = "https://yourstorageaccountname.blob.core.windows.net/"
$container = 'yourcontainername'
$storageaccount = New-AzStorageContext -Anonymous -BlobEndpoint $BlobURL
$blobs = Get-AzStorageBlob -Container $container -Context $storageaccount
$Images = $Blobs.name
$BackgroundDir = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"
$Backgrounds = Get-ChildItem $BackgroundDir | Select -ExpandProperty Name -ErrorAction SilentlyContinue

#compare file names to see if they exist in the teams backgrounds destination
$FileComparison = 
foreach ($image in $images)
{
$image -in $backgrounds
}

Write-Host "Checking to see if blob container images already exist..." -ForegroundColor Green 
If ($FileComparison -contains $False) {
Write-Output "Background Images are Missing"
exit 1
}
else {
Write-Output "All background images exist"
exit 0
}
