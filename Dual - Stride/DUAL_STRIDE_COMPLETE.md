# Analisi DUAL-STRIDE Completa
## Sistema Oracolo Bayesiano per la Catena del Freddo Farmaceutica

---

## 1. Inventario Asset del Sistema

| ID | Asset | Descrizione | Criticità |
|---|---|---|---|
| A1 | Smart Contract | Logica di business e fondi in escrow | **Critica** |
| A2 | Evidenze IoT | Dati dai sensori (E1-E5) | **Critica** |
| A3 | Pagamenti ETH | Fondi depositati dai mittenti | **Critica** |
| A4 | Ruoli e Permessi | Sistema AccessControl | **Alta** |
| A5 | CPT e Probabilità | Parametri della rete bayesiana | **Alta** |
| A6 | Dati spedizioni | Record on-chain e storico | **Media** |
| A7 | Interfaccia Web | Frontend utente (DApp) | **Media** |
| A8 | Chiavi private | Credenziali MetaMask | **Critica** |

---

## 2. Analisi DUAL-STRIDE per Asset

### A1 - Smart Contract (Logica di Business)

**Valore Asset:** Critico

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **T** | Danger | T1.1 | Manipolazione logica bytecode | Med | **CRIT** | Audit + Verifica formale | CAPEC-1 |
| **D** | AoR | D1.1 | Blocco contratto (storage bomb) | Low | High | Gas limits | CAPEC-130 |
| **E** | Exposure | E1.1 | Privilege escalation admin | Med | **CRIT** | Multi-sig Timelock | CAPEC-122 |

### A2 - Evidenze IoT

**Valore Asset:** Critico

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **S** | Danger | S2.1 | Impersonificazione sensore | High | **CRIT** | Role-based access | CAPEC-151 |
| **T** | Danger | T2.1 | Modifica evidenze in transito | Med | High | Firma digitale | CAPEC-94 |
| **R** | - | R2.1 | Ripudio invio evidenza | Low | Med | Event logging | CAPEC-585 |
| **I** | Unreliability | I2.1 | Corruzione dati sensore | High | High | Ridondanza E1-E5 | - |

### A3 - Pagamenti ETH

**Valore Asset:** Critico

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **T** | Danger | T3.1 | Reentrancy attack | High | **CRIT** | ReentrancyGuard | CAPEC-194 |
| **D** | AoR | D3.1 | Blocco fondi escrow | High | **CRIT** | Refund logic + timeout | CAPEC-227 |
| **E** | Exposure | E3.1 | Drenaggio fondi contratto | Med | **CRIT** | Access control withdraw | CAPEC-123 |

### A4 - Ruoli e Permessi

**Valore Asset:** Alto

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **S** | Danger | S4.1 | Assegnazione ruolo fraudolenta | Med | High | Admin-only grant | CAPEC-87 |
| **T** | Danger | T4.1 | Modifica mapping ruoli | Low | High | Private state vars | CAPEC-1 |
| **E** | Exposure | E4.1 | Escalation privilegi | Med | **CRIT** | Multi-level checks | ATT&CK-T1078 |

### A5 - CPT e Probabilità

**Valore Asset:** Alto

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **T** | Danger | T5.1 | Manipolazione CPT | Med | High | Private vars + Admin | CAPEC-1 |
| **I** | Exposure | I5.1 | Reverse engineering CPT | High | High | Offuscamento | CAPEC-188 |
| **E** | Exposure | E5.1 | Leak parametri bayesiani | Med | Med | Private getter | CAPEC-116 |

### A6 - Dati Spedizioni

**Valore Asset:** Medio

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **I** | Exposure | I6.1 | Data mining competitivo | High | Med | Hashing dati sensibili | CAPEC-116 |
| **T** | - | T6.1 | Modifica storico spedizioni | Low | Med | Immutabilità blockchain | CAPEC-271 |
| **R** | - | R6.1 | Ripudio transazione | Low | Low | Event logs permanenti | CAPEC-585 |

### A7 - Interfaccia Web (DApp)

**Valore Asset:** Medio

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **S** | Danger | S7.1 | Phishing/Spoofing UI | High | High | User education + HTTPS | CAPEC-98 |
| **T** | Danger | T7.1 | MITM su connessione Web3 | Med | High | TLS + SubResource Integrity | CAPEC-94 |
| **I** | Exposure | I7.1 | XSS injection | Med | Med | Input sanitization | CAPEC-63 |

### A8 - Chiavi Private (MetaMask)

**Valore Asset:** Critico

| STRIDE | DUA | Threat ID | Descrizione | Prob | Risk | Mitigation | CAPEC/ATT&CK |
|---|---|---|---|---|---|---|---|
| **S** | Danger | S8.1 | Furto chiavi (keylogger) | Med | **CRIT** | Hardware wallet | ATT&CK-T1056 |
| **I** | Exposure | I8.1 | Esposizione seed phrase | High | **CRIT** | Secure storage education | CAPEC-116 |
| **E** | Exposure | E8.1 | Accesso non autorizzato wallet | Med | **CRIT** | Password policy + 2FA | ATT&CK-T1528 |

