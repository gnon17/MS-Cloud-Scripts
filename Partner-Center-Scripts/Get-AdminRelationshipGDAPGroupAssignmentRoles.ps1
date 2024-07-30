Write-Host -ForegroundColor DarkYellow "Checking for directory C:\temp for transcript and output files"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\GDAPGroupRoles.log -Force

#Check For reuqired Modules and Install if missing
$modules = 'Microsoft.Graph.Identity.Partner', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Identity.Governance', 'ImportExcel'

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
Foreach ($module in $modules) {
    try {
        Import-Module $module
    }
    catch {
        Write-Host -ForegroundColor Red $_
    }
    }

#Connect to Graph
Connect-MgGraph -scope "DelegatedAdminRelationship.Read.All","DelegatedAdminRelationship.ReadWrite.All", "Directory.Read.All"

$delegatedAdminRelationshipIds = Get-MgTenantRelationshipDelegatedAdminRelationship | Where-Object Status -eq "active" | Select-Object -ExpandProperty Id
$count = $delegatedAdminRelationshipIds | Measure-Object | Select-Object -expandproperty Count
Write-Host -ForegroundColor Green "Found $count total active admin relationships with assigned GDAP roles"

ForEach ($delegatedAdminRelationshipId in $delegatedAdminRelationshipIds) {
Try {
$ClientName = Get-MgTenantRelationshipDelegatedAdminRelationship -DelegatedAdminRelationshipId $delegatedAdminRelationshipId | Select-Object -ExpandProperty DisplayName
$AccessAssignments = Get-MgTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId | Select-Object -ExpandProperty Id

If ($AccessAssignments) {
Write-Host -ForegroundColor Green "Found GDAP group assignments for admin relationship name $ClientName"
    ForEach ($AccessAssignment in $AccessAssignments) {
        $AssignmentDetail = Get-MgTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -DelegatedAdminAccessAssignmentId $AccessAssignment
        $GroupID = $AssignmentDetail.AccessContainer | Select-Object -ExpandProperty AccessContainerID
        $GroupName = Get-MgGroup -GroupID $GroupID | Select-Object -ExpandProperty DisplayName
        Write-Host -ForegroundColor Yellow "Identifying GDAP Role Assignments for $groupname..."
        $RoleIDs = ($AssignmentDetail.accessdetails | Select-Object -expandproperty UnifiedRoles).RoleDefinitionId
            
            $Roles = ForEach ($RoleID in $RoleIDs) {
            Get-MgRoleManagementDirectoryRoleDefinition | Where-Object Id -eq $RoleID | Select-Object -ExpandProperty DisplayName
            $Roles | Export-Excel -path c:\temp\GDAP.Report-$clientname.xlsx -AutoSize -WorksheetName "Roles-$GroupName"
            }
}
}
}
Catch {
Write-Host $_
}
}
Disconnect-MgGraph
Stop-Transcript