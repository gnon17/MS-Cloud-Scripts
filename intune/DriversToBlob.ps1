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
$sasurl = "YOUR SAS URL"

#Copy File
.\azcopy.exe copy $file $sasurl | Out-Null

CD C:\windows\System32
Remove-Item -Path $CSVPath\azcopy.zip -Force
Remove-Item -Path $CSVPath\azcopy_windows_amd64_10.16.0 -Recurse -Force
Remove-Item -Path $CSVPath\azcopy.exe -Force
