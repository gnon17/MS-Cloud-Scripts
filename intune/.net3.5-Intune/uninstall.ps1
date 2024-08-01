Import-Module DISM
Disable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart