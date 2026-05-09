#Requires -RunAsAdministrator
# MEPI-TUNE Installer
# Usage: irm https://raw.githubusercontent.com/MEPI1234/mepi-tune/main/install.ps1 | iex

$ErrorActionPreference = 'SilentlyContinue'
$REPO = "https://github.com/MEPI1234/mepi-tune/archive/refs/heads/main.zip"
$INSTALL_DIR = "$env:USERPROFILE\Desktop\mepi-tune"
$ZIP_PATH = "$env:TEMP\mepi-tune.zip"

Clear-Host
Write-Host ""
Write-Host "  #     # ####### ######  #" -ForegroundColor Magenta
Write-Host "  ##   ## #       #     # #" -ForegroundColor Magenta
Write-Host "  # # # # #####   ######  #" -ForegroundColor Magenta
Write-Host "  #  #  # #       #       #" -ForegroundColor Magenta
Write-Host "  #     # ####### #       #" -ForegroundColor Magenta
Write-Host ""
Write-Host "  MEPI-TUNE v1.0.0 - PC Optimization Suite" -ForegroundColor DarkMagenta
Write-Host "  ==========================================" -ForegroundColor DarkGray
Write-Host ""

# Check admin
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Please run PowerShell as Administrator." -ForegroundColor Red
    Write-Host "  Right-click PowerShell -> Run as Administrator" -ForegroundColor DarkGray
    Read-Host "  Press Enter to exit"
    exit 1
}

Write-Host "  [OK] Running as Administrator" -ForegroundColor Green
Write-Host "  [..] Downloading MEPI-TUNE..." -ForegroundColor Cyan

# Download zip from GitHub
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $REPO -OutFile $ZIP_PATH -UseBasicParsing
    Write-Host "  [OK] Download complete" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

# Extract
Write-Host "  [..] Extracting files..." -ForegroundColor Cyan
try {
    if (Test-Path $INSTALL_DIR) {
        Remove-Item $INSTALL_DIR -Recurse -Force
    }
    Expand-Archive -Path $ZIP_PATH -DestinationPath "$env:TEMP\mepi-extract" -Force

    # GitHub adds -main suffix to extracted folder
    $extracted = Get-ChildItem "$env:TEMP\mepi-extract" | Select-Object -First 1
    # Find the inner mepi-tune folder
    $inner = Get-ChildItem $extracted.FullName | Where-Object { $_.Name -eq "mepi-tune" } | Select-Object -First 1
    if ($inner) {
        Copy-Item $inner.FullName $INSTALL_DIR -Recurse -Force
    } else {
        Copy-Item $extracted.FullName $INSTALL_DIR -Recurse -Force
    }

    Remove-Item "$env:TEMP\mepi-extract" -Recurse -Force
    Remove-Item $ZIP_PATH -Force
    Write-Host "  [OK] Extracted to $INSTALL_DIR" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Extraction failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

# Create required folders
@("$INSTALL_DIR\logs", "$INSTALL_DIR\backup", "$INSTALL_DIR\ui") | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

Write-Host "  [OK] Installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "  Installed to: $INSTALL_DIR" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Launching MEPI-TUNE..." -ForegroundColor Cyan
Write-Host ""

# Find mepi-tune.ps1 wherever it landed after extraction
$ps1 = Get-ChildItem -Path $INSTALL_DIR -Filter "mepi-tune.ps1" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($ps1 -eq $null) {
    Write-Host "  [ERROR] Could not find mepi-tune.ps1" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

$launchDir = $ps1.DirectoryName
Write-Host "  [OK] Found at $($ps1.FullName)" -ForegroundColor Green

# Copy MEPI.pow to launch dir if needed
$pow = Get-ChildItem -Path $INSTALL_DIR -Filter "MEPI.pow" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pow -and $pow.DirectoryName -ne $launchDir) {
    Copy-Item $pow.FullName $launchDir -Force
}

# Launch
Start-Sleep -Seconds 1
Set-Location $launchDir
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps1.FullName
