param([string]$Action = "apply")

function Apply-Tweak {
    try {
        $schemes = powercfg /list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
        foreach ($scheme in $schemes) {
            powercfg /setacvalueindex $scheme SUB_PROCESSOR CPMINCORES 100 2>$null
            powercfg /setdcvalueindex $scheme SUB_PROCESSOR CPMINCORES 100 2>$null
        }
        # Also via registry
        Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583\DefaultPowerSchemeValues" -ErrorAction SilentlyContinue |
            ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "ValueMax" -Value 100 -Type DWord -ErrorAction SilentlyContinue }
        return @{ Success = $true; Message = "CPU parking disabled - all cores active" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        $schemes = powercfg /list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
        foreach ($scheme in $schemes) {
            powercfg /setacvalueindex $scheme SUB_PROCESSOR CPMINCORES 0 2>$null
        }
        return @{ Success = $true; Message = "CPU parking restored to default" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
