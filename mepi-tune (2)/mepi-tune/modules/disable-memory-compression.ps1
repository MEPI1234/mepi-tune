param([string]$Action = "apply")

function Apply-Tweak {
    try {
        Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Memory compression disabled" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Memory compression restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
