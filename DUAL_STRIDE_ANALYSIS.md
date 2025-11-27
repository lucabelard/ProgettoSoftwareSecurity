# 🛡️ DUAL-STRIDE Security Analysis
## Sistema Oracolo Bayesiano per Catena del Freddo Farmaceutica

**Versione**: 1.0  
**Data**: 27 Novembre 2024  
**Autore**: Luca Belard

---

## 📋 Indice

1. [Introduzione](#introduzione)
2. [Asset del Sistema](#asset-del-sistema)
3. [Attori e Threat Model](#attori-e-threat-model)
4. [Analisi STRIDE per Asset](#analisi-stride-per-asset)
5. [Abuse/Misuse Cases](#abusemisuse-cases)
6. [Contromisure Implementate](#contromisure-implementate)
7. [Raccomandazioni](#raccomandazioni)

---

## 1. Introduzione

### 1.1 Scopo del Documento

Questo documento presenta un'analisi di sicurezza **DUAL-STRIDE** del Sistema Oracolo Bayesiano, identificando minacce per ogni asset del sistema considerando sia **attaccanti intenzionali** che **utenti maldestri**. L'analisi include riferimenti a **CAPEC** (Common Attack Pattern Enumeration and Classification) e **ATT&CK** (Adversarial Tactics, Techniques, and Common Knowledge).

### 1.2 Metodologia

- **STRIDE**: Framework per identificare minacce (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)
- **DUAL**: Analisi separata per attaccanti intenzionali e utenti maldestri
- **CAPEC/ATT&CK**: Mappatura a pattern di attacco noti

---

## 2. Asset del Sistema

### 2.1 Asset Principali

| ID | Asset | Descrizione | Criticità |
|----|-------|-------------|-----------|
| **A1** | Smart Contract `BNCalcolatoreOnChain` | Contratto Solidity che gestisce logica di business | 🔴 Critica |
| **A2** | Evidenze IoT (E1-E5) | Dati dai sensori IoT | 🔴 Critica |
| **A3** | Pagamenti ETH (Escrow) | Fondi bloccati nel contratto | 🔴 Critica |
| **A4** | Ruoli e Permessi (AccessControl) | Sistema di autorizzazione | 🟠 Alta |
| **A5** | CPT e Probabilità | Parametri della Bayesian Network | 🟠 Alta |
| **A6** | Dati Spedizioni On-Chain | Record delle spedizioni | 🟡 Media |
| **A7** | Interfaccia Web | Frontend per interazione utente | 🟡 Media |
| **A8** | Chiavi Private MetaMask | Credenziali utenti | 🔴 Critica |

### 2.2 Dettaglio Asset

#### A1: Smart Contract

```solidity
contract BNCalcolatoreOnChain is AccessControl {
    // Ruoli
    bytes32 public constant RUOLO_ORACOLO = keccak256("RUOLO_ORACOLO");
    bytes32 public constant RUOLO_SENSORE = keccak256("RUOLO_SENSORE");
    bytes32 public constant RUOLO_MITTENTE = keccak256("RUOLO_MITTENTE");
    
    // Soglia di conformità
    uint8 public constant SOGLIA_PROBABILITA = 95; // 95%
}
```

**Valore**: Contiene tutta la logica di business e i fondi in escrow

#### A2: Evidenze IoT

- **E1**: Temperatura (true = OK, false = fuori range)
- **E2**: Sigillo (true = intatto, false = rotto)
- **E3**: Shock (true = rilevato, false = nessuno)
- **E4**: Luce (true = esposto, false = protetto)
- **E5**: Scan arrivo (true = OK, false = mancante)

**Valore**: Determinano se il pagamento viene eseguito

#### A3: Pagamenti ETH

```solidity
function creaSpedizione(address _corriere) external payable {
    require(msg.value > 0, "Pagamento > 0");
    // ETH bloccato in escrow
}
```

**Valore**: Fondi reali depositati dai mittenti

---

## 3. Attori e Threat Model

### 3.1 Attori Legittimi

| Ruolo | Descrizione | Privilegi |
|-------|-------------|-----------|
| **Admin/Oracolo** | Amministratore del sistema | Imposta CPT e probabilità |
| **Mittente** | Farmacia che spedisce | Crea spedizioni, deposita ETH |
| **Sensore** | Dispositivo IoT | Invia evidenze E1-E5 |
| **Corriere** | Azienda di trasporto | Valida e riceve pagamento |

### 3.2 Attori Malevoli

| Tipo | Descrizione | Motivazione | Capacità |
|------|-------------|-------------|----------|
| **Attaccante Esterno** | Hacker senza accesso iniziale | Furto di ETH, disruption | Analisi codice, exploit smart contract |
| **Insider Malevolo** | Utente con ruolo legittimo | Frode, manipolazione pagamenti | Accesso a chiavi private, ruoli |
| **Corriere Disonesto** | Corriere che vuole pagamento immeritato | Profitto | Controllo trasporto fisico |
| **Mittente Fraudolento** | Mittente che vuole evitare pagamento | Risparmio | Creazione spedizioni |
| **Sensore Compromesso** | Dispositivo IoT hackerato | Manipolazione evidenze | Invio dati falsi |

### 3.3 Utenti Maldestri

| Tipo | Descrizione | Impatto |
|------|-------------|---------|
| **Utente Inesperto** | Non comprende il sistema | Errori operativi |
| **Configurazione Errata** | Parametri sbagliati | Funzionamento scorretto |
| **Perdita Chiavi** | Smarrimento chiavi private | Perdita accesso/fondi |

---

## 4. Analisi STRIDE per Asset

## 4.1 Asset A1: Smart Contract

### 🎭 S - Spoofing (Falsificazione Identità)

#### Minaccia S1.1: Impersonificazione Ruolo Sensore

**Descrizione**: Un attaccante ottiene il ruolo SENSORE e invia evidenze false per manipolare il calcolo bayesiano.

**Attore**: Attaccante Esterno / Insider Malevolo

**Scenario**:
```
1. Attaccante ottiene chiave privata di un account con RUOLO_SENSORE
2. Invia evidenze false: E1=true, E2=true, E3=false, E4=false, E5=true
3. Il contratto calcola P(F1) e P(F2) >= 95%
4. Corriere complice riceve pagamento immeritato
```

**CAPEC**: 
- [CAPEC-151](https://capec.mitre.org/data/definitions/151.html): Identity Spoofing
- [CAPEC-94](https://capec.mitre.org/data/definitions/94.html): Man in the Middle Attack

**ATT&CK**:
- [T1078](https://attack.mitre.org/techniques/T1078/): Valid Accounts
- [T1134](https://attack.mitre.org/techniques/T1134/): Access Token Manipulation

**Impatto**: 🔴 Critico - Pagamento fraudolento

**Contromisura Implementata**:
```solidity
function inviaEvidenza(uint256 _idSpedizione, uint8 _idEvidenza, bool _valore)
    external
    onlyRole(RUOLO_SENSORE) // ✅ Controllo ruolo
{
    // ...
}
```

**Contromisura Aggiuntiva Raccomandata**:
- Firma digitale delle evidenze con chiave privata del sensore
- Whitelist di indirizzi sensori autorizzati
- Multi-signature per evidenze critiche (E1, E2)

---

#### Minaccia S1.2: Impersonificazione Corriere

**Descrizione**: Un attaccante si spaccia per il corriere legittimo per ricevere il pagamento.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Mittente crea spedizione con corriere = 0xABC...
2. Attaccante monitora la blockchain
3. Attaccante invia evidenze conformi (se ha RUOLO_SENSORE)
4. Attaccante tenta di chiamare validaEPaga() con proprio account
```

**CAPEC**: 
- [CAPEC-151](https://capec.mitre.org/data/definitions/151.html): Identity Spoofing

**ATT&CK**:
- [T1078](https://attack.mitre.org/techniques/T1078/): Valid Accounts

**Impatto**: 🔴 Critico - Furto di ETH

**Contromisura Implementata**:
```solidity
function validaEPaga(uint256 _id) external {
    Spedizione storage s = spedizioni[_id];
    require(s.corriere == msg.sender, "Non sei il corriere"); // ✅ Verifica identità
    // ...
}
```

**Efficacia**: ✅ Alta - Solo il corriere registrato può validare

---

### 🔧 T - Tampering (Manomissione)

#### Minaccia T1.1: Manipolazione CPT

**Descrizione**: Un attaccante modifica le CPT (Conditional Probability Tables) per alterare il calcolo bayesiano.

**Attore**: Insider Malevolo con RUOLO_ORACOLO

**Scenario**:
```
1. Attaccante con RUOLO_ORACOLO chiama impostaCPT()
2. Imposta CPT favorevoli: cpt_E1.p_FF = 99 (invece di 5)
3. Anche con evidenze negative, P(F1) e P(F2) risultano >= 95%
4. Pagamenti vengono approvati ingiustamente
```

**CAPEC**:
- [CAPEC-75](https://capec.mitre.org/data/definitions/75.html): Manipulating Writeable Configuration Files
- [CAPEC-271](https://capec.mitre.org/data/definitions/271.html): Schema Poisoning

**ATT&CK**:
- [T1565.001](https://attack.mitre.org/techniques/T1565/001/): Stored Data Manipulation

**Impatto**: 🔴 Critico - Sistema di validazione compromesso

**Contromisura Implementata**:
```solidity
function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt)
    external
    onlyRole(RUOLO_ORACOLO) // ✅ Solo oracolo autorizzato
{
    // ...
}
```

**Contromisura Aggiuntiva Raccomandata**:
- **Governance on-chain**: Votazione multi-sig per modifiche CPT
- **Timelock**: Delay di 24-48h prima che modifiche CPT siano attive
- **Event logging**: Emettere eventi per ogni modifica CPT
- **Range validation**: Validare che i valori CPT siano ragionevoli (es. 0-100)

---

#### Minaccia T1.2: Replay Attack su Evidenze

**Descrizione**: Un attaccante riutilizza evidenze di una spedizione precedente per una nuova spedizione.

**Attore**: Attaccante Esterno / Sensore Compromesso

**Scenario**:
```
1. Spedizione #1 ha evidenze conformi → Pagata
2. Spedizione #2 ha problemi reali (temperatura fuori range)
3. Attaccante intercetta e ritrasmette evidenze di Spedizione #1
4. Sistema accetta evidenze duplicate
5. Spedizione #2 viene pagata ingiustamente
```

**CAPEC**:
- [CAPEC-60](https://capec.mitre.org/data/definitions/60.html): Reusing Session IDs (Replay)
- [CAPEC-90](https://capec.mitre.org/data/definitions/90.html): Reflection Attack

**ATT&CK**:
- [T1557](https://attack.mitre.org/techniques/T1557/): Man-in-the-Middle

**Impatto**: 🟠 Alto - Pagamento fraudolento

**Contromisura Implementata**:
```solidity
function inviaEvidenza(uint256 _idSpedizione, uint8 _idEvidenza, bool _valore)
    external
    onlyRole(RUOLO_SENSORE)
{
    Spedizione storage s = spedizioni[_idSpedizione]; // ✅ Evidenze legate a ID specifico
    require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa"); // ✅ Stato verificato
    // ...
}
```

**Efficacia**: ✅ Alta - Evidenze sono legate a spedizioni specifiche

**Contromisura Aggiuntiva Raccomandata**:
- **Nonce/Timestamp**: Includere timestamp nelle evidenze
- **Firma digitale**: Firmare evidenze con chiave privata sensore

---

### 🚫 R - Repudiation (Ripudio)

#### Minaccia R1.1: Negazione Invio Evidenze

**Descrizione**: Un sensore nega di aver inviato evidenze false che hanno causato un pagamento errato.

**Attore**: Sensore Compromesso / Insider Malevolo

**Scenario**:
```
1. Sensore invia E1=true (temperatura OK) ma in realtà era fuori range
2. Pagamento viene eseguito
3. Prodotto arriva danneggiato
4. Sensore nega di aver inviato E1=true, sostiene sia stato un errore di sistema
```

**CAPEC**:
- [CAPEC-268](https://capec.mitre.org/data/definitions/268.html): Audit Log Manipulation

**ATT&CK**:
- [T1070](https://attack.mitre.org/techniques/T1070/): Indicator Removal

**Impatto**: 🟡 Medio - Dispute legali, perdita di fiducia

**Contromisura Implementata**:
```solidity
// ✅ Tutte le transazioni sono registrate on-chain (immutabili)
// ✅ Eventi Ethereum forniscono audit trail
```

**Efficacia**: ✅ Alta - Blockchain fornisce non-repudiation nativo

**Contromisura Aggiuntiva Raccomandata**:
- **Eventi dettagliati**:
```solidity
event EvidenzaInviata(
    uint256 indexed idSpedizione,
    uint8 indexed idEvidenza,
    bool valore,
    address indexed sensore,
    uint256 timestamp
);
```

---

#### Minaccia R1.2: Negazione Ricezione Pagamento

**Descrizione**: Un corriere nega di aver ricevuto il pagamento per evitare tasse o responsabilità.

**Attore**: Corriere Disonesto

**Scenario**:
```
1. Corriere chiama validaEPaga() e riceve 1 ETH
2. Evento SpedizionePagata emesso
3. Corriere sostiene di non aver mai ricevuto il pagamento
```

**CAPEC**:
- [CAPEC-268](https://capec.mitre.org/data/definitions/268.html): Audit Log Manipulation

**Impatto**: 🟡 Medio - Dispute legali

**Contromisura Implementata**:
```solidity
emit SpedizionePagata(_id, s.corriere, importo); // ✅ Evento immutabile
(bool success, ) = s.corriere.call{value: importo}("");
require(success, "Pagamento fallito"); // ✅ Verifica successo
```

**Efficacia**: ✅ Alta - Prova crittografica on-chain

---

### 📢 I - Information Disclosure (Divulgazione Informazioni)

#### Minaccia I1.1: Esposizione Dati Sensibili On-Chain

**Descrizione**: Dati sensibili delle spedizioni sono visibili pubblicamente sulla blockchain.

**Attore**: Qualsiasi osservatore della blockchain

**Scenario**:
```
1. Mittente crea spedizione con dati sensibili
2. Tutti i dati sono pubblici su blockchain
3. Competitor analizza pattern di spedizione
4. Informazioni commerciali sensibili esposte
```

**CAPEC**:
- [CAPEC-116](https://capec.mitre.org/data/definitions/116.html): Excavation
- [CAPEC-169](https://capec.mitre.org/data/definitions/169.html): Footprinting

**ATT&CK**:
- [T1213](https://attack.mitre.org/techniques/T1213/): Data from Information Repositories

**Impatto**: 🟡 Medio - Perdita di privacy commerciale

**Contromisura Implementata**:
```solidity
struct Spedizione {
    address mittente;
    address corriere;
    uint256 importoPagamento;
    // ✅ NO dati sensibili (es. contenuto, destinazione)
}
```

**Contromisura Aggiuntiva Raccomandata**:
- **Crittografia off-chain**: Dati sensibili crittografati, solo hash on-chain
- **Zero-Knowledge Proofs**: Provare conformità senza rivelare evidenze
- **Private blockchain**: Hyperledger Fabric con canali privati

---

#### Minaccia I1.2: Analisi Pattern Bayesiani

**Descrizione**: Un attaccante analizza le CPT pubbliche per reverse-engineering dei requisiti di conformità.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Attaccante legge cpt_E1, cpt_E2, ..., cpt_E5 dalla blockchain
2. Simula calcoli bayesiani off-chain
3. Identifica combinazioni minime di evidenze per P(F1), P(F2) >= 95%
4. Manipola sensori per inviare esattamente quelle evidenze
```

**CAPEC**:
- [CAPEC-116](https://capec.mitre.org/data/definitions/116.html): Excavation

**Impatto**: 🟠 Alto - Aggiramento validazione

**Contromisura Implementata**:
- ❌ Nessuna - CPT sono pubbliche per trasparenza

**Contromisura Aggiuntiva Raccomandata**:
- **CPT dinamiche**: Modificare periodicamente le CPT
- **Randomizzazione**: Aggiungere noise alle CPT
- **Soglie variabili**: SOGLIA_PROBABILITA non costante

---

### 💥 D - Denial of Service

#### Minaccia D1.1: Gas Exhaustion Attack

**Descrizione**: Un attaccante causa fallimento delle transazioni esaurendo il gas disponibile.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Attaccante crea spedizioni con importi minimi
2. Invia evidenze in modo da causare calcoli bayesiani complessi
3. Gas richiesto per validaEPaga() supera block gas limit
4. Corrieri legittimi non possono ricevere pagamenti
```

**CAPEC**:
- [CAPEC-147](https://capec.mitre.org/data/definitions/147.html): XML Ping of the Death
- [CAPEC-469](https://capec.mitre.org/data/definitions/469.html): HTTP DoS

**ATT&CK**:
- [T1499](https://attack.mitre.org/techniques/T1499/): Endpoint Denial of Service

**Impatto**: 🟠 Alto - Sistema inutilizzabile

**Contromisura Implementata**:
```solidity
function _calcolaProbabilitaCombinata(...) internal view returns (uint256) {
    // ✅ Calcoli ottimizzati, complessità O(n) con n=5 evidenze
    // ✅ No loop infiniti
}
```

**Efficacia**: ✅ Alta - Gas consumption prevedibile

**Contromisura Aggiuntiva Raccomandata**:
- **Gas limit check**: Verificare gas disponibile prima di calcoli complessi
- **Importo minimo**: Richiedere deposito minimo per spedizioni

---

#### Minaccia D1.2: Blocco Spedizioni (Evidenze Mancanti)

**Descrizione**: Un sensore malevolo non invia evidenze, bloccando la spedizione indefinitamente.

**Attore**: Sensore Compromesso / Insider Malevolo

**Scenario**:
```
1. Spedizione creata con 1 ETH in escrow
2. Sensore invia E1, E2, E3, E4 ma NON E5
3. validaEPaga() richiede tutte e 5 le evidenze
4. Corriere non può ricevere pagamento
5. ETH bloccato indefinitamente
```

**CAPEC**:
- [CAPEC-469](https://capec.mitre.org/data/definitions/469.html): HTTP DoS

**ATT&CK**:
- [T1499](https://attack.mitre.org/techniques/T1499/): Endpoint Denial of Service

**Impatto**: 🔴 Critico - Fondi bloccati

**Contromisura Implementata**:
```solidity
require(
    s.evidenze.E1_ricevuta && s.evidenze.E2_ricevuta &&
    s.evidenze.E3_ricevuta && s.evidenze.E4_ricevuta &&
    s.evidenze.E5_ricevuta, 
    "Evidenze mancanti" // ✅ Verifica completezza
);
```

**Contromisura Aggiuntiva Raccomandata**:
- **Timeout**: Dopo X giorni, mittente può recuperare fondi se evidenze incomplete
- **Evidenze parziali**: Permettere validazione con 4/5 evidenze (con penalità)
- **Fallback oracle**: Oracolo di backup può fornire evidenze mancanti

```solidity
// Esempio timeout
uint256 public constant TIMEOUT_GIORNI = 7;

function recuperaFondi(uint256 _id) external {
    Spedizione storage s = spedizioni[_id];
    require(s.mittente == msg.sender, "Non sei il mittente");
    require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa");
    require(block.timestamp > s.dataCreazione + (TIMEOUT_GIORNI * 1 days), "Timeout non scaduto");
    
    s.stato = StatoSpedizione.Annullata;
    payable(s.mittente).transfer(s.importoPagamento);
}
```

---

### 👑 E - Elevation of Privilege

#### Minaccia E1.1: Privilege Escalation via AccessControl

**Descrizione**: Un attaccante ottiene ruoli non autorizzati sfruttando vulnerabilità in AccessControl.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Attaccante trova vulnerabilità in grantRole()
2. Si auto-assegna RUOLO_ORACOLO
3. Modifica CPT a proprio favore
4. Manipola sistema di validazione
```

**CAPEC**:
- [CAPEC-233](https://capec.mitre.org/data/definitions/233.html): Privilege Escalation
- [CAPEC-69](https://capec.mitre.org/data/definitions/69.html): Target Programs with Elevated Privileges

**ATT&CK**:
- [T1068](https://attack.mitre.org/techniques/T1068/): Exploitation for Privilege Escalation
- [T1078.004](https://attack.mitre.org/techniques/T1078/004/): Cloud Accounts

**Impatto**: 🔴 Critico - Controllo completo del sistema

**Contromisura Implementata**:
```solidity
import "@openzeppelin/contracts/access/AccessControl.sol"; // ✅ Libreria auditata

contract BNCalcolatoreOnChain is AccessControl {
    // ✅ Uso di OpenZeppelin AccessControl (battle-tested)
}
```

**Efficacia**: ✅ Alta - OpenZeppelin è auditato e sicuro

**Contromisura Aggiuntiva Raccomandata**:
- **Multi-sig admin**: Richiedere 2/3 firme per grantRole()
- **Timelock**: Delay per assegnazione ruoli critici
- **Event monitoring**: Alert su modifiche ruoli

---

#### Minaccia E1.2: Reentrancy Attack su Pagamento

**Descrizione**: Un contratto malevolo sfrutta reentrancy per ricevere pagamenti multipli.

**Attore**: Attaccante Esterno con contratto malevolo

**Scenario**:
```
1. Attaccante deploya contratto malevolo come "corriere"
2. Contratto ha fallback function che richiama validaEPaga()
3. Prima che s.stato sia aggiornato, richiama validaEPaga() di nuovo
4. Riceve pagamento multiplo
```

**CAPEC**:
- [CAPEC-242](https://capec.mitre.org/data/definitions/242.html): Code Injection

**ATT&CK**:
- [T1203](https://attack.mitre.org/techniques/T1203/): Exploitation for Client Execution

**Impatto**: 🔴 Critico - Furto di ETH

**Contromisura Implementata**:
```solidity
function validaEPaga(uint256 _id) external {
    // ...
    s.stato = StatoSpedizione.Pagata; // ✅ Checks-Effects-Interactions pattern
    
    emit SpedizionePagata(_id, s.corriere, importo);
    
    (bool success, ) = s.corriere.call{value: importo}(""); // ✅ Chiamata esterna DOPO modifica stato
    require(success, "Pagamento fallito");
}
```

**Efficacia**: ✅ Alta - Pattern CEI corretto

**Contromisura Aggiuntiva Raccomandata**:
- **ReentrancyGuard**: Usare OpenZeppelin ReentrancyGuard
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BNCalcolatoreOnChain is AccessControl, ReentrancyGuard {
    function validaEPaga(uint256 _id) external nonReentrant {
        // ...
    }
}
```

---

## 4.2 Asset A2: Evidenze IoT

### 🎭 S - Spoofing

#### Minaccia S2.1: Sensore Falso

**Descrizione**: Un dispositivo non autorizzato si spaccia per sensore legittimo.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Attaccante deploya dispositivo IoT falso
2. Dispositivo ottiene RUOLO_SENSORE (chiave rubata)
3. Invia evidenze false: E1=true (temperatura OK) quando in realtà è fuori range
4. Sistema accetta evidenze false
```

**CAPEC**:
- [CAPEC-151](https://capec.mitre.org/data/definitions/151.html): Identity Spoofing
- [CAPEC-94](https://capec.mitre.org/data/definitions/94.html): Man in the Middle

**Impatto**: 🔴 Critico

**Contromisura Raccomandata**:
- **Device attestation**: Certificati hardware (TPM)
- **Mutual TLS**: Autenticazione reciproca sensore-contratto
- **Whitelist**: Solo sensori pre-registrati

---

### 🔧 T - Tampering

#### Minaccia T2.1: Manomissione Fisica Sensore

**Descrizione**: Un attaccante manomette fisicamente il sensore per alterare le letture.

**Attore**: Corriere Disonesto / Insider Malevolo

**Scenario**:
```
1. Corriere apre il pacco durante il trasporto
2. Modifica il sensore di temperatura per leggere sempre "OK"
3. Prodotto si deteriora ma sensore riporta E1=true
4. Pagamento viene eseguito
```

**CAPEC**:
- [CAPEC-390](https://capec.mitre.org/data/definitions/390.html): Bypassing Physical Security

**ATT&CK**:
- [T1200](https://attack.mitre.org/techniques/T1200/): Hardware Additions

**Impatto**: 🔴 Critico

**Contromisura Raccomandata**:
- **Tamper-evident seals**: Sigilli anti-manomissione
- **Sensor redundancy**: Multipli sensori per stesso parametro
- **Anomaly detection**: ML per rilevare letture anomale

---

### 📢 I - Information Disclosure

#### Minaccia I2.1: Intercettazione Dati Sensore

**Descrizione**: Un attaccante intercetta comunicazioni sensore-blockchain.

**Attore**: Attaccante Esterno (Man-in-the-Middle)

**Scenario**:
```
1. Sensore invia evidenze via WiFi non crittografato
2. Attaccante intercetta pacchetti
3. Legge evidenze prima che arrivino on-chain
4. Usa informazioni per insider trading o sabotaggio
```

**CAPEC**:
- [CAPEC-94](https://capec.mitre.org/data/definitions/94.html): Man in the Middle

**ATT&CK**:
- [T1557](https://attack.mitre.org/techniques/T1557/): Man-in-the-Middle

**Impatto**: 🟡 Medio

**Contromisura Raccomandata**:
- **TLS/HTTPS**: Crittografia end-to-end
- **VPN**: Tunnel sicuro sensore-gateway

---

## 4.3 Asset A3: Pagamenti ETH

### 🔧 T - Tampering

#### Minaccia T3.1: Manipolazione Importo Pagamento

**Descrizione**: Un attaccante modifica l'importo del pagamento dopo la creazione della spedizione.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Mittente crea spedizione con 1 ETH
2. Attaccante trova vulnerabilità per modificare s.importoPagamento
3. Aumenta importo a 100 ETH
4. Corriere complice riceve 100 ETH invece di 1 ETH
```

**CAPEC**:
- [CAPEC-75](https://capec.mitre.org/data/definitions/75.html): Manipulating Writeable Configuration Files

**Impatto**: 🔴 Critico

**Contromisura Implementata**:
```solidity
struct Spedizione {
    // ...
    uint256 importoPagamento; // ✅ Immutabile dopo creazione
}

function creaSpedizione(address _corriere) external payable {
    // ...
    importoPagamento: msg.value // ✅ Impostato una sola volta
}
```

**Efficacia**: ✅ Alta - Nessuna funzione modifica importo

---

### 💥 D - Denial of Service

#### Minaccia D3.1: Blocco Fondi (Evidenze Mai Inviate)

**Descrizione**: ETH rimane bloccato indefinitamente se evidenze non vengono mai inviate.

**Attore**: Sensore Malfunzionante / Utente Maldestro

**Scenario**:
```
1. Mittente deposita 10 ETH
2. Sensore si guasta e non invia mai evidenze
3. Corriere non può validare (evidenze mancanti)
4. Mittente non può recuperare fondi
5. 10 ETH bloccati per sempre
```

**CAPEC**:
- [CAPEC-469](https://capec.mitre.org/data/definitions/469.html): HTTP DoS

**Impatto**: 🔴 Critico

**Contromisura Raccomandata**:
- **Timeout con refund**: Implementare funzione di recupero fondi dopo timeout

```solidity
uint256 public constant TIMEOUT_GIORNI = 7;

mapping(uint256 => uint256) public dataCreazione;

function creaSpedizione(address _corriere) external payable returns (uint256) {
    // ...
    dataCreazione[id] = block.timestamp;
    // ...
}

function recuperaFondi(uint256 _id) external {
    Spedizione storage s = spedizioni[_id];
    require(s.mittente == msg.sender, "Non sei il mittente");
    require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa");
    require(block.timestamp > dataCreazione[_id] + (TIMEOUT_GIORNI * 1 days), "Timeout non scaduto");
    
    s.stato = StatoSpedizione.Annullata;
    payable(s.mittente).transfer(s.importoPagamento);
}
```

---

## 4.4 Asset A8: Chiavi Private MetaMask

### 🎭 S - Spoofing

#### Minaccia S8.1: Phishing MetaMask

**Descrizione**: Un attaccante crea sito fake per rubare chiavi private.

**Attore**: Attaccante Esterno

**Scenario**:
```
1. Attaccante crea sito fake: "metamask-update.com"
2. Invia email phishing: "Aggiorna MetaMask per sicurezza"
3. Utente inserisce seed phrase
4. Attaccante ottiene controllo completo del wallet
```

**CAPEC**:
- [CAPEC-98](https://capec.mitre.org/data/definitions/98.html): Phishing
- [CAPEC-163](https://capec.mitre.org/data/definitions/163.html): Spear Phishing

**ATT&CK**:
- [T1566.002](https://attack.mitre.org/techniques/T1566/002/): Spearphishing Link

**Impatto**: 🔴 Critico - Furto totale fondi

**Contromisura Raccomandata**:
- **User education**: Formazione anti-phishing
- **Hardware wallet**: Ledger/Trezor per chiavi critiche
- **Multi-factor authentication**: Conferma transazioni su dispositivo separato

---

## 5. Abuse/Misuse Cases

### 5.1 Abuse Case AC1: Frode Corriere

**Titolo**: Corriere Disonesto Manipola Evidenze per Pagamento Immeritato

**Attore Primario**: Corriere Disonesto  
**Attore Secondario**: Sensore Compromesso (complice)

**Precondizioni**:
- Corriere ha controllo fisico della spedizione
- Sensore è compromesso o complice

**Flusso Principale**:
1. Mittente crea spedizione con 5 ETH
2. Corriere trasporta in condizioni non conformi (temperatura fuori range)
3. Sensore compromesso invia E1=true (falso)
4. Altre evidenze sono conformi: E2=true, E3=false, E4=false, E5=true
5. Sistema calcola P(F1) >= 95%, P(F2) >= 95%
6. Corriere chiama validaEPaga() e riceve 5 ETH
7. Prodotto arriva danneggiato

**Postcondizioni**:
- Corriere ha ricevuto pagamento immeritato
- Mittente ha perso 5 ETH
- Prodotto danneggiato

**Impatto**: 🔴 Critico - Perdita finanziaria e reputazionale

**Contromisure**:
- ✅ **Implementata**: Bayesian Network riduce impatto di singola evidenza falsa
- 🔄 **Raccomandata**: Multi-sensor redundancy per E1 (temperatura)
- 🔄 **Raccomandata**: Firma digitale evidenze con chiave hardware sensore

**Riferimenti**:
- CAPEC-151: Identity Spoofing
- ATT&CK T1078: Valid Accounts

---

### 5.2 Abuse Case AC2: Insider Manipulation CPT

**Titolo**: Admin Malevolo Modifica CPT per Favorire Complici

**Attore Primario**: Admin/Oracolo Malevolo  
**Attore Secondario**: Corriere Complice

**Precondizioni**:
- Admin ha RUOLO_ORACOLO
- Admin è corrotto o compromesso

**Flusso Principale**:
1. Admin chiama impostaCPT() per E1
2. Imposta cpt_E1.p_FF = 99 (invece di 5)
3. Questo significa: "Anche se F1=false (temperatura non conforme), E1=true ha 99% probabilità"
4. Corriere complice trasporta in condizioni pessime
5. Sensore onesto invia E1=false (temperatura fuori range)
6. Ma a causa delle CPT manipolate, P(F1) risulta comunque >= 95%
7. Corriere riceve pagamento immeritato

**Postcondizioni**:
- Sistema di validazione compromesso
- Tutti i pagamenti futuri sono inaffidabili
- Perdita di fiducia nel sistema

**Impatto**: 🔴 Critico - Compromissione sistemica

**Contromisure**:
- 🔄 **Raccomandata**: Multi-sig governance per modifiche CPT
- 🔄 **Raccomandata**: Timelock 48h per modifiche CPT
- 🔄 **Raccomandata**: Event monitoring e alert su modifiche CPT
- 🔄 **Raccomandata**: Range validation (CPT values 0-100)

**Riferimenti**:
- CAPEC-75: Manipulating Writeable Configuration Files
- ATT&CK T1565.001: Stored Data Manipulation

---

### 5.3 Misuse Case MC1: Utente Perde Chiave Privata

**Titolo**: Mittente Maldestro Perde Accesso ai Fondi

**Attore Primario**: Mittente Inesperto

**Precondizioni**:
- Mittente non ha esperienza con crypto
- Non ha backup seed phrase

**Flusso Principale**:
1. Mittente crea spedizione con 10 ETH
2. Mittente formatta computer senza backup MetaMask
3. Perde seed phrase
4. Spedizione viene completata con successo
5. Corriere riceve pagamento
6. Mittente non può più accedere al proprio account
7. Eventuali fondi residui sono persi per sempre

**Postcondizioni**:
- Mittente ha perso accesso permanente
- Nessun modo di recuperare account

**Impatto**: 🟠 Alto - Perdita fondi utente

**Contromisure**:
- 🔄 **Raccomandata**: Onboarding wizard con backup obbligatorio
- 🔄 **Raccomandata**: Warning chiaro su importanza seed phrase
- 🔄 **Raccomandata**: Multi-sig wallet per aziende
- 🔄 **Raccomandata**: Social recovery (Argent wallet style)

**Riferimenti**:
- CAPEC-N/A (errore utente, non attacco)

---

### 5.4 Misuse Case MC2: Configurazione Errata CPT

**Titolo**: Admin Maldestro Imposta CPT Sbagliate

**Attore Primario**: Admin Inesperto

**Precondizioni**:
- Admin non comprende Bayesian Networks
- Nessuna validazione input

**Flusso Principale**:
1. Admin vuole impostare P(E1=T | F1=T, F2=T) = 98%
2. Per errore imposta cpt_E1.p_TT = 9 (invece di 98)
3. Sistema accetta valore
4. Calcoli bayesiani diventano incorretti
5. Spedizioni conformi vengono rifiutate
6. Corrieri legittimi non ricevono pagamenti

**Postcondizioni**:
- Sistema non funziona correttamente
- Perdita di fiducia
- Dispute legali

**Impatto**: 🟠 Alto - Sistema inutilizzabile

**Contromisure**:
- 🔄 **Raccomandata**: Input validation con range check
```solidity
function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt) external onlyRole(RUOLO_ORACOLO) {
    require(_cpt.p_FF <= 100 && _cpt.p_FT <= 100 && _cpt.p_TF <= 100 && _cpt.p_TT <= 100, "CPT values must be 0-100");
    require(_cpt.p_FF + _cpt.p_FT + _cpt.p_TF + _cpt.p_TT > 0, "At least one CPT value must be > 0");
    // ...
}
```
- 🔄 **Raccomandata**: UI con validazione client-side
- 🔄 **Raccomandata**: Simulation tool per testare CPT prima di deployment

**Riferimenti**:
- CAPEC-N/A (errore configurazione)

---

### 5.5 Abuse Case AC3: DoS via Spam Spedizioni

**Titolo**: Attaccante Satura Sistema con Spedizioni Fake

**Attore Primario**: Attaccante Esterno

**Precondizioni**:
- Attaccante ha RUOLO_MITTENTE
- Nessun rate limiting

**Flusso Principale**:
1. Attaccante crea 10,000 spedizioni con importo minimo (0.0001 ETH)
2. Invia evidenze random per ogni spedizione
3. Blockchain si riempie di transazioni spam
4. Gas price aumenta drasticamente
5. Utenti legittimi non possono permettersi transazioni
6. Sistema diventa inutilizzabile

**Postcondizioni**:
- Sistema in DoS
- Utenti legittimi bloccati
- Reputazione danneggiata

**Impatto**: 🟠 Alto - Denial of Service

**Contromisure**:
- 🔄 **Raccomandata**: Importo minimo spedizione (es. 0.1 ETH)
```solidity
uint256 public constant IMPORTO_MINIMO = 0.1 ether;

function creaSpedizione(address _corriere) external payable returns (uint256) {
    require(msg.value >= IMPORTO_MINIMO, "Importo troppo basso");
    // ...
}
```
- 🔄 **Raccomandata**: Rate limiting per mittente (max X spedizioni/giorno)
- 🔄 **Raccomandata**: Reputation system (stake per mittenti)

**Riferimenti**:
- CAPEC-469: HTTP DoS
- ATT&CK T1499: Endpoint Denial of Service

---

## 6. Contromisure Implementate

### 6.1 Riepilogo Contromisure Esistenti

| Minaccia | Contromisura | Efficacia |
|----------|--------------|-----------|
| Spoofing Ruoli | `onlyRole()` modifier (OpenZeppelin) | ✅ Alta |
| Impersonificazione Corriere | `require(s.corriere == msg.sender)` | ✅ Alta |
| Manipolazione Importo | Immutabilità struct Spedizione | ✅ Alta |
| Reentrancy | Checks-Effects-Interactions pattern | ✅ Alta |
| Repudiation | Eventi Ethereum immutabili | ✅ Alta |
| Gas Exhaustion | Calcoli ottimizzati O(n) | ✅ Alta |
| Privilege Escalation | OpenZeppelin AccessControl | ✅ Alta |

### 6.2 Gap Analysis

| Minaccia | Contromisura Mancante | Priorità |
|----------|----------------------|----------|
| Manipolazione CPT | Multi-sig governance | 🔴 Alta |
| Fondi Bloccati | Timeout con refund | 🔴 Alta |
| Sensore Falso | Device attestation | 🟠 Media |
| Phishing | User education | 🟠 Media |
| DoS Spam | Rate limiting | 🟡 Bassa |
| Privacy Dati | Zero-Knowledge Proofs | 🟡 Bassa |

---

## 7. Raccomandazioni

### 7.1 Priorità Alta (Implementare Subito)

#### R1: Multi-Signature Governance per CPT

**Problema**: Admin singolo può manipolare CPT  
**Soluzione**: Richiedere 2/3 firme per modifiche CPT

```solidity
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract BNCalcolatoreOnChain is AccessControl {
    TimelockController public timelock;
    
    constructor(address[] memory proposers, address[] memory executors) {
        timelock = new TimelockController(
            2 days, // delay
            proposers,
            executors,
            address(0)
        );
    }
    
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt)
        external
        onlyRole(RUOLO_ORACOLO)
    {
        // Richiede approvazione timelock
        require(msg.sender == address(timelock), "Must go through timelock");
        // ...
    }
}
```

---

#### R2: Timeout e Recupero Fondi

**Problema**: ETH bloccato se evidenze mai inviate  
**Soluzione**: Funzione recuperaFondi() dopo 7 giorni

```solidity
uint256 public constant TIMEOUT_GIORNI = 7;
mapping(uint256 => uint256) public dataCreazione;

enum StatoSpedizione { InAttesa, Pagata, Annullata }

function recuperaFondi(uint256 _id) external {
    Spedizione storage s = spedizioni[_id];
    require(s.mittente == msg.sender, "Non sei il mittente");
    require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa");
    require(block.timestamp > dataCreazione[_id] + (TIMEOUT_GIORNI * 1 days), "Timeout non scaduto");
    
    // Verifica che non tutte le evidenze siano state ricevute
    bool tutteRicevute = s.evidenze.E1_ricevuta && s.evidenze.E2_ricevuta &&
                         s.evidenze.E3_ricevuta && s.evidenze.E4_ricevuta &&
                         s.evidenze.E5_ricevuta;
    require(!tutteRicevute, "Tutte le evidenze ricevute, usa validaEPaga");
    
    s.stato = StatoSpedizione.Annullata;
    emit SpedizioneAnnullata(_id, s.mittente, s.importoPagamento);
    
    (bool success, ) = s.mittente.call{value: s.importoPagamento}("");
    require(success, "Refund fallito");
}
```

---

#### R3: ReentrancyGuard

**Problema**: Potenziale reentrancy su validaEPaga()  
**Soluzione**: Usare OpenZeppelin ReentrancyGuard

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BNCalcolatoreOnChain is AccessControl, ReentrancyGuard {
    function validaEPaga(uint256 _id) external nonReentrant {
        // ...
    }
}
```

---

### 7.2 Priorità Media

#### R4: Input Validation per CPT

```solidity
function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt)
    external
    onlyRole(RUOLO_ORACOLO)
{
    require(_idEvidenza >= 1 && _idEvidenza <= 5, "ID evidenza non valido");
    require(_cpt.p_FF <= PRECISIONE, "p_FF > 100");
    require(_cpt.p_FT <= PRECISIONE, "p_FT > 100");
    require(_cpt.p_TF <= PRECISIONE, "p_TF > 100");
    require(_cpt.p_TT <= PRECISIONE, "p_TT > 100");
    
    // ...
}
```

---

#### R5: Eventi Dettagliati

```solidity
event EvidenzaInviata(
    uint256 indexed idSpedizione,
    uint8 indexed idEvidenza,
    bool valore,
    address indexed sensore,
    uint256 timestamp
);

event CPTModificata(
    uint8 indexed idEvidenza,
    CPT nuovaCPT,
    address indexed oracolo,
    uint256 timestamp
);

event SpedizioneAnnullata(
    uint256 indexed id,
    address indexed mittente,
    uint256 importoRimborsato
);
```

---

#### R6: Importo Minimo Spedizione

```solidity
uint256 public constant IMPORTO_MINIMO = 0.1 ether;

function creaSpedizione(address _corriere)
    external
    payable
    onlyRole(RUOLO_MITTENTE)
    returns (uint256)
{
    require(msg.value >= IMPORTO_MINIMO, "Importo minimo: 0.1 ETH");
    // ...
}
```

---

### 7.3 Priorità Bassa (Future Work)

#### R7: Zero-Knowledge Proofs per Privacy

Usare zk-SNARKs per provare conformità senza rivelare evidenze:

```
Prova: "Conosco evidenze E1...E5 tali che P(F1) >= 95% e P(F2) >= 95%"
Senza rivelare: Valori esatti di E1...E5
```

**Librerie**: zkSync, StarkWare, Polygon zkEVM

---

#### R8: Oracle Decentralizzato (Chainlink)

Usare Chainlink per evidenze critiche invece di sensori centralizzati:

```solidity
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

function richiestaEvidenzaE1(uint256 _idSpedizione) external {
    Chainlink.Request memory req = buildChainlinkRequest(
        jobId,
        address(this),
        this.fulfillEvidenzaE1.selector
    );
    req.add("shipmentId", _idSpedizione);
    sendChainlinkRequest(req, fee);
}

function fulfillEvidenzaE1(bytes32 _requestId, bool _valore) public recordChainlinkFulfillment(_requestId) {
    // Salva evidenza E1
}
```

---

## 8. Conclusioni

### 8.1 Stato Attuale della Sicurezza

Il sistema presenta una **buona base di sicurezza** grazie a:
- ✅ Uso di OpenZeppelin (AccessControl, pattern CEI)
- ✅ Bayesian Network per tolleranza errori
- ✅ Immutabilità blockchain per non-repudiation

Tuttavia, esistono **gap critici**:
- ❌ Nessuna protezione contro admin malevolo
- ❌ Fondi possono rimanere bloccati indefinitamente
- ❌ Sensori non autenticati crittograficamente

### 8.2 Roadmap di Sicurezza

**Fase 1 (Immediata)**: Implementare R1, R2, R3  
**Fase 2 (3 mesi)**: Implementare R4, R5, R6  
**Fase 3 (6 mesi)**: Ricerca R7, R8  

### 8.3 Metriche di Sicurezza

| Metrica | Valore Attuale | Target |
|---------|----------------|--------|
| Vulnerabilità Critiche | 3 | 0 |
| Vulnerabilità Alte | 5 | 2 |
| Coverage Audit | 60% | 100% |
| Test Penetration | 0 | 1/anno |

---

## 9. Riferimenti

### 9.1 Framework e Standard

- [STRIDE Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [CAPEC - Common Attack Pattern Enumeration](https://capec.mitre.org/)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [OWASP Smart Contract Security](https://owasp.org/www-project-smart-contract-top-10/)

### 9.2 Librerie e Tool

- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Slither - Static Analyzer](https://github.com/crytic/slither)
- [Mythril - Security Analysis](https://github.com/ConsenSys/mythril)
- [Echidna - Fuzzer](https://github.com/crytic/echidna)

### 9.3 Best Practices

- [Consensys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [Ethereum Security](https://ethereum.org/en/developers/docs/smart-contracts/security/)

---

**Fine del Documento**
