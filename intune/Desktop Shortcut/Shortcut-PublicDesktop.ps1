#GPN - 4.25.2022
#Creates shortcut on the public desktop for all users and specifies which browser to open the shortcut. Also sets custom icon file if desired. 
#Create an icon file with convertto-icon.ps1 or https://convertio.co/jpg-ico/
#If you do not want to specify a browser to open the shortcut, and you want it to open in the default browser, do not specify a target path to a browser. Make the target path the URL you want to use, and comment out or delete the $Shortcut.Arguments line. 

#Create directory to hold icon file and copy file there
New-Item -Path "c:\" -Name "mem" -ItemType "directory" -Force
Copy-Item ".\O365.ico" -Destination "c:\mem\O365.ico" 

#Shortcut creation and specify settings
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("C:\users\public\desktop\Office365.lnk")
$ShortCut.TargetPath="C:\Program Files\Google\Chrome\Application\chrome.exe"
$Shortcut.Arguments="https://portal.office.com"
$ShortCut.IconLocation = "C:\mem\O365.ico";
$ShortCut.Description = "O365 Shortcut";
$ShortCut.Save()