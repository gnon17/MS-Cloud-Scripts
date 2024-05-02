param(
	[Parameter(mandatory = $false)]
	[string]$ResourceGroupName = "FSLogixAutomation",
	
    [Parameter(mandatory = $true)]
	[string]$AzureRegion,

    [Parameter(mandatory = $false)]
	[string]$AutomationAccount = "FSLogixAutomationAccount",

    [Parameter(mandatory = $false)]
	[string]$RunbookName = "StaleFSLogixProfiles",

    [Parameter(mandatory = $false)]
	[string]$ScheduleName = "FirstDayofMonth",

    [Parameter(mandatory = $true)]
    [INT32]$daysold,
	
    [Parameter(mandatory = $true)]
    [string]$storageAccName,

    [Parameter(mandatory = $true)]
    [string]$SAresourceGroupName,

    [Parameter(mandatory = $true)]
    [string]$fileShareName,

    [Parameter(mandatory = $true)]
    [string]$recipientemail,

    [Parameter(mandatory = $false)]
    [string]$SharedMailboxName = "FSLogixNotifications"
)

Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for transcript"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\NewiOSMDMAutomation.log -Force

If ($daysold -gt 0) {
    $daysold = -$daysold
}

#Check for modules and install
$modules = 'Az.Accounts', 'Az.ManagedServiceIdentity', 'Az.Resources', 'Az.Automation', 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Applications', 'ExchangeOnlineManagement', 'Microsoft.Graph.Users.Actions'
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
    Write-Output $($subs) | Format-Table
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
$runbookfilename = "New-AutomationRunbook.ps1"
$runbookurl = "https://raw.githubusercontent.com/gnon17/MS-Cloud-Scripts/main/AVD/StaleFSLogixAutomation/development/New-AutomationRunbook.ps1"
Invoke-WebRequest -Uri $runbookurl -OutFile "$pwd\$runbookfilename"

#Import Automation Runbook
Import-AzAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -Path "$pwd\$runbookfilename" -Published -ResourceGroup $ResourceGroupName -Type PowerShell
Remove-Item -Path "$pwd\$runbookfilename" -Force

#Imports required PowerShell modules into Automation Account
#add Microsoft.Graph.Users.Actions if sending emails 
$Loop = $true
$moduleNames = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Beta.DeviceManagement.Administration', 'Microsoft.Graph.Beta.Devices.CorporateManagement', 'Microsoft.Graph.Beta.DeviceManagement.Enrollment', 'Microsoft.Graph.Users.Actions'
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

#Create Automation Schedule
$nextmonth = (Get-Date -Hour 08 -Minute 00 -Second 00).AddMonths(1)
$firstday = $nextmonth
while ($firstday.Day -ne '1') {
    $firstday = $firstday.AddDays(-1)
}
$TimeZone = ([System.TimeZoneInfo]::Local).Id

$param = @{
    Name = $ScheduleName
    AutomationAccountName = $AutomationAccount
    ResourceGroupName = $ResourceGroupName
    TimeZone = $TimeZone
    StartTime = $firstday
    MonthInterval = 1
    DaysOfMonth = 'One'
    }
New-AzAutomationSchedule @param

#Create Shared Mailbox
Connect-ExchangeOnline
New-Mailbox -Shared -Name $SharedMailboxName -Displayname $SharedMailboxName
$SharedMailboxSmtp = get-mailbox -identity $SharedMailboxName | Select-Object -ExpandProperty "PrimarySMTPAddress"

#Runbook Parameters
$runbookParams = @{
    daysold = $daysold
    resourceGroupName = $SAresourceGroupName
    storageAccName = $storageAccName
    fileShareName = $fileShareName
    recipientemail = $recipientemail
    senderemail = $SharedMailboxSmtp
}

#Link Schedule to Runbook and Assign Params
Register-AzAutomationScheduledRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccount -RunbookName $RunbookName -ScheduleName $ScheduleName -Parameters $runbookParams

#Find Service Principal ID for automation account
$ServicePrincipalID = Get-AzADServicePrincipal -Displayname $AutomationAccount | Select-Object -ExpandProperty Id

#Connect to Graph with scopes to assign app permissions
Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All", "Application.ReadWrite.All"

#Find required graph permission for Runbook and grant for Automation Service Principal
#ADD 'Mail.Send', 'Mail.ReadWrite' if you're sending email notifications also
$permissions = 'DeviceManagementServiceConfig.Read.All', 'Mail.Send', 'Mail.ReadWrite'

ForEach ($permission in $permissions) {
$GraphResource = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$approle = $GraphResource.AppRoles | Where-Object {$_.value -eq $permission}
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipalId -PrincipalId $ServicePrincipalId -AppRoleId $approle.Id -ResourceId $GraphResource.Id
}

Disconnect-ExchangeOnline -Confirm:$false
Disconnect-AzAccount
Disconnect-MgGraph
Stop-Transcript