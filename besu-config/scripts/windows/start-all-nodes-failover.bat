@echo off
title Avvio Rete Besu Completa (Failover + 4 Nodi)
cls
echo ============================================================
echo   AVVIO RETE BESU COMPLETA CON FAILOVER
echo ============================================================
echo.

echo 1. Avvio Failover Proxy (Porta 8545)
echo 2. Avvio Node 1 (Porta 8551)
echo 3. Avvio Node 2 (Porta 8546)
echo 4. Avvio Node 3 (Porta 8547)
echo 5. Avvio Node 4 (Porta 8548)
echo.

cd /d "%~dp0"

echo [*] Avvio Failover Proxy...
start "Besu Proxy" start-proxy.bat

echo [*] Avvio Node 1...
start "Besu Node 1" start-node1.bat

echo [*] Attendo avvio Node 1...
timeout /t 5 /nobreak >nul

echo [*] Avvio Node 2...
start "Besu Node 2" start-node2.bat

echo [*] Avvio Node 3...
start "Besu Node 3" start-node3.bat

echo [*] Avvio Node 4...
start "Besu Node 4" start-node4.bat

echo.
echo ============================================================
echo   TUTTI I NODI AVVIATI!
echo ============================================================
echo.
echo La rete e' operativa.
echo.
echo Monitor Failover: Verifica lo stato su porta 8545
echo Nodi 2-3-4: Eseguono in background
echo.
pause
