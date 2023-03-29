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
$myTeamsWebHook  = "YOUR WEBHOOK URL"
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
