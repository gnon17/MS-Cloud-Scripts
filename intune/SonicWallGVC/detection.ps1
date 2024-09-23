$wifinetadapters = Get-NetAdapterRsc | Where-Object Name -Match "Wi-Fi" | Select-Object -ExpandProperty "IPv4Enabled" | Out-String
If ($wifinetadapters -match "True") {
    Write-Output "RSC is enabled on at least one WiFi Adapter"
    Exit 1
}
Else {
    Write-Output "RSC is disabled on all wifi adapters"
    exit 0
}