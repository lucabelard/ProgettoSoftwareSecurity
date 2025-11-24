# ⚡ Setup Veloce - Una Sola Riga

Questo documento spiega come configurare il progetto con **un solo comando**.

## 🚀 Per i Tuoi Amici

### Windows (PowerShell)

```powershell
.\setup.ps1
```

### Linux/Mac (Bash)

```bash
chmod +x setup.sh
./setup.sh
```

## ✅ Cosa Fa lo Script

Lo script automatico:
1. ✓ Verifica che Node.js e npm siano installati
2. ✓ Verifica che Ganache sia in esecuzione
3. ✓ Installa le dipendenze npm
4. ✓ Compila i contratti Solidity
5. ✓ Deploya i contratti su Ganache
6. ✓ Copia l'ABI nell'interfaccia web
7. ✓ Mostra l'indirizzo del contratto deployato

## 📋 Prerequisiti

Prima di eseguire lo script, assicurati di avere:

- ✅ **Ganache** in esecuzione sulla porta 7545
- ✅ **Node.js** v14+ installato
- ✅ **Git** per clonare il repository

## 🔧 Setup Manuale (Se lo Script Fallisce)

Se lo script automatico non funziona, esegui questi comandi uno alla volta:

```bash
# 1. Installa dipendenze
npm install

# 2. Compila contratti
npx truffle compile

# 3. Deploy contratti
npx truffle migrate --reset

# 4. Copia ABI (Windows)
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force

# 4. Copia ABI (Linux/Mac)
cp build/contracts/BNCalcolatoreOnChain.json web-interface/

# 5. Avvia interfaccia
cd web-interface
python -m http.server 8000
```

## 🌐 Configurazione MetaMask

Dopo aver eseguito lo script:

1. **Aggiungi Rete Ganache**:
   - Nome: `Ganache Local`
   - RPC URL: `http://127.0.0.1:7545`
   - Chain ID: `1337`
   - Simbolo: `ETH`

2. **Importa Account**:
   - Apri Ganache
   - Copia la chiave privata del primo account (icona 🔑)
   - In MetaMask: Importa Account → Incolla chiave

3. **Apri Browser**:
   - http://localhost:8000

## ❓ Problemi Comuni

### "Ganache non in esecuzione"
- Avvia Ganache prima di eseguire lo script
- Verifica che sia sulla porta 7545

### "npm install fallisce"
- Verifica la connessione internet
- Prova: `npm cache clean --force` poi `npm install`

### "Contract not deployed"
- Esegui di nuovo: `npx truffle migrate --reset`
- Copia di nuovo l'ABI: `Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force`

### "MetaMask non si connette"
- Verifica di essere sulla rete "Ganache Local"
- Resetta l'account in MetaMask (Impostazioni → Avanzate → Reset Account)

## 📞 Supporto

Se hai ancora problemi:
1. Controlla la console del browser (F12)
2. Controlla i log di Ganache
3. Apri un issue su GitHub

---

**Tip**: Esegui lo script ogni volta che fai `git pull` per assicurarti che tutto sia aggiornato!
