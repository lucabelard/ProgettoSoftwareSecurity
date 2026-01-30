@echo off
title Besu Network Manager
cls
echo ============================================================
echo   AVVIO RETE BESU DISTRIBUITA (4 Nodi)
echo ============================================================
echo.

cd /d "%~dp0..\.."

echo [*] Arresto processi precedenti...
taskkill /F /IM besu.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [*] Avvio Node 1 (Bootstrap)...
start "Besu Node 1" scripts\windows\start-node1.bat

echo [*] Attesa inizializzazione Node 1 (5s)...
timeout /t 5 /nobreak >nul

echo.
echo [*] Avvio Node 2...
start "Besu Node 2" scripts\windows\start-node2.bat

echo [*] Avvio Node 3...
start "Besu Node 3" scripts\windows\start-node3.bat

echo [*] Avvio Node 4...
start "Besu Node 4" scripts\windows\start-node4.bat

echo.
echo [*] I nodi si connetteranno automaticamente tramite P2P discovery...
timeout /t 10 /nobreak >nul

echo.
echo ============================================================
echo   RETE AVVIATA!
echo ============================================================
echo.
echo Per verificare lo stato della rete:
echo   scripts\windows\check-network.ps1
echo.
echo.
pause
