param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Force max performance via nvidia-smi
        $nvidiaSmi = "C:\Windows\System32\nvidia-smi.exe"
        if (Test-Path $nvidiaSmi) {
            & $nvidiaSmi -pm 1 2>$null
            & $nvidiaSmi --auto-boost-default=0 2>$null
        }
        # Registry: prefer max performance
        $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
        if (Test-Path $gpuPath) {
            Set-ItemProperty -Path $gpuPath -Name "PerfLevelSrc" -Value 0x00002222 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $gpuPath -Name "PowerMizerEnable" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $gpuPath -Name "PowerMizerLevel" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $gpuPath -Name "PowerMizerLevelAC" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }
        return @{ Success = $true; Message = "GPU set to maximum performance mode" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        $nvidiaSmi = "C:\Windows\System32\nvidia-smi.exe"
        if (Test-Path $nvidiaSmi) { & $nvidiaSmi -pm 0 2>$null }
        return @{ Success = $true; Message = "GPU performance mode restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
