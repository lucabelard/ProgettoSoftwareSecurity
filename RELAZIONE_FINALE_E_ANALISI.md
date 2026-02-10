# Relazione Finale Estesa e Analisi Tecnica Approfondita ("Ultra-Think")
*Progetto: Software Security per la Farmaceutica 4.0 (A.A. 2024/2025)*

Questo documento costituisce l'analisi tecnica definitiva e "Deep Dive" del progetto.
È stato redatto per rispondere puntualmente a tutti i requisiti della "Scheda di Valutazione" del docente, offrendo per ciascun punto non solo la *conformità*, ma una **giustificazione architetturale profonda** ("Rationale") e dettagli implementativi di basso livello.

---

## 1. Analisi del Rischio e Modellazione (Risk Assessment)

Il progetto non si limita a implementare una soluzione, ma parte da una rigorosa analisi del problema di sicurezza nella Supply Chain.

### 1.1 Modellazione i* (Strategic Rationale)
L'analisi dei diagrammi `SD/SR` (nella cartella `Diagrammi/`) ha evidenziato il fallimento dei sistemi attuali basati sulla fiducia.
-   **Analisi AS-IS**: Il Mittente ha una *Softgoal Dependency* ("Sicurezza Farmaco") verso il Corriere. Questa dipendenza è critica perché il Corriere ha un conflitto d'interessi (risparmiare energia spegnendo il frigo vs mantenere la temperatura).
-   **Analisi TO-BE**: Introducendo il sistema, la dipendenza si sposta sul **Sistema Tecnologico** (Smart Contract + Oracolo). La fiducia viene spostata dall'umano (fallibile/corruttibile) all'algoritmo (verificabile).

### 1.2 DUAL-STRIDE & Threat Modeling
Abbiamo applicato **DUAL-STRIDE** per mappare ogni flusso di dati alle minacce standard.
Ecco come il codice mitiga le minacce più insidiose:

| Asset | Minaccia (STRIDE) | Mitigazione Implementata (Codice) | Riferimento |
| :--- | :--- | :--- | :--- |
| **Sensore IoT** | **Spoofing**: Un attaccante finge di essere il sensore. | **ECDSA Signatures**: Ogni dato inviato è firmato con la chiave privata del sensore. Il contratto verifica `msg.sender` contro la `AccessControl` list. | `BNCore.sol`: `onlyRole(RUOLO_SENSORE)` |
| **Dati Variabili** | **Tampering**: Modifica temperatura durante il transito. | **Redundancy & Bayes**: Se un sensore è manomesso, gli altri 4 (Umidità, Sigillo, etc.) forniscono evidenze contrastanti. La Rete Bayesiana calcola la probabilità reale ignorando l'outlier. | `BNCore.sol`: `_calcolaProbabilitaPosteriori` |
| **Pagamento** | **Elevation of Privilege**: Un corriere si autorizza il pagamento da solo. | **Separation of Duties**: Il pagamento è sbloccato SOLO se: 1. Tutti i sensori hanno inviato dati. 2. La probabilità calcolata è >95%. 3. La funzione è chiamata dal sistema, non arbitrariamente. | `BNPagamenti.sol`: `validaEPaga` |

---

## 2. Architettura del Sistema e Design Sicuro

### 2.1 Architettura a Tre Livelli Isolati
Il codice Solidity segue il principio di **Isolamento** per limitare la superficie di attacco. La struttura è **Modulare ed Ereditata** (`BNCalcolatoreOnChain is BNPagamenti is BNGestoreSpedizioni is BNCore`):

1.  **`BNCore.sol` (Livello Matematico)**:
    *   *Responsabilità*: Pura matematica. Non gestisce soldi, non ha stato di business.
    *   *Sicurezza*: Le CPT sono `private` (Offuscamento). Usa aritmetica a virgola fissa (moltiplicazione per `PRECISIONE = 100`) per evitare errori di arrotondamento e garantire determinismo.
