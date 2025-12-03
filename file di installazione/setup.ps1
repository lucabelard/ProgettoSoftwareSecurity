# 🚀 Script di Setup Automatico - Sistema Oracolo Bayesiano
# Questo script configura tutto l'ambiente per il testing (Windows PowerShell)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🏥 Setup Sistema Oracolo Bayesiano" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verifica prerequisiti
Write-Host "📋 Verifica prerequisiti..." -ForegroundColor Yellow

try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js installato: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js non trovato. Installa da https://nodejs.org/" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = npm --version
    Write-Host "✓ npm installato: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ npm non trovato" -ForegroundColor Red
    exit 1
}

# 2. Verifica Ganache
Write-Host ""
Write-Host "🔍 Verifica Ganache..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:7545" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✓ Ganache in esecuzione su porta 7545" -ForegroundColor Green
} catch {
    Write-Host "✗ Ganache NON in esecuzione!" -ForegroundColor Red
    Write-Host "  Avvia Ganache e assicurati che sia sulla porta 7545" -ForegroundColor Yellow
    Write-Host "  Poi riesegui questo script." -ForegroundColor Yellow
    exit 1
}

# 3. Installa dipendenze
Write-Host ""
Write-Host "📦 Installazione dipendenze..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dipendenze installate" -ForegroundColor Green
} else {
    Write-Host "✗ Errore nell'installazione delle dipendenze" -ForegroundColor Red
    exit 1
}

# 4. Compila contratti
Write-Host ""
Write-Host "🔨 Compilazione contratti..." -ForegroundColor Yellow
npx truffle compile
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Contratti compilati" -ForegroundColor Green
} else {
    Write-Host "✗ Errore nella compilazione" -ForegroundColor Red
    exit 1
}

# 5. Deploy contratti
Write-Host ""
Write-Host "🚀 Deploy contratti su Ganache..." -ForegroundColor Yellow
npx truffle migrate --reset
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Contratti deployati" -ForegroundColor Green
} else {
    Write-Host "✗ Errore nel deploy" -ForegroundColor Red
    exit 1
}

# 6. Copia ABI nell'interfaccia web
Write-Host ""
Write-Host "📄 Copia ABI nell'interfaccia web..." -ForegroundColor Yellow
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force
if ($LASTEXITCODE -eq 0 -or $?) {
    Write-Host "✓ ABI copiato in web-interface\" -ForegroundColor Green
} else {
    Write-Host "✗ Errore nella copia dell'ABI" -ForegroundColor Red
    exit 1
}

# 7. Estrai indirizzo del contratto
Write-Host ""
Write-Host "📍 Informazioni contratto:" -ForegroundColor Yellow
try {
    $contractJson = Get-Content "build\contracts\BNCalcolatoreOnChain.json" | ConvertFrom-Json
    $networks = $contractJson.networks | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    if ($networks) {
        $networkId = $networks[0]
        $contractAddress = $contractJson.networks.$networkId.address
        Write-Host "✓ Indirizzo contratto: $contractAddress" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Impossibile estrarre l'indirizzo del contratto" -ForegroundColor Yellow
}

# 8. Istruzioni finali
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Setup completato con successo!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Prossimi passi:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configura MetaMask:"
Write-Host "   - Aggiungi rete 'Ganache Local'"
Write-Host "   - RPC URL: http://127.0.0.1:7545"
Write-Host "   - Chain ID: 1337"
Write-Host "   - Simbolo: ETH"
Write-Host ""
Write-Host "2. Importa un account da Ganache in MetaMask"
Write-Host "   - Apri Ganache → Copia chiave privata del primo account"
Write-Host "   - MetaMask → Importa account → Incolla chiave"
Write-Host ""
Write-Host "3. Avvia l'interfaccia web:"
Write-Host "   cd web-interface"
Write-Host "   python -m http.server 8000"
Write-Host "   # Oppure: npx http-server -p 8000"
Write-Host ""
Write-Host "4. Apri il browser:"
Write-Host "   http://localhost:8000"
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🎉 Buon testing!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
