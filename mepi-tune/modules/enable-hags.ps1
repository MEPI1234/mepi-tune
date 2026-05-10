param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"

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
        $orig = Get-PropValue -Path $RegPath -Name "HwSchMode" -Default 1

        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_HAGS" -Value $orig -Type DWord
        Set-ItemProperty -Path $RegPath -Name "HwSchMode"       -Value 2    -Type DWord

        return @{ Success = $true; Message = "Hardware Accelerated GPU Scheduling enabled. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $orig = Get-PropValue -Path $RegPath -Name "_MEPI_ORIG_HAGS" -Default 1

        Set-ItemProperty -Path $RegPath -Name "HwSchMode" -Value $orig -Type DWord
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_HAGS" -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "HAGS disabled. Reboot required." }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
