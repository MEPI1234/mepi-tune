param([string]$Action = "apply")

$SCRIPT_DIR  = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$POW_FILE    = "$SCRIPT_DIR\MEPI.pow"
$MEPI_GUID   = "44444444-4444-4444-4444-444444444444"

function Apply-Tweak {
    try {
        # Save current active plan GUID so we can restore it
        $currentRaw = powercfg /getactivescheme
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" `
            -Name "_MEPI_ORIG_PowerPlan" -Value $currentRaw -Type String -ErrorAction SilentlyContinue

        # Check if MEPI plan already imported
        $existing = powercfg /list | Select-String "MEPI"
        if ($existing) {
            # Already imported, just activate it
            $guid = ($existing -split '\s+')[3]
            powercfg /setactive $guid 2>$null
            return @{ Success = $true; Message = "MEPI Power Plan activated (was already imported)" }
        }

        # Import MEPI.pow if file exists
        if (Test-Path $POW_FILE) {
            $importOut = powercfg /import $POW_FILE $MEPI_GUID 2>&1
            Start-Sleep -Milliseconds 500
            powercfg /setactive $MEPI_GUID 2>$null

            # Rename it so it shows nicely
            powercfg /changename $MEPI_GUID "MEPI Power Plan" "Optimized by MEPI-TUNE" 2>$null

            return @{ Success = $true; Message = "MEPI Power Plan imported and activated" }
        } else {
            # Fallback: activate built-in High Performance if .pow missing
            $hp = powercfg /list | Select-String "High performance"
            if ($hp) {
                $guid = ($hp -split '\s+')[3]
                powercfg /setactive $guid 2>$null
                return @{ Success = $true; Message = "MEPI.pow not found - High Performance plan activated as fallback" }
            }
            return @{ Success = $false; Message = "MEPI.pow not found and no High Performance plan available" }
        }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        # Get the saved original plan
        $origRaw = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" `
            -Name "_MEPI_ORIG_PowerPlan" -ErrorAction SilentlyContinue)._MEPI_ORIG_PowerPlan

        if ($origRaw -ne $null -and $origRaw -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
            $origGuid = $matches[1]
            powercfg /setactive $origGuid 2>$null
        } else {
            # Fallback to Balanced
            $balanced = powercfg /list | Select-String "Balanced"
            if ($balanced) {
                $guid = ($balanced -split '\s+')[3]
                powercfg /setactive $guid 2>$null
            }
        }

        # Remove MEPI plan
        powercfg /delete $MEPI_GUID 2>$null
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" `
            -Name "_MEPI_ORIG_PowerPlan" -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "Power plan restored to original" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
