param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Windows Search
        Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue
        # Print Spooler
        Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "Spooler" -StartupType Disabled -ErrorAction SilentlyContinue
        # Delivery Optimization
        Stop-Service -Name "DoSvc" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "DoSvc" -StartupType Disabled -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        # Connected User Experiences
        Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        # Remote Registry
        Stop-Service -Name "RemoteRegistry" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "RemoteRegistry" -StartupType Disabled -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Background services disabled: Search, Print Spooler, Delivery Opt, Remote Registry" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
        Set-Service -Name "Spooler" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
        Set-Service -Name "DoSvc" -StartupType Automatic -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Services restored to defaults" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
