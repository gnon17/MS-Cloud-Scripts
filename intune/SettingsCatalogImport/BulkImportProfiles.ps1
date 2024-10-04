#Variables
$scopes = "DeviceManagementConfiguration.ReadWrite.All"
#Policy.ReadWrite.ConditionalAccess, CloudPC.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, RoleAssignmentSchedule.ReadWrite.Directory, Domain.Read.All, Domain.ReadWrite.All, Directory.Read.All, Policy.ReadWrite.ConditionalAccess, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, openid, profile, email, offline_access, DeviceManagementRBAC.Read.All, DeviceManagementRBAC.ReadWrite.All
$jsonpath = "C:\temp\JSON"
$policyfiles = Get-ChildItem $jsonpath | Select-Object -ExpandProperty Name

Connect-MgGraph -scopes $scopes

Foreach ($policyfile in $policyfiles) {
Try {
$policy = Get-Content -path $jsonpath\$policyfile
Invoke-MgGraphRequest -Method POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies -ContentType "application/json" -Body $policy
}
Catch {
Write-Host "there was an error importing $policyfile"
Write-Host $_
}
}