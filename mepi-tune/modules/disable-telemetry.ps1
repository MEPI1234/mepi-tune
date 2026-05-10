param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Disable telemetry services
        $services = @("DiagTrack","dmwappushservice","WerSvc","WerMgr","PcaSvc")
        foreach ($svc in $services) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }

        # Registry telemetry keys
        $policies = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (-not (Test-Path $policies)) { New-Item -Path $policies -Force | Out-Null }
        Set-ItemProperty -Path $policies -Name "AllowTelemetry" -Value 0 -Type DWord

        $telPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
        if (-not (Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
        Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord
        Set-ItemProperty -Path $telPath -Name "MaxTelemetryAllowed" -Value 0 -Type DWord

        # Scheduled tasks
        $tasks = @(
            "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
            "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
            "\Microsoft\Windows\Autochk\Proxy",
            "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        )
        foreach ($task in $tasks) {
            Disable-ScheduledTask -TaskPath (Split-Path $task) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue | Out-Null
        }

        # Block telemetry hosts via hosts file
        $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
        $telemetryHosts = @(
            "0.0.0.0 vortex.data.microsoft.com",
            "0.0.0.0 vortex-win.data.microsoft.com",
            "0.0.0.0 telecommand.telemetry.microsoft.com",
            "0.0.0.0 telecommand.telemetry.microsoft.com.nsatc.net",
            "0.0.0.0 oca.telemetry.microsoft.com",
            "0.0.0.0 sqm.telemetry.microsoft.com",
            "0.0.0.0 watson.telemetry.microsoft.com",
            "0.0.0.0 telemetry.microsoft.com",
            "0.0.0.0 settings-sandbox.data.microsoft.com"
        )
        $hostsContent = Get-Content $hostsPath -Raw
        $marker = "# MEPI-TUNE TELEMETRY BLOCK"
        if ($hostsContent -notlike "*$marker*") {
            Add-Content -Path $hostsPath -Value "`n$marker"
            foreach ($h in $telemetryHosts) { Add-Content -Path $hostsPath -Value $h }
        }

        return @{ Success = $true; Message = "Telemetry fully disabled. Services stopped, hosts blocked." }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $services = @("DiagTrack","dmwappushservice","WerSvc")
        foreach ($svc in $services) {
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        }
        # Remove hosts entries
        $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
        $lines = Get-Content $hostsPath | Where-Object { $_ -notlike "*microsoft.com*" -and $_ -ne "# MEPI-TUNE TELEMETRY BLOCK" }
        Set-Content -Path $hostsPath -Value $lines
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Telemetry settings restored" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
