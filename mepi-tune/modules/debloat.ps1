param([string]$Action = "apply")

function Apply-Tweak {
    try {
        $bloatware = @(
            "Microsoft.3DBuilder","Microsoft.BingWeather","Microsoft.GetHelp",
            "Microsoft.Getstarted","Microsoft.Messaging","Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub","Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.NetworkSpeedTest","Microsoft.Office.Sway","Microsoft.OneConnect",
            "Microsoft.People","Microsoft.Print3D","Microsoft.SkypeApp",
            "Microsoft.Wallet","Microsoft.WindowsAlarms","Microsoft.WindowsCamera",
            "Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps",
            "Microsoft.WindowsPhone","Microsoft.WindowsSoundRecorder",
            "Microsoft.XboxApp","Microsoft.XboxGameOverlay","Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone","Microsoft.ZuneMusic","Microsoft.ZuneVideo",
            "Microsoft.MixedReality.Portal","Microsoft.Todos",
            "Microsoft.PowerAutomateDesktop","Clipchamp.Clipchamp"
        )
        $removed = 0
        foreach ($app in $bloatware) {
            $pkg = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
            if ($pkg) {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
                $removed++
            }
            # Also remove provisioned
            Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
        }
        return @{ Success = $true; Message = "Debloat complete: $removed apps removed" }
    } catch { return @{ Success = $false; Message = "Failed: $_" } }
}
function Restore-Tweak {
    return @{ Success = $false; Message = "Debloat cannot be auto-restored. Use Settings > Apps or reinstall Windows apps." }
}
if ($Action -eq "apply") { Apply-Tweak } else { Restore-Tweak }
