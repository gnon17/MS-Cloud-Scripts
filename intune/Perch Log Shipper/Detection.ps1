$Perch = get-service -name "perch-winlogbeat"
If ($Perch) {
Write-Output "Perch service detected"
Exit 0
}
Else {
Write-Output "Perch Service not detected"
exit 1
}
