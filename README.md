# Progetto Software Security - Monitoraggio Blockchain

Il presente documento fornisce una guida tecnica completa per l'installazione, la configurazione e l'utilizzo del Sistema di Tracciamento basato su Blockchain. L'architettura del sistema comprende una rete Blockchain Besu privata, Smart Contracts dedicati e un'interfaccia Web per l'interazione utente.

## Prerequisiti di Sistema

Assicurarsi che le seguenti dipendenze siano installate nell'ambiente di esecuzione:
*   **Node.js** (v14 o superiore)
*   **Java JDK** (v11 o v17 raccomandata per Besu)
*   **MetaMask** (Estensione Browser)

### Installazione Dipendenze
Eseguire il seguente comando nella root del progetto per installare i pacchetti necessari:
```bash
npm install
```

---

## 1. Inizializzazione del Sistema

### Ambiente Windows

**1. Avvio Rete Blockchain**
Eseguire lo script di inizializzazione per avviare il cluster di 4 nodi e il proxy di failover:
*   **Script:** `.\besu-config\scripts\windows\start-all-nodes-failover.bat`
*   **Verifica:** Assicurarsi che le istanze dei nodi siano attive e che lo stato del Proxy indichi "Monitoring active...".

**2. Configurazione MetaMask**
*   **Nome Rete:** Localhost 8545
*   **RPC URL:** `http://127.0.0.1:8545`
*   **Chain ID:** `2024`
*   **Impostazioni:** Andare su *Settings > General* e attivare **"Show native token as main balance"** per visualizzare correttamente i fondi.

### Ambiente macOS / Linux

**1. Avvio Rete Blockchain**
Concedere i permessi di esecuzione ed eseguire lo script di avvio:
```bash
chmod +x ./besu-config/scripts/mac/*.sh
./besu-config/scripts/mac/start-all.sh
```
*   **Verifica:** Verificare che le istanze terminale per ciascun nodo siano state avviate correttamente.

**2. Configurazione MetaMask**
*   **Nome Rete:** Localhost 8545
*   **RPC URL:** `http://127.0.0.1:8545`
*   **Chain ID:** `2025`
*   **Impostazioni:** Andare su *Settings > General* e attivare **"Show native token as main balance"** per visualizzare correttamente i fondi.

---

## 2. Deploy degli Smart Contracts

Dopo l'inizializzazione della rete, procedere con il deploy e la configurazione dei contratti:

```bash
# Compilazione Contratti (Opzionale)
truffle compile

# Deploy e Configurazione del Sistema
node deploy-complete.js
```
*Questo script automatizza il deploy, l'assegnazione dei ruoli e la configurazione delle probabilità iniziali.*

### Importazione Account MetaMask

Per interagire con il sistema, è necessario importare i seguenti account di test pre-finanziati utilizzando le relative Chiavi Private.

| Ruolo | Indirizzo Pubblico | Chiave Privata (SOLO PER TESTNET) |
| :--- | :--- | :--- |
| **Admin** | `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73` | `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` |
| **Mittente** | `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` |
| **Sensore** | `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` |
| **Corriere** | `0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef` | `0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1` |

---

## 3. Interfaccia Web

Avviare l'interfaccia utente per interagire con il sistema distribuito.

*   **Windows:** Eseguire `avvia-sito.bat`
*   **Mac/Linux:** Eseguire `./besu-config/scripts/mac/avvia-sito.sh`

**URL di Accesso:** `http://127.0.0.1:8080`

---

## 4. Flussi Operativi (Workflows)

### Pannello Amministratore
Accesso tramite account **Admin**.
*   **Monitoraggio Spedizioni:** Visualizzazione in tempo reale dello stato di tutte le spedizioni attive.
*   **Circuit Breaker (Pausa Contratto):** Arresto di emergenza delle operazioni contrattuali. **Nota:** È necessario ricaricare la pagina dopo aver modificato lo stato.
*   **Gestione Parametri:** Regolazione delle soglie delle evidenze e dei parametri di calcolo dell'affidabilità.

### Flusso Standard (Consegna Riuscita)

1.  **Mittente (Creazione):**
    *   Navigare su "Crea Nuova Spedizione".
    *   Inserire **Indirizzo Corriere** e **Importo ETH**.
    *   Confermare la transazione.
2.  **Sensore (Validazione):**
    *   Inserire **ID Spedizione**.
    *   Inviare **Conferma/Evidenze** senza modificare i dati ambientali (simulazione condizioni ottimali).
3.  **Corriere (Completamento):**
    *   Inserire **ID Spedizione**.
    *   Eseguire **Validazione Consegna**.
    *   I fondi vengono rilasciati previa verifica positiva.

### Scenario di Rimborso (Mancata Consegna)

1.  **Mittente:** Creare la spedizione secondo il flusso standard.
2.  **Sensore:**
    *   Inserire **ID Spedizione**.
    *   **Modificare** i dati ambientali (es. Temperatura/Umidità fuori soglia).
    *   Inviare le Evidenze. Il sistema contrassegna la spedizione come non conforme.
3.  **Corriere:**
    *   Tentare la **Validazione Consegna**.
    *   **Esito:** Transazione Respinta/Negata.
    *   **Requisito:** Eseguire **3 tentativi falliti** per attivare la condizione di rimborso.
4.  **Mittente:**
    *   Inserire **ID Spedizione**.
    *   Selezionare **"Richiedi Rimborso"**.
    *   I fondi vengono restituiti al Mittente.

---

## Risoluzione Problemi (Troubleshooting)

| Problema | Soluzione |
| :--- | :--- |
| **Genesis Mismatch** | Inconsistenza dati Blockchain.<br>**Win:** `.\besu-config\scripts\windows\clean-data.bat`<br>**Mac:** `./besu-config/scripts/mac/clean-data.sh`<br>Riavviare la rete dopo la pulizia. |
| **Errore Nonce MetaMask** | Si verifica dopo il riavvio della rete.<br>**Azione:** Impostazioni > Avanzate > Cancella dati attività tab. |
| **Contratti non Trovati** | Assicurarsi che `node deploy-complete.js` sia stato eseguito *dopo* l'inizializzazione della rete. |

---

**Nota di Configurazione:**
*   **Windows Chain ID:** `2024`
*   **Mac Chain ID:** `2025`
