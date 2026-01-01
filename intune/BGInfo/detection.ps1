$bgifile = "hostname.bgi"
$bginfo = Test-Path -Path "$env:programdata\bginfo\Bginfo64.exe"
$bgi = Test-Path -Path "$env:programdata\bginfo\$bgifile"
$task = Get-Scheduledtask -taskname "BGInfo-Logon"

If ($bginfo -and $bgi -and $task) {
    Write-Output "found everything"
    exit 0
}
else {
    write-output "something is missing"
    exit 1
}