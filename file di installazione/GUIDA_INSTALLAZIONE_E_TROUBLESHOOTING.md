# 📦 Guida Completa: Installazione e Risoluzione Problemi

**Sistema Oracolo Bayesiano per Catena del Freddo Farmaceutica**

---

## 📋 Indice

1. [Prerequisiti](#prerequisiti)
2. [Installazione Iniziale](#installazione-iniziale)
3. [Configurazione Ganache](#configurazione-ganache)
4. [Configurazione MetaMask](#configurazione-metamask)
5. [Deploy del Contratto](#deploy-del-contratto)
6. [Avvio dell'Interfaccia Web](#avvio-dellinterfaccia-web)
7. [Procedura Dopo git pull](#procedura-dopo-git-pull)
8. [Risoluzione Problemi](#risoluzione-problemi)
9. [Checklist di Verifica](#checklist-di-verifica)

---

## 🔧 Prerequisiti

### Software Richiesto

| Software | Versione Minima | Download |
|----------|----------------|----------|
| **Node.js** | v14.0.0+ | [nodejs.org](https://nodejs.org/) |
| **npm** | v6.0.0+ | Incluso con Node.js |
| **Ganache** | v7.0.0+ | [trufflesuite.com/ganache](https://trufflesuite.com/ganache) |
| **MetaMask** | Latest | [metamask.io](https://metamask.io/) |
| **Git** | v2.0.0+ | [git-scm.com](https://git-scm.com/) |

### Verifica Installazione

```bash
node --version    # Deve mostrare v14.0.0 o superiore
npm --version     # Deve mostrare v6.0.0 o superiore
git --version     # Deve mostrare v2.0.0 o superiore
```

> **Nota Importante**: Ogni membro del team deve eseguire l'installazione sulla propria macchina. Ganache è una blockchain **locale** - il contratto deployato esiste solo sulla tua istanza!

---

## 📥 Installazione Iniziale

### 1. Clone del Repository

```bash
git clone https://github.com/lucabelard/ProgettoSoftwareSecurity.git
cd ProgettoSoftwareSecurity
```

### 2. Installazione Dipendenze

```bash
npm install
```

**Output atteso:**
```
added 234 packages in 15s
```

Questo installerà:
- Truffle Framework
- OpenZeppelin Contracts
- Web3.js
- Altre dipendenze necessarie

---

## ⚙️ Configurazione Ganache

### 1. Avvio di Ganache

1. Apri **Ganache**
2. Clicca su **"New Workspace"** o **"Quickstart"**
3. Verifica le impostazioni:
   - **Port**: `7545`
   - **Network ID**: `1337` o `5777`
   - **Accounts**: Almeno 10 account con 100 ETH ciascuno

> **Importante**: Lascia Ganache in esecuzione durante tutto il lavoro con il sistema!

### 2. Verifica Ganache

Dovresti vedere:
- 10 account con indirizzi Ethereum
- Ogni account ha ~100 ETH
- La porta è 7545
- Il server RPC è attivo

---

## 🦊 Configurazione MetaMask

### 1. Aggiungi Rete Ganache Locale

1. Apri MetaMask
2. Clicca sul menu delle reti (in alto)
3. Seleziona **"Aggiungi rete"** → **"Aggiungi rete manualmente"**
4. Inserisci i seguenti dati:

   | Campo | Valore |
   |-------|--------|
   | **Nome rete** | `Ganache Local` |
   | **URL RPC** | `http://127.0.0.1:7545` |
   | **Chain ID** | `1337` |
   | **Simbolo valuta** | `ETH` |

5. Clicca **"Salva"**
6. Seleziona la rete **"Ganache Local"**

### 2. Importa Account di Test

1. In Ganache, clicca sull'icona della **chiave** 🔑 accanto al primo account
2. Copia la **Private Key**
3. In MetaMask:
   - Clicca sull'icona dell'account (in alto a sinistra)
   - Seleziona **"Add Wallet"** e poi **"Import an account"**
   - Incolla la chiave privata
   - Clicca **"Importa"**

> **Suggerimento**: Importa almeno 3 account per testare i diversi ruoli (Admin, Mittente, Corriere)

### 3. Verifica Configurazione

- In MetaMask dovresti vedere la rete "Ganache Local" selezionata
- L'account importato dovrebbe mostrare ~100 ETH

---

## 🚀 Deploy del Contratto

### 1. Compila i Contratti

```bash
truffle compile
```

**Output atteso:**
```
Compiling your contracts...
===========================
> Compiling .\contracts\BNCalcolatoreOnChain.sol
> Artifacts written to .\build\contracts
> Compiled successfully using:
   - solc: 0.8.19+commit.7dd6d404.Emscripten.clang
```

### 2. Deploy sulla Blockchain Locale

```bash
truffle migrate --reset
```

**Output atteso:**
```
Deploying BNCalcolatoreOnChain...
----------------------------------------------------
Contratto deployato a: 0x...
Ruolo SENSORE assegnato a: 0x...
Ruolo MITTENTE assegnato a: 0x...
Probabilità a priori impostate (P(F1)=90, P(F2)=90)
Setup delle CPT per E1-E5 completato.
----------------------------------------------------
```

> **Importante**: Annota l'indirizzo del contratto deployato!

### 3. Copia l'ABI nell'Interfaccia Web

**QUESTO PASSO È FONDAMENTALE!**

```bash
# Windows PowerShell
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\BNCalcolatoreOnChain.json" -Force

# Linux/Mac
cp build/contracts/BNCalcolatoreOnChain.json web-interface/BNCalcolatoreOnChain.json
```

**Verifica che il file sia stato copiato:**

```bash
# Windows PowerShell
Test-Path "web-interface\BNCalcolatoreOnChain.json"
# Deve dire: True

# Linux/Mac
ls -l web-interface/BNCalcolatoreOnChain.json
# Deve mostrare il file
```

---

## 🌐 Avvio dell'Interfaccia Web

Scegli una delle seguenti opzioni:

### Opzione 1: Server HTTP Semplice (Python)

```bash
cd web-interface
python -m http.server 8000
```

Apri il browser: [http://localhost:8000](http://localhost:8000)

### Opzione 2: Live Server (VS Code)

1. Installa l'estensione **"Live Server"** in VS Code
2. Apri `web-interface/index.html`
3. Click destro → **"Open with Live Server"**

### Opzione 3: Node.js http-server

```bash
npx http-server web-interface -p 8000
```

---

## 🔄 Procedura Dopo `git pull`

**OGNI VOLTA** che qualcuno fa push di modifiche e tu fai `git pull`, devi seguire questa procedura:

### 1. Compila i Contratti

```bash
truffle compile
```

### 2. Deploy con Reset

```bash
truffle migrate --reset
```

> **Perché `--reset`?** Questo flag forza il re-deploy del contratto anche se è già stato deployato, assicurando che tu abbia l'ultima versione.

### 3. Copia il File JSON Aggiornato

```bash
# Windows PowerShell
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\BNCalcolatoreOnChain.json" -Force

# Linux/Mac
cp build/contracts/BNCalcolatoreOnChain.json web-interface/BNCalcolatoreOnChain.json
```

### 4. Elimina il Backup (se esiste)

```bash
# Windows PowerShell
Remove-Item "web-interface\BNCalcolatoreOnChain.json.backup" -ErrorAction SilentlyContinue

# Linux/Mac
rm -f web-interface/BNCalcolatoreOnChain.json.backup
```

> **Nota**: I file di backup possono causare problemi di caricamento nell'interfaccia web.

### 5. Ricarica la Pagina Web

Ricarica la pagina con **hard refresh**:
- **Windows/Linux**: `Ctrl + Shift + R`
- **Mac**: `Cmd + Shift + R`

---

## 🔍 Risoluzione Problemi

### ❌ Problema: "Contract not deployed on network 1337"

**Causa:** Il contratto non è stato deployato sulla tua istanza di Ganache.

**Soluzione:**
```bash
truffle migrate --reset
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\BNCalcolatoreOnChain.json" -Force
```
Ricarica la pagina con `Ctrl+Shift+R`

---

### ❌ Problema: "Cannot read property 'methods' of undefined"

**Causa:** Il file `BNCalcolatoreOnChain.json` non è stato copiato nell'interfaccia web.

**Soluzione:**
```bash
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\BNCalcolatoreOnChain.json" -Force
```

**Verifica:**
1. Apri il browser (F12)
2. Vai alla tab "Network"
3. Ricarica la pagina
4. Cerca `BNCalcolatoreOnChain.json`
5. Deve essere **200 OK** (non 404)

---

### ❌ Problema: "Returned error: Internal JSON-RPC error"

**Possibili cause e soluzioni:**

1. **Account non ha il ruolo necessario**
   - Soluzione: Usa `accounts[0]` (ha tutti i ruoli per testing)

2. **Spedizione già pagata**
   - Soluzione: Verifica lo stato della spedizione prima di inviare evidenze

3. **Evidenze mancanti**
   - Soluzione: Invia tutte e 5 le evidenze prima di validare

4. **Gas insufficiente**
   - Soluzione: Aumenta il gas limit in MetaMask

**Debug dettagliato:**
1. Apri la console del browser (F12)
2. Cerca errori in rosso
3. L'errore completo fornirà più dettagli

---

### ❌ Problema: MetaMask non si connette

**Soluzione 1: Verifica Ganache**
- Assicurati che Ganache sia in esecuzione
- Verifica che sia sulla porta 7545

**Soluzione 2: Verifica Rete**
- In MetaMask, verifica di essere sulla rete "Ganache Local"
- Verifica che il Chain ID sia 1337

**Soluzione 3: Reset Account**
1. In MetaMask: Impostazioni → Avanzate → Reset Account
2. Questo cancella la cronologia delle transazioni locali
3. Riconnetti il wallet

---

### ❌ Problema: "User rejected the request"

**Causa:** Hai rifiutato la connessione o la transazione in MetaMask.

**Soluzione:**
- Ricarica la pagina
- Clicca di nuovo "Connect Wallet"
- Approva la richiesta in MetaMask

---

### ❌ Problema: "Insufficient funds"

**Causa:** L'account non ha abbastanza ETH per la transazione.

**Soluzione:**
- Usa il primo account di Ganache (ha 100 ETH)
- Oppure importa un altro account con ETH disponibile

---

### ❌ Problema: Transazione fallisce senza errore chiaro

**Debug step-by-step:**

1. **Verifica Console Browser**
   ```
   F12 → Tab "Console" → Cerca errori in rosso
   ```

2. **Verifica Contratto Caricato**
   ```javascript
   // Nella console del browser:
   contract._address
   // Deve mostrare un indirizzo tipo: 0x5FbDB2315678afecb367f032d93F642f64180aa3
   ```

3. **Verifica Contatore Spedizioni**
   ```javascript
   // Nella console del browser:
   contract.methods._contatoreIdSpedizione().call().then(console.log)
   // Deve mostrare un numero (0 se nessuna spedizione creata)
   ```

4. **Verifica Ruoli**
   ```javascript
   // Nella console del browser (sostituisci con il tuo indirizzo):
   contract.methods.hasRole(web3.utils.keccak256("MITTENTE_ROLE"), "0xTUO_INDIRIZZO").call().then(console.log)
   // Deve mostrare: true
   ```

---

### ❌ Problema: "Funziona solo a te" (altri membri del team)

**Causa:** Ogni istanza di Ganache è una blockchain separata e locale!

**Soluzione:** Ogni persona deve:
1. Avere Ganache in esecuzione sulla propria macchina
2. Eseguire `npm install`
3. Eseguire `truffle compile`
4. Eseguire `truffle migrate --reset`
5. Copiare il file JSON: `Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\BNCalcolatoreOnChain.json" -Force`
6. Configurare MetaMask con la propria rete Ganache locale
7. Importare account dalla propria istanza di Ganache

> **Importante**: Non è possibile condividere una blockchain Ganache tra più macchine senza configurazioni avanzate!

---

### ❌ Problema: "npm install fallisce"

**Soluzione 1: Pulisci Cache**
```bash
npm cache clean --force
npm install
```

**Soluzione 2: Elimina node_modules**
```bash
# Windows PowerShell
Remove-Item -Recurse -Force node_modules
npm install

# Linux/Mac
rm -rf node_modules
npm install
```

**Soluzione 3: Verifica Connessione Internet**
- Assicurati di avere una connessione internet stabile
- Alcuni firewall aziendali possono bloccare npm

---

### ❌ Problema: File di backup causano errori

**Sintomo:** L'interfaccia web non carica correttamente il contratto.

**Causa:** Esistono file `.backup` nella cartella `web-interface/`.

**Soluzione:**
```bash
# Windows PowerShell
Remove-Item "web-interface\*.backup" -Force

# Linux/Mac
rm -f web-interface/*.backup
```

---

## ✅ Checklist di Verifica

Prima di chiedere aiuto, verifica che:

- [ ] Ganache è in esecuzione sulla porta 7545
- [ ] `npm install` completato senza errori
- [ ] `truffle compile` completato senza errori
- [ ] `truffle migrate --reset` completato senza errori
- [ ] File `web-interface/BNCalcolatoreOnChain.json` esiste
- [ ] NON esistono file `.backup` in `web-interface/`
- [ ] MetaMask configurato su rete "Ganache Local"
- [ ] Account importato da Ganache in MetaMask
- [ ] Account ha almeno 1 ETH disponibile
- [ ] Server web in esecuzione (porta 8000)
- [ ] Browser aperto su http://localhost:8000
- [ ] Console del browser (F12) non mostra errori rossi critici
- [ ] Rete MetaMask corrisponde a Ganache (Chain ID: 1337)

---

## 🆘 Supporto

Se dopo aver seguito tutti questi passi ancora non funziona:

### 1. Raccogli Informazioni

**Fai screenshot di:**
- Ganache (mostra gli account e la porta)
- Console del browser (F12 → Console)
- Output di `truffle migrate --reset`
- Errore esatto in MetaMask (se presente)

### 2. Condividi

- Quale passo ha dato errore
- L'errore esatto (copia/incolla il testo)
- Sistema operativo (Windows/Mac/Linux)
- Versione Node.js (`node --version`)

### 3. Contatti

- **Repository**: [github.com/lucabelard/ProgettoSoftwareSecurity](https://github.com/lucabelard/ProgettoSoftwareSecurity)
- **Issues**: Apri un issue su GitHub con le informazioni raccolte

---

## 📚 Riferimenti Tecnici

- [Documentazione Truffle](https://trufflesuite.com/docs/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [MetaMask Documentation](https://docs.metamask.io/)
- [Ganache Documentation](https://trufflesuite.com/docs/ganache/)

---

**Versione**: 2.0  
**Data**: 27 Novembre 2024  
**Autore**: Luca Belard
