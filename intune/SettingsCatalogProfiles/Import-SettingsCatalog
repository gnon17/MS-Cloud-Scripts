param(
  [Parameter(mandatory = $true)]
  [String]$client_Id,
  [Parameter(mandatory = $true)]
  [String]$client_Secret,
  [Parameter(mandatory = $true)]
  [String]$tenant_Id
)

$Body = @{    
  Grant_Type    = "client_credentials"
  resource      = "https://graph.microsoft.com"
  client_id     = $client_Id
  client_secret = $client_Secret
  } 
  
$ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoft.com/$tenant_Id/oauth2/token?api-version=1.0" -Method POST -Body $Body
$TimeZone = Get-Content -Path .\TimeZone.json

#====================================================
#Timezone
Invoke-RestMethod -UseBasicParsing -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" `
-Method "POST" `
-WebSession $session `
-Headers @{
  "X-Content-Type-Options"="nosniff"
  "x-ms-command-name"="PolicyGraphProxy_updateConfigurationPolicy"
  "Accept-Language"="en"
  "Authorization"="Bearer $($ConnectGraph.access_token)"
  "x-ms-effective-locale"="en.en-us"
  "Accept"="*/*"
  "Referer"=""
} `
-ContentType "application/json" `
-Body $TimeZone
