# Test automatico semplificato
Write-Host "=== Test Offuscamento ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Avvia Ganache in background
Write-Host "[1/4] Avvio Ganache..." -ForegroundColor Yellow
$ganache = Start-Job -ScriptBlock {
    Set-Location "c:\Users\lucab\OneDrive\Desktop\ProgettoSoftwareSecurity"
    npx ganache-cli --port 7545 --networkId 5777
}
Write-Host "  OK Ganache avviato (Job ID: $($ganache.Id))" -ForegroundColor Green
Start-Sleep -Seconds 8

# Step 2: Deploy contratti
Write-Host "[2/4] Deploy contratti..." -ForegroundColor Yellow
$deploy = npx truffle migrate --reset 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Deploy completato" -ForegroundColor Green
}
else {
    Write-Host "  ERRORE Deploy fallito" -ForegroundColor Red
    Write-Host $deploy
    Stop-Job $ganache
    Remove-Job $ganache
    exit 1
}

# Step 3: Esegui test offuscamento
Write-Host "[3/4] Esecuzione test offuscamento..." -ForegroundColor Yellow
Write-Host ""
npx truffle test test\test-offuscamento.js
$testResult = $LASTEXITCODE

# Step 4: Cleanup
Write-Host ""
Write-Host "[4/4] Cleanup..." -ForegroundColor Yellow
Stop-Job $ganache
Remove-Job $ganache

# Risultato finale
Write-Host ""
Write-Host "======================" -ForegroundColor Cyan
if ($testResult -eq 0) {
    Write-Host "SUCCESSO!" -ForegroundColor Green
    Write-Host "Tutti i test passati" -ForegroundColor Green
}
else {
    Write-Host "FALLITO" -ForegroundColor Red
    Write-Host "Alcuni test non passati" -ForegroundColor Red
}
Write-Host "======================" -ForegroundColor Cyan

exit $testResult
