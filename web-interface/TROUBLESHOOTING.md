# 🔧 Guida Risoluzione Problemi MetaMask

## Problema: MetaMask si connette e poi si disconnette subito

### Causa Principale
Questo problema si verifica quando:
1. MetaMask non è configurato per connettersi alla rete Ganache locale
2. Il contratto non è deployato sulla rete corrente
3. Ci sono problemi di CORS o permessi

### ✅ Soluzione Completa

#### Passo 1: Configura MetaMask per Ganache

1. **Apri MetaMask** e clicca sull'icona della rete in alto
2. **Clicca su "Aggiungi Rete"** → "Aggiungi una rete manualmente"
3. **Inserisci i seguenti parametri**:
   ```
   Nome della rete: Ganache Local
   Nuovo URL RPC: http://127.0.0.1:7545
   ID catena: 1337
   Simbolo della valuta: ETH
   URL Block Explorer: (lascia vuoto)
   ```
4. **Clicca "Salva"**

> **Nota**: Se Ganache usa un Chain ID diverso (es. 5777), usa quello invece di 1337.

#### Passo 2: Importa un Account Ganache in MetaMask

1. **Apri Ganache** e copia la chiave privata di un account (clicca sull'icona della chiave)
2. **In MetaMask**, clicca sull'icona dell'account → "Importa account"
3. **Incolla la chiave privata** e clicca "Importa"

Ora hai un account con ETH di test!

#### Passo 3: Verifica che il Contratto sia Deployato

1. **Apri il terminale** nella directory del progetto
2. **Esegui**:
   ```bash
   truffle migrate --reset
   ```
3. **Verifica** che l'output mostri il deploy del contratto `BNCalcolatoreOnChain`

#### Passo 4: Ricarica la Pagina

1. **Ricarica la pagina** dell'interfaccia web (F5)
2. **Clicca "Connect Wallet"**
3. **Autorizza** la connessione in MetaMask

### 🐛 Debugging

#### Controlla la Console del Browser

Premi **F12** per aprire la console e cerca:

**✅ Messaggi di Successo:**
```
MetaMask rilevato
Account connesso: 0x...
Caricamento contratto...
Network ID: 1337
Contratto caricato: 0x...
```

**❌ Errori Comuni:**

1. **"Contratto non deployato sulla rete X"**
   - **Soluzione**: Esegui `truffle migrate --reset`
   - Verifica che il Chain ID in MetaMask corrisponda a quello di Ganache

2. **"Failed to fetch"**
   - **Soluzione**: Il file JSON del contratto non è accessibile
   - Verifica di usare un server HTTP locale (non `file://`)

3. **"User rejected the request"**
   - **Soluzione**: Hai rifiutato la connessione in MetaMask
   - Clicca di nuovo su "Connect Wallet" e accetta

#### Verifica Chain ID di Ganache

1. **Apri Ganache**
2. **Vai su Settings** → **Server**
3. **Controlla "NETWORK ID"** (di solito 5777 o 1337)
4. **Usa questo valore** in MetaMask

### 🔄 Reset Completo

Se nulla funziona, prova un reset completo:

1. **In MetaMask**:
   - Vai su Impostazioni → Avanzate
   - Clicca "Reset Account" (questo cancella la cronologia delle transazioni)

2. **Riavvia Ganache**:
   - Chiudi e riapri Ganache
   - Oppure clicca sull'icona del cestino per resettare

3. **Redeploy il contratto**:
   ```bash
   truffle migrate --reset
   ```

4. **Ricarica la pagina** e riconnetti

### 📝 Checklist Rapida

Prima di usare l'interfaccia, verifica:

- [ ] Ganache è in esecuzione su `http://127.0.0.1:7545`
- [ ] MetaMask è configurato con la rete Ganache (Chain ID corretto)
- [ ] Hai importato un account Ganache in MetaMask
- [ ] Il contratto è deployato (`truffle migrate --reset`)
- [ ] Stai usando un server HTTP locale (non `file://`)
- [ ] La console del browser non mostra errori

### 🎯 Test Rapido

Per verificare che tutto funzioni:

1. **Apri la console del browser** (F12)
2. **Digita**:
   ```javascript
   web3.eth.net.getId().then(console.log)
   ```
3. **Dovresti vedere** il Chain ID di Ganache (es. 1337 o 5777)

Se vedi un errore, MetaMask non è connesso correttamente.

### 💡 Suggerimenti

- **Usa sempre lo stesso Chain ID** in Ganache e MetaMask
- **Non cambiare rete** in MetaMask mentre usi l'interfaccia
- **Controlla sempre la console** per messaggi di errore dettagliati
- **Se modifichi il contratto**, esegui sempre `truffle migrate --reset`

### 📞 Ancora Problemi?

Se continui ad avere problemi:

1. **Controlla i log** nella console del browser
2. **Verifica** che Ganache mostri le transazioni
3. **Prova** a usare l'interfaccia senza MetaMask (si connetterà direttamente a Ganache)
4. **Apri un issue** su GitHub con i log della console
