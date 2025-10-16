#MAM Configuration Script
    #Creates a MAM_PilotGroup policy with no members
    #Creates managed app filters for Unmanaged iOS and Unmanaged Android devices
    #Configures MAM baseline App Protection policies for iOS & Android and assigns to the MAM_PilotGroup group 
    #Creates Conditional Access Policy requiring app protection policy and assigns to the MAM_PilotGroup security group

    $LogFile = "C:\Temp\MAMAutoConfiglog.txt"
    Start-Transcript -Path $LogFile
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
    
    # Login to Graph with required scopes
    $scopes = @(
      "Group.ReadWrite.All",
      "DeviceManagementConfiguration.ReadWrite.All",
      "DeviceManagementApps.ReadWrite.All",
      "Policy.ReadWrite.ConditionalAccess"
    )
    Connect-MgGraph -Scopes $scopes

Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for logfile"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}



$scopes = "Policy.ReadWrite.ConditionalAccess", "Policy.Read.All", "Application.Read.All", "User.Read.All","Group.ReadWrite.All", "Directory.ReadWrite.All", "DeviceManagementConfiguration.ReadWrite.All", "DeviceManagementApps.ReadWrite.All"
Connect-MgGraph -Scopes $Scopes

#########Create MAM Pilot Security Group#####
Write-Host -ForegroundColor DarkYellow "Creating MAM_PilotGroup Security Group"
try {
    $groupBody = @{
        displayName     = "MAM_PilotGroup"
        description     = "Pilot group for MAM"
        mailEnabled     = $false
        mailNickname    = "mampilotgroup"
        securityEnabled = $true
        groupTypes      = @()
    } | ConvertTo-Json -Depth 4

    $grp = Invoke-MgGraphRequest -Method POST -Uri "/beta/groups" -Body $groupBody -ContentType "application/json"
    $GroupID = $grp.id
}
catch {
    Write-Host -ForegroundColor Red "Error while creating the MAM_PilotGroup:"
    Write-Host -ForegroundColor Red $_
    throw
}

#########Managed App Filters#################
#Managed App Filter - Unmanaged Android Devices
Write-Host -ForegroundColor DarkYellow "Creating Managed App Filter for Unmanaged Android Devices"
try {
    $androidFilterBody = @{
        displayName   = "Unmanaged Android Devices"
        description   = "Filter for all unmanaged Android devices"
        platform      = "AndroidMobileApplicationManagement"
        rule          = '(app.deviceManagementType -eq "Unmanaged")'
        roleScopeTags = @()  # optional
    } | ConvertTo-Json -Depth 4

    $androidfilter = Invoke-MgGraphRequest -Method POST -Uri "/beta/deviceManagement/assignmentFilters" -Body $androidFilterBody -ContentType "application/json"
    $androidfilterid = $androidfilter.id
}
catch {
    Write-Host -ForegroundColor Red "Error while creating the managed app filter for Unmanaged Android Devices"
    Write-Host -ForegroundColor Red $_
}

#Managed App Filter - Unmanaged iOS Devices
Write-Host -ForegroundColor DarkYellow "Creating Managed App Filter for Unmanaged iOS Devices"
try {
    $iosFilterBody = @{
        displayName   = "Unmanaged iOS Devices"
        description   = "All non-MDM iOS devices"
        platform      = "iOSMobileApplicationManagement"
        rule          = '(app.deviceManagementType -eq "Unmanaged")'
        roleScopeTags = @()
    } | ConvertTo-Json -Depth 4

    $iosfilter = Invoke-MgGraphRequest -Method POST -Uri "/beta/deviceManagement/assignmentFilters" -Body $iosFilterBody -ContentType "application/json"
    $iosfilterid = $iosfilter.id
}
catch {
    Write-Host -ForegroundColor Red "Error while creating the managed app filter for Unmanaged iOS Devices"
    Write-Host -ForegroundColor Red $_
}


#############################################Android App Protecion Policy###################################################
############################################################################################################################

$workingdir = Get-Location
$policyName = "Unmanaged Android App Protection.json"
$filePath = Join-Path -Path $workingdir -ChildPath $policyName
$url = "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/intune/MAM%20Scripts/Unmanaged%20Android%20App%20Protection.json"

# Download the JSON file
Invoke-WebRequest -Uri $url -OutFile $filePath

Write-Host -ForegroundColor Green "Downloaded JSON file to: $filePath"

$policyPath = $filePath
$body = Get-Content -Path $policyPath -Raw

# Create the Android MAM policy using Graph
try {
    $androidresponse = Invoke-MgGraphRequest -Method POST -Uri "/beta/deviceAppManagement/androidManagedAppProtections" -Body $body -ContentType "application/json"
    Write-Host -ForegroundColor Green "Created Windows MAM policy: $($androidresponse.displayName)"
    $androidpolicyID = $androidresponse.id
    Write-Host "Policy ID: $androidpolicyID"
}
catch {
    Write-Host -ForegroundColor Red "Error creating Windows MAM policy"
    Write-Host -ForegroundColor Red $_
}

