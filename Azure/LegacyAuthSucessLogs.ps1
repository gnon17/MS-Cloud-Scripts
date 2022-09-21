##Variables
$BasicAuths = @('Autodiscover', 'Exchange ActiveSync', 'Exchange Online Powershell', 'Exchange Web Services', 'IMAP', 'MAPI Over HTTP', 'Offline Address Book', 'Other clients', 'Outlook Anywhere (RPC over HTTP)', 'POP', 'Reporting Web Services', 'SMTP', 'Authenticated SMTP', 'Universal Outlook')

#Checking for AzureADPreview Module
Write-Host -f Yellow "Checking if AzureADPreview Module is installed"
if (Get-Module -ListAvailable -Name AzureADPreview) {
    Write-Host "Module exists, continuing"
} 
else {
    Write-Host "Module does not exist - Installing AzureADPreview Module"
    Install-Module -Name AzureADPreview -AllowClobber -Force
}
Import-Module AzureADPreview -Force

#Connect to AzureAD and pull successful legacy Auth Sign-ins
Write-Host -f Yellow "Connecting to AzureAD...."
Connect-AzureAD
Get-AzureADAuditSignInLogs -Filter "status/errorCode eq 0" | where-object{$BasicAuths -eq $_.ClientAppUsed} | Format-Table -Property CreatedDateTime, UserPrincipalName, AppDisplayName, IPAddress, ClientAppUsed
Write-Host -F Yellow "Script Complete - Press enter to disconnect from AzureAD"
Pause
Disconnect-AzureAD
