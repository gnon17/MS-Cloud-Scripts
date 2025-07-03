#Variables - Set your model number and groupTag value first
$model = "YourModelHere"
$grouptag = "YourGroupTagHere"

Write-Host -ForegroundColor DarkYellow "Checking for directory C:\temp for transcript and output files"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If (!$LogPathExists) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\groupTagUpdate.log -Force

#check for and install required modules
$modules = 'Microsoft.Graph.Authentication'

Write-Host -ForegroundColor DarkYellow "Installing Required Modules if they're missing..."
Foreach ($module in $modules) {
if (Get-Module -ListAvailable -Name $module) {
    Write-Host -ForegroundColor Yellow "$module module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the $module Module for Current User"
    Install-Module -Name $module -Scope CurrentUser -Force 
    Write-Host "Installed $module module for current user"
}
}
$scopes = "DeviceManagementServiceConfig.ReadWrite.All"
Connect-MgGraph -scopes $scopes

$uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities"
$response = Invoke-MgGraphRequest -Method GET -URI $uri -OutputType PSObject

$body = @{
    groupTag = $grouptag
} | ConvertTo-Json -Depth 5

$filtereddevices = $response.value | Where-Object Model -eq $model

ForEach ($filtereddevice in $filtereddevices) {
Try {
$ID = $filtereddevice.id
$uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$id/updateDeviceProperties"
Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body -ContentType "application/json"
Write-Host -ForegroundColor Green "Updated groupTag on"$filtereddevice.serialnumber""
}
Catch {
        Write-Host -ForegroundColor Red "Error setting GroupTag on"$filtereddevice.serialnumber""
        Write-Host $_
        }
}

Disconnect-MgGraph
Stop-Transcript