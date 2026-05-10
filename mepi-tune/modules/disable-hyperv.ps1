param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Disable via bcdedit (works on all Windows editions)
        $bcd = bcdedit /set hypervisorlaunchtype off 2>&1
        
        # Stop and disable Hyper-V related services (silently skip if not present)
        $services = @("vmms","HvHost","vmickvpexchange","vmicguestinterface","vmicshutdown","vmicheartbeat","vmicvmsession","vmicrdv","vmictimesync")
        foreach ($svc in $services) {
            $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($s -ne $null) {
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }

        # Try to disable the Windows feature (Pro/Enterprise only - skip silently on Home)
        $feature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -ErrorAction SilentlyContinue
        if ($feature -ne $null -and $feature.State -eq "Enabled") {
            Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -ErrorAction SilentlyContinue | Out-Null
        }

        return @{ Success = $true; Message = "Hyper-V disabled via bcdedit. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        bcdedit /set hypervisorlaunchtype auto 2>&1 | Out-Null

        $services = @("vmms","HvHost","vmickvpexchange","vmicguestinterface")
        foreach ($svc in $services) {
            $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($s -ne $null) {
                Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
            }
        }

        return @{ Success = $true; Message = "Hyper-V re-enabled. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
