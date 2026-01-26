# Besu Network Scripts

Scripts organizzati per avviare e gestire una rete Besu IBFT 2.0 con 4 nodi validator.

## Struttura

```
besu-config/
├── scripts/
│   ├── windows/          # Script PowerShell per Windows
│   │   ├── start-network.ps1
│   │   ├── stop-network.ps1
│   │   ├── check-network.ps1
│   │   ├── start-node1.ps1
│   │   ├── start-node2.ps1
│   │   ├── start-node3.ps1
│   │   └── start-node4.ps1
│   └── mac/              # Script Bash per Mac/Linux
│       ├── start-network.sh
│       ├── stop-network.sh
│       ├── check-network.sh
│       ├── start-node1.sh
│       ├── start-node2.sh
│       ├── start-node3.sh
│       └── start-node4.sh
├── node1/                # Dati Node 1
├── node2/                # Dati Node 2
├── node3/                # Dati Node 3
├── node4/                # Dati Node 4
└── genesis-ibft.json     # Genesis file IBFT 2.0
```

## Configurazione Rete

- **Consenso**: IBFT 2.0 (Istanbul Byzantine Fault Tolerance)
- **Numero Nodi Validator**: 4
- **Byzantine Fault Tolerance**: f=1 (tollera 1 nodo malfunzionante)
- **Chain ID**: 2024
- **Block Period**: 2 secondi

### Porte dei Nodi

| Nodo   | RPC Port | P2P Port | Ruolo       |
|--------|----------|----------|-------------|
| Node 1 | 8545     | 30303    | Bootstrap   |
| Node 2 | 8546     | 30304    | Validator   |
| Node 3 | 8547     | 30305    | Validator   |
| Node 4 | 8548     | 30306    | Validator   |

## Uso - Windows

### Prerequisiti

1. Besu installato e disponibile nel PATH
2. PowerShell 5.0 o superiore

### Comandi

#### Avviare l'intera rete

```powershell
cd besu-config
.\scripts\windows\start-network.ps1
```

Questo script:
- Ferma eventuali processi Besu esistenti
- Avvia Node 1 (bootstrap) e attende 8 secondi
- Avvia Nodes 2-4 in sequenza
- Mostra i PID di tutti i processi
- Salva i PID in `besu-network-pids.json`

#### Verificare lo stato della rete

```powershell
.\scripts\windows\check-network.ps1
```

Mostra per ogni nodo:
- Versione client
- Numero di peer connessi
- Numero dell'ultimo blocco
- Stato P2P listening
- Processi in esecuzione

#### Fermare la rete

```powershell
.\scripts\windows\stop-network.ps1
```

Arresta tutti i nodi in modo pulito.

#### Avviare un singolo nodo

```powershell
.\scripts\windows\start-node1.ps1  # Node 1
.\scripts\windows\start-node2.ps1  # Node 2
.\scripts\windows\start-node3.ps1  # Node 3
.\scripts\windows\start-node4.ps1  # Node 4
```

**NOTA**: Quando avvii nodi singolarmente, assicurati di avviare Node 1 per primo e aspettare qualche secondo prima di avviare gli altri (Node 1 è il bootstrap node).

## Uso - Mac/Linux

### Prerequisiti

1. Besu installato e disponibile nel PATH
2. Bash shell
3. `curl` installato (per check-network.sh)

### Comandi

#### Avviare l'intera rete

```bash
cd besu-config
chmod +x scripts/mac/*.sh  # Solo la prima volta
./scripts/mac/start-network.sh
```

Questo script:
- Ferma eventuali processi Besu esistenti
- Rende eseguibili gli script dei nodi
- Avvia ogni nodo in background
- Salva i PID in `nodeX/nodeX.pid`
- Redirige i log in `nodeX/nodeX.log`

#### Verificare lo stato della rete

```bash
./scripts/mac/check-network.sh
```

Mostra per ogni nodo:
- Versione client
- Numero di peer connessi
- Numero dell'ultimo blocco
- Stato P2P listening
- Processi in esecuzione con uso RAM e CPU

#### Fermare la rete

```bash
./scripts/mac/stop-network.sh
```

Arresta tutti i nodi in modo pulito usando i PID salvati.

#### Avviare un singolo nodo

```bash
chmod +x scripts/mac/start-node1.sh  # Solo la prima volta
./scripts/mac/start-node1.sh  # Node 1 (bootstrap)

# In un altro terminale
./scripts/mac/start-node2.sh  # Node 2
./scripts/mac/start-node3.sh  # Node 3
./scripts/mac/start-node4.sh  # Node 4
```

**NOTA**: Avvia sempre Node 1 per primo (è il bootstrap node).

#### Visualizzare i log (Mac/Linux)

```bash
tail -f node1/node1.log  # Node 1
tail -f node2/node2.log  # Node 2
tail -f node3/node3.log  # Node 3
tail -f node4/node4.log  # Node 4
```

## Endpoints JSON-RPC

Dopo l'avvio, puoi connetterti ai nodi tramite:

- **Node 1**: `http://127.0.0.1:8545`
- **Node 2**: `http://127.0.0.1:8546`
- **Node 3**: `http://127.0.0.1:8547`
- **Node 4**: `http://127.0.0.1:8548`

### Esempio di test con curl

```bash
# Verifica versione client
curl -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  -H "Content-Type: application/json" http://127.0.0.1:8545

# Verifica numero blocco
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  -H "Content-Type: application/json" http://127.0.0.1:8545

# Verifica peer count
curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
  -H "Content-Type: application/json" http://127.0.0.1:8545
```

## Troubleshooting

### Windows

**Problema**: Gli script PowerShell non si eseguono

**Soluzione**: Abilita l'esecuzione degli script:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problema**: Besu non viene trovato

**Soluzione**: Verifica che Besu sia nel PATH:
```powershell
besu --version
```

### Mac/Linux

**Problema**: Permission denied

**Soluzione**: Rendi eseguibili gli script:
```bash
chmod +x scripts/mac/*.sh
```

**Problema**: Besu non viene trovato

**Soluzione**: Verifica che Besu sia nel PATH:
```bash
besu --version
```

### Problemi comuni a entrambi

**Problema**: I nodi non si connettono tra loro

**Soluzione**: 
1. Verifica che tutte le porte (30303-30306) siano disponibili
2. Assicurati che Node 1 sia avviato per primo e completamente inizializzato
3. Controlla i log per errori di connessione

**Problema**: Porte già in uso

**Soluzione**: Ferma eventuali altri processi Besu o servizi che usano le porte 8545-8548 o 30303-30306

## Note Importanti

1. **Bootstrap Node**: Node 1 è il bootstrap node. Gli altri nodi si connettono ad esso tramite l'enode URL hardcoded negli script.

2. **Enode URL**: L'enode URL del bootstrap node è attualmente hardcoded negli script. Se rigeneri le chiavi del Node 1, dovrai aggiornare l'enode URL in tutti gli script dei nodi 2, 3 e 4.

3. **Ordine di avvio**: Avvia sempre Node 1 per primo e aspetta almeno 5-8 secondi prima di avviare gli altri nodi.

4. **Persistenza dati**: I dati blockchain sono salvati in `nodeX/data/`. Per resettare la rete, elimina queste directory (ma mantieni i file `key`).

5. **Genesis file**: Tutti i nodi devono usare lo stesso `genesis-ibft.json`. Non modificarlo dopo aver avviato la rete.

## Struttura Account

Gli account preconfigurati nel genesis file con balance:

- `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73`
- `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
- `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
- `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef`

Ciascuno con un balance iniziale enorme per testing.
