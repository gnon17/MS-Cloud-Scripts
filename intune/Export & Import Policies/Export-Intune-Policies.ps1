#check for log directory and start transcript 
Write-Host -ForegroundColor DarkYellow "Checking for directory C:\temp for transcript and output files"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\PolicyExport.log -Force

#check for and install required modules
$modules = 'Microsoft.Graph.Authentication'

Write-Host -ForegroundColor DarkYellow "Installing Required Modules if they're missing..."
Foreach ($module in $modules) {
if (Get-Module -ListAvailable -Name $module) {
    Write-Host -ForegroundColor Yellow "$module module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the $module Module for Current User"
    Install-Module -Name $module -Scope CurrentUser -Force 
    Write-Host "Installed $module module for current user"
}
}

Connect-MgGraph -Scopes "Policy.Read.All","DeviceManagementConfiguration.Read.All"

#Conditional Access Policies
$path = "C:\temp\CA-Policies"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting Conditional Access Policies to $path"
$uri = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$policy = Invoke-MgGraphRequest -Method GET -URI $uri$policyId
$policyjson = $policy | ConvertTo-Json -Depth 15
$name = $policy.displayname
$policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
write-host -ForegroundColor yellow "Exported $name successfully"
}

#Settings Catalog Policies
$path = "C:\temp\ConfigurationPolicies"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting Configuration Policies to $path"
$uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$allPolicies = @()
do {
    $allPolicies += $response.value
    $nextLink = $response.'@odata.nextLink'
    if ($nextLink) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $nextLink
    }
} while ($nextLink)
Foreach ($policy in $allPolicies) {
    $name = $policy.name
    $id = $policy.id
    $policy = Invoke-MgGraphRequest -Method GET -Uri $uri/$id -OutputType PSObject
    $policyconfig = Invoke-MgGraphRequest -Method GET -Uri "$uri$($policy.id)/settings"
    $policy | Add-Member -MemberType NoteProperty -Name 'settings' -Value @() -Force
    $policy.settings += $policyconfig.value
    $policyJson = $policy | ConvertTo-Json -Depth 25 
    $policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
    Write-Host -ForegroundColor Yellow "Exported $name successfully"
}

#App Protection Policies
$path = "C:\temp\App_Protection_Policies"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting App Protection Policies to $path"
$uri = "https://graph.microsoft.com/beta/deviceAppManagement/managedAppPolicies/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$policy = Invoke-MgGraphRequest -Method GET -URI $uri$policyId
$policyjson = $policy | ConvertTo-Json -Depth 15
$name = $policy.displayname
$policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
write-host -ForegroundColor yellow "Exported $name successfully"
}

#App Configuration Policies
$path = "C:\temp\App_Configuration_Policies"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting App Configuration Policies to $path"
$uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$policy = Invoke-MgGraphRequest -Method GET -URI $uri$policyId
$policyjson = $policy | ConvertTo-Json -Depth 15
$name = $policy.displayname
$policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
write-host -ForegroundColor yellow "Exported $name successfully"
}

#Custom Device Configuration Profiles
$path = "C:\temp\DeviceConfigurations"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting Device Configurations to $path"
$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$uridecrypted = "?includeEncryptedData=true"
$policy = Invoke-MgGraphRequest -Method GET -URI "$uri$policyId$uridecrypted" -OutputType PSObject
if ($policy.'@odata.type' -eq "#microsoft.graph.windows10CustomConfiguration") {
    Foreach ($omaSetting in $policy.omaSettings) {
        if ($omaSetting.isEncrypted -eq $true) {
        $plainTextUri = "$uri$policyId/getOmaSettingPlainTextValue(secretReferenceValueId='$($omaSetting.secretReferenceValueId)')"
        $plainTextValue = Invoke-MgGraphRequest -Method GET -Uri $plainTextUri
        $omasetting.value = $plainTextValue.value
        $policy.PsObject.Properties.Remove("id")
        $policy.PsObject.Properties.Remove("lastModifiedDateTime")
        $omaSetting.PsObject.Properties.Remove("secretReferenceValueId")
        $omaSetting.PsObject.Properties.Remove("isEncrypted")
        }
        else {
        $policy.PsObject.Properties.Remove("id")
        $policy.PsObject.Properties.Remove("lastModifiedDateTime")
        $omaSetting.PsObject.Properties.Remove("secretReferenceValueId")
        $omaSetting.PsObject.Properties.Remove("isEncrypted")
        $omaSetting.PsObject.Properties.Remove("isReadOnly")
        }
    }
}
$policyjson = $policy | ConvertTo-Json -Depth 15
$name = $policy.displayname
$policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
write-host -ForegroundColor yellow "Exported $name successfully"
}

#Remediations
$path = "C:\temp\Remediations"
New-Item -Path $path -ItemType Directory -Force
Write-Host -ForegroundColor Green "Exporting App Configuration Policies to $path"
$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$policy = Invoke-MgGraphRequest -Method GET -URI $uri$policyId -OutputType PSObject
$policy.PsObject.Properties.Remove("id")
$policy.PsObject.Properties.Remove("lastModifiedDateTime")
$policyjson = $policy | ConvertTo-Json -Depth 15
$name = $policy.displayname
$policyJson | Out-File -FilePath "$path\$name.json" -Encoding utf8
write-host -ForegroundColor yellow "Exported $name successfully"
}

Stop-Transcript
Disconnect-MgGraph
