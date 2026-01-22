# Script per fermare la rete Besu distribuita
# Windows PowerShell version

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  [STOP] ARRESTO RETE BESU DISTRIBUITA" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Ferma tutti i processi Besu
Write-Host "[*] Arresto nodi Besu..." -ForegroundColor Yellow

$besuProcesses = Get-Process | Where-Object {$_.Name -like "*besu*"}

if ($besuProcesses) {
    $besuProcesses | ForEach-Object {
        Stop-Process -InputObject $_ -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Processo fermato (PID: $($_.Id))"
    }
} else {
    Write-Host "  [INFO] Nessun processo Besu trovato in esecuzione"
}

Start-Sleep -Seconds 2

# Verifica che tutti i processi siano effettivamente terminati
$remaining = Get-Process | Where-Object {$_.Name -like "*besu*"} | Measure-Object | Select-Object -ExpandProperty Count

Write-Host ""
if ($remaining -eq 0) {
    Write-Host "[OK] Tutti i nodi Besu sono stati fermati correttamente" -ForegroundColor Green
} else {
    Write-Host "[WARN] Alcuni processi potrebbero essere ancora attivi ($remaining)" -ForegroundColor Yellow
    Write-Host "   Usa 'Get-Process | Where-Object {`$_.Name -like '*besu*'} | Stop-Process -Force' per force kill" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