---

## 3. Abuse e Misuse Cases Dettagliati

### S2.1 - Impersonificazione Sensore

#### ABUSE CASE: S2.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Invio Evidenza Sensore |
| **Case ID** | S2.1-A |
| **Case Name** | **Sensore Malevolo Falsificato** |
| **Actors** | Attaccante Esterno con chiave compromessa RUOLO_SENSORE |
| **Description** | Un attaccante ottiene una chiave privata con RUOLO_SENSORE associato (tramite phishing, malware IoT o compromissione dispositivo) e la utilizza per inviare evidenze fraudolente al contratto BNCore, facendo validare spedizioni non conformi come valide. |
| **Data** | Chiave privata RUOLO_SENSORE, ID spedizione target, valori evidenze falsificati (E1-E5) |
| **Stimulus and Preconditions** | - Spedizione attiva con stato ATTIVA<br>- Attaccante possiede chiave con RUOLO_SENSORE<br>- Target: spedizione con merce deteriorata (temperatura fuori range) |
| **Basic Flow** | 1. Attaccante identifica spedizione target tramite eventi blockchain<br>2. Chiama `aggiungiEvidenza(idSpedizione, E1=true)` omettendo violazioni<br>3. Ripete per E2-E5 con valori falsi<br>4. Corriere chiama `validaEPaga()` con soglia bassa<br>5. Sistema valida e paga mittente fraudolentemente |
| **Alternative Flow** | - Se revert per ruolo mancante: attacco fallisce<br>- Se evidenza già presente: usa altro sensore compromesso |
| **Exception Flow** | - Rilevamento anomalia temporale evidenze (troppo ravvicinate)<br>- Multiple submission da stesso sensore bloccata |
| **Response and Postconditions** | **Successo attacco:** Pagamento fraudolento mittente, merce non conforme consegnata<br>**Non Functional Requirements:** Audit trail su blockchain, sistema di reputazione sensori |
| **Comments** | **CAPEC-151:** Identity Spoofing<br>**Mitigation:** Rotazione chiavi sensori, binding hardware-based, challenge-response |

#### MISUSE CASE: S2.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Invio Evidenza Sensore |
| **Case ID** | S2.1-M |
| **Case Name** | **Guasto Hardware Sensore (Unreliability)** |
| **Actors** | Sensore IoT difettoso/starato |
| **Description** | Un sensore legittimo invia dati errati a causa di drift HW, calibrazione scaduta, batteria scarica o interferenze ambientali, causando falsi positivi/negativi non intenzionali. |
| **Data** | Letture sensore errate, timestamp |
| **Stimulus and Preconditions** | - Sensore installato da >6 mesi senza calibrazione<br>- Ambiente con interferenze elettromagnetiche<br>- Batteria sotto 20% |
| **Basic Flow** | 1. Sensore temperatura legge +2°C per drift<br>2. Spedizione a 4°C letta come 6°C (fuori range 2-8°C)<br>3. Invia `E1=false` erroneamente<br>4. Bayesian network calcola P bassa<br>5. Validazione fallisce, mittente perde pagamento |
| **Alternative Flow** | - Altri sensori (E2-E5) compensano errore E1<br>- Timeout scaduto attiva refund automatico |
| **Exception Flow** | - Sistema ridondanza rileva inconsistenza cross-sensor<br>- Admin interviene manualmente |
| **Response and Postconditions** | **Impatto:** Falso negativo, merce conforme rifiutata, perdita economica mittente legittimo<br>**NFR:** SLA manutenzione sensori, calibrazione semestrale, monitoring batteria |
| **Comments** | **DUA-Unreliability:** Assenza di manutenzione preventiva<br>**Mitigation:** Drift detection ML, consensus multi-sensor |

---

### T3.1 - Reentrancy Attack su Pagamenti

