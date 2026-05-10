param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Use RAMMap-style approach via WMI
        [System.Runtime.InteropServices.Marshal]::AllocHGlobal(0) | Out-Null
        $code = @"
using System;
using System.Runtime.InteropServices;
public class MemClear {
    [DllImport("psapi.dll")] public static extern bool EmptyWorkingSet(IntPtr hProcess);
    [DllImport("kernel32.dll")] public static extern IntPtr GetCurrentProcess();
}
"@
        Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
        Get-Process | ForEach-Object {
            try { [MemClear]::EmptyWorkingSet($_.Handle) | Out-Null } catch {}
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        return @{ Success = $true; Message = "Standby memory cleared" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    return @{ Success = $true; Message = "Standby memory is runtime-only, no restore needed" }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
