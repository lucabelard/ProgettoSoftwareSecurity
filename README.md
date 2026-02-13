
# 📦 Progetto Software Security - Monitoraggio Blockchain

![Besu](https://img.shields.io/badge/Hyperledger%20Besu-Latest-blue?style=for-the-badge&logo=hyperledger)
![Truffle](https://img.shields.io/badge/Truffle-Suite-orange?style=for-the-badge&logo=truffle)
![Node.js](https://img.shields.io/badge/Node.js-v14+-green?style=for-the-badge&logo=node.js)
![MetaMask](https://img.shields.io/badge/MetaMask-Compatible-orange?style=for-the-badge&logo=metamask)

Il presente documento fornisce una guida tecnica completa per l'installazione, la configurazione e l'utilizzo del Sistema di Tracciamento basato su Blockchain. L'architettura comprende una rete Blockchain Besu privata, Smart Contracts dedicati e un'interfaccia Web per l'interazione utente.

---

## 🛠️ Prerequisiti di Sistema

Assicurarsi che le seguenti dipendenze siano installate nell'ambiente di esecuzione:

*   **Node.js** (v14 o superiore)
*   **Java JDK** (v11 o v17 raccomandata per Besu)
*   **Hyperledger Besu v25.11.0** (Binari necessari nel PATH)
    *   [Scarica Besu](https://github.com/hyperledger/besu/releases)
    *   *Nota:* Assicurati che il comando `besu --version` funzioni nel terminale.
*   **MetaMask** (Estensione Browser)

### 📦 Installazione Dipendenze
Eseguire il seguente comando nella root del progetto per installare Truffle (globale) e le dipendenze locali:
```bash
npm install -g truffle
npm install
```

---

## 🚀 1. Inizializzazione del Sistema

Scegli il tuo sistema operativo e segui le istruzioni dedicate.

### 🪟 Ambiente Windows

> [!TIP]
> **Consigliato:** Eseguire la pulizia preventiva per evitare conflitti o errori di _Genesis Mismatch_.

**1. Pulizia Preventiva**
```cmd
.\besu-config\scripts\windows\clean-data.bat
```

**2. Avvio Rete Blockchain**
Questo script avvia il cluster di 4 nodi e il proxy di failover in finestre separate.
```cmd
.\besu-config\scripts\windows\start-all-nodes-failover.bat
```
*   **Verifica:** Assicurarsi che le istanze dei nodi siano attive e che lo stato del Proxy indichi "Monitoring active...".

### 🍎 Ambiente Mac / Linux

**1. Pulizia Preventiva & Permessi**
Rimuove dati di vecchie sessioni e processi appesi.
```bash
chmod +x ./besu-config/scripts/mac/*.sh
./besu-config/scripts/mac/clean-data.sh
```

**2. Avvio Rete Blockchain**
Avvia il cluster e il proxy aprendo automaticamente nuovi terminali per ogni nodo.
```bash
./besu-config/scripts/mac/start-all.sh
```
*   **Verifica:** Controllare che le finestre del terminale (Node 1-4 + Proxy) siano aperte e producano log.

---

## 🦊 Configurazione MetaMask

Configura MetaMask con i seguenti parametri per connetterti alla rete locale.

| Parametro | Valore |
| :--- | :--- |
| **Nome Rete** | Localhost 8545 |
| **RPC URL** | `http://127.0.0.1:8545` |
| **Chain ID (Windows)** | `2024` |
| **Chain ID (Mac)** | `2025` |

> [!NOTE]
> Andare su *Settings > General* e attivare **"Show native token as main balance"** per visualizzare correttamente i fondi.

---

## 📜 2. Deploy degli Smart Contracts

Dopo l'inizializzazione della rete, procedere con il deploy e la configurazione dei contratti.

### 🪟 Windows
```cmd
# Compilazione (Opzionale)
truffle compile

# Deploy e Configurazione Completa
node deploy-complete.js
```

### 🍎 Mac / Linux
```bash
# Compilazione
truffle compile

# Deploy tramite Truffle (Include migrazione e setup)
truffle migrate --network besu
```

> [!IMPORTANT]
> Entrambi i metodi eseguono il deploy, l'assegnazione dei ruoli e la configurazione delle probabilità iniziali.

---

## 👤 3. Account di Test

Per interagire con il sistema, importa i seguenti account pre-finanziati nel tuo wallet MetaMask.

| Ruolo | Indirizzo Pubblico | Chiave Privata (SOLO PER TESTNET) |
| :--- | :--- | :--- |
| **👑 Admin** | `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73` | `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` |
| **📦 Mittente** | `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` |
| **📡 Sensore** | `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` |
| **🚚 Corriere** | `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef` | `0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1` |

---

## 💻 4. Interfaccia Web

Avvia l'interfaccia utente per interagire con il sistema distribuito.

*   **🪟 Windows:** Eseguire `avvia-sito.bat`
*   **🍎 Mac/Linux:** Eseguire `./besu-config/scripts/mac/avvia-sito.sh`

🔗 **URL di Accesso:** `http://127.0.0.1:8080`

---

## 🔄 5. Flussi Operativi (Workflows)

### 👑 Pannello Amministratore
Accesso tramite account **Admin**.
*   **Monitoraggio Spedizioni:** Visualizzazione in tempo reale dello stato.
*   **Circuit Breaker:** Arresto di emergenza (*Ricaricare la pagina dopo la modifica*).
*   **Parametri:** Regolazione soglie e affidabilità.

### ✅ Flusso Standard (Consegna Riuscita)
1.  **Mittente:** Crea la spedizione (Indirizzo Corriere + Importo ETH).
2.  **Sensore:** Inserisce ID Spedizione e invia Conferma/Evidenze (senza anomalie).
3.  **Corriere:** Esegue la Validazione Consegna -> Fondi rilasciati.

### ❌ Scenario di Rimborso (Mancata Consegna)
1.  **Mittente:** Crea la spedizione.
2.  **Sensore:** Modifica i dati ambientali (es. Temp/Umidità fuori soglia) -> Invia Evidenze (Non Conforme).
3.  **Corriere:** Tenta la Validazione -> Transazione Respinta.
    *   *Requisito:* 3 tentativi falliti per attivare il rimborso.
4.  **Mittente:** Richiede il Rimborso -> Fondi restituiti.

---

## ❓ Risoluzione Problemi (Troubleshooting)

| Problema | Soluzione |
| :--- | :--- |
| **Genesis Mismatch** | Inconsistenza dati Blockchain.<br>**Win:** `.\besu-config\scripts\windows\clean-data.bat`<br>**Mac:** `./besu-config/scripts/mac/clean-data.sh`<br>Riavviare la rete dopo la pulizia. |
| **Errore Nonce** | Si verifica dopo il riavvio della rete.<br>**Azione:** MetaMask -> Impostazioni > Avanzate > Cancella dati attività tab. |
| **Contratti Assenti** | Assicurarsi di aver eseguito il deploy (`node deploy-complete.js` o `truffle migrate`) **dopo** l'avvio della rete. |

---
