Write-Host "Checking for required module"
$module = get-module -listavailable -name 'Microsoft.Graph.Identity.DirectoryManagement' -ErrorAction SilentlyContinue
if ($module -eq $null) {
    Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force
}
$appid = 'your app ID'
$tenantid = 'your tenant ID'
$secret = 'your secret'
 
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}
 
$connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
    -Method POST `
    -Body $body
 
$token = $connection.access_token
 
Connect-MgGraph -AccessToken $token
$laptop = '{ "extensionAttributes": { "extensionAttribute1": "Laptop" } }'
$desktop = '{ "extensionAttributes": { "extensionAttribute1": "Desktop" } }'
$battery = Get-WmiObject Win32_Battery
$DeviceId = Get-MgDevice | where DisplayName -eq $env:computername | Select-Object -ExpandProperty Id
if ($battery -eq $null) {
Update-MgDevice -DeviceId $DeviceId -BodyParameter $desktop
}
if ($battery -ne $null) {
Update-MgDevice -DeviceId $DeviceId -BodyParameter $laptop
}
Disconnect-MgGraph