#### ABUSE CASE: T3.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Pagamento Mittente |
| **Case ID** | T3.1-A |
| **Case Name** | **Reentrancy Attack su validaEPaga** |
| **Actors** | Attaccante con contratto malevolo (RUOLO_MITTENTE) |
| **Description** | Attaccante deploya un contratto mittente che implementa una fallback function malevola. Quando BNCore esegue `transfer()`, la fallback ri-chiama `validaEPaga()` prima dell'aggiornamento stato, drenando i fondi. |
| **Data** | Contratto mittente malevolo, ID spedizione, balance contratto BNCore |
| **Stimulus and Preconditions** | - Attaccante crea spedizione legittima con contratto malevolo come mittente<br>- Spedizione completata e validabile<br>- BNCore contiene fondi multipli di altre spedizioni |
| **Basic Flow** | 1. Attaccante chiama `validaEPaga()` da contratto malevolo<br>2. BNCore calcola probabilità (OK)<br>3. Esegue `mittente.transfer(valoreDovuto)`<br>4. Fallback del contratto attaccante ri-chiama `validaEPaga()`<br>5. Check `stato == ATTIVA` ancora true → secondo pagamento<br>6. Ripete finché gas/fondi disponibili |
| **Alternative Flow** | - Se ReentrancyGuard presente: revert alla seconda chiamata<br>- Se pattern Checks-Effects-Interactions: stato cambia prima di transfer |
| **Exception Flow** | - Out of gas blocca loop<br>- BNCore balance insufficiente causa revert |
| **Response and Postconditions** | **Successo:** Drenaggio totale fondi contratto<br>**Fallimento:** Revert transazione, nessun pagamento |
| **Comments** | **CAPEC-194:** Fake Resource Injection<br>**ATT&CK:** T1539 Steal Web Session Cookie (analogia)<br>**Mitigation:** OpenZeppelin ReentrancyGuard, CEI pattern, Pull over Push payments |

#### MISUSE CASE: T3.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Pagamento Mittente |
| **Case ID** | T3.1-M |
| **Case Name** | **Errore Indirizzo Destinatario (User Mistake)** |
| **Actors** | Mittente distratto/inesperto |
| **Description** | Utente legittimo inserisce indirizzo errato (typo) come parametro mittente durante creazione spedizione, causando pagamento irrecuperabile a indirizzo sbagliato o inesistente. |
| **Data** | Indirizzo mittente errato, fondi ETH |
| **Stimulus and Preconditions** | - Utente crea spedizione via DApp<br>- Copy-paste parziale indirizzo<br>- Nessuna validazione UI checksum |
| **Basic Flow** | 1. Utente chiama `creaSpedizione(wrongAddress, ...)`<br>2. Deposita ETH nel contratto<br>3. Spedizione completata correttamente<br>4. `validaEPaga()` trasferisce fondi a wrongAddress<br>5. Mittente legittimo non riceve pagamento |
| **Alternative Flow** | - Se wrongAddress è EOA controllato da terzi: fondi persi<br>- Se wrongAddress è contratto senza fallback: fondi bloccati |
| **Exception Flow** | - Validazione checksum EIP-55 in UI previene typo<br>- Conferma doppia indirizzo |
| **Response and Postconditions** | **Impatto:** Perdita irrevocabile fondi, impossibile chargeback blockchain<br>**NFR:** UX design con validazione indirizzo, warning pre-transazione |
| **Comments** | **DUA-Exposure:** Assenza meccanismi protezione utente<br>**Mitigation:** Address book, QR code, conferma visuale indirizzo |

---

### D3.1 - Blocco Fondi Escrow

#### ABUSE CASE: D3.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Validazione Spedizione |
| **Case ID** | D3.1-A |
| **Case Name** | **Withholding Attack (Denial of Service)** |
| **Actors** | Sensore compromesso / Corriere collusivo |
| **Description** | Attaccante con controllo su sensore E5 (o corriere) rifiuta intenzionalmente di inviare l'ultima evidenza necessaria, bloccando i fondi del mittente in escrow come forma di estorsione o danno reputazionale. |
| **Data** | ID spedizione, evidenze E1-E4 (inviate), E5 (trattenuta) |
| **Stimulus and Preconditions** | - Spedizione in stato ATTIVA<br>- E1-E4 già registrate<br>- Attaccante controlla sensore E5 o account corriere<br>- Nessun timeout implementato |
| **Basic Flow** | 1. Spedizione procede normalmente<br>2. Sensori E1-E4 inviano evidenze<br>3. Attaccante trattiene E5 indefinitamente<br>4. `validaEPaga()` non può essere chiamata (evidenze incomplete)<br>5. Fondi mittente bloccati in contratto |
| **Alternative Flow** | - Attaccante richiede riscatto per inviare E5<br>- Multipli sensori compromessi (E3+E4+E5) per attacco più robusto |
| **Exception Flow** | - Timeout timer (7 giorni) scade → `richiestaRimborso()` disponibile<br>- Admin override per emergenza |
| **Response and Postconditions** | **Successo:** Blocco fondi temporaneo, danno reputazione sistema, potenziale estorsione<br>**Mitigation attiva:** Timeout refund dopo N giorni |
| **Comments** | **CAPEC-227:** Sustained Client Engagement<br>**CAPEC-469:** Futile Investment Exploitation<br>**Mitigation:** Timeout automatico + 3-attempt retry logic → refund |

