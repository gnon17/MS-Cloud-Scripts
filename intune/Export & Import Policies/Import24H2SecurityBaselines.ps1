##### Imports security baseline policies from https://github.com/dgulle/Security-Baselines/tree/master/Windows%20Baseline%2024H2 to Intune"

$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\SecurityBaselineImport.log -Force

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

$apiUrl = "https://api.github.com/repos/dgulle/Security-Baselines/contents/Windows%20Baseline%2024H2?ref=master"

try {
    $contents = Invoke-RestMethod -Uri $apiUrl
} catch {
    Write-Host "Error retrieving folder contents."
    exit
}
$filenames = $contents.name | where-object {$_ -match ".json"}

# Connect to MS Graph
$scopes = "Directory.Read.All, DeviceManagementServiceConfig.ReadWrite.All, Domain.Read.All, Policy.Read.All, DeviceManagementConfiguration.ReadWrite.All"
connect-mggraph -scopes $scopes

# Grab policies, format policies, import to Intune
$uri = "https://github.com/dgulle/Security-Baselines/raw/master/Windows%20Baseline%2024H2/"
ForEach ($filename in $filenames) {
    $policy = Invoke-RestMethod -Uri $uri/$filename    
If ($policy.gettype().Name -eq "PSCustomObject") {
    Try {
        $policy = $policy | ConvertTo-JSON -Depth 30
        Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/ -ContentType "application/json" -Body $policy
        Write-Host -ForegroundColor Green "Imported"$filename successfully""
        }
        Catch {
            Write-Host -ForegroundColor Red "Error Importing"$filename""
            Write-Host $_
        }
}
Elseif ($policy.StartsWith('"{\r\n')) {
        Try {
        $policy = $policy | ConvertFrom-JSON -Depth 30
        Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/ -ContentType "application/json" -Body $policy
        Write-Host -ForegroundColor Green "Imported"$filename successfully""
        }
        Catch {
            Write-Host -ForegroundColor Red "Error Importing"$filename""
            Write-Host $_
        }
    }
else {
        Try{
    Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/ -ContentType "application/json" -Body $policy
    Write-Host -ForegroundColor Green "Imported"$filename successfully""
    }
    Catch {
        Write-Host -ForegroundColor Red "Error Importing"$filename""
        Write-Host $_
    }
}
}

Stop-Transcript
Disconnect-MgGraph