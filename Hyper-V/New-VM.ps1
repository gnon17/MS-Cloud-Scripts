$VMName = Read-Host 'Name your VM'
New-Item -Path C:\Hyper-V\ -Name "$VMname" -ItemType Directory -Force
Copy-Item -Path "C:\Hyper-V\W10_image\image.vhdx" -Destination "C:\Hyper-V\$VMname\$vmname.vhdx" | Out-Null
New-VM -Name $VMName -Path C:\Hyper-V\$VMName -MemoryStartupBytes 4GB -VHDPath "C:\Hyper-V\$VMname\$vmname.vhdx" -Generation 2 -BootDevice VHD
Set-VM -Name $VMName -ProcessorCount 2
Set-VMMemory $VMName -DynamicMemoryEnabled $false
Set-VM -Name $VMName -CheckpointType Disabled
Connect-VMNetworkAdapter -VMName $VMName -SwitchName External

#TPM
$HGOwner = Get-HgsGuardian UntrustedGuardian
$KeyProtector = New-HgsKeyProtector -Owner $HGOwner -AllowUntrustedRoot
Set-VMKeyProtector -VMName $VMName -KeyProtector $KeyProtector.RawData
Enable-VMTPM $VMName
