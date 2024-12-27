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

#Variables
$scopes = "Directory.Read.All, DeviceManagementServiceConfig.ReadWrite.All, Domain.Read.All, Domain.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All"
$jsonpath = "C:\Temp"
$policyfiles = Get-ChildItem $jsonpath -Filter "*.json" -Recurse

Connect-MgGraph -scopes $scopes

Foreach ($policyfile in $policyfiles) {
$policydata = Get-Content -path $policyfile.FullName | ConvertFrom-JSON | Select-Object -ExpandProperty '@odata.context' -ErrorAction SilentlyContinue
$policytype = Get-Content -path $policyfile.FullName | ConvertFrom-JSON | Select-Object -ExpandProperty '@odata.type' -ErrorAction SilentlyContinue

## CA POLICIES ##
#Clear assignments and import Conditional Access Policies
If ($policydata -match "conditionalAccess") {
    Try{
    Write-Host -ForegroundColor Yellow "Policy type is Conditional Access Policy"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $policy.state = "disabled"
    $policy.conditions.users.includeUsers = @("None")
    $policy.conditions.users.excludeRoles = @()
    $policy.conditions.users.excludeUsers = @()
    $policy.conditions.users.excludeGroups = @()
    $policy.conditions.users.includeGroups = @()
    $policy.conditions.users.includeRoles = @()
    $policy.conditions.users.includeGuestsOrExternalUsers = $null
    $policy.conditions.users.excludeGuestsOrExternalUsers = $null
    #If authentication strength is configured then clear out what breaks the JSON import
    if ($policy.grantControls.authenticationStrength) {
        $policy.grantControls = $policy.grantControls | Select-Object -ExcludeProperty authenticationStrength@odata.context
        $policy.grantControls.authenticationStrength = $policy.grantControls.authenticationStrength | Select-Object id 
    }
    $policyjson = $policy | ConvertTo-Json -Depth 15
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/identity/conditionalAccess/policies/ -ContentType "application/json" -Body $policyjson
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile.name"
        Write-Host $_
        }}

## Settings Catalog Policies ##
If ($policydata -match "configurationPolicies") {
    Try {
    Write-Host -ForegroundColor Yellow "Policy type is Settings Catalog Policy"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies -ContentType "application/json" -Body $policy
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile"
        Write-Host $_
        }    
}

## App Protection Policies ##
If ($policydata -match "managedAppPolicies") {
    Try {
    Write-Host -ForegroundColor Yellow "Policy type is App Protection Policy"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceAppManagement/managedAppPolicies/ -ContentType "application/json" -Body $policy
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile"
        Write-Host $_
        }    
}

## App Configuration Policies ##
If ($policydata -match "mobileAppConfigurations") {
    Try {
    Write-Host -ForegroundColor Yellow "Policy type is App Configuration Policy"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations/ -ContentType "application/json" -Body $policy
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile"
        Write-Host $_
        }    
}

## Custom Device Config Profiles ##
If ($policytype -eq "#microsoft.graph.windows10CustomConfiguration" -or "#microsoft.graph.windows10GeneralConfiguration" -or "#microsoft.graph.macOSCustomConfiguration" -or "#microsoft.graph.iosDeviceFeaturesConfiguration" -or "#microsoft.graph.windowsUpdateForBusinessConfiguration" -or "#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration") {
    Try {
    Write-Host -ForegroundColor Yellow "Policy type is Custom Device Configuration Policy"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile
    #getting errors when using Beta so using v1
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations -ContentType "application/json" -Body $policy
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile"
        Write-Host $_
        }    
}

##Remediations##
If ($policydata -match "deviceHealthScripts") {
    Try {
    Write-Host -ForegroundColor Yellow "Policy type is Remediation"
    Write-Host -ForegroundColor Yellow "Trying to import "$policyfile.name""
    $policy = Get-Content -path $policyfile
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/ -ContentType "application/json" -Body $policy
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing $policyfile"
        Write-Host $_
        }    
}

else {
    write-host "Policy type not supported for Import with this script"
}
}