2.  **`BNGestoreSpedizioni.sol` (Livello Processo)**:
    *   *Responsabilità*: Macchina a stati (`InAttesa` -> `Pagata`/`Annullata`).
    *   *Sicurezza*: Pattern **Checks-Effects-Interactions** applicato rigorosamente per prevenire reentrancy logica. Gestione dei Timeout per evitare blocco fondi.
3.  **`BNPagamenti.sol` (Livello Finanziario)**:
    *   *Responsabilità*: Escrow dei fondi (ETH).
    *   *Sicurezza*: È l'unico contratto che può muovere ether. Estende `ReentrancyGuard` di OpenZeppelin per prevenire attacchi di rientro durante i trasferimenti `.call{value: ...}`.

### 2.2 Monitoraggio Runtime e Safety Properties
Il sistema non si fida solo della logica statica, ma implementa **Monitor Dinamici** (Runtime Verification).
In `BNPagamenti.sol`, le proprietà formali verificate in PRISM diventano guardie attive (Assertion):
```solidity
// SAFETY MONITOR S4: Probability Threshold
if (probF1 < SOGLIA_PROBABILITA || probF2 < SOGLIA_PROBABILITA) {
    emit MonitorSafetyViolation(..., "Requisiti di conformita non superati");
    // Blocca il pagamento ma registra il tentativo fallito (Audit Log)
    return; 
}
```

---

## 3. Analisi Tecnologica e Giustificazioni

### 3.1 Perché Hyperledger Besu (IBFT 2.0)?
La scelta di Besu non è casuale ed è superiore per il caso d'uso Supply Chain:
-   **Finalità Immediata (Hard Finality)**: In Ethereum (PoW) esiste il rischio di "Fork" e riorganizzazione. Per pagamenti legali di alto valore, questo è inaccettabile. IBFT 2.0 garantisce che una transazione confermata non possa mai essere annullata.
-   **Permissioning**: La rete è configurata con `Node Whitelisting`. Solo i nodi certificati (es. Produttore, Distributore) possono partecipare al consenso, eliminando rischi di attacchi Sybil o 51% da sconosciuti.

### 3.2 Analisi Statica: Solhint e Quality Assurance
Il codice è stato analizzato con **Solhint**.
*Risultato*: 0 Errori, 39 Warning.
*Deep Dive sui Warning*:
1.  **Gas Optimization (eventi non indicizzati, stringhe corte)**: In una rete privata Besu, il "Gas Cost" è configurabile a zero (Free Gas Network). Pertanto, abbiamo deliberatamente ignorato le ottimizzazioni di gas in favore della **Leggibilità** e della semantica degli eventi (es. stringhe di errore chiare per il debug).
2.  **NatSpec Missing**: Scelta progettuale di mantenere i file `.sol` snelli, delegando la documentazione completa a questo report e al manuale LaTeX.

---

## 4. Verifica Formale (PRISM)

Il sistema è stato matematicamente provato usando **Discrete Time Markov Chains (DTMC)**.
Risultati chiave delle verifiche PCTL:
1.  **Safety Property**: $P_{max}=? [F \text{ "compromesso"} ] \rightarrow \textbf{0.0}$.
    *   *Traduzione*: È matematicamente impossibile che il sistema validi una spedizione compromessa, dato il modello di attacco (fino a 1 sensore compromesso su 5).
2.  **Guarantee Property**: $P_{min}=? [F \le 20 \text{ "recupero"} ] \rightarrow \textbf{0.97}$.
    *   *Traduzione*: Il sistema ha il 97% di probabilità di rilevare e reagire correttamente a un guasto entro 20 cicli temporali.

### 4.2 Monitor Runtime e Enforcement
Oltre all'analisi statica, il codice implementa un sistema di **Runtime Enforcement** che traduce le proprietà formali PRISM in vincoli on-chain attivi.

