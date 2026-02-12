Try {
$Db = "$env:ProgramData\Microsoft\Windows\CapabilityAccessManager\CapabilityConsentStorage.db"

# Get interactive user SID
$cs = Get-CimInstance Win32_ComputerSystem
if ([string]::IsNullOrWhiteSpace($cs.UserName)) { throw "No interactive user logged on." }

$Sid = (New-Object System.Security.Principal.NTAccount($cs.UserName)).
  Translate([System.Security.Principal.SecurityIdentifier]).Value

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class LiteQ {
  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_open_v2(string filename, out IntPtr db, int flags, string vfs);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_prepare_v2(IntPtr db, string sql, int nByte, out IntPtr stmt, IntPtr tail);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_step(IntPtr stmt);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern IntPtr sqlite3_column_text(IntPtr stmt, int iCol);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_finalize(IntPtr stmt);

  [DllImport("winsqlite3.dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int sqlite3_close(IntPtr db);

  static string PtrToStringUtf8(IntPtr p) {
    if (p == IntPtr.Zero) return null;
    return Marshal.PtrToStringAnsi(p);
  }

  public static string Scalar(string dbPath, string sql) {
    const int SQLITE_OK = 0;
    const int SQLITE_ROW = 100;

    IntPtr db;
    int rc = sqlite3_open_v2(dbPath, out db, 1, null); // 1 = READONLY
    if (rc != SQLITE_OK) throw new Exception("sqlite3_open_v2 failed: " + rc);

    IntPtr stmt;
    rc = sqlite3_prepare_v2(db, sql, -1, out stmt, IntPtr.Zero);
    if (rc != SQLITE_OK) { sqlite3_close(db); throw new Exception("sqlite3_prepare_v2 failed: " + rc); }

    string result = null;
    rc = sqlite3_step(stmt);
    if (rc == SQLITE_ROW) {
      result = PtrToStringUtf8(sqlite3_column_text(stmt, 0));
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return result;
  }
}
"@ -ErrorAction Stop

$sql = "SELECT Value FROM UserGlobal WHERE Capability='location' AND User='$Sid' LIMIT 1;"

$value = [LiteQ]::Scalar($Db, $sql)
Write-Host "Logged in SID: $Sid"
Write-Host "Location UserGlobal Value: $value"

If ($value -eq "1") {
    Write-Output "Enabled"
    Exit 0
}
else {
    Write-Output "Location database value note set to 1. Running Remediation"
    Exit 1
}
}
Catch {
    Write-Output "Error running script $($_.Exception.Message)"
    Exit 1
}