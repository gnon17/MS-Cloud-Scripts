$localadmins = Get-LocalGroupMember -Group "Administrators" | Where Name -ne "$env:computername\administrator" | Select-Object -ExpandProperty Name
ForEach ($localadmin in $localadmins) {
Try {
Remove-LocalGroupMember -Group "Administrators" -Member $localadmin -ErrorAction Continue
}
Catch {
	Write-Host -ForegroundColor Red "While removing local admin account"
	Write-Host -ForegroundColor Red $_
}
}