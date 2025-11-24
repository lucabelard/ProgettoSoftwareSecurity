# 🆘 GUIDA TROUBLESHOOTING - Problema "Funziona solo a te"

## 🔴 Problema

L'interfaccia web funziona solo sulla macchina di chi ha fatto il deploy originale, ma non funziona per gli altri membri del team.

## 🎯 Causa

Ogni istanza di Ganache è una blockchain **separata e locale**. Il contratto deployato esiste solo sulla blockchain di chi l'ha deployato, non su quella degli altri!

## ✅ Soluzione Passo-Passo

### **IMPORTANTE: Ogni persona deve fare questi passi sulla PROPRIA macchina!**

### Passo 1: Verifica Ganache

```bash
# Ganache DEVE essere in esecuzione
# Porta: 7545
# Network ID: 1337 o 5777
```

**Screenshot Ganache:**
- Dovresti vedere 10 account con 100 ETH ciascuno
- La porta deve essere 7545

### Passo 2: Pulisci Tutto (Importante!)

```bash
# Vai nella cartella del progetto
cd ProgettoSoftwareSecurity

# Elimina le vecchie build (se esistono)
# Windows PowerShell:
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# Linux/Mac:
rm -rf build
```

### Passo 3: Installa Dipendenze

```bash
npm install
```

**Output atteso:**
```
added 234 packages in 15s
```

### Passo 4: Compila Contratti

```bash
npx truffle compile
```

**Output atteso:**
```
Compiling your contracts...
===========================
> Compiling .\contracts\BNCalcolatoreOnChain.sol
> Artifacts written to .\build\contracts
> Compiled successfully
```

### Passo 5: Deploy Contratti (CRITICO!)

```bash
npx truffle migrate --reset
```

**Output atteso:**
```
Deploying BNCalcolatoreOnChain...
Contratto deployato a: 0x... (indirizzo)
Ruolo SENSORE assegnato a: 0x...
Ruolo MITTENTE assegnato a: 0x...
Probabilità a priori impostate
Setup delle CPT per E1-E5 completato
```

⚠️ **Se vedi errori qui, FERMATI e segnala l'errore!**

### Passo 6: Copia ABI nell'Interfaccia Web

```bash
# Windows PowerShell:
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force

# Linux/Mac:
cp build/contracts/BNCalcolatoreOnChain.json web-interface/
```

**Verifica:**
```bash
# Controlla che il file esista
# Windows:
Test-Path "web-interface\BNCalcolatoreOnChain.json"
# Deve dire: True

# Linux/Mac:
ls -l web-interface/BNCalcolatoreOnChain.json
# Deve mostrare il file
```

### Passo 7: Configura MetaMask

1. **Aggiungi Rete Ganache** (se non l'hai già fatto):
   - Nome: `Ganache Local`
   - RPC URL: `http://127.0.0.1:7545`
   - Chain ID: `1337`
   - Simbolo: `ETH`

2. **Importa Account da Ganache**:
   - Apri Ganache
   - Clicca sull'icona 🔑 del **primo account**
   - Copia la **Private Key**
   - In MetaMask: Menu → Importa Account → Incolla chiave
   - Clicca "Importa"

3. **Seleziona la Rete Ganache**:
   - In MetaMask, clicca sul menu reti
   - Seleziona "Ganache Local"
   - Dovresti vedere ~100 ETH

### Passo 8: Avvia Interfaccia Web

```bash
cd web-interface

# Opzione 1 (Python):
python -m http.server 8000

# Opzione 2 (Node.js):
npx http-server -p 8000
```

### Passo 9: Apri Browser

```
http://localhost:8000
```

### Passo 10: Testa

1. Clicca "Connect Wallet"
2. Approva in MetaMask
3. Dovresti vedere il tuo indirizzo connesso
4. Vai al pannello "Mittente"
5. Prova a creare una spedizione

## 🔍 Debug - Se Ancora Non Funziona

### Controllo 1: Console Browser

1. Apri la console (F12)
2. Vai alla tab "Console"
3. Cerca errori in rosso
4. **Copia e incolla l'errore esatto**

### Controllo 2: Network Tab

1. F12 → Tab "Network"
2. Ricarica la pagina
3. Cerca `BNCalcolatoreOnChain.json`
4. Deve essere **200 OK** (non 404)

### Controllo 3: Verifica Contratto

Nella console del browser, esegui:

```javascript
// Apri console (F12)
// Copia e incolla questo:
contract.methods._contatoreIdSpedizione().call().then(console.log)
```

**Risultato atteso:** `0` (se nessuna spedizione creata)  
**Errore:** Se dice "contract is undefined" → Il contratto non è caricato

### Controllo 4: Verifica Indirizzo Contratto

```javascript
// Nella console del browser:
contract._address
```

**Risultato atteso:** Un indirizzo tipo `0x5FbDB2315678afecb367f032d93F642f64180aa3`

## ❌ Errori Comuni e Soluzioni

### Errore: "Contract not deployed on network 1337"

**Causa:** Il contratto non è stato deployato su Ganache  
**Soluzione:** Esegui `npx truffle migrate --reset`

### Errore: "Cannot read property 'methods' of undefined"

**Causa:** Il file `BNCalcolatoreOnChain.json` non è stato copiato  
**Soluzione:** Esegui il Passo 6 di nuovo

### Errore: "User rejected the request"

**Causa:** Hai rifiutato la connessione in MetaMask  
**Soluzione:** Ricarica la pagina e approva

### Errore: "Insufficient funds"

**Causa:** L'account non ha abbastanza ETH  
**Soluzione:** Usa il primo account di Ganache (ha 100 ETH)

### Errore: "Returned error: Internal JSON-RPC error"

**Causa:** Account non ha il ruolo necessario  
**Soluzione:** Usa `accounts[0]` (ha tutti i ruoli)

## 📞 Supporto

Se dopo aver seguito TUTTI questi passi ancora non funziona:

1. **Fai screenshot** di:
   - Ganache (mostra gli account)
   - Console del browser (F12 → Console)
   - Output di `npx truffle migrate --reset`

2. **Condividi**:
   - Quale passo ha dato errore
   - L'errore esatto (copia/incolla)
   - Sistema operativo (Windows/Mac/Linux)

## ✅ Checklist Finale

Prima di chiedere aiuto, verifica:

- [ ] Ganache è in esecuzione sulla porta 7545
- [ ] `npm install` completato senza errori
- [ ] `npx truffle compile` completato senza errori
- [ ] `npx truffle migrate --reset` completato senza errori
- [ ] File `web-interface/BNCalcolatoreOnChain.json` esiste
- [ ] MetaMask configurato su rete Ganache Local
- [ ] Account importato da Ganache in MetaMask
- [ ] Server web in esecuzione (porta 8000)
- [ ] Browser aperto su http://localhost:8000
- [ ] Console del browser (F12) non mostra errori rossi

---

**Ricorda:** Ogni persona deve fare il deploy sulla PROPRIA blockchain Ganache locale!
