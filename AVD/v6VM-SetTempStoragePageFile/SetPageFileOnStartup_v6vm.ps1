$LogLocation = "C:\Temp\Logs"
$logdatestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = "$LogLocation\PageFileTask-$logdatestamp.log"

if (-not (Test-Path $LogLocation)) {
        New-Item -Path $LogLocation -ItemType Directory -Force | Out-Null
}
function Write-Log {
    param([string]$Message)
    $line = "{0} {1}" -f (Get-Date -Format s), $Message
    Add-Content -Path $LogFile -Value $line
    Write-Host $line
}

Write-Log "==== Script Starting... ===="

#Only hold 3 weeks worth of logs
Get-ChildItem -Path $LogLocation -Filter 'PageFileTask-*.log' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-21) } | Remove-Item -Force -ErrorAction SilentlyContinue

#Boot loop guard: detects last 5 reboots and stops script if 4 or more reboots have been detected in the last 12 minutes ---
$bootEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Id=6005} -MaxEvents 5 | Select-Object -ExpandProperty TimeCreated
$recentBoots = $bootEvents | Where-Object { $_ -gt (Get-Date).AddMinutes(-12) }
Write-Log "Running boot loop protection. Found $($recentBoots.Count) restarts in the past 12 minutes. Continuing..."

if ($recentBoots.Count -ge 4) {
    Write-Log "Detected at least $($recentBoots.Count) restarts in the past 12 minutes. Skipping this run to prevent boot loop."
    
    #Logging to EventViewer
    $source = "PageFileScript"
    $logName = "Application"
    if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
    New-EventLog -LogName $logName -Source $source
}
    Write-EventLog -LogName $logName -Source $source -EventId 9876 -EntryType "Warning" -Message "Boot loop protection triggered. Detected $($recentBoots.Count) restarts in the past 10 minutes. Page File script skipped."
    exit
}
#End boot loop guard

#Exit if pagefile is found on D
$usedpagefiles = Get-CimInstance Win32_PageFileUsage |
  ForEach-Object {
    ($_.Name -replace '^(\\\\\?\\\?\\|\\\?\\\?)','')
  }

if ($usedpagefiles -match '^D:\\pagefile\.sys$') {
    Write-Log "Pagefile is correctly set to D: exiting script"
    Write-Log "=== Script Ended ==="
    exit

}
else {
    Write-Log "Pagefile is not set to D. Continuing script."
}

#Exit if there is already a D volume
if (Get-Volume -DriveLetter D -ErrorAction SilentlyContinue) {
    Write-Log "D: drive already exists. Exiting script."
    Write-Log "=== Script Ended ==="
    exit
}

#Identify Temp Storage Volume with name based on v6 VM
$TempStorage = Get-Disk | Where-Object {$_.PartitionStyle -eq 'RAW' -and $_.OperationalStatus -eq 'Online' -and $_.FriendlyName -eq 'Microsoft NVMe Direct Disk v2'}

#Falls back to alternate method if name ever changes
if (!$TempStorage) {
    $osDiskNumber = (Get-Partition -DriveLetter C | Get-Disk).Number
    $TempStorage = Get-Disk | Where-Object {
        $_.PartitionStyle -eq 'RAW' -and $_.OperationalStatus -eq 'Online' -and $_.Number -ne $osDiskNumber
    }
    Write-Log "Temporary storage identified with fallback method. Friendly name of $TempStorage.FriendlyName"
}

#Stop Script if Temp Storage can't be identified
if (!$tempstorage) {
    Write-Log "Temp storage could not be identified. Exiting."
    Write-Log "=== Script Ended ==="
    exit
}
else {
    Write-Log "RAW Temporary storage found. Continuing script."
}

#Initialize the Disk, Format, and Name Partition
try {
    Write-Log "Initializing disk $($TempStorage.FriendlyName)..."
    Initialize-Disk -Number $TempStorage.Number -PartitionStyle GPT -ErrorAction Stop

    Write-Log "Creating partition and assigning drive letter D on disk $($TempStorage.FriendlyName)..."
    $partition = New-Partition -DiskNumber $TempStorage.Number -UseMaximumSize -DriveLetter D -ErrorAction Stop

    Write-Log "Formatting partition D: as NTFS..."
    Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel 'Temporary Storage' -Confirm:$false -ErrorAction Stop

    Write-Log "Disk initialization, partition, and format completed successfully."
}
catch {
    Write-Log "ERROR in disk initialization, partitioning, or formatting: $($_.Exception.Message)"
    Write-Log "=== Script Ended ==="
    exit 1
}

#set reg values
$regsettings = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
$pagefiles = (Get-ItemProperty -Path $regsettings -Name PagingFiles -ErrorAction SilentlyContinue).PagingFiles
$pagefilesarray = @()
$pagefilesarray = @($pagefiles)

if ($pagefilesarray -match '^D:\\pagefile\.sys\s+0\s+0$') {
    Try {
        New-ItemProperty -Path $regsettings -Name 'TempPageFile' -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path $regsettings -Name 'ExistingPageFiles' -PropertyType MultiString -Value @('D:\pagefile.sys') -Force
        Write-Log "Reg settings are set to use D drive as page file. Setting temp/existing page file values."
    }
    Catch {
        Write-Log "Error updating TempPageFile or ExistingPageFiles registry value: $($_.Exception.Message)"
        Write-Log "=== Script Ended ==="
        exit 
    }
    }
else {
    Try {
    New-ItemProperty -Path $regsettings -Name 'AutomaticManagedPagefile' -PropertyType DWord -Value 0 -Force
    New-ItemProperty -Path $regsettings -Name 'PagingFiles' -PropertyType MultiString -Value @('D:\pagefile.sys 0 0') -Force
    New-ItemProperty -Path $regsettings -Name 'ExistingPageFiles' -PropertyType MultiString -Value @('D:\pagefile.sys') -Force
    New-ItemProperty -Path $regsettings -Name 'TempPageFile' -PropertyType DWord -Value 0 -Force | Out-Null
    Write-Log "Reg settings are not configured to use D drive as page file. Updating Reg values."
}
Catch {
    Write-Log "Error updating a registry value for AUtomaticManagedPagefile, PagingFiles, ExistingPageFiles, or TempPageFile: $($_.Exception.Message)"
    Write-Log "=== Script Ended ==="
    exit 
}
}

#final checks before reboot
$usedpagefiles = Get-CimInstance Win32_PageFileUsage 
if ($usedpagefiles -match '^D:\\pagefile\.sys$') {
    Write-Log "Pagefile is correctly in use on D No reboot needed."
    Write-Log "=== Script Ended ==="
    exit
}
else {
    #verify that reg values for Page file are correct prior to reboot
    $regpagefiles = (Get-ItemProperty -Path $regsettings -Name PagingFiles -ErrorAction SilentlyContinue).PagingFiles
    $regpagefilesArray = @($regpagefiles)
    $pagefileD = $regpagefilesArray -match '^D:\\pagefile\.sys\s+0\s+0$'
    if ($pagefileD) {
        Write-Log "Registry confirmed set to D:\pagefile.sys 0 0. Rebooting so D pagefile is picked up."
        Restart-Computer -Force
    }
    else {
        Write-Log "Registry check failed: PagingFiles is not set to D:\pagefile.sys 0 0. Skipping reboot."
        Write-Log "=== Script Ended ==="
        exit
    }
}