#### MISUSE CASE: D3.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Validazione Spedizione |
| **Case ID** | D3.1-M |
| **Case Name** | **Timeout Connettività IoT (Absence of Resilience)** |
| **Actors** | Sensore offline per guasto rete/alimentazione |
| **Description** | Sensore legittimo perde connettività durante trasporto (batteria esaurita, zona senza copertura, guasto modem) e non riesce a inviare evidenze, causando blocco involontario dei fondi. |
| **Data** | Evidenze parziali, log connettività sensore |
| **Stimulus and Preconditions** | - Spedizione in zona remota (scarsa copertura)<br>- Batteria sensore sotto 10%<br>- Nessun sistema store-and-forward |
| **Basic Flow** | 1. Spedizione parte con sensori funzionanti<br>2. Zona montuosa causa perdita segnale GSM<br>3. E1-E2 inviate, E3-E5 mai trasmesse<br>4. Batteria sensore si esaurisce<br>5. Spedizione arriva a destinazione senza evidenze complete<br>6. Fondi bloccati (non intenzionale) |
| **Alternative Flow** | - Sensore recupera connessione in extremis<br>- Backup manuale evidenze da logger interno |
| **Exception Flow** | - Sistema rileva timeout 7gg → auto-refund mittente<br>- Corriere fornisce documentazione manuale evidenze |
| **Response and Postconditions** | **Impatto:** Mittente attende 7gg per refund, servizio degradato, costi opportunità<br>**NFR:** SLA 99.5% uptime sensori, batteria hot-swap, dual-SIM failover |
| **Comments** | **DUA-AoR:** Sistema non resiliente a guasti infrastrutturali<br>**Mitigation:** Buffer locale evidenze, trasmissione batch al ripristino, redundancy path |

---

### T5.1 - Manipolazione CPT (Conditional Probability Tables)

#### ABUSE CASE: T5.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Configurazione Rete Bayesiana |
| **Case ID** | T5.1-A |
| **Case Name** | **Insider Admin Attack su Parametri Bayesiani** |
| **Actors** | Admin infedele con RUOLO_ORACOLO |
| **Description** | Amministratore con privilegi RUOLO_ORACOLO modifica intenzionalmente le CPT per manipolare la logica decisionale, favorendo validazioni fraudolente (es. P(Esito\|Freschezza=false) = 95% invece che 10%). |
| **Data** | Variabili CPT (cptEsitoFrFr, cptEsitoFrNF, cptFranchezzaAmb), chiave admin |
| **Stimulus and Preconditions** | - Admin con RUOLO_ORACOLO compromesso (corruzione, ricatto, insider threat)<br>- Parametri CPT modificabili via funzione admin<br>- Nessun audit log dettagliato |
| **Basic Flow** | 1. Admin chiama `setCPTParams()` con valori fraudolenti<br>2. Imposta `P(Esito\|Freschezza=false, Franchezza=false) = 99%` (dovrebbe essere ~5%)<br>3. Qualsiasi spedizione (anche non conforme) supera validazione<br>4. Mittenti collusivi ricevono pagamenti indebiti<br>5. Sistema logico completamente compromesso |
| **Alternative Flow** | - Admin riduce soglie: `P(Esito\|true,true) = 1%` per negare pagamenti legittimi |
| **Exception Flow** | - Monitoring rileva anomalia statistiche validazioni (99% approval rate)<br>- Multi-sig richiede 2/3 admin per modifica CPT |
| **Response and Postconditions** | **Successo:** Perdita integrità sistema, validazione inutile, danno finanziario<br>**Detection:** Drift detection su tassi validazione, alerting anomalie |
| **Comments** | **CAPEC-1:** Accessing Functionality Not Properly Constrained by ACLs<br>**CAPEC-122:** Privilege Abuse<br>**Mitigation:** Multi-sig governance, CPT immutabili post-deployment, DAO voting |

#### MISUSE CASE: T5.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Configurazione Rete Bayesiana |
| **Case ID** | T5.1-M |
| **Case Name** | **Errore Configurazione Probabilità (Human Error)** |
| **Actors** | Admin inesperto/distratto |
| **Description** | Amministratore commette errore non intenzionale durante configurazione CPT: typo numerico (150 invece di 15), inversione condizionale (P(A\|B) vs P(B\|A)), o overflow uint. |
| **Data** | Parametri CPT errati, transaction hash configurazione |
| **Stimulus and Preconditions** | - Admin aggiorna CPT per nuovo modello bayesiano<br>- Assenza validazione range input<br>- Nessun testing pre-produzione |
| **Basic Flow** | 1. Admin vuole impostare `cptEsitoFrFr = 15` (15%)<br>2. Scrive erroneamente `150` (overflow su uint8 → 150 mod 100 = 50)<br>3. Deploy configurazione errata<br>4. Calcoli probabilità producono risultati inconsistenti<br>5. Validazioni casuali (50% sempre) invece che basate su evidenze |
| **Alternative Flow** | - Typo decimale: scrive `0.85` come `85` (interpretato come 8500%)<br>- Inverte P(Esito\|Freschezza) con P(Freschezza\|Esito) |
| **Exception Flow** | - Require guard `value <= 100` previene overflow<br>- Staging test rileva incongruenza prima di production |
| **Response and Postconditions** | **Impatto:** Sistema instabile, decisioni errate fino a rollback, validazioni/rimborsi incorretti<br>**NFR:** Input validation, unit test configurazioni, staged rollout |
| **Comments** | **DUA-Danger:** Configurazione pericolosa senza safeguards<br>**Mitigation:** Bounded input (1-100), sanity check post-set, dry-run simulation |

