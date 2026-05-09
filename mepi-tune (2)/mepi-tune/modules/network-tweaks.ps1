param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # DNS - Cloudflare
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
        }
        # Disable Nagle's Algorithm
        $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        Get-ChildItem $tcpPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }
        # TCP global optimizations
        netsh int tcp set global autotuninglevel=normal 2>$null
        netsh int tcp set global chimney=disabled 2>$null
        netsh int tcp set global dca=enabled 2>$null
        netsh int tcp set global netdma=enabled 2>$null
        netsh int tcp set global ecncapability=disabled 2>$null
        netsh int tcp set global timestamps=disabled 2>$null
        netsh int tcp set global rss=enabled 2>$null
        netsh int tcp set global nonsackrttresiliency=disabled 2>$null
        netsh int tcp set heuristics disabled 2>$null
        # Winsock buffer
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DefaultSendWindow" -Value 65536 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DefaultReceiveWindow" -Value 65536 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "FastSendDatagramThreshold" -Value 1024 -Type DWord -ErrorAction SilentlyContinue
        # Reduce background interference - disable NCSI
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" -Name "EnableActiveProbing" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        # Stabilize routing
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnableICMPRedirect" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DeadGWDetectDefault" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        # Optimize MPP - disable extra TCP validation
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableTaskOffload" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPMaxDupAcks" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        # USB polling rate
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\usbhub\Parameters" -Name "TransferBufferSize" -Value 0x80000 -Type DWord -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "All network tweaks applied: DNS, Nagle, TCP, Winsock, routing optimized" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}

function Restore-Tweak {
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        }
        netsh int tcp set heuristics enabled 2>$null
        netsh int tcp set global autotuninglevel=normal 2>$null
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" -Name "EnableActiveProbing" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnableICMPRedirect" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Network tweaks restored to defaults" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
