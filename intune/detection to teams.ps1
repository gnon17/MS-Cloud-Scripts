$program1 = $chrome = Get-Package -name '*zoom*' -ErrorAction SilentlyContinue | select -ExpandProperty "Name"
$File1 = "c:\temp\file1.txt"
$Reg1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$filedetect = Test-Path $File1
$regdetect = Test-Path $Reg1
#
If (($filedetect -and $regdetect -eq $true) -and ($program1 -ne $null)) {
    Write-Output "App Detected"
    exit 0
}
else {
$hostname = hostname
$application = "MyWin32App"
$myTeamsWebHook  = "https://ganlab.webhook.office.com/webhookb2/70980a5b-0f03-466c-902d-1c64e57b1fd6@d422cde1-afaf-4b32-9a42-11bfc5233470/IncomingWebhook/84536dda23664ed1af7b8cdb00ec6c22/6eab05ca-d60c-4b52-9e70-e5b808767691"
$webhookMessage = [PSCustomObject][Ordered]@{
"themeColor" = '#0037DA'
"title"      = "Win32 App No Longer Detected"
"text" = "`n
Device: $Hostname `n
Application: $application `n
Failure Details: `n
$File1 = $filedetect `n
$Reg1 = $regdetect `n
Get-Package Name: $program1"
}
$webhookJSON = convertto-json $webhookMessage -Depth 50
$webhookCall = @{
"URI"         = $myTeamsWebHook
"Method"      = 'POST'
"Body"        = $webhookJSON
"ContentType" = 'application/json'
}
Invoke-RestMethod @webhookCall
exit 1
}