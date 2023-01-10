$DownloadsFiles = get-childitem -Path $env:USERPROFILE\Downloads -File -Recurse | Where-Object {$_.Length -gt 1MB} | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-1)}
$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$XMLString = Get-Content -Path C:\temp\NotificationXML.xml
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$ToastXml.LoadXml($XmlString)
$Toast = [Windows.UI.Notifications.ToastNotification]::new($ToastXml)
If ($DownloadsFiles.count -gt 0) {
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($Toast)    
    }
