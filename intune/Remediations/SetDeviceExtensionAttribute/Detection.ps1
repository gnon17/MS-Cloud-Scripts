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
$DeviceId = Get-MgDevice | where DisplayName -eq $env:computername | Select-Object -ExpandProperty Id
$properties = get-mgdevice -DeviceId $deviceID | select-object -expandproperty AdditionalProperties
$extensionattributes = $properties.extensionAttributes | FT -HideTableHeaders | Out-String
$battery = Get-WmiObject Win32_Battery
if ($battery -eq $null) {
    $attributevalue = "extensionAttribute1 Desktop"
    }
if ($battery -ne $null) {
    $attributevalue = "extensionAttribute1 Laptop"
    }
if ($extensionattributes.Trim() -match $attributevalue) {
    write-output "Correct Attribute Assigned"
    exit 0
}
else {
    write-output "Attribute missing or incorrect"
    Exit 1
}