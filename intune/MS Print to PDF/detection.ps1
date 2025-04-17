$driver = Get-PrinterDriver -name "Microsoft Print to PDF" -ErrorAction Continue
$printer = Get-Printer -name "Microsoft Print to PDF" -ErrorAction Continue

If ($driver -and $printer) {
    Write-Output "Printer is detected"
    Exit 0
}
else {
    Write-Output "Printer is not installed or Driver is missing."
    Exit 1
}
