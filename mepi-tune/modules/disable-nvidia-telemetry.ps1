param([string]$Action = "apply")

function Apply-Tweak {
    try {
        $nvidiaServices = @(
            "NvTelemetryContainer","NvSvc","NVDisplay.ContainerLocalSystem",
            "NvContainerLocalSystem","NvContainerNetworkService"
        )
        foreach ($svc in $nvidiaServices) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        # Scheduled tasks
        Get-ScheduledTask | Where-Object { $_.TaskName -like "*NvTm*" -or $_.TaskName -like "*Nvidia*Telemetry*" } |
            Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
        # Registry
        New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" -Force -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" -Name "OptInOrOutPreference" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "NVIDIA telemetry disabled" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        $nvidiaServices = @("NvTelemetryContainer","NvSvc")
        foreach ($svc in $nvidiaServices) { Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue }
        return @{ Success = $true; Message = "NVIDIA telemetry restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
