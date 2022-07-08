#Variables
$TenantID = "d422cde1-afaf-4b32-9a42-11bfc5233470"
$AppID = "354b5a0a-acb4-4c71-a07b-e9f72dcbe262"
$AppSecret = "JHE8Q~BgIVQgvkQOmZ3s~U3yqZw_NnKVGoBJsdeQ"
$GroupTag = "Autopilot"

#Script
Set-ExecutionPolicy Unrestricted -Force
Install-PackageProvider NuGet -Force -ErrorAction SilentlyContinue
Install-Script Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo -Online -TenantId $TenantID -AppID $AppID -AppSecret $AppSecret -GroupTag $GroupTag