# Test verifica offuscamento
Write-Host "Test Modifiche Offuscamento" -ForegroundColor Cyan
Write-Host ""

# Verifica file
Write-Host "[1/2] Verifica file..." -ForegroundColor Yellow
if (Test-Path "contracts\BNCore.sol") {
    Write-Host "  OK BNCore.sol" -ForegroundColor Green
} else {
    Write-Host "  ERRORE BNCore.sol" -ForegroundColor Red
    exit 1
}

if (Test-Path "test\test-offuscamento.js") {
    Write-Host "  OK test-offuscamento.js" -ForegroundColor Green
} else {
    Write-Host "  ERRORE test-offuscamento.js" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/2] Ricerca Node.js..." -ForegroundColor Yellow

$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    Write-Host "  OK Node.js trovato" -ForegroundColor Green
    $ver = node --version
    Write-Host "  Versione: $ver" -ForegroundColor Gray
} else {
    Write-Host "  ERRORE Node.js non trovato" -ForegroundColor Red
    Write-Host "  Installare da: https://nodejs.org" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "ISTRUZIONI PER TESTARE:" -ForegroundColor Cyan
Write-Host "1. Apri un terminale ed esegui:" -ForegroundColor White
Write-Host "   cd c:\Users\lucab\OneDrive\Desktop\ProgettoSoftwareSecurity" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Compila i contratti:" -ForegroundColor White
Write-Host "   npx truffle compile" -ForegroundColor Gray
Write-Host "   OPPURE: truffle compile (se installato globalmente)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Avvia Ganache in un terminale separato:" -ForegroundColor White
Write-Host "   npx ganache-cli --port 7545" -ForegroundColor Gray
Write-Host ""
Write-Host "4. In questo terminale, fai deploy e test:" -ForegroundColor White
Write-Host "   npx truffle migrate --reset" -ForegroundColor Gray
Write-Host "   npx truffle test test/test-offuscamento.js" -ForegroundColor Gray
Write-Host ""