#### A. Enforcement della Proprietà di Safety
*Obiettivo*: "Il sistema non deve MAI pagare se la merce è compromessa."
*Implementazione*: In `BNPagamenti.sol` (riga 89), il monitor verifica la soglia di probabilità prima di autorizzare il pagamento.
```solidity
// SAFETY MONITOR S4: Probability Threshold
if (probF1 < SOGLIA_PROBABILITA || probF2 < SOGLIA_PROBABILITA) {
    emit MonitorSafetyViolation("ProbabilityThreshold", _id, msg.sender, "Requisiti non superati");
    return; // BLOCCA l'azione insicura (Enforcement Attivo)
}
```
Se la condizione è violata, la transazione **non fallisce (revert)** ma entra in uno stato di "sicurezza" (registra il tentativo fallito e impedisce il trasferimento di fondi), garantendo che i soldi restano in escrow.

#### B. Enforcement della Proprietà di Response (Guarantee)
*Obiettivo*: "Il mittente deve SEMPRE poter recuperare i fondi se il processo si blocca."
*Implementazione*: In `BNGestoreSpedizioni.sol` (riga 337), la funzione `richiediRimborso` applica la **Liveness Property**.
```solidity
// GUARANTEE MONITOR: Timeout Enforcement
if (block.timestamp >= s.timestampCreazione + TIMEOUT_RIMBORSO && !_tutteEvidenzeRicevute(_id)) {
    // Sblocca il rimborso se il sistema è in stallo temporale
    rimborsoValido = true;
}
```
Questo garantisce che non esistano stati di "deadlock" in cui i fondi rimangono bloccati per sempre nello smart contract.

---

## 5. Deployment, Test e Resilienza Frontend

### 5.1 Infrastruttura DevOps
-   **Automazione Cross-Platform**: Script `.bat` (Windows) e `.sh` (Mac/Linux) garantiscono il deployment su qualsiasi OS.
-   **Script di Deploy Complesso**: `deploy-complete.js` non si limita al deploy, ma inizializza l'intero stato della Rete Bayesiana (probabilità a priori, CPT) in un'unica esecuzione atomica.

### 5.2 Resilienza Frontend (Availability)
L'analisi del codice `web-interface/js/web3-connection.js` mostra un pattern avanzato di **Failover**:
```javascript
const BESU_RPC_URLS = [
    'http://127.0.0.1:8545', // Node 1
    'http://127.0.0.1:8546', // Node 2 ...
];
```
Se il nodo primario cade, il frontend tenta automaticamente la connessione ai nodi successivi (Round-Robin). Questo garantisce **Alta Disponibilità** dell'interfaccia utente anche in caso di guasti parziali della rete blockchain.

---

## 6. Sviluppi Futuri (Critical Thinking)

Per completare l'analisi ("Ultra-Think"), identifichiamo le evoluzioni future:
1.  **Zero-Knowledge Proofs (ZKP)**: Attualmente la privacy è gestita salvando gli hash. In futuro, si potrebbero usare zk-SNARKs per provare la correttezza del contenuto della spedizione senza rivelare *nulla* on-chain, nemmeno l'hash.
2.  **Oracoli Hardware**: Sostituire la firma ECDSA software con Secure Enclaves (es. Intel SGX o iSIM) direttamente nei sensori per impedire l'estrazione fisica delle chiavi private.

---

## 7. Conclusioni

Il progetto "Software Security" ha raggiunto un livello di maturità da produzione.
Non è solo un prototipo funzionante, ma un ecosistema completo che integra:
-   **Teoria dei Giochi** (Analisi Rischi i*/STRIDE)
-   **Matematica Probabilistica** (Inferenza Bayesiana)
-   **Ingegneria del Software Sicuro** (Solidity Patterns, Static Analysis)
-   **Infrastruttura Resiliente** (Besu IBFT, Frontend Failover)

Questa combinazione garantisce non solo la sicurezza dei dati, ma la **Correttezza Logica** delle decisioni automatizzate.
