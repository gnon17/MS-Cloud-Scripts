#check for module
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
$scopes = "DeviceManagementConfiguration.ReadWrite.All"
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