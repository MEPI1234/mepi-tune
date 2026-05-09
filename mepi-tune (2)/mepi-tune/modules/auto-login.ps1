param([string]$Action = "apply")

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

function Apply-Tweak {
    try {
        $userRaw = (Get-WmiObject Win32_ComputerSystem).UserName
        if ($userRaw -like "*\*") {
            $user = $userRaw.Split("\")[1]
        } else {
            $user = $env:USERNAME
        }

        $plainPass = Read-Host "Enter password for $user (leave blank if no password)"

        $origProp = Get-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
        if ($origProp -ne $null) {
            $origVal = $origProp.AutoAdminLogon
        } else {
            $origVal = "0"
        }

        Set-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_AutoAdminLogon" -Value $origVal          -Type String
        Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon"            -Value "1"               -Type String
        Set-ItemProperty -Path $RegPath -Name "DefaultUserName"           -Value $user             -Type String
        Set-ItemProperty -Path $RegPath -Name "DefaultPassword"           -Value $plainPass        -Type String
        Set-ItemProperty -Path $RegPath -Name "DefaultDomainName"         -Value $env:COMPUTERNAME -Type String

        return @{ Success = $true; Message = "Auto login enabled for $user" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $origProp = Get-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_AutoAdminLogon" -ErrorAction SilentlyContinue
        if ($origProp -ne $null) {
            $origVal = $origProp._MEPI_ORIG_AutoAdminLogon
        } else {
            $origVal = "0"
        }
        Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value $origVal -Type String
        Remove-ItemProperty -Path $RegPath -Name "DefaultPassword"           -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "_MEPI_ORIG_AutoAdminLogon" -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Auto login disabled" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
