#Requires -RunAsAdministrator
# MEPI-TUNE v1.0.0 Installer
# irm https://raw.githubusercontent.com/MEPI1234/mepi-tune/main/install.ps1 | iex

$ErrorActionPreference = 'SilentlyContinue'
$REPO    = "https://github.com/MEPI1234/mepi-tune/archive/refs/heads/main.zip"
$DEST    = "$env:USERPROFILE\Desktop\mepi-tune"
$ZIP     = "$env:TEMP\mepi-tune.zip"
$EXTRACT = "$env:TEMP\mepi-extract"

Clear-Host
Write-Host ""
Write-Host "  MEPI-TUNE v1.0.0 - PC Optimization Suite" -ForegroundColor Magenta
Write-Host "  ==========================================" -ForegroundColor DarkGray
Write-Host ""

# Admin check
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$pr = New-Object Security.Principal.WindowsPrincipal($id)
if (-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Run PowerShell as Administrator." -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}
Write-Host "  [OK] Administrator" -ForegroundColor Green

# Download
Write-Host "  [..] Downloading MEPI-TUNE..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    Invoke-WebRequest -Uri $REPO -OutFile $ZIP -UseBasicParsing -ErrorAction Stop
    Write-Host "  [OK] Downloaded" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

# Clean old folders
if (Test-Path $DEST)    { Remove-Item $DEST    -Recurse -Force }
if (Test-Path $EXTRACT) { Remove-Item $EXTRACT -Recurse -Force }

# Extract
Write-Host "  [..] Extracting..." -ForegroundColor Cyan
Expand-Archive -Path $ZIP -DestinationPath $EXTRACT -Force
Remove-Item $ZIP -Force

# GitHub extracts to mepi-tune-main\ — copy that directly to Desktop
$extracted = Get-ChildItem $EXTRACT | Select-Object -First 1
Copy-Item $extracted.FullName $DEST -Recurse -Force
Remove-Item $EXTRACT -Recurse -Force

Write-Host "  [OK] Installed to $DEST" -ForegroundColor Green

# Make sure required folders exist
foreach ($f in @("$DEST\logs","$DEST\backup","$DEST\ui")) {
    if (-not (Test-Path $f)) { New-Item -ItemType Directory -Path $f -Force | Out-Null }
}

Write-Host "  [OK] Installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "  Launching MEPI-TUNE..." -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 1
Set-Location $DEST
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$DEST\mepi-tune.ps1"
