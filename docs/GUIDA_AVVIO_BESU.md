# 🚀 Guida Avvio Hyperledger BESU + Frontend

Questa guida spiega come avviare l'ambiente blockchain Enterprise con Hyperledger Besu, configurare MetaMask e utilizzare l'applicazione.

## 1. Avvio Blockchain BESU

Per avviare un nodo locale in modalità sviluppo (mining automatico, account pre-caricati):

1. Apri un terminale nella root del progetto.
2. Pulisci eventuali dati vecchi (opzionale, per ripartire da zero):
   ```powershell
   Remove-Item -Recurse -Force .\besu-data -ErrorAction SilentlyContinue
   ```
3. Avvia BESU:
   ```powershell
   besu --network=dev --data-path=./besu-data --rpc-http-enabled --rpc-http-api=ETH,NET,WEB3,MINER,TXPOOL,ADMIN,DEBUG --rpc-http-host=0.0.0.0 --rpc-http-port=8545 --rpc-http-cors-origins="*" --host-allowlist="*" --revert-reason-enabled --miner-enabled --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 --min-gas-price=0
   ```
   *Lascia questo terminale aperto.*

## 2. Configurazione MetaMask

1. Apri MetaMask nel browser.
2. Aggiungi una **nuova rete manualmente**:
   - **Nome Rete**: `BESU Local`
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `1337`
   - **Simbolo**: `ETH`
3. Salva e seleziona la rete.

## 3. Importazione Account

Devi importare gli account specifici di BESU (non usare quelli di Ganache!).
In MetaMask: Clicca icona profilo -> **Importa Account** -> Incolla Chiave Privata.

| Ruolo | Indirizzo | Chiave Privata |
|-------|-----------|----------------|
| **Admin/Oracolo** | `0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73` | `8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` |
| **Sensore*** | `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` |
| **Mittente*** | `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` |
| **Corriere** | `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef` | `0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1` |

*\*Nota: I ruoli indicati nel file di migrazione associano Sensore e Mittente a questi indirizzi specifici.*

## 4. Deploy Smart Contract

In un **nuovo terminale**:

```powershell
npx truffle migrate --network besu --reset
```

Questo comando compilerà i contratti e li caricherà sulla blockchain BESU locale.

## 5. Avvio Frontend

In un **nuovo terminale**:

1. Copia l'ABI aggiornato (se hai ridato il migrate):
   ```powershell
   Copy-Item -Force .\build\contracts\BNCalcolatoreOnChain.json .\web-interface\
   ```
2. Avvia il server web:
   ```powershell
   cd web-interface
   python -m http.server 3000
   ```
3. Apri il browser su: [http://localhost:3000](http://localhost:3000)

## Verifica Funzionamento

Se tutto è corretto:
1. MetaMask si connetterà senza errori.
2. Potrai vedere il balance in ETH degli account importati.
3. Potrai interagire con la dApp (creare spedizioni, inviare evidenze, validare).
4. Le transazioni appariranno nel terminale dove gira BESU.

## 6. Monitoraggio Log (Simil-Ganache)

Poiché BESU non ha un'interfaccia grafica come Ganache per vedere le transazioni in tempo reale, abbiamo creato uno script di monitoraggio dedicato.

In un **nuovo terminale** (lasciando gli altri aperti):

```powershell
node besu-config/monitor-besu.js
```

Questo script:
1. Si connette al nodo BESU locale.
2. Mostra in tempo reale ogni nuova transazione minata.
3. Ti permette di vedere hash, mittente, destinatario e valore, confermando visivamente che le tue azioni sul sito sono state registrate sulla blockchain.
