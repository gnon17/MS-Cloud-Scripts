<#
.SYNOPSIS
  The script can be used in an Azure Automation runbook using a system managed identity to locate FSLogix profiles that have not been modified for a specified number of days 
.DESCRIPTION
- Analyze the FSLogix profiles share for profiles that have not been modified for the specified number of days
- Calculates the total size in GB for the stale profiles 
- Calculates the estimated savings in Azure spend per month if the stale profiles are deleted. Currently set to the cost of AZ Files Premium GB in the NCUS region ($0.16)
- Sends a log of the Runbook output and a CSV file of the profiles and their size to a storage account container

.PARAMETER daysold
    the number of days since profiles have been modified (e.g. -30)
.PARAMETER resourceGroupName
    The resource group name where the FSLogix storage account is located
.PARAMETER StorageAccName
    The name of the FSLogix storage account
.PARAMETER fileShareName
    The name of the FSLogix file share
.PARAMETER LogStorageResourceGroup
    The name of the resource group for the storage account where the container for the log and CSV export is located
.PARAMETER logstorageaccount
    The name of the storage account for the log and CSV files
.PARAMETER logcontainer
    The name of the container for the log and CSV files
.PARAMETER WebhookURL
    The Teams webhook URL for the Teams notification
#>

param(
[Parameter(mandatory = $true)]
[INT32]$daysold,
	 
[Parameter(mandatory = $true)]
[string]$resourceGroupName,
	
[Parameter(mandatory = $true)]
[string]$storageAccName,

[Parameter(mandatory = $true)]
[string]$fileShareName,

[Parameter(mandatory = $true)]
[string]$LogStorageResourceGroup,

[Parameter(mandatory = $true)]
[string]$logstorageaccount,

[Parameter(mandatory = $true)]
[string]$logcontainer,

[Parameter(mandatory = $true)]
[string]$WebhookURL
)

Enable-AzureRmAlias
$dateString = (Get-Date).ToString("MM-dd-yyyy")
$logname = "StaleFSLogix.$dateString.log"
Start-Transcript $logname -Verbose
$AgeLimit = (Get-Date).AddDays($daysold)

Write-Host "Connecting to Azure..."
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Host "Setting context for CSV and Log destinations and Looking for Stale FSLogix profiles"
$storagecontext=(Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName).Context
$directories=Get-AZStorageFile -Context $storagecontext -ShareName $fileShareName  

$oldFiles = foreach($directory in $directories)  
    {  
        Get-AZStorageFile -Context $storagecontext -ShareName $fileShareName -Path $directory.Name | Get-AZStorageFile | Where-Object LastModified -lt $AgeLimit | Select-Object -expandproperty Name
    }

$csv = foreach($directory in $directories)  
    {  
        Get-AZStorageFile -Context $storagecontext -ShareName $fileShareName -Path $directory.Name | Get-AZStorageFile | Where-Object LastModified -lt $AgeLimit | Select-Object Name,LastModified,Length
    }

foreach ($directory in $directories)  
    {  
        $size = (Get-AZStorageFile -Context $storagecontext -ShareName $fileShareName -Path $directory.Name | Get-AZStorageFile | Where-Object LastModified -lt $AgeLimit | Measure-Object Length -sum).sum
        $sizemb = $size / 1gb
        $totalsize += $sizemb 
    }

Write-Host "Generating CSV File and setting blob storage container"
$csvname = "StaleFSLogix.$datestring.csv"
$csv | Export-CSV $csvname
$logstoragecontext=(Get-AzStorageAccount -ResourceGroupName $LogStorageResourceGroup -Name $logstorageaccount).Context
Set-AzureStorageBlobContent -Context $logstoragecontext -Container $logcontainer -File $csvname -Blob $csvname -Force

If ($oldfiles -eq $null) {
    Write-Host "No stale profiles were found. Sending Teams message."
    $webhookMessage = [PSCustomObject][Ordered]@{
        "themeColor" = '#0037DA'
        "title"      = "No stale FSLogix Profiles were detected"
        "text" = "There were no profiles detected that have not been modified for 30+ days"
        }
        $webhookJSON = convertto-json $webhookMessage -Depth 50
        $webhookCall = @{
        "URI"         = $webhookurl
        "Method"      = 'POST'
        "Body"        = $webhookJSON
        "ContentType" = 'application/json'
        }
    Invoke-RestMethod @webhookCall
    Stop-Transcript
    Set-AzureStorageBlobContent -Context $logstoragecontext -Container $logcontainer -File $logname -Blob $logname -Force
}
Else {
$numberofprofiles = $oldfiles.Count
$savings = 0.16*$totalsize
$savingsrounded = [Math]::Round($savings,2)
$totalsizerounded = [Math]::Round($totalsize,2)
$savingsdollars = $savingsrounded.ToString('C',[cultureinfo]$_)
Write-Host "Stale profiles were detected. Calculating size and cost savings estimate to send to Teams. $numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Estimated savings of $savingsdollars per month if profiles are removed.
Review the following profiles for deletion: $oldfiles"

$webhookMessage = [PSCustomObject][Ordered]@{
"themeColor" = '#0037DA'
"title"      = "$numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Potential cost reduction of $savingsdollars per month if profiles are removed.
Review the following profiles for deletion:"
"text" = "$oldFiles"
}
$webhookJSON = convertto-json $webhookMessage -Depth 50
$webhookCall = @{
"URI"         = $webhookurl
"Method"      = 'POST'
"Body"        = $webhookJSON
"ContentType" = 'application/json'
}
Invoke-RestMethod @webhookCall
Stop-Transcript
Set-AzureStorageBlobContent -Context $logstoragecontext -Container $logcontainer -File $logname -Blob $logname -Force
}
