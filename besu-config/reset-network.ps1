# Script per reset completo della rete Besu (elimina dati blockchain)
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  [RESET] RESET RETE BESU DISTRIBUITA" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[WARN] ATTENZIONE: Questo eliminerà tutti i dati blockchain!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Confermi il reset? (s/N)"

if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "[CANCEL] Reset annullato" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[*] Arresto nodi in esecuzione..." -ForegroundColor Yellow
& .\stop-network.ps1

Write-Host ""
Write-Host "[*] Eliminazione dati blockchain..." -ForegroundColor Yellow

# Elimina database blockchain di ogni nodo
for ($i = 1; $i -le 4; $i++) {
    $dbPath = "node$i/data/database"
    $cachePath = "node$i/data/caches"
    $logPath = "node$i/besu.log"
    
    if (Test-Path $dbPath) {
        Remove-Item $dbPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Eliminato database Node $i"
    }
    
    if (Test-Path $cachePath) {
        Remove-Item $cachePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Eliminato cache Node $i"
    }
    
    if (Test-Path $logPath) {
        Remove-Item $logPath -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Eliminato log Node $i"
    }
}

Write-Host ""
Write-Host "[OK] Reset completato!" -ForegroundColor Green
Write-Host ""
Write-Host "Per riavviare la rete con blockchain pulita:" -ForegroundColor Cyan
Write-Host "  .\start-network.ps1"
Write-Host ""
