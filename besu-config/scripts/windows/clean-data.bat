@echo off
title Pulizia Dati Besu
cls
echo ============================================================
echo   PULIZIA DATI BESU
echo ============================================================
echo.
echo ATTENZIONE: Questo script cancellera' il database blockchain locale.
echo E' necessario farlo se il file genesis.json e' cambiato.
echo.
echo I seguenti dati verranno rimossi:
echo - besu-config\node1\data
echo - besu-config\node2\data
echo - besu-config\node3\data
echo - besu-config\node4\data
echo.
echo Le chiavi private (networkFiles/keys) NON verranno toccate.
echo.
pause

cd /d "%~dp0..\..\.."

echo [*] Rimozione dati Node 1...
rmdir /s /q "besu-config\node1\data"
mkdir "besu-config\node1\data"

echo [*] Rimozione dati Node 2...
rmdir /s /q "besu-config\node2\data"
mkdir "besu-config\node2\data"

echo [*] Rimozione dati Node 3...
rmdir /s /q "besu-config\node3\data"
mkdir "besu-config\node3\data"

echo [*] Rimozione dati Node 4...
rmdir /s /q "besu-config\node4\data"
mkdir "besu-config\node4\data"

echo.
echo [*] Ripristino static-nodes.json per tutti i nodi...
copy "besu-config\static-nodes.json" "besu-config\node1\data\static-nodes.json" >nul
copy "besu-config\static-nodes.json" "besu-config\node2\data\static-nodes.json" >nul
copy "besu-config\static-nodes.json" "besu-config\node3\data\static-nodes.json" >nul
copy "besu-config\static-nodes.json" "besu-config\node4\data\static-nodes.json" >nul

echo.
echo ============================================================
echo   PULIZIA E RIPRISTINO COMPLETATI
echo ============================================================
echo.
echo Ora puoi riavviare la rete con start-all-nodes-failover.bat
echo.
pause
