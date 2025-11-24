# 🚀 Quick Start Guide - 5 Minuti

Guida rapida per testare il sistema in 5 minuti.

## ⚡ Setup Veloce

### 1. Prerequisiti (1 minuto)
- ✅ Node.js installato
- ✅ Ganache in esecuzione su porta 7545
- ✅ MetaMask installato e configurato su rete Ganache

### 2. Installazione (2 minuti)

```bash
# Clone e installazione
git clone https://github.com/lucabelard/ProgettoSoftwareSecurity.git
cd ProgettoSoftwareSecurity
npm install

# Deploy contratto
truffle migrate --reset

# Copia ABI
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force

# Avvia interfaccia
cd web-interface
python -m http.server 8000
```

Apri: http://localhost:8000

### 3. Test Rapido (2 minuti)

#### Step 1: Connetti Wallet
- Clicca "Connect Wallet"
- Approva in MetaMask

#### Step 2: Crea Spedizione
- Pannello "Mittente"
- Corriere: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` (esempio)
- Importo: `1` ETH
- Clicca "Crea Spedizione"

#### Step 3: Invia Evidenze
- Pannello "Sensore"
- ID Spedizione: `1`
- Invia tutte e 5 le evidenze:
  - E1: ✅ True
  - E2: ✅ True  
  - E3: ❌ False
  - E4: ❌ False
  - E5: ✅ True

#### Step 4: Valida Pagamento
- Cambia account in MetaMask (usa corriere)
- Pannello "Corriere"
- ID Spedizione: `1`
- Clicca "Valida e Ricevi Pagamento"

✅ **Successo!** Il corriere riceve 1 ETH

## 🎯 Test Negativo (Opzionale)

Ripeti con evidenze sbagliate:
- E1: ❌ False (temperatura fuori range)
- E3: ✅ True (shock rilevato)

Risultato: Pagamento rifiutato ❌

## 📖 Guida Completa

Per dettagli completi, vedi [INSTALLATION_GUIDE.md](./INSTALLATION_GUIDE.md)
