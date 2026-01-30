# 🔄 Istruzioni per Riavviare la Rete con Nuovo Chain ID

## ⚠️ IMPORTANTE
Ho modificato il Chain ID della rete Besu da **1337** a **2024** per farlo combaciare con MetaMask.

## 📋 Passi da Seguire

### 1️⃣ Ferma la Rete Besu Corrente
```powershell
# Premi CTRL+C nel terminale dove sta girando avvia-rete-besu.bat
# Oppure chiudi il terminale
```

### 2️⃣ Elimina i Dati Vecchi della Blockchain
```powershell
# Nella directory del progetto
Remove-Item -Path ".\besu-data" -Recurse -Force
```

### 3️⃣ Riavvia la Rete Besu
```powershell
.\avvia-rete-besu.bat
```

Aspetta che compaia:
```
Besu avviato! 
RPC disponibile su http://127.0.0.1:8545
Chain ID: 2024
```

### 4️⃣ Re-Deploy dei Contratti
Apri un **NUOVO** terminale PowerShell e:

```powershell
cd C:\Users\lucab\OneDrive\Desktop\ProgettoSoftwareSecurity
npx truffle migrate --reset
```

### 5️⃣ Aggiorna il File del Contratto nell'Interfaccia Web
```powershell
Copy-Item ".\build\contracts\BNCalcolatoreOnChain.json" -Destination ".\web-interface\" -Force
```

### 6️⃣ Ricarica la Pagina Web
- Vai su http://127.0.0.1:8080
- Premi **CTRL+F5** per ricaricare completamente
- Riconnetti il wallet

## ✅ Verifica

Dopo questi passaggi, MetaMask dovrebbe mostrare:
- **Chain ID: 2024** ✅
- **Bilancio: ~5,000,000 ETH** (bilancio iniziale dal genesis)
- **Niente più "0 ETH"** ✅
- **Niente più token strani** ✅

## 🆘 Se Hai Problemi

Se MetaMask continua a mostrare 0 ETH dopo questi passaggi:
1. **Disconnetti** il wallet dall'applicazione
2. In MetaMask, vai su **Impostazioni → Avanzate → Cancella dati attività**
3. **Riconnetti** il wallet
