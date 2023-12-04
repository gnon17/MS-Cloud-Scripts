param(
	[Parameter(mandatory = $true,HelpMessage='The amount of days since profiles were last modified. Default value is -30 if this is not set')]
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
#Variables
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
Write-Host "Stale profiles were detected. Calculating size and cost savings estimate to send to Teams. $numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Potential cost reduction of $savingsrounded dollars per month if profiles are removed.
Review the following profiles for deletion: $oldfiles"
$numberofprofiles = $oldfiles.Count
$savings = 0.16*$totalsize
$savingsrounded = [Math]::Round($savings,2)
$totalsizerounded = [Math]::Round($totalsize,2)

$webhookMessage = [PSCustomObject][Ordered]@{
"themeColor" = '#0037DA'
"title"      = "$numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Potential cost reduction of $savingsrounded dollars per month if profiles are removed.
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