#=========================
#Sets Hash Directory and Generates HardwareHash file
#=========================
$CSVPath = new-item -Path "c:\" -Name "hhash" -ItemType Directory -Force
$serialnumber = Get-WmiObject win32_bios | select Serialnumber
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Set-ExecutionPolicy Unrestricted -Force
Get-WindowsAutoPilotInfo -Outputfile $CSVPath\$($serialnumber.SerialNumber)-Hash.csv

#===========================
#Download and Extract AZCopy
#===========================

$downloadsource = 'https://aka.ms/downloadazcopy-v10-windows'
$filename = "azcopy.zip"
Start-BitsTransfer -Source $downloadsource -Destination $CSVPath\$filename | Out-Null
Expand-Archive -LiteralPath $CSVPath\azcopy.zip -DestinationPath $CSVPath -Force
Move-Item -Path $CSVPath\azcopy_windows_amd64_*\azcopy.exe -Destination $CSVPath
CD $CSVPath

#=========================
#Upload to Blob
#=========================

#Hash File:
$file = "$CSVPath\$($serialnumber.SerialNumber)-Hash.csv"

#Storage Account SAS URL
$sasurl = "your blob URL"

#Copy File
.\azcopy.exe copy $file $sasurl | Out-Null

CD C:\windows\System32
Remove-Item -Path $CSVPath -Recurse -Force
