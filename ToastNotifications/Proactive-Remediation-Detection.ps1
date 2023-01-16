$DownloadsFiles = get-childitem -Path $env:USERPROFILE\Downloads -File -Recurse | Where-Object {$_.Length -gt 1MB} | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-1)}
If ($DownloadsFiles.count -eq 0) {
    Write-Output "No large 30 day old files found in Downloads folder"
    exit 0
}
else {
    Write-Output "Large 30+ old files in user downloads folder - sending toast notification"
    exit 1
}