# 🚀 Progetto Software Security - Blockchain & System Monitor

Benvenuto! Questa guida ti aiuterà ad installare e avviare l'intero sistema (Blockchain Besu, Contratti Intelligenti e Interfaccia Web) sul tuo computer.

## 📋 Prerequisiti

Assicurati di avere installato:
*   **Node.js** (v14 o superiore)
*   **Java JDK** (v11 o v17 raccomandato per Besu)
*   **MetaMask** (Estensione Browser)

### Installazione Iniziale
Apri il terminale nella cartella del progetto ed esegui:
```bash
npm install
```

---

## 🏁 Avvio Sistema (Scegli il tuo OS)

### 🪟 Windows

**1. Avvia la Rete Blockchain**
Esegui lo script che pulisce l'ambiente e lancia i 4 nodi + proxy:
*   **Script:** `.\besu-config\scripts\windows\start-all-nodes-failover.bat`
*   **Attendere:** Aspetta che si aprano le finestre dei nodi e che il Proxy indichi "Monitoring active...".

**2. Configura MetaMask**
*   **Rete:** Localhost 8545
*   **Chain ID:** `2024`
*   **RPC URL:** `http://127.0.0.1:8545`

### 🍎 Mac / Linux

**1. Avvia la Rete Blockchain**
Apri il terminale, dai i permessi di esecuzione (solo la prima volta) e lancia lo script:
```bash
chmod +x ./besu-config/scripts/mac/*.sh
./besu-config/scripts/mac/start-all.sh
```
*   **Attendere:** Si apriranno nuovi terminali per ogni nodo.

**2. Configura MetaMask**
*   **Rete:** Localhost 8545
*   **Chain ID:** `2025`
*   **RPC URL:** `http://127.0.0.1:8545`

---

## 📜 Deploy Smart Contracts (Comune)

Una volta che la blockchain è attiva (verifica che i nodi stiano producendo blocchi), pubblica i contratti:

```bash
# Compila i contratti (opzionale se non modificati)
truffle compile

# Esegui il deploy e la configurazione automatica
node deploy-complete.js
```
*Questo script pubblicherà i contratti, imposterà i ruoli e configurerà le probabilità iniziali.*

---

## 🌐 Avvio Sito Web

Lancia l'interfaccia utente per interagire con il sistema.

*   **Windows:** Doppio click su `avvia-sito.bat`
*   **Mac/Linux:** Esegui `./besu-config/scripts/mac/avvia-sito.sh` (o `./avvia-sito.sh` se presente nella root)

Il sito si aprirà solitamente su: `http://127.0.0.1:8080`

---

## 🛠️ Risoluzione Problemi

| Problema | Soluzione |
| :--- | :--- |
| **Genesis Mismatch** | I dati della blockchain sono corrotti o vecchi.<br>**Win:** `.\besu-config\scripts\windows\clean-data.bat`<br>**Mac:** `./besu-config/scripts/mac/clean-data.sh`<br>Poi riavvia la rete. |
| **MetaMask Error (Nonce)** | Se hai riavviato la rete, MetaMask potrebbe avere un "nonce" vecchio.<br>Vai su **Impostazioni > Avanzate > Cancella dati attività tab** (Reset Account). |
| **Contratti non trovati** | Assicurati di aver eseguito `node deploy-complete.js` *dopo* aver avviato la rete Besu. |

---

