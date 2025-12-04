# Configurazione Hyperledger Besu

Questa directory contiene i file di configurazione per eseguire Hyperledger Besu come rete di sviluppo locale.

## File

### `genesis.json`
File di configurazione del blocco genesis (blocco iniziale) della blockchain. Definisce:
- **Chain ID**: 1337 (compatibile con Ganache)
- **Account precaricati**: 4 account con ETH per testing
- **Gas Limit**: Molto alto per lo sviluppo
- **EIP attivati**: Tutti gli EIP fino a Cancun per massima compatibilità

### `start-besu.sh`
Script bash per avviare Besu con tutte le configurazioni necessarie:
- RPC HTTP su porta 8545
- WebSocket su porta 8546
- Mining abilitato
- API complete per sviluppo
- CORS aperto (solo per sviluppo locale!)

### `accounts.json`
Lista degli account di test con indirizzi e chiavi private. Questi account sono:
- ⚠️ **PUBBLICI** - Non usare MAI in produzione
- Pre-caricati con ETH nel genesis.json
- Gli stessi usati nei test di Truffle

## Utilizzo Rapido

```bash
# Dalla root del progetto
./besu-config/start-besu.sh
```

## Account di Test

| Numero | Indirizzo | Ruolo |
|--------|-----------|-------|
| 0 | 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 | Admin/Oracolo/Sensore/Mittente |
| 1 | 0x627306090abaB3A6e1400e9345bC60c78a8BEf57 | Sensore |
| 2 | 0xf17f52151EbEF6C7334FAD080c5704D77216b732 | Mittente |
| 3 | 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef | Corriere |

Tutti gli account hanno 100,000,000 ETH pre-caricati.

## Modificare la Configurazione

### Cambiare il Chain ID
Modifica sia `genesis.json` che `start-besu.sh`:
```json
// genesis.json
"chainId": 5777
```
```bash
# start-besu.sh
--network-id=5777
```

### Aggiungere Account
Aggiungi nuovi account nel campo `alloc` di `genesis.json`:
```json
"alloc": {
  "TUO_INDIRIZZO": {
    "balance": "0x200000000000000000000000000000000000000000000000000000000000000"
  }
}
```

### Abilitare Consenso IBFT/QBFT
Per una rete multi-nodo con consenso Byzantine Fault Tolerant, consulta:
https://besu.hyperledger.org/stable/private-networks/tutorials/ibft

## Directory Dati

La directory `../besu-data/` (ignorata da git) contiene:
- Database della blockchain
- Keystore
- Logs
- Cache

Per resettare completamente la blockchain:
```bash
rm -rf besu-data/
./besu-config/start-besu.sh
```

## Porte Utilizzate

| Servizio | Porta |
|----------|-------|
| RPC HTTP | 8545 |
| WebSocket | 8546 |
| P2P (discovery) | 30303 (non usata in single-node) |

## Sicurezza

⚠️ **ATTENZIONE**: Questa configurazione è SOLO per sviluppo locale:
- CORS completamente aperto
- Tutte le API abilitate
- Host allowlist = *
- Gas price = 0
- Account con chiavi pubbliche

**NON utilizzare mai questa configurazione in produzione o su reti pubbliche!**
