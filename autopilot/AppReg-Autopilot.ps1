#For adding App Registration in Azure AD and Assigning proper API Permissions for Graph
#The Object ID is for the newly created App Registration. The APIID is for the respective Graph URI. The -Type Role are application permissions.
#Resources - https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azadapplication?view=azps-7.4.0 | https://docs.microsoft.com/en-us/powershell/module/az.resources/add-azadapppermission?view=azps-7.4.0 | https://docs.microsoft.com/en-us/graph/permissions-reference


#Install Necessary Modules
#Install-Module AZ -Force
#Install-Module AzureAD -Force

#Connect to Azure Powershell
Write-Host -f Yellow "Connecting to AzAccount and AzureAD" 
Connect-AzAccount
Connect-AzureAD

#Variables and naming the new AAD Application
$AppName = Read-Host "Name your App"
$Today = Get-Date
$ExpirationDate = (Get-Date).AddDays(14)

#Create new App Registration and assign ID (ObjectID) to variable
Write-Host -f Yellow "Creating Azure AD App"
New-AzADApplication -DisplayName $AppName -HomePage "https://portal.azure.com" -ReplyUrls "https://portal.azure.com" | Out-Null
$ObjectID = Get-AzADApplication -DisplayName $AppName | Select-Object -ExpandProperty ID
$AppID = Get-AzADApplication -DisplayName $AppName | Select-Object -ExpandProperty AppID
Start-Sleep -s 5

#Add required permissions for Graph API (reference: https://docs.microsoft.com/en-us/graph/permissions-reference)
Write-Host -f Yellow "Setting $AppName API Permissions"
#DeviceManagementApps.ReadWrite.All
Add-AzADAppPermission -ObjectId $ObjectID -ApiId 00000003-0000-0000-c000-000000000000 -PermissionId 78145de6-330d-4800-a6ce-494ff2d33d07 -Type Role
#DeviceManagementConfiguration.ReadWrite.All
Add-AzADAppPermission -ObjectId $ObjectID -ApiId 00000003-0000-0000-c000-000000000000 -PermissionId 9241abd9-d0e6-425a-bd4f-47ba86e767a4 -Type Role
#DeviceManagementManagedDevices.ReadWrite.All
Add-AzADAppPermission -ObjectId $ObjectID -ApiId 00000003-0000-0000-c000-000000000000 -PermissionId 243333ab-4d21-40cb-a475-36241daa0842 -Type Role
#DeviceManagementServiceConfig.ReadWrite.All
Add-AzADAppPermission -ObjectId $ObjectID -ApiId 00000003-0000-0000-c000-000000000000 -PermissionId 5ac13192-7ace-4fcf-b828-1a26f28068ee -Type Role
Start-Sleep -s 8 

#Create Client Secret for secure remote access to GraphAPI
Write-Host -f Yellow "Creating App Credential"
$ClientSecret = Get-AzADApplication -ApplicationID $appid | New-AzADAppCredential -StartDate $today -EndDate $ExpirationDate | Select-Object -ExpandProperty SecretText

#Gather output variable details for the App connection:
$TenantID = Get-AzTenant | Select-Object -ExpandProperty ID
$ClientID = (get-azureadapplication -filter "DisplayName eq '$($AppName)'" | foreach { $_.AppID })

#Display details on screen:
$AppConnectionDetails = "Connection details for the newly created $AppName AAD Application:
============================================================
THE BELOW VALUES WERE AUTO-COPIED TO YOUR CLIPBOARD. RECORD THESE VALUES. 
-------------------
Application name:   $AppName
App/Client ID:      $ClientID
Secret Key:         $ClientSecret
Tenant ID:          $TenantID
-------------------
============================================================"

#Obtain admin consent for new Azure AD Application
Write-Host -f Yellow "Press ENTER to launch Browser and obtain Consent for Microsoft Graph permissions. Use the same client credentials you previously used"
$AppConnectionDetails | clip
Pause
Start "https://login.microsoftonline.com/common/adminconsent?client_id=$ClientID&redirect_uri=https://portal.azure.com"
Write-Host -f Yellow "After obtaining admin consent, press ENTER again to continue"
Pause

Write-Host -f Yellow $AppConnectionDetails
Write-Host -f Yellow "Script is complete - Press ENTER to safely disconnect from Azure and AzureAD"

Pause

Disconnect-AzAccount
Disconnect-AzureAD