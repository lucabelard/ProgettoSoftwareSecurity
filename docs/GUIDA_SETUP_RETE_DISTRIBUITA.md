# 🌐 Guida Setup Rete Besu Distribuita Multi-Nodo

**Data**: 16 Gennaio 2026  
**Versione**: 1.0  
**Configurazione**: 4 Nodi IBFT 2.0 Validator

---

## 📚 Indice

1. [Panoramica Architettura](#panoramica-architettura)
2. [Prerequisiti](#prerequisiti)
3. [Avvio della Rete](#avvio-della-rete)
4. [Verifica Stato Rete](#verifica-stato-rete)
5. [Gestione della Rete](#gestione-della-rete)
6. [Deploy Smart Contracts](#deploy-smart-contracts)
7. [Troubleshooting](#troubleshooting)

---

## 📋 Panoramica Architettura

La rete Besu distribuita implementa un'architettura multi-nodo con consensus IBFT 2.0 (Istanbul Byzantine Fault Tolerant):

```
┌─────────────────────────────────────────────────────┐
│         RETE BESU DISTRIBUITA (4 Nodi)              │
├─────────────────────────────────────────────────────┤
│                                                      │
│   Node 1 (Validator)  ←──P2P──→  Node 2 (Validator) │
│   RPC: 8545 | P2P: 30303      RPC: 8546 | P2P: 30304│
│         ↕                             ↕              │
│   Node 3 (Validator)  ←──P2P──→  Node 4 (Validator) │
│   RPC: 8547 | P2P: 30305      RPC: 8548 | P2P: 30306│
│                                                      │
│   ✅ Distribuzione: P2P mesh completa                │
│   ✅ Ridondanza: Byzantine Tolerance f=1             │
│   ✅ Diversificazione: 4 validator indipendenti     │
│                                                      │
└─────────────────────────────────────────────────────┘
```

**Caratteristiche**:
- **4 Nodi Validator**: Consensus distribuito tra 4 validatori
- **Byzantine Fault Tolerance**: Tolleranza fino a 1 nodo compromesso (f=1)
- **P2P Network**: Mesh network completo (ogni nodo connesso agli altri 3)
- **IBFT 2.0**: Finality immediata, ideale per reti enterprise
- **Localhost Simulation**: Tutti i nodi su localhost (facilmente portabile su server distribuiti)

---

## 🔧 Prerequisiti

### Software Richiesto
- **Hyperledger Besu** ≥ 25.11.0
- **Java** ≥ 17 (OpenJDK o Oracle)
- **curl** e **jq** (per script diagnostici)

### Verifica Installazione
```bash
besu --version  # Dovrebbe mostrare: besu/v25.11.0+
java --version  # Java 17 o superiore
```

---

## 🚀 Avvio della Rete

### Metodo 1: Script Automatico (Raccomandato)

```bash
cd besu-config
./start-network.sh
```

Output atteso:
```
═══════════════════════════════════════════════════
  🚀 AVVIO RETE BESU DISTRIBUITA
═══════════════════════════════════════════════════

Configurazione:
  • 4 Nodi Validator IBFT 2.0
  • Byzantine Fault Tolerance: f=1
  ...

✅ Rete Besu avviata!
```

### Metodo 2: Avvio Manuale Nodi Singoli

```bash
cd besu-config

# Terminal 1 - Node 1 (Bootstrap)
./start-node1.sh

# Terminal 2 - Node 2
./start-node2.sh

# Terminal 3 - Node 3
./start-node3.sh

# Terminal 4 - Node 4
./start-node4.sh
```

---

## 🔍 Verifica Stato Rete

### Script Diagnostico Automatico

```bash
cd besu-config
./check-network.sh
```

**Output esempio (rete operativa)**:
```
📡 CONNETTIVITÀ P2P
───────────────────────────────────────────────────
  ✅ Node 1 (port 8545): 3 peers connessi
  ✅ Node 2 (port 8546): 3 peers connessi
  ✅ Node 3 (port 8547): 3 peers connessi
  ✅ Node 4 (port 8548): 3 peers connessi

📦 SINCRONIZZAZIONE BLOCKCHAIN
───────────────────────────────────────────────────
  📊 Node 1: Blocco #42
  📊 Node 2: Blocco #42
  📊 Node 3: Blocco #42
  📊 Node 4: Blocco #42

🔐 CONSENSO IBFT 2.0
───────────────────────────────────────────────────
  ✅ Consenso raggiunto: Tutti i nodi al blocco #42

✅ STATO RETE: OPERATIVA
```

### Verifica Manuale con curl

```bash
# Check peer count Node 1
curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
  http://localhost:8545 | jq

# Check block number Node 1
curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq
```

---

## ⚙️ Gestione della Rete

### Fermare la Rete

```bash
cd besu-config
./stop-network.sh
```

### Reset Completo (Elimina Blockchain)

```bash
cd besu-config
./reset-network.sh

# Conferma eliminazione (y)
# Riavvia rete pulita
./start-network.sh
```

### Monitoraggio Log Real-Time

```bash
# Log di tutti i nodi
cd besu-config
tail -f node*/besu.log

# Log singolo nodo
tail -f besu-config/node1/besu.log
```

---

## 📦 Deploy Smart Contracts

### Configurazione Truffle

Il file `truffle-config.js` è già configurato per la rete distribuita:

```javascript
besu: {
  provider: () => new HDWalletProvider({
    privateKeys: besuPrivateKeys,
    providerOrUrl: "http://127.0.0.1:8545", // Node 1
    ...
  }),
  network_id: "2024",
  gas: 8000000,
  gasPrice: 0
}
```

### Deploy Contratti

```bash
# Assicurati che la rete sia avviata
cd besu-config && ./check-network.sh

# Deploy
cd ..
truffle migrate --network besu

# Output atteso:
# Deploying 'BNCalcolatoreOnChain'
# > transaction hash:    0x...
# > contract address:    0x...
# ✅ Deployed successfully
```

### Verifica Contratto Replicato

```bash
# Il contratto deve essere visibile su TUTTI i nodi
CONTRACT_ADDR="0x..."  # Indirizzo dal deploy

for port in 8545 8546 8547 8548; do
  echo "Node port $port:"
  curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$CONTRACT_ADDR\",\"latest\"],\"id\":1}" \
    http://localhost:$port | jq -r '.result'
done

# Tutti devono restituire lo stesso bytecode (non "0x")
```

---

## 🧪 Test Ridondanza e Byzantine Tolerance

### Test 1: Failure di 1 Nodo

```bash
# La rete dovrebbe continuare a funzionare con 3/4 nodi

# Ferma Node 4
pkill -f "besu.*node4"

# Attendi 10 secondi
sleep 10

# Verifica che la rete continui
curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq

# ✅ La rete DEVE continuare a produrre blocchi

# Riavvia Node 4
cd besu-config && ./start-node4.sh
```

### Test 2: Failure di 2 Nodi (Limite Byzantine)

```bash
# Ferma Node 3 e Node 4
pkill -f "besu.*node3"
pkill -f "besu.*node4"

# ⚠️ La rete SI FERMA (solo 2/4 nodi, sotto soglia BFT)
# IBFT 2.0 richiede almeno (2f+1) = 3 nodi per f=1

# Riavvia nodi
cd besu-config && ./start-node3.sh && ./start-node4.sh
```

---

## 🐛 Troubleshooting

### Problema: Nodi non si connettono

**Sintomo**: `check-network.sh` mostra 0 peers connessi

**Diagnosi**:
```bash
# Verifica che tutti i nodi siano in esecuzione
ps aux | grep besu | grep -v grep

# Controlla log per errori P2P
grep -i "error\|failed" besu-config/node*/besu.log
```

**Soluzioni**:
1. **Porte occupate**: Verifica che 8545-8548 e 30303-30306 siano libere
   ```bash
   lsof -i :8545-8548
   lsof -i :30303-30306
   ```

2. **Firewall**: Assicurati che il firewall permetta connessioni localhost

3. **Bootnodes errati**: Verifica che node2-4 puntino al bootnode corretto
   ```bash
   grep "bootnodes" besu-config/start-node*.sh
   ```

### Problema: Consensus non raggiunto

**Sintomo**: Blocchi diversi su nodi diversi

**Diagnosi**:
```bash
# Check block su tutti i nodi
for port in 8545 8546 8547 8548; do
  curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:$port | jq -r '.result'
done
```

**Soluzioni**:
1. **Reset completo**:
   ```bash
   cd besu-config
   ./stop-network.sh
   ./reset-network.sh
   ./start-network.sh
   ```

2. **Verifica validatori nel genesis**: Gli indirizzi nel genesis devono corrispondere alle chiavi

### Problema: "Port already in use"

**Errore**: `Port(s) '[30303]' already in use`

**Soluzione**:
```bash
# Ferma tutti i processi Besu
pkill -9 besu

# Aspetta 2 secondi
sleep 2

# Riavvia
cd besu-config && ./start-network.sh
```

---

## 📊 Metriche e Monitoraggio

### Metriche Prometheus (Opzionale)

Besu espone metriche Prometheus sulla porta 9545 (non abilitata di default).

Per abilitare, aggiungi a `start-node*.sh`:
```bash
--metrics-enabled \
--metrics-host=0.0.0.0 \
--metrics-port=9545
```

Endpoint: `http://localhost:9545/metrics`

---

## 🔐 Sicurezza in Produzione

⚠️ **IMPORTANTE**: La configurazione attuale è per **SVILUPPO/TESTING**

Per produzione:
1. **Permissioned Network**: Abilita node permissioning
   ```bash
   --permissions-nodes-config-file-enabled=true
   --permissions-nodes-config-file=permissions-config.toml
   ```

2. **HTTPS/TLS**: Abilita TLS per RPC
3. **Chiavi Sicure**: Non usare le chiavi di test
4. **Firewall**: Limita accesso RPC e P2P ports
5. **Server Distribuiti**: Deploy nodi su macchine separate

---

## ✅ Checklist Pre-Deploy Produzione

- [ ] Nodi su server fisicamente separati
- [ ] TLS abilitato per RPC
- [ ] Node permissioning configurato
- [ ] Backup chiavi validator
- [ ] Monitoring (Prometheus + Grafana) configurato
- [ ] Alerting configurato
- [ ] Firewall configurato
- [ ] Documentazione disaster recovery

---

**Supporto**: Per problemi, consulta i log in `besu-config/node*/besu.log`  
**Documentazione Ufficiale**: https://besu.hyperledger.org/
