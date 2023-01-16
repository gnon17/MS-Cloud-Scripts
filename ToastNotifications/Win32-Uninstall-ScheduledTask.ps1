remove-item C:\programdata\toast\TriggerToast-DownloadsFolder.ps1 -force
unregister-scheduledtask -taskname Toast-DownloadsFolder -confirm:$false