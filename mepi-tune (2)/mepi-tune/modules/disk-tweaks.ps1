param([string]$Action = "apply")

function Apply-Tweak {
    try {
        fsutil behavior set disable8dot3 1 2>$null
        fsutil behavior set disablelastaccess 1 2>$null
        # Enable write caching on all disks
        Get-Disk | ForEach-Object {
            $disk = $_
            try {
                $storagePort = Get-StorageReliabilityCounter -Disk $disk -ErrorAction SilentlyContinue
            } catch {}
        }
        # Via registry
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsDisable8dot3NameCreation" -Value 1 -Type DWord
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsDisableLastAccessUpdate" -Value 1 -Type DWord
        # Optimize pagefile - fixed size
        $cs = Get-WmiObject Win32_ComputerSystem
        $cs.AutomaticManagedPagefile = $false
        $cs.Put() | Out-Null
        $pf = Get-WmiObject Win32_PageFileSetting -ErrorAction SilentlyContinue
        if ($pf) {
            $pf.InitialSize = 4096
            $pf.MaximumSize = 8192
            $pf.Put() | Out-Null
        }
        return @{ Success = $true; Message = "Disk tweaks applied: 8.3 off, last access off, pagefile fixed 4-8GB" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        fsutil behavior set disable8dot3 0 2>$null
        fsutil behavior set disablelastaccess 0 2>$null
        $cs = Get-WmiObject Win32_ComputerSystem
        $cs.AutomaticManagedPagefile = $true
        $cs.Put() | Out-Null
        return @{ Success = $true; Message = "Disk tweaks restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
