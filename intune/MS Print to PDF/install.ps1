$driver = Get-PrinterDriver -name "Microsoft Print to PDF" -ErrorAction Continue
If (!$driver) {
    Try {
    move-item -path ".\prnms009.inf_amd64_3107874c7db0aa5a" -Destination "c:\windows\system32\driverstore\filerepository"
    pnputil /add-driver "c:\windows\system32\driverstore\filerepository\.\prnms009.inf_amd64_3107874c7db0aa5a\prnms009.inf" /install
}
Catch {
    Write-Host $_
}
}

Try { 
# Try Reinstalling/Installing Feature
Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -ErrorAction SilentlyContinue
Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -All -ErrorAction SilentlyContinue

$printer = Get-Printer -name "Microsoft Print to PDF" -ErrorAction Continue

If (!$printer) {
            #manually connect printer if feature install still failed
            Add-Printer -Name "Microsoft Print to PDF" -DriverName "Microsoft Print To PDF" -PortName "PORTPROMPT:"
        }
}
Catch {
    Write-Host $_
}