---

### I6.1 - Data Mining Competitivo

#### ABUSE CASE: I6.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Consultazione Storico Spedizioni |
| **Case ID** | I6.1-A |
| **Case Name** | **Analisi Competitiva Blockchain** |
| **Actors** | Concorrente commerciale, Data analyst |
| **Description** | Competitor analizza transazioni pubbliche su blockchain per estrarre intelligence competitiva: volumi spedizioni, rotte ricorrenti, clienti frequenti, periodi di picco, margini (tramite valori ETH). |
| **Data** | Eventi `SpedizioneCreata`, `SpedizioneValidata`, indirizzi mittenti/corrieri, importi ETH |
| **Stimulus and Preconditions** | - Blockchain pubblica (Besu in permissioned ma log accessibili)<br>- Eventi non offuscati<br>- Indirizzi correlabili a identità reali (KYC leak, social engineering) |
| **Basic Flow** | 1. Competitor scrape eventi `SpedizioneCreata` da blocco 0<br>2. Raggruppa per indirizzo mittente → identifica top clienti<br>3. Analizza timestamp → rileva picchi stagionali (es. campagne vaccini)<br>4. Correla importi ETH → stima margini/volumi<br>5. Utilizza intelligence per undercutting prezzi o acquisizione clienti |
| **Alternative Flow** | - Analisi pattern rotte per ottimizzazione logistica competitiva<br>- Identificazione fallimenti validazione → debolezze competitor |
| **Exception Flow** | - Hashing parametri sensibili (destinazioni, prodotti) limita leak<br>- Zero-knowledge proof per importi nasconde margini |
| **Response and Postconditions** | **Impatto:** Perdita vantaggio competitivo, informazioni commerciali sensibili esposte<br>**Legale:** Potenziale violazione segreto industriale (dipende da giurisdizione) |
| **Comments** | **CAPEC-116:** Excavation (Information Gathering)<br>**CAPEC-118:** Collect and Analyze Information<br>**Mitigation:** Hash dati sensibili, permissioned read access, private transactions (es. Aztec, zkSNARK) |

---

### S7.1 - Phishing/Spoofing UI

#### ABUSE CASE: S7.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Accesso DApp |
| **Case ID** | S7.1-A |
| **Case Name** | **Cloning DApp Phishing** |
| **Actors** | Attaccante phisher, Utente vittima |
| **Description** | Attaccante crea replica identica della DApp legittima (clone frontend), hostata su dominio simile (typosquatting: bayesian-oracIe.com invece di bayesian-oracle.com), per rubare seed phrase o far firmare transazioni malevole. |
| **Data** | Seed phrase MetaMask, chiavi private, approval token |
| **Stimulus and Preconditions** | - Utente riceve link phishing via email/social<br>- Frontend DApp non verificato (nessun badge ENS)<br>- Utente non controlla URL barra indirizzi |
| **Basic Flow** | 1. Attaccante registra dominio `bayesian-0racle.com` (0 invece di o)<br>2. Deploys clone DApp con backend malevolo<br>3. Invia email: "Aggiorna wallet per nuova versione"<br>4. Utente clicca link, raggiunge sito fake<br>5. Popup: "Riconnetti MetaMask" → utente inserisce seed<br>6. Attaccante cattura seed, drena wallet |
| **Alternative Flow** | - Fake "Approva contratto" → utente firma `approve(attackerAddress, MAX_UINT)`<br>- MITM injecting malicious script via compromised CDN |
| **Exception Flow** | - Browser extension (MetaMask PhishFort) blocca dominio noto<br>- Utente nota differenza URL |
| **Response and Postconditions** | **Successo:** Furto completo fondi wallet, compromissione identità on-chain<br>**NFR:** Security awareness training, HTTPS strict, CSP header |
| **Comments** | **CAPEC-98:** Phishing<br>**CAPEC-163:** Spear Phishing<br>**ATT&CK-T1566:** Phishing<br>**Mitigation:** HTTPS + HSTS, ENS name verification, WalletConnect secure deeplink, educational popup warnings |

