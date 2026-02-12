$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
$value = (Get-ItemProperty -Path $key -Name Value -ErrorAction Stop).Value

    if ($value -eq "Allow") {
       write-output "location services is on"
      exit 0
    }
    else {
      Write-Output "Value set to deny, running remediation"
      exit 1   
    }