#Assign Policy to MAM Group + Filter we created earlier
$assignmentbody = @{
    assignments = @(
        @{
        "@odata.type" = "#microsoft.graph.targetedManagedAppPolicyAssignment"
            target = @{
                "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                groupId = $groupid
                deviceAndAppManagementAssignmentFilterId = $androidfilterid
                deviceAndAppManagementAssignmentFilterType = "include"
            }
            
        }
    )    
} | ConvertTo-JSON -Depth 10

try {
    Invoke-MgGraphRequest -Method POST -URI "/beta/deviceAppManagement/androidManagedAppProtections/$androidpolicyid/assign" -Body $assignmentbody -ContentType "application/JSON"
    Write-Host -ForegroundColor Green "Android App Protection Policy assigned to pilot group with filter"
}
catch {
    Write-Host -Foreground Color Red "Error assigning Android policy to pilot group"
    Write-Host -Foreground Color Red $_
}

#############################################iOS App Protecion Policy###################################################
########################################################################################################################

$workingdir = Get-Location
$policyName = "Unmanaged iOS App Protection.json"
$filePath = Join-Path -Path $workingdir -ChildPath $policyName
$url = "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/intune/MAM%20Scripts/Unmanaged%20iOS%20App%20Protection.json"

# Download the JSON file
Invoke-WebRequest -Uri $url -OutFile $filePath
Write-Host -ForegroundColor Green "Downloaded JSON file to: $filePath"

$policyPath = $filePath
$body = Get-Content -Path $policyPath -Raw

# Create the Android MAM policy using Graph
try {
    $iosresponse = Invoke-MgGraphRequest -Method POST -Uri "/beta/deviceAppManagement/iosManagedAppProtections" -Body $body -ContentType "application/json"
    Write-Host -ForegroundColor Green "Created Windows MAM policy: $($iosresponse.displayName)"
    $iospolicyid = $iosresponse.id
    Write-Host "Policy ID: $iospolicyid"
}
catch {
    Write-Host -ForegroundColor Red "Error creating Windows MAM policy"
    Write-Host -ForegroundColor Red $_
}

#Assign Policy to MAM Group + Filter we created earlier
$assignmentbody = @{
    assignments = @(
        @{
        "@odata.type" = "#microsoft.graph.targetedManagedAppPolicyAssignment"
            target = @{
                "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                groupId = $groupid
                deviceAndAppManagementAssignmentFilterId = $iosfilterid
                deviceAndAppManagementAssignmentFilterType = "include"
            }
            
        }
    )    
} | ConvertTo-JSON -Depth 10

try {
    Invoke-MgGraphRequest -Method POST -URI "/beta/deviceAppManagement/iosManagedAppProtections/$iospolicyid/assign" -Body $assignmentbody -ContentType "application/JSON"
    Write-Host -ForegroundColor Green "iOS App Protection Policy assigned to pilot group with filter"
}
catch {
    Write-Host -Foreground Color Red "Error assigning iOS policy to pilot group"
    Write-Host -Foreground Color Red $_
}

#############################################MAM Conditional Access Policy##############################################
########################################################################################################################
Write-Host -ForegroundColor DarkYellow "Creating Conditional Access Policy for MAM"

$workingdir = Get-Location
$policyName = "Require AppProtection - Unmanaged Mobile Devices.json"
$filePath = Join-Path -Path $workingdir -ChildPath $policyName
# Raw GitHub URL (use raw.githubusercontent.com, not github.com)
$url = "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/intune/MAM%20Scripts/Require%20AppProtection%20-%20Unmanaged%20Mobile%20Devices.json"

# Download the JSON file
Invoke-WebRequest -Uri $url -OutFile $filePath

Write-Host -ForegroundColor Green "Downloaded JSON file to: $filePath"

#Assign to our group and make sure its set to disabled
$policyPath = $filePath
$policy = Get-Content -Path $policyPath | ConvertFrom-JSON
$policy.conditions.users.includeGroups = @($GroupID)
$policy.conditions.users.includeUsers = @()
$policy.state = 'disabled'
$body = $policy | ConvertTo-Json -Depth 20

#Create the CA policy using graph
try {
    $caresponse = Invoke-MgGraphRequest -Method POST -Uri "/beta/identity/conditionalAccess/policies" -Body $body -ContentType "application/json"
    Write-Host -ForegroundColor Green "Created MAM conditional access policy policy: $($caresponse.displayName)"
    $capolicyid = $caresponse.id
    Write-Host "Policy ID: $capolicyid"
}
catch {
    Write-Host -ForegroundColor Red "Error creating Conditional Access policy"
    Write-Host -ForegroundColor Red $_
}


Disconnect-MgGraph
Stop-Transcript