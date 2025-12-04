# 🔄 Guida Migrazione: Ganache → Hyperledger Besu

Questa guida spiega come passare da Ganache a Hyperledger Besu per il deployment dei contratti.

---

## 📋 Indice

1. [Perché Besu?](#perché-besu)
2. [Installazione Besu](#installazione-besu)
3. [Avvio della Rete Besu](#avvio-della-rete-besu)
4. [Deploy dei Contratti](#deploy-dei-contratti)
5. [Configurazione MetaMask](#configurazione-metamask)
6. [Differenze Rispetto a Ganache](#differenze-rispetto-a-ganache)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Perché Besu?

**Hyperledger Besu** è un client Ethereum enterprise-grade con vantaggi rispetto a Ganache:

✅ **Production-ready**: Utilizzato in ambienti enterprise  
✅ **Consenso avanzato**: Supporta IBFT 2.0, QBFT, Clique  
✅ **Privacy**: Supporto per transazioni private  
✅ **Permissioning**: Controllo avanzato degli accessi  
✅ **Monitoraggio**: Metriche Prometheus integrate  
✅ **EVM Completo**: Compatibilità 100% con Ethereum mainnet

---

## 📥 Installazione Besu

### macOS (Homebrew)

```bash
brew tap hyperledger/besu
brew install besu

# Verifica installazione
besu --version
```

### Linux

```bash
# Scarica l'ultima versione
wget https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/24.12.0/besu-24.12.0.tar.gz

# Estrai
tar -xzf besu-24.12.0.tar.gz

# Sposta nella directory bin
sudo mv besu-24.12.0 /opt/besu
sudo ln -s /opt/besu/bin/besu /usr/local/bin/besu

# Verifica
besu --version
```

### Windows

```powershell
# Usa Chocolatey
choco install besu

# Verifica
besu --version
```

---

## 🚀 Avvio della Rete Besu

### Opzione 1: Script Automatico (Raccomandato)

```bash
# Dalla root del progetto
./besu-config/start-besu.sh
```

### Opzione 2: Comando Manuale

```bash
besu --data-path=besu-data \
  --genesis-file=besu-config/genesis.json \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,ADMIN,DEBUG,MINER,TXPOOL \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8545 \
  --rpc-http-cors-origins="*" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,WEB3,ADMIN,DEBUG,MINER,TXPOOL \
  --rpc-ws-host=127.0.0.1 \
  --rpc-ws-port=8546 \
  --host-allowlist="*" \
  --revert-reason-enabled \
  --miner-enabled \
  --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
  --min-gas-price=0 \
  --network-id=1337
```

**Output Atteso:**
```
2024-12-04 15:00:00.000+01:00 | main | INFO  | Besu | Starting Besu version: besu/v24.12.0/...
2024-12-04 15:00:01.000+01:00 | main | INFO  | Besu | RPC HTTP service started on 127.0.0.1:8545
2024-12-04 15:00:01.000+01:00 | main | INFO  | Besu | RPC WebSocket service started on 127.0.0.1:8546
```

**Nota Importante**: Besu NON auto-mina le transazioni come Ganache. Devi abilitare il mining con `--miner-enabled`.

---

## 📦 Deploy dei Contratti

### 1. Compila i Contratti

```bash
truffle compile
```

### 2. Deploy su Besu

```bash
# Deploy sulla rete Besu
truffle migrate --network besu --reset
```

**Output Atteso:**
```
Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'besu'
> Network id:      1337
> Block gas limit: 268435455 (0xfffffff)


2_deploy_oracolo.js
===================

   Deploying 'BNCalcolatoreOnChain'
   ---------------------------------
   > transaction hash:    0x...
   > Blocks: 0            Seconds: 0
   > contract address:    0x...
   > block number:        1
   > block timestamp:     1733325600
   > account:             0xfe3b557e8fb62b89f4916b721be55ceb828dbd73
   > balance:             99.9...
   > gas used:            6721975
   > gas price:           0 gwei
   > value sent:          0 ETH
   > total cost:          0 ETH

   > Saving artifacts
   -------------------------------------
   > Total cost:                  0 ETH
```

### 3. Copia l'ABI

```bash
# macOS/Linux
cp build/contracts/BNCalcolatoreOnChain.json web-interface/

# Windows
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force
```

---

## 🦊 Configurazione MetaMask

### Aggiungi Rete Besu Locale

1. **Apri MetaMask**
2. **Clicca sul menu delle reti**
3. **"Aggiungi rete manualmente"**
4. **Inserisci:**

| Campo | Valore |
|-------|--------|
| **Nome rete** | `Besu Local` |
| **URL RPC** | `http://127.0.0.1:8545` |
| **Chain ID** | `1337` |
| **Simbolo valuta** | `ETH` |

5. **Salva**

### Importa Account di Test

Gli account sono definiti in `besu-config/accounts.json`:

**Account 1** (Admin/Oracolo/Sensore/Mittente):
```
Address: 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73
Private Key: 0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63
```

**Account 2** (Sensore):
```
Address: 0x627306090abaB3A6e1400e9345bC60c78a8BEf57
Private Key: 0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
```

**Account 3** (Mittente):
```
Address: 0xf17f52151EbEF6C7334FAD080c5704D77216b732
Private Key: 0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f
```

**Account 4** (Corriere):
```
Address: 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef
Private Key: 0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1
```

⚠️ **ATTENZIONE**: Questi account sono pubblici e SOLO per sviluppo locale!

---

## ⚖️ Differenze Rispetto a Ganache

| Caratteristica | Ganache | Besu |
|----------------|---------|------|
| **Porta RPC** | 7545 | 8545 |
| **Auto-mining** | Sì (istantaneo) | Solo con `--miner-enabled` |
| **GUI** | Sì | No (solo CLI) |
| **Account precaricati** | Automatico | Definiti in genesis.json |
| **Gas Price** | 20 Gwei | 0 (configurabile) |
| **Chain ID** | 1337 o 5777 | 1337 (configurabile) |
| **Produzione** | No | Sì |

### Cosa Cambia nel Codice?

**Nulla!** Il codice Solidity e l'interfaccia web rimangono identici. Cambia solo:
- Il comando di deploy: `--network besu` invece di `--network development`
- La porta RPC per MetaMask: `8545` invece di `7545`

---

## 🔍 Troubleshooting

### ❌ "Could not connect to your Ethereum client"

**Causa**: Besu non è in esecuzione o è su una porta diversa.

**Soluzione**:
```bash
# Verifica che Besu sia in esecuzione
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:8545

# Se non risponde, riavvia Besu
./besu-config/start-besu.sh
```

---

### ❌ "Transaction was not mined within 750 seconds"

**Causa**: Il mining non è abilitato.

**Soluzione**:
```bash
# Assicurati che Besu sia avviato con --miner-enabled
# Verifica nel file start-besu.sh che contenga:
--miner-enabled \
--miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73
```

---

### ❌ "Insufficient funds"

**Causa**: L'account non ha ETH.

**Soluzione**:
Gli account sono precaricati con ETH nel file `genesis.json`. Se hai modificato il genesis, elimina la directory `besu-data` e riavvia:
```bash
rm -rf besu-data
./besu-config/start-besu.sh
```

---

### ❌ "Network with different genesis block"

**Causa**: La directory `besu-data` contiene dati di una rete precedente.

**Soluzione**:
```bash
# Elimina i dati e ricomincia
rm -rf besu-data
./besu-config/start-besu.sh
```

---

### ❌ MetaMask non si connette

**Soluzione 1**: Verifica la configurazione
- RPC URL: `http://127.0.0.1:8545` (NON https)
- Chain ID: `1337`

**Soluzione 2**: Reset account MetaMask
- Impostazioni → Avanzate → Reset Account

---

## 🔄 Workflow Completo con Besu

### Setup Iniziale (Una volta)
```bash
# 1. Installa Besu
brew install besu

# 2. Installa dipendenze progetto
npm install
```

### Ciclo di Sviluppo
```bash
# 1. Avvia Besu (in un terminale separato)
./besu-config/start-besu.sh

# 2. Compila i contratti
truffle compile

# 3. Deploy su Besu
truffle migrate --network besu --reset

# 4. Copia ABI
cp build/contracts/BNCalcolatoreOnChain.json web-interface/

# 5. Avvia interfaccia web (in un altro terminale)
cd web-interface
python -m http.server 8000

# 6. Apri browser su http://localhost:8000
```

### Dopo Modifiche ai Contratti
```bash
truffle compile
truffle migrate --network besu --reset
cp build/contracts/BNCalcolatoreOnChain.json web-interface/
# Hard refresh browser (Cmd+Shift+R)
```

---

## 📊 Monitoraggio di Besu

### Log in Tempo Reale

Besu stampa i log nel terminale. Per salvarli in un file:
```bash
./besu-config/start-besu.sh > besu.log 2>&1
```

### Comandi Utili

**Blocco corrente:**
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:8545
```

**Lista account:**
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://127.0.0.1:8545
```

**Balance di un account:**
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xfe3b557e8fb62b89f4916b721be55ceb828dbd73","latest"],"id":1}' http://127.0.0.1:8545
```

---

## 🎯 Vantaggi della Migrazione

1. **Esperienza Enterprise**: Besu è usato in produzione da grandi aziende
2. **Consenso Reale**: Puoi configurare IBFT 2.0 o QBFT per multi-nodo
3. **Privacy**: Supporto per transazioni private (importante per farmaceutica)
4. **Permissioning**: Controllo degli accessi a livello di rete
5. **Compatibilità**: Stesso client usato in molte blockchain enterprise

---

## 📚 Riferimenti

- [Documentazione Besu](https://besu.hyperledger.org/)
- [Besu GitHub](https://github.com/hyperledger/besu)
- [Truffle con Besu](https://trufflesuite.com/docs/truffle/how-to/migrate-to-hardhat/)

---

**Versione**: 1.0  
**Data**: 4 Dicembre 2024  
**Autore**: Luigi Greco
