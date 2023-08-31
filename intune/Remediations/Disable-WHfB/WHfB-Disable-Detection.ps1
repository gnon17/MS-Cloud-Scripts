$ngc = get-childitem C:\windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc -ErrorAction SilentlyContinue
if ($ngc -ne $null) {
    Write-output "WHfB PIN configured"
    exit 1
}
else {
    write-output "WHfB PIN not configured"
    exit 0
}