Set WshShell = CreateObject("Wscript.Shell")
WshShell.Run chr(34) & "C:\Temp\TeamsBackgroundSync.cmd" & Chr(34), 0, True
Set WshShell = Nothing