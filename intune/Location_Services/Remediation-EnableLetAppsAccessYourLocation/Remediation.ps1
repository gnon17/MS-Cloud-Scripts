$Capability    = "location"
$DesiredValue  = 1   # 1=ON, 2=OFF
$DbDir         = Join-Path $env:ProgramData "Microsoft\Windows\CapabilityAccessManager"
$Db            = Join-Path $DbDir "CapabilityConsentStorage.db"

if (!(Test-Path $Db)) { throw "DB not found: $Db" }

function Get-InteractiveUserSid {
    # Get the user currently logged into the physical/console session
    $cs = Get-CimInstance Win32_ComputerSystem
    $u  = $cs.UserName
    if ([string]::IsNullOrWhiteSpace($u)) { return $null }   # no one logged on

    $acct = New-Object System.Security.Principal.NTAccount($u)
    return ($acct.Translate([System.Security.Principal.SecurityIdentifier])).Value
}

$TargetSid = Get-InteractiveUserSid
if (-not $TargetSid) {
    Write-Host "No interactive user detected. Exiting."
    exit 0
}

Write-Host "Target SID: $TargetSid"
Stop-Service camsvc -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

<#
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $DbDir "Backup-$stamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
foreach ($f in @("CapabilityConsentStorage.db","CapabilityConsentStorage.db-wal","CapabilityConsentStorage.db-shm")) {
    $p = Join-Path $DbDir $f
    if (Test-Path $p) { Copy-Item $p -Destination (Join-Path $backupDir $f) -Force }
}
#>

# Minimal sqlite exec (winsqlite3.dll)
$src = @"
using System;
using System.Runtime.InteropServices;
public static class WinSqliteRW
{
  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_open_v2(string filename, out IntPtr db, int flags, string vfs);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_close(IntPtr db);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_exec(IntPtr db, string sql, IntPtr callback, IntPtr arg, out IntPtr errMsg);

  static string PtrToStringUtf8(IntPtr p)
  {
    if (p == IntPtr.Zero) return "";
    return Marshal.PtrToStringAnsi(p);
  }

  public static void Exec(string dbPath, string sql)
  {
    const int SQLITE_OK = 0;

    // READWRITE = 0x00000002
    IntPtr db;
    int rc = sqlite3_open_v2(dbPath, out db, 0x00000002, null);
    if (rc != SQLITE_OK) throw new Exception("sqlite3_open_v2 failed");

    IntPtr err;
    rc = sqlite3_exec(db, sql, IntPtr.Zero, IntPtr.Zero, out err);
    if (rc != SQLITE_OK)
    {
      string e = PtrToStringUtf8(err);
      throw new Exception("sqlite3_exec failed: " + e);
    }

    sqlite3_close(db);
  }
}
"@

if (-not ("WinSqliteRW" -as [type])) {
    Add-Type -TypeDefinition $src -Language CSharp -ErrorAction Stop
}

# Update the same row Settings flips: UserGlobal(Capability, User, Value)
$sql = @"
BEGIN;
INSERT OR REPLACE INTO UserGlobal (Capability, User, Value)
VALUES ('$Capability', '$TargetSid', $DesiredValue);
COMMIT;
"@

[WinSqliteRW]::Exec($Db, $sql)

Start-Service camsvc -ErrorAction SilentlyContinue
Write-Host "Set UserGlobal($Capability, $TargetSid) = $DesiredValue"