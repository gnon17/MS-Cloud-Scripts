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
#$TimeZone = Get-Content -Path .\TimeZone.json 
#==================================================== 
#Profile 1
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
-Body "{`"creationSource`":null,`"name`":`"A Settings Catalog Policy`",`"description`":`"Sets device to Central Time zone`",`"platforms`":`"windows10`",`"technologies`":`"mdm`",`"roleScopeTagIds`":[`"0`"],`"settings`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSetting`",`"settingInstance`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_timelanguagesettings_configuretimezone`",`"simpleSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationStringSettingValue`",`"value`":`"Eastern Standard Time`"}}}],`"templateReference`":{`"templateId`":`"`",`"templateFamily`":`"none`",`"templateDisplayName`":null,`"templateDisplayVersion`":null}}" 
#==================================================== 
#Profile 2 
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
-Body "{`"creationSource`":null,`"name`":`"Another Settings Catalog Policy`",`"description`":`"Locks workstation screen after 15 minurtes of inactivity`",`"platforms`":`"windows10`",`"technologies`":`"mdm`",`"roleScopeTagIds`":[`"0`"],`"settings`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSetting`",`"settingInstance`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_devicelock_devicepasswordenabled`",`"choiceSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`",`"value`":`"device_vendor_msft_policy_config_devicelock_devicepasswordenabled_0`",`"children`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_devicelock_maxinactivitytimedevicelock`",`"simpleSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue`",`"value`":15}}]}}}],`"templateReference`":{`"templateId`":`"`",`"templateFamily`":`"none`",`"templateDisplayName`":null,`"templateDisplayVersion`":null}}" 
