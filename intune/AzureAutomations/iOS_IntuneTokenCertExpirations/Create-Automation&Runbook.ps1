param(
	[Parameter(mandatory = $false)]
	[string]$ResourceGroupName = "iOS_MDMAutomation",
	
    [Parameter(mandatory = $true)]
	[string]$AzureRegion,

    [Parameter(mandatory = $false)]
	[string]$AutomationAccount = "iOSMDMAutoationAccount",

    [Parameter(mandatory = $false)]
	[string]$RunbookName = "iOSMDMExpirations",

    [Parameter(mandatory = $false)]
	[string]$ScheduleName = "EveryOtherSunday",

    [Parameter(mandatory = $false)]
	[string]$daystilexpiry = "30",

    [Parameter(mandatory = $true)]
	[string]$webhookURL

)

Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for transcript"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\NewiOSMDMAutomation.log -Force

#Check for modules and install
#add Microsoft.Graph.Users.Actions for email
$modules = 'Az.ManagedServiceIdentity', 'Az.Resources', 'Az.Automation', 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Applications'
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

#Connect to Az and prompts for subscription if more than one sub are detected
Connect-AzAccount
$subs = Get-AzSubscription | Select-Object Name,Id
$subscount = Get-AzSubscription | Measure-Object | Select-Object -expandproperty Count
If ($subscount -gt "1") {
    Write-Host -ForegroundColor DarkYellow "There are multiple Azure Subscriptions. Select the subscription you want to use"
    Write-Output $($subs) | FT
    $subID = Read-Host "Enter the Azure subscription ID you want to select"
    Select-AzSubscription -SubscriptionID $subID
}
Else {
    Write-Host -ForegroundColor DarkYellow "Only one subscription in this Azure tenant. Using the $($subs.name) subscription."
}

#Creates Resource Group and Automation Account
New-AzResourceGroup -Name $ResourceGroupName -Location $AzureRegion
New-AzAutomationAccount -Name $AutomationAccount -Location $AzureRegion -ResourceGroupName $ResourceGroupName -AssignSystemIdentity

#Download the Runbook file from Github
$runbookfilename = "Get-AppleEnrollmentCertExpiration.ps1"
$runbookurl = "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/intune/AzureAutomations/iOS_IntuneTokenCertExpirations/Get-iosIntuneCertTokenExpirations.ps1"
Invoke-WebRequest -Uri $runbookurl -OutFile "$pwd\$runbookfilename"

#Import Automation Runbook
Import-AzAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -Path "$pwd\$runbookfilename" -Published -ResourceGroup $ResourceGroupName -Type PowerShell
Remove-Item -Path "$pwd\$runbookfilename" -Force

#Imports required PowerShell modules into Automation Account
#add Microsoft.Graph.Users.Actions if sending emails 
$Loop = $true
$moduleNames = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Beta.DeviceManagement.Administration', 'Microsoft.Graph.Beta.Devices.CorporateManagement', 'Microsoft.Graph.Beta.DeviceManagement.Enrollment'
Foreach ($modulename in $modulenames) {
try {
    $module = Find-Module $moduleName
    $modulePath = $module.RepositorySourceLocation + "/package/$($module.Name)/$($module.Version)"
    New-AzAutomationModule -AutomationAccountName $AutomationAccount -Name $moduleName -ContentLinkUri $modulePath -ResourceGroupName $ResourceGroupName -Verbose
    while($Loop){
        $AuthModule = Get-AzAutomationModule -resourcegroup $resourcegroupname -AutomationAccountName $automationaccount | Where-Object Name -eq Microsoft.Graph.Authentication | Select-Object -expandproperty ProvisioningState
        if($AuthModule -eq "Succeeded") {
        Write-Host -ForegroundColor Green "The Microsoft.Graph.Authentication Module imported successfully. Importing remaining modules..."
        $Loop = $false
        }
        else{
        Write-Host -ForegroundColor DarkYellow "Waiting for the Microsoft.Graph.Authentication Module to succeed. This is a dependency for the remaining modules. Current state is $Authmodule"        
        Start-Sleep -Seconds 10
        }
    }
}
catch {
    Write-Host -ForegroundColor Red $_
}
}

#Find date of next upcoming Sunday
$today = (Get-Date).DayOfWeek.Value__
$DaysNeeded = (7 - $today)
$NextSunday = (Get-Date -Hour 12 -Minute 00 -Second 00).AddDays($DaysNeeded)
$TimeZone = ([System.TimeZoneInfo]::Local).Id

#Create Automation Schedule
New-AzAutomationSchedule -Name $ScheduleName -StartTime $NextSunday -WeekInterval 2 -DaysofWeek Sunday -ResourceGroupName $ResourceGroupName -TimeZone $TimeZone -AutomationAccountName $AutomationAccount

#Runbook Parameters
$runbookParams = @{
    webhookurl = $webhookurl
    daystilexpiry = $daystilexpiry
    }

#Link Schedule to Runbook and Assign Params
Register-AzAutomationScheduledRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccount -RunbookName $RunbookName -ScheduleName $ScheduleName -Parameters $runbookParams

#Find Service Principal ID for automation account
$ServicePrincipalID = Get-AzADServicePrincipal -Displayname $AutomationAccount | Select-Object -ExpandProperty Id

#Connect to Graph with scopes to assign app permissions
Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All", "Application.ReadWrite.All"

#Find required graph permission for Runbook and grant for Automation Service Principal
#ADD 'Mail.Send', 'Mail.ReadWrite' if you're sending email notifications also
$permissions = 'DeviceManagementServiceConfig.Read.All'

ForEach ($permission in $permissions) {
$GraphResource = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$approle = $GraphResource.AppRoles | Where-Object {$_.value -eq 'DeviceManagementServiceConfig.Read.All'}
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipalId -PrincipalId $ServicePrincipalId -AppRoleId $approle.Id -ResourceId $GraphResource.Id
}

Disconnect-AzAccount
Disconnect-MgGraph
Stop-Transcript