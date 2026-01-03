Write-Host -ForegroundColor DarkYellow "Checking for directory C:\temp for transcript and output files"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\PolicyImport.log -Force

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
$scopes = "Directory.Read.All, DeviceManagementServiceConfig.ReadWrite.All, Domain.Read.All, Domain.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, AuthenticationContext.ReadWrite.All, AuthenticationContext.Read.All, Policy.Read.All, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementScripts.ReadWrite.All, Application.Read.All"
$jsonpath = "C:\Temp"
$policyfiles = Get-ChildItem $jsonpath -Filter "*.json" -Recurse

Connect-MgGraph -scopes $scopes

#Set Arrays for policy gathering
$namedLocations = @()
$configurationPolicies = @()
$managedapppolicies = @()
$deviceConfigurations = @()
$deviceHealthScripts = @()
$deviceManagementScripts = @()
$assignmentFilters = @()
$deviceComplianceScripts = @()
$deviceCompliancePolicies = @()

#Determine policytypes and group them together in respective array
Foreach ($policyfile in $policyfiles) {
$policydata = Get-Content -path $policyfile.FullName | ConvertFrom-JSON | Select-Object -ExpandProperty '@odata.context' -ErrorAction SilentlyContinue
If ($policydata -match "namedLocations") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $namedLocations += $policy
}
If ($policydata -match "configurationPolicies") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $configurationPolicies += $policy
}
If ($policydata -match "managedAppPolicies") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $managedapppolicies += $policy
}
If ($policydata -match "deviceConfigurations") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $deviceConfigurations += $policy
}
If ($policydata -match "deviceHealthScripts") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $deviceHealthScripts += $policy
}
If ($policydata -match "deviceManagementScripts") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $deviceManagementScripts += $policy
}
If ($policydata -match "assignmentFilters") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $assignmentFilters += $policy
}
If ($policydata -match "deviceComplianceScripts") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $deviceComplianceScripts += $policy
}
If ($policydata -match "deviceCompliancePolicies") {
    $policy = Get-Content -path $policyfile | ConvertFrom-Json
    $deviceCompliancePolicies += $policy
}
}

## Named Locations ##
Write-Host -ForegroundColor Cyan "Importing Named Locations"
foreach ($namedLocation in $namedLocations) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$namedLocation.displayName""
    $policy = $namedLocation | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/conditionalAccess/namedLocations/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully Imported"$namedLocation.displayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing "$namedLocation.displayname""
        Write-Host $_
        }    
}

## Settings Catalog Policies ##
Write-Host -ForegroundColor Cyan "Importing Settings Catalog Policies"
foreach ($configurationpolicy in $configurationPolicies) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import "$configurationpolicy.Name""
    $policy = $configurationpolicy | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully Imported"$configurationpolicy.Name""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing "$configurationpolicy.Name""
        Write-Host $_
        }    
}

## App Protection Policies ##
Write-Host -ForegroundColor Cyan "Importing App Protection Policies"
foreach ($managedAppPolicy in $managedAppPolicies) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import "$managedAppPolicy.displayname""
    $policy = $managedAppPolicy | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceAppManagement/managedAppPolicies/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully Imported"$managedAppPolicy.displayname""
    }
        Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$managedAppPolicy.displayname""
        Write-Host $_
        }    
}

## Custom Device Config Profiles ##
Write-Host -ForegroundColor Cyan "Importing Custom Device Configuration Profiles"
foreach ($deviceConfiguration in $deviceConfigurations) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import "$deviceConfiguration.displayName""
    $policy = $deviceConfiguration | ConvertTo-JSON -Depth 20
    #getting errors when using Beta so using v1
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully Imported"$deviceConfiguration.displayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$deviceConfiguration.displayName""
        Write-Host $_
        }    
}

## Remediations ##
Write-Host -ForegroundColor Cyan "Importing Remediations"
ForEach ($deviceHealthScript in $deviceHealthScripts) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$deviceHealthScript.displayName""
    $policy = $deviceHealthScript | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully imported"$deviceHealthScript.displayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$deviceHealthScript.displayName""
        Write-Host $_
        }    
}

## Platform Scripts ##
Write-Host -ForegroundColor Cyan "Importing Platform Scripts"
ForEach ($deviceManagementScript in $deviceManagementScripts) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$deviceManagementScript.displayname""
    $policy = $deviceManagementScript | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully Imported"$deviceManagementScript.displayname""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$deviceManagementScript.displayname""
        Write-Host $_
        }    
}