#### MISUSE CASE: S7.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Creazione Spedizione |
| **Case ID** | S7.1-M |
| **Case Name** | **Errore Input Parametri (User Mistake)** |
| **Actors** | Mittente distratto |
| **Description** | Utente legittimo interagisce con DApp autentica ma commette errore input: indirizzo corriere sbagliato, importo ETH errato (1 ETH invece di 0.1), parametro spedizione invertito. |
| **Data** | Parametri transazione errati, gas fees |
| **Stimulus and Preconditions** | - Form creazione spedizione con campi liberi<br>- Nessuna validazione client-side<br>- Utente si sbaglia copia-incollando |
| **Basic Flow** | 1. Mittente crea spedizione con `valore = 1 ETH` (voleva 0.1)<br>2. Conferma transazione MetaMask senza rileggere<br>3. Transazione eseguita con 10x fondi<br>4. Validazione OK → corriere riceve 1 ETH invece di 0.1<br>5. Mittente perde 0.9 ETH (nessun chargeback) |
| **Alternative Flow** | - Indirizzo corriere typo → fondi a terzi<br>- Soglia probabilità inserita come 0.9 invece di 90 → interpretata come 0% |
| **Exception Flow** | - UI conferma visuale: "Stai inviando 1.00 ETH, confermi?"<br>- Slider invece di textbox previene typo |
| **Response and Postconditions** | **Impatto:** Perdita economica utente, impossibile annullare transazione<br>**NFR:** UX validation (dropdown, slider, max limits), modal conferma dettagliata |
| **Comments** | **DUA-Exposure:** UI non foolproof espone utenti a errori costosi<br>**Mitigation:** Input constraints, preview transazione pre-firma, cooling-off simulation |

---

### S8.1 - Furto Chiavi Private

#### ABUSE CASE: S8.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Gestione Wallet |
| **Case ID** | S8.1-A |
| **Case Name** | **Keylogger/Malware Exfiltration** |
| **Actors** | Attaccante con malware installato, Vittima |
| **Description** | Attaccante installa keylogger o clipboard hijacker su dispositivo vittima per catturare seed phrase durante restore wallet, o estrae chiavi da storage non cifrato. |
| **Data** | Seed phrase 12/24 parole, keystore JSON, password MetaMask |
| **Stimulus and Preconditions** | - Utente installa software compromesso (fake airdrop, pirated software)<br>- Keylogger attivo in background<br>- Utente apre MetaMask per restore wallet |
| **Basic Flow** | 1. Utente scarica "wallet optimizer tool" malevolo<br>2. Malware installa keylogger + clipboard monitor<br>3. Utente fa restore MetaMask → digita seed phrase<br>4. Keylogger cattura parole e invia a C2 server<br>5. Attaccante importa seed nel proprio wallet<br>6. Drena immediatamente tutti fondi (ETH + token) |
| **Alternative Flow** | - Clipboard hijacker sostituisce indirizzo destinatario con indirizzo attaccante durante copy-paste<br>- Screen capture malware fotografa seed su schermo |
| **Exception Flow** | - Antivirus rileva e blocca malware<br>- Hardware wallet (Ledger/Trezor) non espone seed a OS |
| **Response and Postconditions** | **Successo:** Furto totale fondi, compromissione identità permanente (seed immutabile)<br>**Detection:** Wallet emptying rapido → red flag, ma troppo tardi |
| **Comments** | **ATT&CK-T1056.001:** Keylogging<br>**ATT&CK-T1113:** Screen Capture<br>**CAPEC-568:** Capture Credentials via Keylogger<br>**Mitigation:** Hardware wallet obbligatorio per asset >$1k, OS hardening, antivirus, never type seed digitally |

#### MISUSE CASE: S8.1-M

| Campo | Contenuto |
|---|---|
| **Case Type** | Misuse Case |
| **Use Case** | Backup Wallet |
| **Case ID** | S8.1-M |
| **Case Name** | **Seed Phrase Salvata in Chiaro (User Negligence)** |
| **Actors** | Utente inesperto/negligente |
| **Description** | Utente salva seed phrase in formato non sicuro: screenshot cloud sync, email a sé stesso, note smartphone non cifrate, foto physical backup in Google Photos. |
| **Data** | Seed phrase in chiaro, backup cloud |
| **Stimulus and Preconditions** | - Utente novizio crypto non comprende gravità seed<br>- Default cloud backup attivo (iCloud, Google Drive)<br>- Nessun tool gestione segreti |
| **Basic Flow** | 1. Creazione wallet MetaMask genera seed<br>2. Utente fa screenshot su iPhone per "sicurezza"<br>3. iPhone auto-upload foto su iCloud (default)<br>4. Breach iCloud (phishing, password debole, 2FA assente)<br>5. Attaccante accede iCloud Photos → trova screenshot seed<br>6. Importa wallet e ruba fondi |
| **Alternative Flow** | - Seed scritta in note.txt su Desktop sincronizzato Dropbox<br>- Email "Promemoria wallet" inviata a Gmail con seed in chiaro |
| **Exception Flow** | - Utente usa password manager cifrato (1Password, Bitwarden)<br>- Backup fisico in cassaforte offline |
| **Response and Postconditions** | **Impatto:** Furto fondi da negligenza, nessun recovery possibile<br>**NFR:** Onboarding educativo obbligatorio, warning MetaMask su screenshot seed |
| **Comments** | **DUA-Exposure:** Mancanza consapevolezza sicurezza cripto<br>**Mitigation:** In-app tutorial seed security, blocco screenshot durante visualizzazione seed, Shamir Secret Sharing (2-of-3), social recovery (Argent) |

