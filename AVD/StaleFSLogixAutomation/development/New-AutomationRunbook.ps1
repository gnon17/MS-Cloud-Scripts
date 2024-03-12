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
[string]$recipientemail,

[Parameter(mandatory = $true)]
[string]$senderemail
)

$dateString = (Get-Date).ToString("MM-dd-yyyy")
#$logname = "StaleFSLogix.$dateString.log"
#Start-Transcript $logname -Verbose
$AgeLimit = (Get-Date).AddDays($daysold)
$csvname = "StaleFSLogix.$datestring.csv"

Write-Host "Connecting to Azure..."
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
    $AccessToken = Get-AzAccessToken -ResourceTypeName MSGraph
    $SecureToken = $AccessToken.Token | ConvertTo-SecureString -AsPlainText -Force
    Connect-MgGraph -AccessToken $SecureToken -Nowelcome
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Set-AzContext -Subscription "4e9e2233-2576-4eec-b36f-0e56b48c9c75"
Write-Host "Setting context for FSLogix storage account and Looking for Stale FSLogix profiles"
$storagecontext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName).Context

$profilefolders = Get-AZStorageFile -ShareName $fileShareName -context $storagecontext | Select -ExpandProperty Name
$output = Try {
ForEach ($profilefolder in $profilefolders) {
Get-AZStorageFile -ShareName $fileShareName -Path $profilefolder -context $storagecontext | Get-AZStorageFile | Where-Object LastModified -lt $agelimit | Select Name,LastModified -ErrorAction Continue
}
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$outputfiltered = $output | Where-Object {$_.Name -notmatch '.metadata' -and $_.Name -match '.VHDX'}
$outputfiltered | Export-CSV $csvname

#foreach ($directory in $directories)  
#    {  
#        $size = (Get-AZStorageFile -Context $storagecontext -ShareName $fileShareName -Path $directory.Name | Where-Object LastModified -lt $AgeLimit | Measure-Object Length -sum).sum
#        $sizemb = $size / 1gb
#        $totalsize += $sizemb 
#    }

Write-Host "Generating CSV File and setting blob storage container"

$outputfiltered | Export-CSV $csvname


If ($null -eq $output) {
Write-Host "No stale profiles were found. Sending Teams message."
#Generate and send email
$senderemail = $senderemail
$recipient = $recipientemail
$subject = "No Stale FSLogix Profiles Detected"
$body = "No stale FSLogix profiles were detected. All profiles have been used within the last 45 days."

$oldFiles
$type = "Text"
$save = "true"

$params = @{
    Message         = @{
        Subject       = $subject
        Body          = @{
            ContentType = $type
            Content     = $body
        }
        ToRecipients  = @(
            @{
                EmailAddress = @{
                    Address = $recipient
                }
            }
        )
    }
    SaveToSentItems = $save
}
Send-MgUserMail -UserId $senderemail -BodyParameter $params -Verbose
    Stop-Transcript
}
Else {
$numberofprofiles = $outputfiltered.Count
$savings = 0.16*$totalsize
#$savingsrounded = [Math]::Round($savings,2)
#$totalsizerounded = [Math]::Round($totalsize,2)
#$savingsdollars = $savingsrounded.ToString('C',[cultureinfo]$_)
#Write-Host "Stale profiles were detected. Calculating size and cost savings estimate to send to Teams. $numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Estimated savings of $savingsdollars per month if profiles are removed.
#Review the following profiles for deletion: $oldfiles"

#Generate and send email
$senderemail = $senderemail
$recipient = $recipientemail
$subject = "Stale FSLogix Profiles"
$body = "$numberofprofiles FSLogix profiles have not been used in 45+ days. Please review the attachment for any profiles that can be deleted."
$attachmentpath = "$pwd\$csvname"
$attachmentmessage = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$attachmentpath"))
$attachmentname = $csvname
$type = "Text"
$save = "true"

$params = @{
    Message         = @{
        Subject       = $subject
        Body          = @{
            ContentType = $type
            Content     = $body
        }
        ToRecipients  = @(
            @{
                EmailAddress = @{
                    Address = $recipient
                }
            }
        )
        Attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                Name = $attachmentname
                ContentType = "text/plain"
                ContentBytes = $attachmentmessage
            }
        )
    }
    SaveToSentItems = $save
}
Send-MgUserMail -UserId $senderemail -BodyParameter $params -Verbose
}
Disconnect-AzAccount
Disconnect-MgGraph