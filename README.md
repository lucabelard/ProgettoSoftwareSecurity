
# 📦 Progetto Software Security - Monitoraggio Blockchain

![Besu](https://img.shields.io/badge/Hyperledger%20Besu-Latest-blue?style=for-the-badge&logo=hyperledger)
![Truffle](https://img.shields.io/badge/Truffle-Suite-orange?style=for-the-badge&logo=truffle)
![Node.js](https://img.shields.io/badge/Node.js-v18+-green?style=for-the-badge&logo=node.js)
![MetaMask](https://img.shields.io/badge/MetaMask-Compatible-orange?style=for-the-badge&logo=metamask)

Il presente documento fornisce una guida tecnica completa per l'installazione, la configurazione e l'utilizzo del Sistema di Tracciamento basato su Blockchain. L'architettura comprende una rete Blockchain Besu privata, Smart Contracts dedicati e un'interfaccia Web per l'interazione utente.

---

### 🛠️ Prerequisiti di sistema

Prima di iniziare, assicurati di avere installato i seguenti componenti. Le versioni sono **vincolanti** per il corretto funzionamento.

| Componente | Versione Richiesta | Note |
| :--- | :--- | :--- |
| **Node.js** | `v18.x` o superiore | gestore runtime JS. |
| **Java JDK** | `v17` (Consigliato) o `v11` | necessario per eseguire Besu. |
| **Hyperledger Besu** | `v25.11.0` | **CRITICO:** versioni differenti possono causare errori di consenso. |
| **MetaMask** | Estensione Browser | wallet per interagire con la blockchain. |

### 📥 0. Download del Progetto
Inizia clonando il repository e posizionandoti nella cartella di lavoro:

```bash
git clone https://github.com/lucabelard/ProgettoSoftwareSecurity.git
cd ProgettoSoftwareSecurity
```

### 📦 1. Installazione automatica dipendenze (JS)
Il file `package.json` è configurato per gestire le dipendenze JavaScript (Truffle, Web3, OpenZeppelin).

1.  Apri il terminale nella cartella del progetto.
2.  Esegui il comando:
    ```bash
    npm install
    ```
    *Questo installerà `truffle` localmente, garantendo che tutti utilizzino la stessa versione.*

---

## ⚙️ 2. Installazione system-level (manuale)

Le dipendenze di sistema (Besu, Java) devono essere configurate manualmente o tramite script, poiché variano in base al Sistema Operativo.

### 🪟 Windows Setup

#### 1. Java JDK
Assicurarsi di avere Java installato. Verifica con `java -version`. Se mancante, scaricare e installare [Java JDK 17](https://www.oracle.com/java/technologies/downloads/#java17).

#### 2. Hyperledger Besu (v25.11.0)
Besu non si installa tramite `npm`. Va scaricato e aggiunto al PATH.

1.  **Download:** Scarica lo zip di Besu v25.11.0 direttamente [qui](https://github.com/hyperledger/besu/releases/download/25.11.0/besu-25.11.0.zip).
2.  **Estrazione:** Estrai il contenuto in una cartella stabile, ad esempio `C:\Besu`.
3.  **Configurazione PATH (Variabili d'Ambiente):**
    *   Premi `Win + R`, digita `sysdm.cpl` e premi Invio.
    *   Vai su **Avanzate** > **Variabili d'ambiente**.
    *   Nella sezione **Variabili di sistema**, trova la variabile `Path` e clicca **Modifica**.
    *   Clicca **Nuovo** e incolla il percorso alla cartella `bin` di Besu (es. `C:\Besu\besu-25.11.0\bin`).
    *   Conferma tutto con OK.
4.  **Verifica:** Apri un **nuovo** terminale (CMD o PowerShell) e digita:
    ```bash
    besu --version
    ```
    *Dovresti vedere l'output confermare la versione 25.11.0.*

### 🍎 Mac / Linux Setup

#### 1. Java JDK
Verifica con `java -version`. Se necessario, installalo tramite Homebrew:
```bash
brew install openjdk@17
```

#### 2. Hyperledger Besu (v25.11.0)
Puoi usare Homebrew (se la versione corrisponde) o l'installazione manuale (consigliata per versioni specifiche).

**Metodo Manuale (Consigliato per v25.11.0):**
1.  Scarica il pacchetto `.tar.gz` direttamente [qui](https://github.com/hyperledger/besu/releases/download/25.11.0/besu-25.11.0.tar.gz).
2.  Estrai l'archivio:
    ```bash
    tar -xvf besu-25.11.0.tar.gz
    sudo mv besu-25.11.0 /usr/local/besu
    ```
3.  Aggiungi al PATH nel tuo `~/.zshrc` o `~/.bash_profile`:
    ```bash
    export PATH=$PATH:/usr/local/besu/bin
    ```
4.  Ricarica la configurazione: `source ~/.zshrc`
5.  Verifica: `besu --version`

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
*   **Verifica:** assicurarsi che le istanze dei nodi siano attive e che lo stato del Proxy indichi "Monitoring active...".

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
*   **Verifica:** controllare che le finestre del terminale (Node 1-4 + Proxy) siano aperte e producano log.

---

## 🦊 Configurazione MetaMask



Per configurare la rete su MetaMask:
1.  Clicca sulle **3 linee** in alto a destra (o sull'icona del profilo).
2.  Vai su **Impostazioni > Reti** (Settings > Networks).
3.  Clicca su **"Aggiungi una rete"** (Add a network) > **"Aggiungi una rete manualmente"**.
4.  Inserisci i seguenti parametri:

| Parametro | Valore |
| :--- | :--- |
| **Nome Rete** | Localhost 8545 |
| **RPC URL** | `http://127.0.0.1:8545` |
| **Chain ID** | `2024` |
| **Simbolo Valuta** | `ETH` |

> [!NOTE]
> Andare su *Settings > General* e attivare **"Show native token as main balance"** per visualizzare correttamente i fondi.

### 👤 Importazione account di test
Per interagire con il sistema, importa i seguenti account pre-finanziati nel tuo wallet MetaMask.

**Procedura di Importazione:**
1.  Clicca sull'icona circolare dell'account (generalmente in alto a sinistra).
2.  Seleziona **"Add wallet"** (o "Add account").
3.  Clicca su **"Importa account"**.
4.  Incolla la **Chiave Privata** (dalla tabella sottostante) e conferma.
5.  Ripeti per tutti gli account che vuoi usare.

| Ruolo | Indirizzo Pubblico | Chiave Privata (SOLO PER TESTNET) |
| :--- | :--- | :--- |
| **👑 Admin** | `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73` | `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` |
| **📦 Mittente** | `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` |
| **📡 Sensore** | `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` |
| **🚚 Corriere** | `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef` | `0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1` |

### ⚠️ Risoluzione problemi macOS (Chain ID)
In alcuni ambienti macOS, potresti riscontrare errori di connessione con Chain ID 2024.
**Soluzione:**
1.  Apri `truffle-config.js` e modifica `network_id` da `2024` a `2025`.
2.  Riavvia la rete Besu.
3.  In MetaMask, usa **Chain ID: 2025**.

## 📜 2. Deploy degli Smart Contracts

Dopo l'inizializzazione della rete, procedere con il deploy e la configurazione dei contratti.

### 🪟 Windows
```cmd
# Compilazione (Obbligatoria al primo avvio)
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



## 💻 3. Interfaccia web

Avvia l'interfaccia utente per interagire con il sistema distribuito.

*   **🪟 Windows:** Eseguire `.\besu-config\scripts\windows\avvia-sito.bat`
*   **🍎 Mac/Linux:** Eseguire `./besu-config/scripts/mac/avvia-sito.sh`

🔗 **URL di Accesso:** `http://127.0.0.1:8080`

![Home Page Filiera Sicura](docs/images/home.png)
<sub> 1) Pagina principale del sistema</sub>

![Pannello Admin - Vista 1](docs/images/vista_admin1.png)

![Pannello Admin - Vista 2](docs/images/vista_admin2.png)
<sub>2) Vista Admin</sub>

![Vista Mittente](docs/images/vista_mittente.png)
<sub>3) Vista Mittente</sub>

![Vista Sensori](docs/images/vista_sensori.png)
<sub>4) Vista Sensori</sub>

![Vista Corriere](docs/images/vista_corriere.png)
<sub>5) Vista Corriere</sub>

---

## 🔄 4. Flussi operativi

### 👑 Pannello amministratore
Accesso tramite account **Admin**.
*   **Monitoraggio Spedizioni:** visualizzazione in tempo reale dello stato.
*   **Circuit Breaker:** arresto di emergenza (*Ricaricare la pagina dopo la modifica*).
*   **Parametri:** regolazione soglie e affidabilità.



### ✅ Flusso standard (Consegna riuscita)
1.  **Mittente:** crea la spedizione (indirizzo corriere + importo ETH).
2.  **Sensore:** inserisce ID spedizione e invia conferma/evidenze (senza anomalie).
3.  **Corriere:** esegue la validazione consegna -> fondi rilasciati.

### ❌ Scenario di rimborso (Mancata consegna)
1.  **Mittente:** crea la spedizione.
2.  **Sensore:** modifica i dati ambientali (es. temp/umidità fuori soglia) -> invia evidenze (non conforme).
3.  **Corriere:** tenta la validazione -> transazione respinta.
    *   *Requisito:* 3 tentativi falliti per attivare il rimborso.
4.  **Mittente:** richiede il rimborso -> fondi restituiti.

---

## ❓ Risoluzione problemi

| Problema | Soluzione |
| :--- | :--- |
| **Genesis Mismatch** | inconsistenza dati Blockchain.<br>**Win:** `.\besu-config\scripts\windows\clean-data.bat`<br>**Mac:** `./besu-config/scripts/mac/clean-data.sh`<br>Riavviare la rete dopo la pulizia. |
| **Errore Nonce** | si verifica dopo il riavvio della rete.<br>**Azione:** MetaMask -> Impostazioni > Avanzate > Cancella dati attività tab. |
| **Contratti assenti** | assicurarsi di aver eseguito il deploy (`node deploy-complete.js` o `truffle migrate`) **dopo** l'avvio della rete. |
| **Interfaccia non aggiornata** | se lo stato del contratto non cambia (es. dopo blocca/sblocca), **aggiornare la pagina** del browser. |

---
