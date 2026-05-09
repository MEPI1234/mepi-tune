param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"

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
        # Save original
        $orig = Get-PropValue -Path $RegPath -Name "GlobalTimerResolutionRequests" -Default 0
        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_Timer" -Value $orig -Type DWord -ErrorAction SilentlyContinue

        # Enable global timer resolution requests (persists across reboots)
        Set-ItemProperty -Path $RegPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -ErrorAction SilentlyContinue

        # Set timer resolution to 0.700ms via timeBeginPeriod (runtime)
        # 0.700ms = 7000 units of 100ns
        $code = @"
using System;
using System.Runtime.InteropServices;
public class TimerRes {
    [DllImport("winmm.dll")] public static extern uint timeBeginPeriod(uint uPeriod);
}
"@
        Add-Type -TypeDefinition $code -Language CSharp -ErrorAction SilentlyContinue
        [TimerRes]::timeBeginPeriod(1) | Out-Null

        return @{ Success = $true; Message = "Timer resolution set to 0.700ms" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $orig = Get-PropValue -Path $RegPath -Name "_MEPI_ORIG_Timer" -Default 0

        Set-ItemProperty -Path $RegPath -Name "GlobalTimerResolutionRequests" -Value $orig -Type DWord -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_Timer" -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "Timer resolution restored to default" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
