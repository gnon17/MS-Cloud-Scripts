$x64 = get-package -name 'Microsoft Visual C++ 2015-2022 Redistributable (x64)*' -erroraction continue
$x86 = get-package -name 'Microsoft Visual C++ 2015-2022 Redistributable (x86)*' -erroraction continue
If ($x64 -and $x86) {
Write-Output "Both packages detected"
Exit 0
}
Else {
Write-Output "One or both packages not detected"
Exit 1
}