$destinationpath = "$env:APPDATA\Microsoft\Office"
$destexists = test-path $destinationpath
If (!$desexists) {
New-Item -Path $destinationpath -ItemType Directory -Force
}
Copy-Item .\MSO1033.acl -Destination $destinationpath -Force
#Check for copied file
$aclexists = Test-Path "$destinationpath\MSO1033.acl" 
If ($aclexists) {
New-Item -Path "$env:APPDATA\Microsoft\Office\AutoComplete040425.txt" -ItemType File -Force
}
else {
Write-Output "ACL file copy failed"
}