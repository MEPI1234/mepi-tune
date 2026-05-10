param([string]$Action = "apply")

function Apply-Tweak {
    try {
        # Raw mouse input - disable pointer acceleration
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10" -Type String
        # Disable pointer precision (enhance pointer precision = mouse accel)
        $regPath = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $regPath -Name "MouseHoverTime" -Value "400" -Type String
        # SmoothMouseXCurve / SmoothMouseYCurve - flat curve = no accel
        $flatX = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)
        $flatY = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)
        Set-ItemProperty -Path $regPath -Name "SmoothMouseXCurve" -Value $flatX -Type Binary
        Set-ItemProperty -Path $regPath -Name "SmoothMouseYCurve" -Value $flatY -Type Binary
        return @{ Success = $true; Message = "Raw mouse input enabled - pointer acceleration disabled" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Type String
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "6" -Type String
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "10" -Type String
        return @{ Success = $true; Message = "Mouse settings restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
