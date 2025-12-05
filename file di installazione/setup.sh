#!/bin/bash

# 🚀 Script di Setup Automatico - Sistema Oracolo Bayesiano
# Questo script configura tutto l'ambiente per il testing

echo "================================================"
echo "🏥 Setup Sistema Oracolo Bayesiano"
echo "================================================"
echo ""

# Colori per output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funzione per stampare messaggi colorati
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# 1. Verifica prerequisiti
echo "📋 Verifica prerequisiti..."

if ! command -v node &> /dev/null; then
    print_error "Node.js non trovato. Installa Node.js da https://nodejs.org/"
    exit 1
fi
print_success "Node.js installato: $(node --version)"

if ! command -v npm &> /dev/null; then
    print_error "npm non trovato."
    exit 1
fi
print_success "npm installato: $(npm --version)"

# 2. Verifica Ganache
echo ""
echo "🔍 Verifica Ganache..."
if curl -s http://127.0.0.1:7545 > /dev/null 2>&1; then
    print_success "Ganache in esecuzione su porta 7545"
else
    print_error "Ganache NON in esecuzione!"
    echo "   Avvia Ganache e assicurati che sia sulla porta 7545"
    echo "   Poi riesegui questo script."
    exit 1
fi

# 3. Installa dipendenze
echo ""
echo "📦 Installazione dipendenze..."
npm install
if [ $? -eq 0 ]; then
    print_success "Dipendenze installate"
else
    print_error "Errore nell'installazione delle dipendenze"
    exit 1
fi

# 4. Compila contratti
echo ""
echo "🔨 Compilazione contratti..."
npx truffle compile
if [ $? -eq 0 ]; then
    print_success "Contratti compilati"
else
    print_error "Errore nella compilazione"
    exit 1
fi

# 5. Deploy contratti
echo ""
echo "🚀 Deploy contratti su Ganache..."
npx truffle migrate --reset
if [ $? -eq 0 ]; then
    print_success "Contratti deployati"
else
    print_error "Errore nel deploy"
    exit 1
fi

# 6. Copia ABI nell'interfaccia web
echo ""
echo "📄 Copia ABI nell'interfaccia web..."
cp build/contracts/BNCalcolatoreOnChain.json web-interface/
if [ $? -eq 0 ]; then
    print_success "ABI copiato in web-interface/"
else
    print_error "Errore nella copia dell'ABI"
    exit 1
fi

# 7. Estrai indirizzo del contratto
echo ""
echo "📍 Informazioni contratto:"
CONTRACT_ADDRESS=$(cat build/contracts/BNCalcolatoreOnChain.json | grep -o '"address":"0x[^"]*"' | head -1 | cut -d'"' -f4)
if [ ! -z "$CONTRACT_ADDRESS" ]; then
    print_success "Indirizzo contratto: $CONTRACT_ADDRESS"
else
    print_warning "Impossibile estrarre l'indirizzo del contratto"
fi

# 8. Istruzioni finali
echo ""
echo "================================================"
echo "✅ Setup completato con successo!"
echo "================================================"
echo ""
echo "📝 Prossimi passi:"
echo ""
echo "1. Configura MetaMask:"
echo "   - Aggiungi rete 'Ganache Local'"
echo "   - RPC URL: http://127.0.0.1:7545"
echo "   - Chain ID: 1337"
echo "   - Simbolo: ETH"
echo ""
echo "2. Importa un account da Ganache in MetaMask"
echo "   - Apri Ganache → Copia chiave privata del primo account"
echo "   - MetaMask → Importa account → Incolla chiave"
echo ""
echo "3. Avvia l'interfaccia web:"
echo "   cd web-interface"
echo "   python -m http.server 8000"
echo "   # Oppure: npx http-server -p 8000"
echo ""
echo "4. Apri il browser:"
echo "   http://localhost:8000"
echo ""
echo "================================================"
echo "🎉 Buon testing!"
echo "================================================"
