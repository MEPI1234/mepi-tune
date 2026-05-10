param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

function Get-PropValue {
    param([string]$Path, [string]$Name, $Default)
    $prop = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($prop -ne $null) {
        return $prop.$Name
    }
    return $Default
}

function Apply-Tweak {
    try {
        $orig = Get-PropValue -Path $RegPath -Name "FeatureSettingsOverride" -Default 0

        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_FSO" -Value $orig -Type DWord
        Set-ItemProperty -Path $RegPath -Name "FeatureSettingsOverride"     -Value 3 -Type DWord
        Set-ItemProperty -Path $RegPath -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord

        return @{ Success = $true; Message = "WARNING: Spectre/Meltdown mitigations disabled. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        Remove-ItemProperty -Path $RegPath -Name "FeatureSettingsOverride"     -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "FeatureSettingsOverrideMask" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_FSO"              -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "Spectre/Meltdown mitigations re-enabled. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
