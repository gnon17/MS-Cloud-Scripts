#Variables
$TenantID = ""
$AppID = ""
$AppSecret = ""
$GroupTag = "Autopilot"

#Script
Set-ExecutionPolicy Unrestricted -Force
Install-PackageProvider NuGet -Force -ErrorAction SilentlyContinue
Install-Script Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo -Online -TenantId $TenantID -AppID $AppID -AppSecret $AppSecret -GroupTag $GroupTag
