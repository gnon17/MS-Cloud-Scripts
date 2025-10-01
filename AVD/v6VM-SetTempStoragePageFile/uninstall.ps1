Unregister-ScheduledTask -TaskName "Set Page File on Startup" -Confirm:$false
Remove-Item -Path "C:\mem\SetPageFileOnStartup_v6vm.ps1" -Force