param([string]$Action = "apply")

function Apply-Tweak {
    try {
        bcdedit /deletevalue useplatformclock 2>$null
        bcdedit /set useplatformclock false 2>$null
        bcdedit /set disabledynamictick yes 2>$null
        bcdedit /set tscsyncpolicy enhanced 2>$null

        # Disable HPET device in Device Manager
        Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision Event Timer*" } |
            Disable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "HPET disabled. TSC timer active. Reboot recommended." }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        bcdedit /set useplatformclock true 2>$null
        bcdedit /deletevalue disabledynamictick 2>$null
        Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High Precision Event Timer*" } |
            Enable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "HPET re-enabled. Reboot recommended." }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
