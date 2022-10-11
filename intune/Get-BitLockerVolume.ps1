$BitLockerOSVolume = Get-BitLockerVolume -MountPoint $env:SystemRoot
If ((($BitLockerOSVolume.VolumeStatus -eq 'FullyEncrypted') -and ($BitLockerOSVolume.KeyProtector.KeyProtectorType -contains 'Tpm')) -and ($BitLockerOSVolume.ProtectionStatus -eq 'On')) {
    return 0
}