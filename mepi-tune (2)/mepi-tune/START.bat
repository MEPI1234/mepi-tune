@echo off
title MEPI-TUNE Launcher
color 5F
echo.
echo  ==========================================
echo   MEPI-TUNE v2.1.0 - PC Optimization Suite
echo  ==========================================
echo.

:: Check for admin
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  [!] Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo  [OK] Running as Administrator
echo  [..] Launching MEPI-TUNE...
echo.

:: Set execution policy and launch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0mepi-tune.ps1"

if %errorLevel% NEQ 0 (
    echo.
    echo  [ERROR] Something went wrong. Check logs folder.
    pause
)
