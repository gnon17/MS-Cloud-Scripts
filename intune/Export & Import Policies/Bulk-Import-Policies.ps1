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
$scopes = "Directory.Read.All, DeviceManagementServiceConfig.ReadWrite.All, Domain.Read.All, Domain.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, AuthenticationContext.ReadWrite.All, AuthenticationContext.Read.All, Policy.Read.All, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, Application.Read.All"
$jsonpath = "C:\Temp"
$policyfiles = Get-ChildItem $jsonpath -Filter "*.json" -Recurse

Connect-MgGraph -scopes $scopes

Foreach ($policyfile in $policyfiles) {
$policydata = Get-Content -path $policyfile.FullName | ConvertFrom-JSON | Select-Object -ExpandProperty '@odata.context' -ErrorAction SilentlyContinue

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

## Custom Device Config Profiles ##
If ($policydata -match "deviceConfigurations") {
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

## Remediations ##
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

Stop-Transcript
Disconnect-MgGraph