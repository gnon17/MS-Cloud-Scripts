$msi = "GVCInstall64.msi"
$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\GVCInstallLog.log"
$arguments = "/i `"$msi`" /QN /l*v `"$logpath`""

# Install GVC
Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
start-sleep 10

#copy config
copy-item .\default.rcf -Destination "c:\program files\SonicWall\Global VPN Client\" -Force

#set modify permissions on default.rcf file
icacls "C:\Program Files\SonicWall\Global VPN Client\default.rcf" /grant BUILTIN\Users:M
