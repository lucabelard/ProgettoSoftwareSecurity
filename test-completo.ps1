# Test completo del sistema su blockchain privata
# Versione PowerShell

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Test Sistema Oracolo Bayesiano - Blockchain Privata      " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# [1/3] Avvio blockchain
Write-Host "[1/3] Avvio blockchain privata (Ganache)..." -ForegroundColor Yellow

# Killa eventuali Ganache esistenti
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Avvia Ganache in background
$ganacheJob = Start-Job -ScriptBlock {
    npx -y ganache-cli@latest --deterministic --networkId 1337 --port 7545 --defaultBalanceEther 1000
}

Write-Host "✓ Blockchain avviata (Job ID: $($ganacheJob.Id))" -ForegroundColor Green
Start-Sleep -Seconds 5

# [2/3] Deploy contratto
Write-Host "📦 Deploy smart contract..." -ForegroundColor Yellow

try {
    truffle migrate --reset > deploy.log 2>&1
    if ($LASTEXITCODE -eq 0) {
        $contractAddr = Select-String -Path deploy.log -Pattern "contract address:" | Select-Object -Last 1 | ForEach-Object { $_.Line.Split()[-1] }
        Write-Host "✓ Contratto deployato: $contractAddr" -ForegroundColor Green
    } else {
        throw "Errore deploy"
    }
} catch {
    Write-Host "✗ Errore deploy. Vedi deploy.log" -ForegroundColor Red
    Stop-Job -Job $ganacheJob
    Remove-Job -Job $ganacheJob
    exit 1
}

# [3/3] Esecuzione test
Write-Host "🧪 Esecuzione test suite (24 test)..." -ForegroundColor Yellow
Write-Host ""

truffle test
$testResult = $LASTEXITCODE

# Cleanup
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
if ($testResult -eq 0) {
    Write-Host "✅ Tutti i test passati!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Alcuni test falliti. Vedi output sopra." -ForegroundColor Yellow
}
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Ferma Ganache
Stop-Job -Job $ganacheJob
Remove-Job -Job $ganacheJob

exit $testResult
