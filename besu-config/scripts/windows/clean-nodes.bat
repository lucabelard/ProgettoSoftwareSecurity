@echo off
echo ========================================
echo   PULIZIA DATI NODI BESU
echo ========================================
echo.

cd /d "%~dp0.."

echo [1] Arresto tutti i processi Besu...
taskkill /F /IM besu.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2] Eliminazione dati nodi...
if exist "node1\data" (
    echo  - Pulizia node1...
    rmdir /s /q "node1\data"
)
if exist "node2\data" (
    echo  - Pulizia node2...
    rmdir /s /q "node2\data"
)
if exist "node3\data" (
    echo  - Pulizia node3...
    rmdir /s /q "node3\data"
)
if exist "node4\data" (
    echo  - Pulizia node4...
    rmdir /s /q "node4\data"
)

echo.
echo ✓ Pulizia completata!
echo.
echo Ora riavvia la rete con: .\avvia-rete-besu.bat
echo.
pause
