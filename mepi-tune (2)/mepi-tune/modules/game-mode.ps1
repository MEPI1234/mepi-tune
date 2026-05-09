param([string]$Action = "apply")
$RegPath = "HKCU:\Software\Microsoft\GameBar"
$GameModePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"

function Apply-Tweak {
    try {
        if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        Set-ItemProperty -Path $RegPath -Name "AllowAutoGameMode" -Value 1 -Type DWord
        Set-ItemProperty -Path $RegPath -Name "AutoGameModeEnabled" -Value 1 -Type DWord
        # Disable Game DVR (causes FPS drops)
        if (-not (Test-Path $GameModePath)) { New-Item -Path $GameModePath -Force | Out-Null }
        Set-ItemProperty -Path $GameModePath -Name "AppCaptureEnabled" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Game Mode enabled, Game DVR disabled" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    try {
        Set-ItemProperty -Path $RegPath -Name "AllowAutoGameMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $GameModePath -Name "AppCaptureEnabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        return @{ Success = $true; Message = "Game Mode settings restored" }
    } catch { return @{ Success = $false; Message = "Restore failed: $_" } }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
