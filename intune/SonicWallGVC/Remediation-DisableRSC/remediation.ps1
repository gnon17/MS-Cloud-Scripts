$wifinetadapters = Get-NetAdapter | Where-Object InterfaceDescription -Match "Wi-Fi" | Select-Object -ExpandProperty "Name"
ForEach ($wifinetadapter in $wifinetadapters) {
Try {
    Disable-NetAdapterRsc -Name $wifinetadapter
}
Catch {
    Write-Host "An error occurred:"
    Write-Host $_
}
}