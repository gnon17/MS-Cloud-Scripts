###VHDX/VHD Repair Script###
#Will mount and repair all VHDX files in a directory (including subdirectories)
#Log of output located at c:\temp\diskrepair.log

param(
[Parameter(mandatory = $true)]
[string]
#The path where your VHDX files are located. This can be a top level share, such as \\storageacct.file.core.windows.net\fslogix
$vhdxdirectory
)

#Setting Log Directory and starting transcript
Write-Host -ForegroundColor DarkYellow "Checking if C:\temp exists for transcript log"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}
Start-Transcript -Path $LogPath\DiskRepair.log -Force

#Get paths of all VHDX files in specified directory
$vhdxs = Get-Childitem $vhdxdirectory -recurse -include *.vhdx

#Mount and Repair VHDX files
Foreach ($vhdx in $vhdxs) {
Write-Host -ForegroundColor DarkYellow "Mounting"$vhdx.name"and identifying drive label"

Try {
#$DriveLetter = ((Mount-VHD -Path $vhdx.fullname -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter | Out-String).trim()
$Drive = (Mount-VHD -Path $vhdx.fullname -PassThru | Get-Disk | Get-Partition | Get-Volume)
$DriveFSLabel = $Drive.Filesystemlabel
$DriveLetter = ($Drive.DriveLetter | Out-String).Trim()

}
Catch {
Write-Host -ForegroundColor Red $_
}

Write-Host -ForegroundColor DarkYellow "Drive Label for"$vhdx.name"is $driveFSLabel"
Write-Host -ForegroundColor DarkYellow "Drive Label for"$vhdx.name"is $driveletter"
Write-Host -ForegroundColor DarkYellow "Scanning and repairing"$vhdx.name""

Try {
Repair-Volume -FileSystemLabel $DriveFSLabel -OfflineScanAndFix -Verbose
Write-Host -ForegroundColor DarkYellow "Scan and repair finished. Detaching"$vhdx.name""
Dismount-DiskImage -ImagePath $vhdx.fullname
}
catch {
    Write-Host -ForegroundColor Red $_
    Try {
    Write-Host -ForegroundColor Magenta "An error occured. Attempting to mount and scan drive by drive letter"
    Repair-Volume -DriveLetter $DriveLetter -OfflineScanAndFix -Verbose
    Dismount-DiskImage -ImagePath $vhdx.fullname
    }
        Catch {
        Write-Host -ForegroundColor Red $_
        Write-Host -ForegroundColor Magenta "Another error occured. Unable to scan and repair"$vhdx.name"moving on to next file"
        }
    }
    }

Stop-Transcript