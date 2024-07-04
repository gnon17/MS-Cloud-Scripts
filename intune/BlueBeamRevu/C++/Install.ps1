Try {
Start-Process .\vc_redist.x86.exe -ArgumentList "/install /q /norestart" -NoNewWindow -Wait -PassThru -Verbose
}
Catch {
Write-Host $_
}
Try {
Start-Process .\vc_redist.x64.exe -ArgumentList "/install /q /norestart" -NoNewWindow -Wait -PassThru -Verbose
}
Catch {
Write-Host $_
}