## Tenant Filters ##
Write-Host -ForegroundColor Cyan "Importing Tenant Filters"
ForEach ($assignmentFilter in $assignmentFilters) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$assignmentfilter.displayName""
    $policy = $assignmentFilter | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/assignmentFilters/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Successfully imported"$assignmentfilter.displayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$assignmentfilter.displayName""
        Write-Host $_
        }    
}

#Count current compliance policy scripts
$URI = "https://graph.microsoft.com/beta/deviceManagement/deviceComplianceScripts/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$existingcount = $response.'@odata.count'

If ($devicecompliancescripts.count -ne 0) {
## Custom Compliance Scripts ##
Write-Host -ForegroundColor Cyan "Importing Custom Compliance Scripts"
ForEach ($deviceComplianceScript in $deviceComplianceScripts) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$deviceComplianceScript.displayName""
    $policy = $deviceComplianceScript | ConvertTo-Json -Depth 20
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/deviceComplianceScripts/ -ContentType "application/json" -Body $policy | Out-Null
    Write-Host -ForegroundColor Green "Succesfully imported"$deviceComplianceScript.displayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing"$deviceComplianceScript.displayName""
        Write-Host $_
        }    
}

$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$newcount = $response.'@odata.count'

While ($newcount -ne $existingcount + $devicecompliancescripts.count) {
    Write-Host -ForegroundColor Yellow "New compliance policy IDs not available yet. Checking again in five seconds..."
    Start-Sleep -Seconds 5
    $response = Invoke-MgGraphRequest -Method GET -Uri $uri
    $newcount = $response.'@odata.count'
}

# Update Reference file with new script ID so imported compliance scripts are assigned correctly
Write-Host -ForegroundColor Yellow "Updating reference file for custom compliance policy scripts"
$allPolicies = @()
$referencefile = Import-CSV -path C:\temp\compliance_policies\ComplianceScriptReference.csv
$URI = "https://graph.microsoft.com/beta/deviceManagement/deviceComplianceScripts/"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri
$policyIds = $response.value.id
Foreach ($policyId in $PolicyIds) {
$policy = Invoke-MgGraphRequest -Method GET -URI "$uri$policyId" -OutputType PSObject
#$name = $policy.displayname
$allpolicies += $policy 
}
}

Write-Host -ForegroundColor Yellow "Matching compliance script to new ID"
ForEach ($policy in $allPolicies) {
    $compliancescriptname = $policy.displayName
    $match = $Referencefile | Where-Object { $_.displayName -eq $compliancescriptname }
    Try {    
    If ($match) {
            Write-Host -ForegroundColor Green "Found compliance scrpit match for $($policy.displayName)"
            $match.NewCompliancePolicyID = $policy.ID
        }
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error matching a compliance script for $($policy.displayName)"
        Write-Host $_
        }  
}

## Compliance Policies ##
Write-Host -ForegroundColor Cyan "Importing Compliance Policies"
ForEach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
    Try {
    Write-Host -ForegroundColor Yellow "Trying to import"$deviceCompliancePolicy.DisplayName""
    $policy = $deviceCompliancePolicy
    if ($policy.deviceCompliancePolicyScript.deviceComplianceScriptId) {
        $match = $referencefile | Where-Object { $_.ID -eq $policy.deviceCompliancePolicyScript.deviceComplianceScriptId }
        Try {
        If ($match) {
            Write-Host -ForegroundColor Yellow "Editing compliance policy script ID for "$policy.displayname" "
            $policy.deviceCompliancePolicyScript.deviceComplianceScriptId = $match.NewCompliancePolicyID
        }
        }   
            Catch {
            Write-Host -ForegroundColor Red "There was an error editing"$policy.displayname"to match the new compliance script ID"
            Write-Host $_
            }
    }
    $policyjson = $policy | ConvertTo-Json -Depth 15
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies/ -ContentType "application/json" -Body $policyjson | Out-Null
    Write-Host -ForegroundColor Green "Successfully imported"$deviceCompliancePolicy.DisplayName""
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error importing$deviceCompliancePolicy.DisplayName"
        Write-Host $_
        }    
    }

Stop-Transcript
Disconnect-MgGraph