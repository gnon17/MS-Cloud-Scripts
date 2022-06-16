$printdriver = "Xerox Global Print Driver PS"
C:\Windows\system32\pnputil.exe /add-driver ".\Global-PS\UNIV_5.860.1.0_PS_x64_Driver.inf\x3UNIVP.inf" /install
Add-PrinterDriver -name $printdriver