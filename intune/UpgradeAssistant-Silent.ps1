#Variable Gathering
$dir = new-item -Path "c:\" -Name "WinUpgrade" -ItemType Directory -Force
$UpdateAssistantURL = "https://go.microsoft.com/fwlink/?LinkID=799445"
$Filename = "WindowsUpdateAssistant.exe"
$file = "$dir\$filename"

#Download Update assistant and Launch. Copy logs to $dir
Invoke-WebRequest -Uri $UpdateAssistantURL -Outfile $dir\$filename | Out-Null
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'
Out-File "$dir\$(Get-Date -f yyyy-MM-dd-HH-mm)Winupdate.log" -Force