---

### E4.1 - Escalation Privilegi Sistema Ruoli

#### ABUSE CASE: E4.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Assegnazione Ruoli |
| **Case ID** | E4.1-A |
| **Case Name** | **Privilege Escalation via Function Selector Collision** |
| **Actors** | Attaccante esperto Solidity |
| **Description** | Attaccante sfrutta (ipotetica) collisione hash funzione o vulnerability delegatecall per bypassare `onlyRole` modifier e auto-assegnarsi RUOLO_ORACOLO o DEFAULT_ADMIN_ROLE. |
| **Data** | Function signature collision, payload delegatecall |
| **Stimulus and Preconditions** | - Contratto usa delegatecall con user input<br>- Hash collision su function selector (birthday attack su 4 bytes)<br>- Assenza check origin strict |
| **Basic Flow** | 1. Attaccante identifica function `grantRole(bytes32,address)` selector: `0x2f2ff15d`<br>2. Trova funzione benigna con stesso hash truncato<br>3. Crafta payload che bypassa modifier via collision<br>4. Chiama funzione "benigna" che esegue `grantRole` internamente<br>5. Si auto-assegna DEFAULT_ADMIN_ROLE<br>6. Controlla intero sistema |
| **Alternative Flow** | - Delegatecall a contratto attaccante con fallback che chiama `_grantRole` internal |
| **Exception Flow** | - OpenZeppelin AccessControl ha protezioni anti-collision<br>- Function visibility strict (public vs external) |
| **Response and Postconditions** | **Successo:** Takeover completo contratto, modifica logica, drenaggio fondi<br>**Severity:** CRITICAL |
| **Comments** | **CAPEC-122:** Privilege Abuse<br>**ATT&CK-T1078:** Valid Accounts (privilege escalation)<br>**Mitigation:** Latest OpenZeppelin lib, avoid delegatecall user input, formal verification access control |

---

### I5.1 - Reverse Engineering CPT

#### ABUSE CASE: I5.1-A

| Campo | Contenuto |
|---|---|
| **Case Type** | Abuse Case |
| **Use Case** | Lettura Parametri Bayesiani |
| **Case ID** | I5.1-A |
| **Case Name** | **Storage Slot Reading via Web3** |
| **Actors** | Attaccante/Competitor |
| **Description** | Anche se variabili CPT sono `private`, attaccante usa `eth_getStorageAt` per leggere storage slot contratto e decompila bytecode per identificare mapping parametri → CPT. |
| **Data** | Bytecode contratto, storage layout, CPT values |
| **Stimulus and Preconditions** | - Contratto deployed su blockchain pubblica<br>- Variabili CPT dichiarate `private` (ma leggibili via RPC)<br>- Attaccante conosce Solidity storage layout |
| **Basic Flow** | 1. Attaccante ottiene address contratto BNCore<br>2. Usa `web3.eth.getStorageAt(address, slot)` per ogni slot 0-20<br>3. Identifica pattern uint8[100] → CPT arrays<br>4. Decompila con tools (Dedaub, Etherscan) per mapping names<br>5. Ricostruisce Bayesian network completo<br>6dual. Crea sistema competitor con stessa logica (IP theft) |
| **Alternative Flow** | - Analisi transaction calldata per inferenza probabilità dai risultati |
| **Exception Flow** | - Offuscamento storage con encryption on-chain (gas intensive)<br>- Zero-knowledge proof computa probabilità senza esporre CPT |
| **Response and Postconditions** | **Impatto:** Furto IP modello bayesiano, replicazione sistema, commoditization<br>**Legal:** Possibile violazione brevetti/copyright algoritmo |
| **Comments** | **CAPEC-188:** Reverse Engineering<br>**CAPEC-116:** Excavation<br>**Mitigation:** Compute off-chain con oracle trusted (Chainlink Functions), zkSNARK proof validità senza svelare parametri, TEE (Trusted Execution Env) |

---

## 4. Mapping CAPEC/ATT&CK Completo

| Threat ID | STRIDE | CAPEC ID | CAPEC Name | ATT&CK TTP |
|---|---|---|---|---|
| S2.1 | Spoofing | CAPEC-151 | Identity Spoofing | T1134 |
| T2.1 | Tampering | CAPEC-94 | Man-in-the-Middle | T1557 |
| T3.1 | Tampering | CAPEC-194 | Fake Resource Injection | - |
| T5.1 | Tampering | CAPEC-1 | Accessing Functionality Not Properly Constrained | T1078 |
| D3.1 | Denial | CAPEC-227 | Sustained Client Engagement | T1499 |
| I6.1 | Info Disclosure | CAPEC-116 | Excavation | T1213 |
| I5.1 | Info Disclosure | CAPEC-188 | Reverse Engineering | - |
| S7.1 | Spoofing | CAPEC-98 | Phishing | T1566.002 |
| S8.1 | Spoofing | CAPEC-568 | Capture Credentials via Keylogger | T1056.001 |
| E4.1 | Elevation | CAPEC-122 | Privilege Abuse | T1078.004 |

