param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"

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
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }

        $orig = Get-PropValue -Path $RegPath -Name "PowerThrottlingOff" -Default 0

        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG" -Value $orig -Type DWord
        Set-ItemProperty -Path $RegPath -Name "PowerThrottlingOff" -Value 1 -Type DWord

        return @{ Success = $true; Message = "Power throttling disabled" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $orig = Get-PropValue -Path $RegPath -Name "_MEPI_ORIG" -Default 0

        Set-ItemProperty -Path $RegPath -Name "PowerThrottlingOff" -Value $orig -Type DWord
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG" -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "Power throttling restored" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
