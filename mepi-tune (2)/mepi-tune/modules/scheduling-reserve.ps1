param([string]$Action = "apply")

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

function Apply-Tweak {
    try {
        $orig = (Get-ItemProperty -Path $RegPath -Name "SystemResponsiveness").SystemResponsiveness
        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_SystemResponsiveness" -Value $orig -Type DWord
        Set-ItemProperty -Path $RegPath -Name "SystemResponsiveness" -Value 0 -Type DWord
        return @{ Success = $true; Message = "SystemResponsiveness set to 0 (full CPU for foreground)" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $orig = (Get-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_SystemResponsiveness")._MEPI_ORIG_SystemResponsiveness
        Set-ItemProperty -Path $RegPath -Name "SystemResponsiveness" -Value $orig -Type DWord
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_SystemResponsiveness" -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "SystemResponsiveness restored to $orig" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
