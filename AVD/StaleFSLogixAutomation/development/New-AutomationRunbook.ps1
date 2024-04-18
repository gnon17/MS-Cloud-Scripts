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
$AgeLimit = (Get-Date).AddDays($daysold)
$csvname = "StaleFSLogix.$datestring.csv"
#Fix daysold if its not negative
If ($daysold -gt 0) {
  $daysold = -$daysold
}

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
    Write-Host $_
}

Write-Host "Setting context for FSLogix storage account and Looking for Stale FSLogix profiles"
$storagecontext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName).Context
$profilefolders = Get-AZStorageFile -ShareName $fileShareName -context $storagecontext | Select-Object -ExpandProperty Name
$files = Try {
ForEach ($profilefolder in $profilefolders) {
Get-AZStorageFile -ShareName $fileShareName -Path $profilefolder -context $storagecontext | Get-AZStorageFile | Where-Object {$_.LastModified -lt $agelimit -and $_.Name -notmatch '.metadata' -and $_.Name -match '.VHDX'} | Select-Object Name,LastModified,length
}
}
catch {
    Write-Host $_
}
$files
$files | export-csv $csvname
$size = ($files | Measure-Object Length -sum).sum
$totalsize = $size / 1gb

#Generate and send email
If ($null -eq $files) {
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
$numberofprofiles = $files.Count
$savings = 0.16*$totalsize
$savingsrounded = [Math]::Round($savings,2)
$totalsizerounded = [Math]::Round($totalsize,2)
$savingsdollars = $savingsrounded.ToString('C',[cultureinfo]$_)
Write-Host "Stale profiles were detected. Calculating size and cost savings estimate to send to Teams. $numberofprofiles FSLogix profiles totaling $totalsizerounded GB have not been modified in 30+ days. Estimated savings of $savingsdollars per month if profiles are removed.
Review the following profiles for deletion:"
Write-Host $files.name

#Generate and send email
$senderemail = $senderemail
$recipient = $recipientemail
$subject = "Stale FSLogix Profiles"
$body = "$numberofprofiles FSLogix profiles have not been used in 45+ days totaling $totalsizerounded GB. Estimated savings of $savingsdollars per month if profiles are removed. Review the attachment and delete stale profiles"
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