$connections = Test-Path "$env:APPDATA\sonicwall\Global VPN Client\connections.rcf"
$backup = Test-Path "$env:APPDATA\sonicwall\Global VPN Client\backup.rcf"
if ($connections -and $backup) {
write-output "configuration files exist. Deleting default.rcf"
Exit 1
}
Else {
write-output "configuration files not built yet"
Exit 0
}