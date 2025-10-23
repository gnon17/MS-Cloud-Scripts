Install-Module "Microsoft.Graph.Authentication"

Start-Transcript -Path ".\RemoveOffice365MobileDevices.log"

$scopes = "DeviceManagementManagedDevices.Read.All, DeviceManagementManagedDevices.ReadWrite.All, Directory.ReadWrite.All"
Connect-MgGraph -Scopes $scopes
$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"

$response = Invoke-MgGraphRequest -Method GET -Uri $uri

#Get Devices with Ownership of Unknown (these are managed by Office 365 Mobile)
$UnknownWindowsDevices = $response.value | Where-Object {$_.operatingSystem -eq "Windows" -and $_.managedDeviceOwnerType -eq "Unknown"}

Write-Host "Found "($UnknownWindowsDevices.count)" Windows devices with Unknown Ownership"
Write-Host "Removing devices with unknown ownership from Intune"

ForEach ($UnknownWindowsDevice in $UnknownWindowsDevices) {
Try {
    Invoke-MgGraphRequest -Method DELETE -Uri "$uri/$($unknownwindowsdevice.id)"
    Write-Host "Successfully deleted $($unknownwindowsdevice.devicename)"
}
Catch {
    Write-Host "Error deleting $($unknownwindowsdevice.devicename)"
    Write-Host $_
}
}
disconnect-mggraph
Stop-Transcript