#RequiredModules
#Microsoft.Graph.Beta.DeviceManagement.Administration
#Microsoft.Graph.Beta.Devices.CorporateManagement
#Microsoft.Graph.Beta.DeviceManagement.Enrollment
#If emailing, Microsoft.Graph.Users.Actions

param(
	[Parameter(mandatory = $true)]
	[string]$webhookurl,
	 
    [Parameter(mandatory = $false)]
	[string]$daystilexpiry = "30"
)

try
{
    Connect-AzAccount -Identity
    $AccessToken = Get-AzAccessToken -ResourceTypeName MSGraph
    $SecureToken = $AccessToken.Token | ConvertTo-SecureString -AsPlainText -Force
    Connect-MgGraph -AccessToken $SecureToken
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$today = get-date

###MDM Push Cert
$certexpiration = Get-MgBetaDeviceManagementApplePushNotificationCertificate | select-object -expandproperty ExpirationDateTime

### VPP Token
$tokenexpiration = Get-MgBetaDeviceAppManagementVppToken | select-object -expandproperty ExpirationDateTime

###Enrollment Program Token
$EPTExpiration = Get-MgBetaDeviceManagementDepOnboardingSetting | Select-object -expandproperty TokenExpirationDateTime

If ($today.AddDays($daystilexpiry) -gt $certexpiration -or $today.AddDays($daystilexpiry) -gt $tokenexpiration -or $today.AddDays($daystilexpiry) -gt $EPTExpiration) {
Write-Output "An iOS MDM Certificate or Token is expiring in less than 30 days"
$webhookMessage = [PSCustomObject][Ordered]@{
    "themeColor" = '#0037DA'
    "title"      = "An iOS MDM Certificate or Token is expiring in less than 30 days. Verify expiration dates below:"
    "text" = "`n
    Apple MDM  Push Certificate Expiration:     $certexpiration 
    Apple VPP Token Expiration:                 $tokenexpiration
    Apple Enrollment Program Token Expiration:  $EPTExpiration

    https://learn.microsoft.com/en-us/intune-education/renew-ios-certificate-token"          
}
    $webhookJSON = convertto-json $webhookMessage -Depth 50
    $webhookCall = @{
    "URI"         = $webhookurl
    "Method"      = 'POST'
    "Body"        = $webhookJSON
    "ContentType" = 'application/json'
    }
Invoke-RestMethod @webhookCall

#######Send Email Template##########
#$senderemail = "thesenderemail@domain.com"
#$recipient = "recipienteamil@domain.com"
#$subject = "Expiration Warning - Intune iOS Cert or Token"
#$body = "An iOS MDM Certificate or Token is expiring in less than 30 days. Verify expiration dates below:

#Apple MDM  Push Certificate Expiration:     $certexpiration 
#Apple VPP Token Expiration:                 $tokenexpiration
#Apple Enrollment Program Token Expiration:  $EPTExpiration

#Click the link below for renewal details: 
#https://learn.microsoft.com/en-us/intune-education/renew-ios-certificate-token"
#$type = "Text"
#$save = "true"

#$params = @{
#    Message         = @{
#        Subject       = $subject
#        Body          = @{
#            ContentType = $type
#            Content     = $body
#        }
#        ToRecipients  = @(
#            @{
#                EmailAddress = @{
#                    Address = $recipient
#                }
#            }
#        )
#    }
#    SaveToSentItems = $save
#}
#Send-MgUserMail -UserId $senderemail -BodyParameter $params
}
Else {
write-Output "Certificate and tokens are not within 30 days of expiration"
}

Disconnect-MgGraph
