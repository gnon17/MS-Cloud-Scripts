$JsonFile = Test-Path "$env:ProgramData\Cisco\Cisco Secure Client\Umbrella\OrgInfo.json"
$UmbrellaService = Get-Service -Name 'csc_umbrellaagent' -ErrorAction SilentlyContinue
$VPNService = Get-Service -Name 'csc_vpnagent' -ErrorAction SilentlyContinue
If ($UmbrellaService -and $VPNService -and $JsonFile) {
Write-Output "Detected"
Exit 0
}
Else {
Write-Output "Not Detected"
Exit 1
}