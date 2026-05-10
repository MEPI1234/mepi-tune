param([string]$Action = "apply")

function Apply-Tweak {
    try {
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "SysMain/Superfetch/Prefetch disabled" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "SysMain" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 3 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "SysMain/Superfetch restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
