@echo off
title Avvio Rete Besu
echo ==================================================
echo   LANCIATORE RETE BESU
echo ==================================================
echo.
echo Sto avviando la rete blockchain (4 nodi) da besu-config...
echo.

cd besu-config
call scripts\windows\start-network.bat
