param([string]$Action = "apply")

$DesktopPath = "HKCU:\Control Panel\Desktop"
$ExplorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"

function Apply-Tweak {
    try {
        # Save originals
        $origUPM = (Get-ItemProperty -Path $DesktopPath -Name "UserPreferencesMask" -ErrorAction SilentlyContinue).UserPreferencesMask
        Set-ItemProperty -Path $DesktopPath -Name "_MEPI_ORIG_UPM" -Value $origUPM -ErrorAction SilentlyContinue

        # Disable animations
        Set-ItemProperty -Path $DesktopPath -Name "AnimateWindows" -Value "0" -Type String
        Set-ItemProperty -Path $DesktopPath -Name "MinAnimate" -Value "0" -Type String
        Set-ItemProperty -Path $DesktopPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary

        # Visual effects - performance mode
        if (-not (Test-Path $ExplorerPath)) { New-Item -Path $ExplorerPath -Force | Out-Null }
        Set-ItemProperty -Path $ExplorerPath -Name "VisualFXSetting" -Value 2 -Type DWord

        # DWM animations
        Set-ItemProperty -Path $DWMPath -Name "EnableAeroPeek" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DWMPath -Name "AlwaysHibernateThumbnails" -Value 0 -Type DWord -ErrorAction SilentlyContinue

        # Taskbar animations
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -ErrorAction SilentlyContinue

        # Combo box animation
        Set-ItemProperty -Path $DesktopPath -Name "ComboBoxAnimation" -Value "0" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DesktopPath -Name "CursorBlinkRate" -Value "530" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DesktopPath -Name "MenuAnimation" -Value "0" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DesktopPath -Name "SelectionFade" -Value "0" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DesktopPath -Name "TooltipAnimation" -Value "0" -Type String -ErrorAction SilentlyContinue

        return @{ Success = $true; Message = "All system animations disabled" }
    } catch {
        return @{ Success = $false; Message = "Failed: $_" }
    }
}

function Restore-Tweak {
    try {
        Set-ItemProperty -Path $DesktopPath -Name "AnimateWindows" -Value "1" -Type String
        Set-ItemProperty -Path $DesktopPath -Name "MinAnimate" -Value "1" -Type String
        Set-ItemProperty -Path $ExplorerPath -Name "VisualFXSetting" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $DWMPath -Name "EnableAeroPeek" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "System animations restored" }
    } catch {
        return @{ Success = $false; Message = "Restore failed: $_" }
    }
}

if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
