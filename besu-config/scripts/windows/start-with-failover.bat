@echo off
title Besu Failover Monitor - Porta 8545
cls

echo ============================================================
echo   BESU FAILOVER MONITOR
echo   Mantiene sempre un nodo attivo sulla porta 8545
echo ============================================================
echo.
echo Questo script:
echo   - Avvia il Node 1 sulla porta 8545
echo   - Monitora continuamente la porta
echo   - Se il nodo cade, avvia automaticamente un backup
echo.
echo Premi CTRL+C per fermare il monitor
echo.
echo ============================================================
echo.


cd /d "%~dp0..\\.."

REM Killing process on port 8545
echo [*] Pulizia porta 8545...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8545" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1


REM Esegui lo script PowerShell di monitoring
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0failover-monitor.ps1"

pause
