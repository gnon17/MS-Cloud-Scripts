$Umbrella = Get-Service "Umbrella_RC" -ErrorAction SilentlyContinue
If ($umbrella) {
Write-Output "Umbrella Roaming Client is installed"
exit 0
}
Else {
Write-Output "Umbrella Roaming Client Service not found"
exit 1
{