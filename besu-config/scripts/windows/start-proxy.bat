@echo off
title Besu Failover Proxy (Port 8545)
cls
echo ============================================================
echo   BESU FAILOVER PROXY
echo   Porta RPC Unica: 8545
echo ============================================================
echo.
echo Questo proxy riceve richieste su 8545 e le inoltra a:
echo  - Node 1 (8551)
echo  - Node 2 (8546)
echo  - Node 3 (8547)
echo  - Node 4 (8548)
echo.
echo Se un nodo cade, passa automaticamente al successivo
echo senza che MetaMask se ne accorga.
echo.

cd /d "%~dp0..\\.."

REM Killing process on port 8545 (pulizia)
echo [*] Pulizia porta 8545...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8545" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1

echo [*] Avvio Proxy Node.js...
node scripts/rpc-proxy.js


pause
