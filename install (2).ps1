#Requires -RunAsAdministrator
# MEPI-TUNE Installer
# Usage: irm https://raw.githubusercontent.com/MEPI1234/mepi-tune/main/install.ps1 | iex

$ErrorActionPreference = 'SilentlyContinue'
$REPO = "https://github.com/MEPI1234/mepi-tune/archive/refs/heads/main.zip"
$INSTALL_DIR = "$env:USERPROFILE\Desktop\mepi-tune"
$ZIP_PATH = "$env:TEMP\mepi-tune-download.zip"
$EXTRACT_PATH = "$env:TEMP\mepi-extract-temp"

Clear-Host
Write-Host ""
Write-Host "  MEPI-TUNE v1.0.0 - PC Optimization Suite" -ForegroundColor Magenta
Write-Host "  ==========================================" -ForegroundColor DarkGray
Write-Host ""

# Check admin
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Please run PowerShell as Administrator." -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

Write-Host "  [OK] Running as Administrator" -ForegroundColor Green
Write-Host "  [..] Downloading MEPI-TUNE..." -ForegroundColor Cyan

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $REPO -OutFile $ZIP_PATH -UseBasicParsing
    Write-Host "  [OK] Download complete" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

Write-Host "  [..] Extracting files..." -ForegroundColor Cyan
try {
    # Clean up old installs
    if (Test-Path $INSTALL_DIR) { Remove-Item $INSTALL_DIR -Recurse -Force }
    if (Test-Path $EXTRACT_PATH) { Remove-Item $EXTRACT_PATH -Recurse -Force }

    # Extract zip
    Expand-Archive -Path $ZIP_PATH -DestinationPath $EXTRACT_PATH -Force

    # Find mepi-tune.ps1 anywhere in the extracted folder
    $ps1File = Get-ChildItem -Path $EXTRACT_PATH -Filter "mepi-tune.ps1" -Recurse | Select-Object -First 1

    if ($ps1File -eq $null) {
        Write-Host "  [ERROR] Could not find mepi-tune.ps1 in extracted files" -ForegroundColor Red
        Write-Host "  Extracted contents:" -ForegroundColor DarkGray
        Get-ChildItem $EXTRACT_PATH -Recurse | ForEach-Object { Write-Host "    $($_.FullName)" -ForegroundColor DarkGray }
        Read-Host "  Press Enter to exit"
        exit 1
    }

    # Copy the folder containing mepi-tune.ps1 to Desktop
    $sourceDir = $ps1File.DirectoryName
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Copy-Item "$sourceDir\*" $INSTALL_DIR -Recurse -Force

    # Cleanup temp
    Remove-Item $EXTRACT_PATH -Recurse -Force
    Remove-Item $ZIP_PATH -Force

    Write-Host "  [OK] Extracted to $INSTALL_DIR" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Extraction failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

# Create required folders
@("$INSTALL_DIR\logs", "$INSTALL_DIR\backup") | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

Write-Host "  [OK] Installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "  Installed to: $INSTALL_DIR" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Launching MEPI-TUNE..." -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 1
Set-Location $INSTALL_DIR
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTALL_DIR\mepi-tune.ps1"
