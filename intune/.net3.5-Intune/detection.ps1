$Enabled = Get-WindowsOptionalFeature -online | Where FeatureName -eq 'NetFx3' | Select -expandproperty State
If ($enabled -eq "enabled") {
Write-Output ".net 3.5 is enabled"
Exit 0
}
Else {
Write-Output ".net 3.5 is not enabled"
Exit 1
}