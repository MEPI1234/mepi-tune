param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"

function Apply-Tweak {
    try {
        $orig = (Get-ItemProperty -Path $RegPath -Name "Win32PrioritySeparation").Win32PrioritySeparation
        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_Win32PrioritySeparation" -Value $orig -Type DWord
        Set-ItemProperty -Path $RegPath -Name "Win32PrioritySeparation" -Value 18 -Type DWord
        return @{ Success = $true; Message = "Win32PrioritySeparation set to 18 (was $orig)" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $orig = (Get-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_Win32PrioritySeparation")._MEPI_ORIG_Win32PrioritySeparation
        Set-ItemProperty -Path $RegPath -Name "Win32PrioritySeparation" -Value $orig -Type DWord
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_Win32PrioritySeparation" -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Win32PrioritySeparation restored to $orig" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
