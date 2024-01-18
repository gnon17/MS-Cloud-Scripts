Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for transcript"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}

Start-Transcript -Path $LogPath\SettingsCatalogImport.log -Force
Write-Host -ForegroundColor DarkYellow "Installing Required Modules"

if (Get-Module -ListAvailable -Name "Microsoft.Graph.Authentication") {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Authentication Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Authentication Module for Current User"
    Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Authentication Module"
}

if (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.DeviceManagement) {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Beta.DeviceManagement Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Beta.DeviceManagement Module for Current User"
    Install-Module -Name Microsoft.Graph.Beta.DeviceManagement -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Beta.DeviceManagement Module"
}

$scopes = "DeviceManagementConfiguration.ReadWrite.All"
Connect-MgGraph -Scopes $Scopes

#$path = "C:\Users\gpnov\OneDrive\Desktop\Scripts\Templates\"
$profiles = Get-ChildItem .\ -Filter '*.json'
Try {
ForEach ($profile in $profiles) {
    $json = Get-Content $profile | ConvertFrom-Json | Select-Object -Property Name,Description,Platforms,roleScopeTagIds,settings,technologies -ErrorAction Continue
    $JsonConverted = ConvertTo-Json $json -Depth 20 -ErrorAction Continue
    New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $jsonconverted -ErrorAction Continue
}
}
Catch {
    Write-Host -ForegroundColor Red "Error while importing one or more setting profiles"
    Write-Host -ForegroundColor Red $_
}

Disconnect-MgGraph
Stop-Transcript