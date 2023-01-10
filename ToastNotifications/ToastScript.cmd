powershell.exe -WindowStyle hidden -NonInteractive -NoLogo -NoProfile -Command "& '%1'.Replace('powershell://', '').Trim('/')"
pause