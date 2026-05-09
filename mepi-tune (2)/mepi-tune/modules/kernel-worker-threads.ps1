param([string]$Action = "apply")

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive"

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
        $origCrit  = Get-PropValue -Path $RegPath -Name "AdditionalCriticalWorkerThreads"  -Default 0
        $origDelay = Get-PropValue -Path $RegPath -Name "AdditionalDelayedWorkerThreads"   -Default 0
        $cores     = (Get-WmiObject Win32_Processor).NumberOfLogicalProcessors

        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_CritWorker"  -Value $origCrit  -Type DWord
        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_DelayWorker" -Value $origDelay -Type DWord
        Set-ItemProperty -Path $RegPath -Name "AdditionalCriticalWorkerThreads" -Value $cores -Type DWord
        Set-ItemProperty -Path $RegPath -Name "AdditionalDelayedWorkerThreads"  -Value $cores -Type DWord

        return @{ Success = $true; Message = "Kernel worker threads set to $cores (logical cores)" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $origCrit  = Get-PropValue -Path $RegPath -Name "_MEPI_ORIG_CritWorker"  -Default 0
        $origDelay = Get-PropValue -Path $RegPath -Name "_MEPI_ORIG_DelayWorker" -Default 0

        Set-ItemProperty -Path $RegPath -Name "AdditionalCriticalWorkerThreads" -Value $origCrit  -Type DWord
        Set-ItemProperty -Path $RegPath -Name "AdditionalDelayedWorkerThreads"  -Value $origDelay -Type DWord
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_CritWorker"  -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_DelayWorker" -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "Kernel worker threads restored" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
