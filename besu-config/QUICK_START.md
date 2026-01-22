# 🚀 Quick Start Guide - Besu Network

## Windows - Avvio Rapido

```powershell
cd besu-config
.\scripts\windows\start-network.ps1
```

Aspetta circa 20 secondi, poi verifica che tutto funzioni:

```powershell
.\scripts\windows\check-network.ps1
```

Per fermare la rete:

```powershell
.\scripts\windows\stop-network.ps1
```

## Mac/Linux - Avvio Rapido

```bash
cd besu-config
chmod +x scripts/mac/*.sh  # Solo la prima volta
./scripts/mac/start-network.sh
```

Aspetta circa 20 secondi, poi verifica che tutto funzioni:

```bash
./scripts/mac/check-network.sh
```

Per fermare la rete:

```bash
./scripts/mac/stop-network.sh
```

## Troubleshooting Veloce

### "Besu non trovato"
Assicurati che Besu sia installato e nel PATH:
```bash
besu --version
```

### "I nodi non si connettono"
1. Verifica che le porte 30303-30306 siano libere
2. Assicurati che Node 1 sia avviato completamente prima degli altri
3. Controlla i log

### "Execution policy error" (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Permission denied" (Mac/Linux)
```bash
chmod +x scripts/mac/*.sh
```

## Endpoints RPC

- Node 1: http://127.0.0.1:8545
- Node 2: http://127.0.0.1:8546
- Node 3: http://127.0.0.1:8547
- Node 4: http://127.0.0.1:8548

## Test Veloce

```bash
# Verifica che un nodo risponda
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  -H "Content-Type: application/json" http://127.0.0.1:8545
```

PowerShell:
```powershell
Invoke-WebRequest -Uri http://127.0.0.1:8545 -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

Per maggiori dettagli, vedi: **scripts/README.md**
