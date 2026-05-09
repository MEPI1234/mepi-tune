param([string]$Action = "apply")
# disable-cstates.ps1
function Apply-Tweak {
    try {
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 1 2>$null
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCIDLEFLAGS 0 2>$null
        powercfg /apply 2>$null
        return @{ Success = $true; Message = "C-States disabled for current power scheme. Reboot recommended." }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 0 2>$null
        powercfg /apply 2>$null
        return @{ Success = $true; Message = "C-States restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
