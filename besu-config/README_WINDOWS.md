# 🚀 Besu Setup - Windows (Automatico)

Configurazione automatizzata per avviare una rete Besu privata IBFT 2.0 con 4 nodi su Windows.

## 📋 Requisiti
- **Java 17+** installato
- **Besu** installato e nel PATH (verifica con `besu --version`)
- PowerShell

## ▶️ Avvio Rapido

Fai doppio click su:
`scripts\windows\start-network.bat`

Questo script farà tutto da solo:
1. Pulisce eventuali processi vecchi.
2. Avvia i 4 nodi in finestre separate.
3. Esegue automaticamente uno script di "pairing" che connette i nodi tra loro.

## 🔍 Verifica

Per controllare che tutto funzioni (peers collegati e blocchi in produzione):

Esegui in PowerShell:
```powershell
.\scripts\windows\check-network.ps1
```

Dovresti vedere:
- **Peers: 3** (per ogni nodo)
- **Block:** Numero crescente (es. 10, 11, 12...)

## 🛑 Stop

Fai doppio click su:
`scripts\windows\stop-network.bat`

## ⚙️ Dettagli Tecnici
- **Node 1** (Port 8545): Bootnode / Validatore
- **Node 2, 3, 4**: Validatori
- La connessione avviene via JSON-RPC API post-avvio (`auto-connect.ps1`), evitando problemi di discovery UDP su reti Windows nattate/locali.

## 📦 Deployment Smart Contracts

Per deployare i contratti sulla rete (dalla root del progetto):

```bash
truffle migrate --network besu
```

**Nota:** La rete usa Gas Price = 0, quindi le transazioni sono gratuite.
I contratti verranno deployati usando le chiavi private pre-configurate in `truffle-config.js`.
