New-Item -Path "HKLM:\Software\Policies\Google\Chrome" -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome" -Name CloudAPAuthEnabled -PropertyType DWORD -Value 1 -Force