#=========================
#Sets Hash Directory and Generates HardwareHash file
#=========================
$CSVPath = new-item -Path "c:\" -Name "temp" -ItemType Directory -Force
$serialnumber = Get-WmiObject win32_bios | select Serialnumber
Get-WindowsDriver -Online | Export-CSV $CSVPath\$($serialnumber.SerialNumber)-Drivers.csv -Force

#===========================
#Download and Extract AZCopy
#===========================

$downloadsource = 'https://aka.ms/downloadazcopy-v10-windows'
$filename = "azcopy.zip"
Start-BitsTransfer -Source $downloadsource -Destination $CSVPath\$filename | Out-Null
Expand-Archive -LiteralPath $CSVPath\azcopy.zip -DestinationPath $CSVPath -Force
Move-Item -Path $CSVPath\azcopy_windows_amd64_10.16.0\azcopy.exe -Destination $CSVPath
CD $CSVPath

#=========================
#Upload to Blob
#=========================

#Hash File:
$file = "$CSVPath\$($serialnumber.SerialNumber)-Drivers.csv"

#Storage Account SAS URL
$sasurl = "https://ganlabsa1.blob.core.windows.net/workstationdrivers?sp=rwl&st=2022-08-09T11:53:12Z&se=2022-08-13T19:53:12Z&spr=https&sv=2021-06-08&sr=c&sig=IQ%2FV70YpEZgL59PkZmR8T0fKdTyb0cddy22aWOaFXBQ%3D"

#Copy File
.\azcopy.exe copy $file $sasurl | Out-Null

CD C:\windows\System32
Remove-Item -Path $CSVPath\azcopy.zip -Force
Remove-Item -Path $CSVPath\azcopy_windows_amd64_10.16.0 -Recurse -Force
Remove-Item -Path $CSVPath\azcopy.exe -Force