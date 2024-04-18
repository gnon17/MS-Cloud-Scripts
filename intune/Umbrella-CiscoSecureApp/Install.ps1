Try {
Start-Process 'msiexec.exe' -ArgumentList '/package cisco-secure-client-win-5.1.2.42-core-vpn-predeploy-k9.msi /norestart /passive PRE_DEPLOY_DISABLE_VPN=1' -Wait
}
Catch {
    Write-Host "An error occured:"
    Write-Host $_
}
Try {
    Start-Process 'msiexec.exe' -ArgumentList '/package cisco-secure-client-win-5.1.2.42-umbrella-predeploy-k9.msi /norestart /passive' -Wait
    }
    Catch {
    Write-Host "An error occured:"
    Write-Host $_
}
Try {
    Start-Process 'msiexec.exe' -ArgumentList '/package cisco-secure-client-win-5.1.2.42-dart-predeploy-k9.msi /norestart /passive' -Wait
    }
    Catch {
    Write-Host "An error occured:"
    Write-Host $_
}
$Service = 'csc_umbrellaagent'
$Directory = Test-Path "$env:ProgramData\Cisco\Cisco Secure Client\Umbrella"
If ($directory -eq $True) {
Try {
Copy-Item -Path .\OrgInfo.json -Destination "$env:ProgramData\Cisco\Cisco Secure Client\Umbrella" -Force
Restart-Service -Name $service -Verbose
}
catch {
    Write-Host $_   
}
}
Else {
    Write-Output "Destination directory does not exist"
}