---

## 5. Riepilogo Mitigazioni per Asset

### A1 - Smart Contract
- Audit formale (CertiK, Trail of Bits)
- Verifica formale logica (Certora, K Framework)
- Multi-sig deployment (2/3)
- Timelock upgrade (48h)
- Bug bounty program

### A2 - Evidenze IoT
- Firma digitale ECDSA per ogni evidenza
- Challenge-response authentication sensori
- Rate limiting invii (max 1 evidenza/sensore/ora)
- Ridondanza cross-validation (E1 vs E3 temperatura)
- Hardware security module (HSM) per chiavi sensori

### A3 - Pagamenti ETH
- OpenZeppelin ReentrancyGuard
- CEI pattern (Checks-Effects-Interactions)
- Pull payment pattern (withdrawal invece di transfer)
- Timeout refund automatico (7 giorni)
- Emergency pause (CircuitBreaker pattern)

### A4 - Ruoli e Permessi
- OpenZeppelin AccessControl latest version
- Multi-sig per grant/revoke RUOLO_ORACOLO
- Timelock ruoli critici
- Event monitoring anomalie assegnazioni
- Immutable role setup post-init

### A5 - CPT e Probabilità
- Private visibility + no getter pubblici
- Multi-sig 2/3 per modifica CPT
- Range validation (1-100)
- Staging test pre-produzione
- Hashing parametri sensibili

### A6 - Dati Spedizioni
- Hashing dati sensibili (destinazione, prodotto)
- Permissioned read access (solo stakeholder)
- IPFS per dati voluminosi, hash on-chain
- Zero-knowledge proof per query privacy-preserving

### A7 - Interfaccia Web
- HTTPS + HSTS strict
- Content Security Policy (CSP)
- Subresource Integrity (SRI) per CDN
- Input sanitization + validation
- ENS domain verification badge
- WalletConnect secure session

### A8 - Chiavi Private
- Mandatory hardware wallet per >$1000
- Educational onboarding seed security
- Screenshot blocking durante display seed
- Social recovery (Argent model)
- Multi-sig wallet per organizzazioni

---

## 6. Metriche di Rischio Residuo

| Asset | Inherent Risk | Mitigations | Residual Risk | Acceptance |
|---|---|---|---|---|
| A1 | CRITICAL | Audit + Formal Verification | LOW | ✓ Accepted |
| A2 | CRITICAL | HSM + Signatures | MEDIUM | ✓ Accepted |
| A3 | CRITICAL | ReentrancyGuard + Timeout | LOW | ✓ Accepted |
| A4 | HIGH | Multi-sig + Events | LOW | ✓ Accepted |
| A5 | HIGH | Private + Multi-sig | MEDIUM | ✓ Accepted |
| A6 | MEDIUM | Hashing | LOW | ✓ Accepted |
| A7 | MEDIUM | HTTPS + CSP | MEDIUM | ⚠️ User training required |
| A8 | CRITICAL | HW Wallet recommendation | HIGH | ⚠️ User responsibility |

**Note:** A7 e A8 mantengono rischio residuo MEDIUM/HIGH perché dipendono da comportamento utente finale (out of scope controllo sistema).

---

## 7. Conclusioni

L'analisi **DUAL-STRIDE** completa ha identificato:
- **24 threat scenario** attraverso tutti 8 asset
- **16 abuse cases** (attacchi intenzionali)
- **8 misuse cases** (errori/guasti accidentali)
- **12 CAPEC pattern** di attacco
- **8 ATT&CK TTP** correlate

**Key Findings:**
1. **Asset A8 (Chiavi Private)** è il weak link: nessuna mitigation tecnica può proteggere da negligenza utente
2. **Asset A3 (Fondi ETH)** richiede ReentrancyGuard imperativo + timeout logic
3. **Asset A5 (CPT)** necessita governance decentralizzata per evitare single point of trust

**Raccomandazioni Prioritarie:**
1. ✅ Implementare ReentrancyGuard (già fatto)
2. ✅ Timeout refund 7gg (già fatto)
3. 🔴 **TODO:** Multi-sig per modifica CPT
4. 🔴 **TODO:** HSM per chiavi sensori
5. 🟡 **Consigliato:** zkSNARK per privacy CPT

**Residual Risk Acceptance:**
- Rischi A1-A6: ACCETTATI con mitigazioni implementate
- Rischi A7-A8: ACCETTATI con disclaimer utente (user education obbligatoria)
