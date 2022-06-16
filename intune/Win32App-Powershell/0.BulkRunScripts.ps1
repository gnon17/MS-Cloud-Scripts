$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"

Connect-MSIntuneGraph -TenantID $TenantID

Get-ChildItem '.\scripts' | ForEach-Object {
& $_.FullName
Start-Sleep -Seconds 1
} -Verbose

Remove-Item -Path '.\scripts\apps' -Recurse -Force
