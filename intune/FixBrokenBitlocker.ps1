#Script identifies the state of Bitlocker on the device, and takes appropriate action
#This Script is dependant on Nickolaj Anderson's script located here - https://msendpointmgr.com/2019/10/31/silently-enable-bitlocker-for-hybrid-azure-ad-joined-devices-using-windows-autopilot/
$Loop = $true
$BitlockerStatus = Get-BitLockerVolume -MountPoint C:
If ((($BitlockerStatus.VolumeStatus -eq 'FullyEncrypted') -and ($BitlockerStatus.KeyProtector.KeyProtectorType -contains 'Tpm')) -and ($BitlockerStatus.ProtectionStatus -eq 'On'))
    {
        Write-Host -f Yellow "Drive is encrypted with correct configuration. Uploading recovery key to Azure AD"
        $BLV = Get-BitLockerVolume -MountPoint "C:"
        BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }
If ((($BitlockerStatus.VolumeStatus -eq 'FullyDecrypted') -and ($BitlockerStatus.KeyProtector.KeyProtectorType -notcontains 'TPM')) -and ($BitlockerStatus.ProtectionStatus -eq 'Off'))
    {
        Write-Host -f Yellow "Drive is decrypted. Encrypting and Uploading recovery Key to AzureAD"
        & ".\Enable-Bitlocker.ps1"
    }
If ((($BitlockerStatus.VolumeStatus -eq 'FullyEncrypted') -and ($BitlockerStatus.KeyProtector -notcontains 'Tpm')) -and ($BitlockerStatus.ProtectionStatus -eq 'Off'))
    {
        Write-Host -f Yellow "Drive is Encrypted without protection and no Key Protectors. Disabling Bitlocker and re-encrypting drive with corporate settings. Decryption Key will be uploaded to Azure AD."
        manage-bde -off c:
        while($Loop){
        [int]$encryptionpercentage = Get-BitlockerVolume | Select-Object -expand EncryptionPercentage
        if($encryptionpercentage -ne 0)
        {
        Write-Progress -Activity "Bitlocker Drive Decryption Status" -Status "Decrypting" -PercentComplete $encryptionpercentage
        Start-Sleep -Seconds 5
        }else{
        Write-Progress -Activity "Bitlocker Drive Decryption Status" -Completed
        $Loop = $false
        }
    }
        & ".\Enable-Bitlocker.ps1"
    }
