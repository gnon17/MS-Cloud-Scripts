$printdriver = "Xerox Global Print Driver PS"
Remove-PrinterDriver -Name $printdriver
C:\Windows\sysnative\pnputil.exe /delete-driver ".\Global-PS\UNIV_5.860.1.0_PS_x64_Driver.inf\x3UNIVP.inf" /uninstall
