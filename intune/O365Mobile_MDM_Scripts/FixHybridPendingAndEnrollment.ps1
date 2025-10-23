#Script is intended to be ran to resolve hybrid-joined devices stuck at pending that had a previous MDM enrollment

dsregcmd /leave
start-sleep 3

schtasks.exe /run /tn "Microsoft\Windows\Workplace Join\Automatic-Device-Join"

#Grab enrollment IDs
$taskpath = "C:\windows\system32\tasks\Microsoft\Windows\EnterpriseMgmt"
$EnrollmentGUIDs = Get-ChildItem $taskpath | Where-Object { $_.Name -match '^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$' } | Select-Object -ExpandProperty Name

#Loop through each enrollment ID, identify scheduled tasks, and remove. 
ForEach ($EnrollmentGUID in $EnrollmentGUIDs) {
Try {
$tasks = Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\$EnrollmentGUID\*" | Select-Object -ExpandProperty "TaskName"
ForEach ($task in $tasks) {
Unregister-ScheduledTask -TaskName $task -Confirm:$false
}
Remove-Item -path "$taskpath\$enrollmentguid" -Force -Erroraction Continue

#Delete the folder in task scheduler
$scheduleObject = New-Object -ComObject Schedule.Service
$scheduleObject.connect()
$folder = $scheduleObject.GetFolder("\Microsoft\Windows\EnterpriseMgmt")
$folder.DeleteFolder($EnrollmentGUID, 0)

if (Test-Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollmentGUID) {
Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollmentGUID -Force -Recurse -ErrorAction Continue
}
}
Catch {
Write-Host $_
}}

start-Sleep 3
gpupdate /force

#If Entra-Joined: Comment out lines 3, 4, 6, and 36. Uncomment what is below this line. 
<#
# Set MDM Enrollment URL's
$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'
$keyinfo = Get-Item "HKLM:\$key"
$url = $keyinfo.name
$url = $url.Split("\")[-1]
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"
New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path  -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;

# Trigger AutoEnroll
C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
#>