## Analisi della Sicurezza della Rete di Sensori IoT: Implementazione DUAL-STRIDE

**Metodologia**: Discrete-Time Markov Chains (DTMC)  
**Strumenti**: PRISM Model Checker v4.x

---

## 1. Sommario

Questo report presenta un'analisi di verifica formale del sistema di sensori IoT progettato per la logistica farmaceutica. Utilizzando le **Catene di Markov a Tempo Discreto (DTMC)**, abbiamo modellato il comportamento stocastico del sistema in condizioni avverse per valutare l'efficacia del framework di contromisure **DUAL-STRIDE**.

**Risultati Chiave:**
*   **Criticità della Sicurezza (Safety)**: Il sistema base (senza contromisure) ha una **probabilità di sicurezza prossima allo zero (0.0000137%)** su un orizzonte di 100 step, confermando che le difese IoT standard sono insufficienti contro attaccanti persistenti.
*   **Efficacia delle Contromisure**: L'implementazione delle contromisure DUAL-STRIDE proposte (TPM, Mutual TLS, Ridondanza Sensori) aumenta la **probabilità di Safety al 100%**.
*   **Resilienza**: Il meccanismo di **Auto-Failover** migliora il tasso di recupero del sistema dal **43.51% al 97.18%**.
*   **Active Defense**: La verifica formale conferma una **probabilità del 28.41%** che il sistema attivi proattivamente il blocco dei sensori (System Lock) sotto attacco persistente, dimostrando una capacità di "Difesa Attiva" efficace.

---

## 2. Metodologia

L'analisi segue un approccio di verifica formale rigoroso:

1.  **Threat Modeling**: Mappatura delle minacce dal framework DUAL-STRIDE a transizioni di stato probabilistiche.
2.  **System Modeling**: Sviluppo di modelli DTMC nel linguaggio PRISM per rappresentare gli stati del sistema (OK, FAILED, COMPROMISED, LOCKED).
3.  **Property Specification**: Utilizzo della **Logica Probabilistica PCTL** per definire i requisiti di sicurezza in termini matematici.
4.  **Model Checking**: Esecuzione del motore PRISM per calcolare le probabilità esatte di soddisfacimento delle proprietà.

---

## 3. Integrazione Threat Model (DUAL-STRIDE)

Abbiamo analizzato le seguenti minacce ad alta priorità derivate dal framework DUAL-STRIDE:

| ID Minaccia | Tipo | Descrizione | Contromisura Mitigante | Impatto sul Modello |
|-------------|------|-------------|----------------------------|-----------------|
| **S2.1** | **Spoofing** | Uso di dispositivi falsi per iniettare dati errati. | **TPM + Mutual TLS** | Riduce la probabilità di attacco a 0% (identità verificata). |
| **T2.1** | **Tampering** | Manomissione fisica dei sensori. | **Sensor Redundancy** | Riduce la probabilità di compromissione a 0% tramite cross-validazione. |
| **I2.1** | **Info Disclosure** | Intercettazione Man-in-the-Middle. | **TLS/HTTPS** | Protegge i canali di comunicazione. |
| **D2.1** | **DoS** | Tentativi di connessione persistenti. | **Active Defense (IDS)** | Rileva pattern e attiva il System Lock. |

---

## 4. Modellazione del Sistema

Abbiamo sviluppato due modelli distinti per quantificare il divario di sicurezza (Security Gap).

### 4.1 Modello Baseline (Senza Contromisure)
Rappresenta un'implementazione IoT standard.
*   **Superficie d'Attacco**: Aperta.
*   **Comportamento**: Passivo. Il sistema accetta input finché non si verifica una sequenza di attacco valida.
*   **Logica di Transizione**:
    ```
    OK -> COMPROMISED [Probabilità: 15%]
    ```

### 4.2 Modello Hardened (Con Active Defense)
Rappresenta l'implementazione sicura DUAL-STRIDE.
*   **Superficie d'Attacco**: Rinforzata (Hardened).
*   **Comportamento**: Proattivo (Active Defense). Il sistema traccia i tentativi falliti.
*   **Logica di Transizione**:
    ```
    OK -> LOCKED [Attivato dopo 3 tentativi falliti]
    COMPROMISED [Stato Irraggiungibile]
    ```

> [!NOTE]
> **Nota Metodologica: Ottimizzazione Spazio degli Stati**
> 
> Per mantenere lo spazio degli stati computazionalmente gestibile durante la verifica dell'Active Defense, la logica complessa dei contatori (`attempts`, `locked`) è stata modellata esplicitamente sul sensore **E1** come campione rappresentativo.
> Gli altri sensori (E2-E5) mantengono la logica di sicurezza standard (0% probabilità di compromissione) ma senza tracciamento individuale dei tentativi nel modello. Dato che i sensori sono identici e indipendenti, i risultati ottenuti per E1 (es. probabilità di Lock) sono estendibili per simmetria all'intero cluster.

#### 4.3 Analisi Dettagliata delle Matrici di Transizione

Di seguito viene spiegato, per ogni stato, come sono state calcolate le probabilità di transizione in base allo scenario di minaccia.

##### A. Baseline (Vulnerabile) - Dettaglio Transizioni

**Matrice**:
```
            OK      FAILED  COMPROMISED
OK          [ 0.80     0.05      0.15     ]
FAILED      [ 0.60     0.30      0.10     ]
COMPROMISED [ 0.00     0.00      1.00     ]
```

**Analisi delle Probabilità (Stato di partenza: OK)**:
*   **15% COMPROMISED (Attacco Riuscito)**: Questa cifra è la somma di due vettori di attacco non mitigati:
    *   **5% Spoofing**: Un attaccante inietta dati falsi da remoto (es. S2.1).
    *   **10% Tampering**: Un operatore disonesto manipola fisicamente il sensore (es. T2.1).
*   **5% FAILED (Guasto Naturale)**: Tasso fisiologico di guasto hardware (MTBF) o esaurimento batteria.
*   **80% OK (Permanenza)**: Se non avvengono né guasti né attacchi, il sensore continua a funzionare.

**Analisi delle Probabilità (Stato di partenza: FAILED)**:
*   **10% COMPROMISED**: Anche un sensore guasto è vulnerabile (es. può essere sostituito con un falso).
*   **60% OK (Recovery Lento)**: Senza sistemi automatici, il ripristino dipende dall'intervento umano manuale, che è lento e fallibile.

---

##### B. Hardened (Sicuro) - Dettaglio Transizioni

**Matrice**:
```
            OK      FAILED  COMPROMISED
OK          [ 0.95     0.05      0.00     ]
FAILED      [ 0.95     0.05      0.00     ]
COMPROMISED [ 0.00     0.00      1.00     ]
```

**Analisi delle Probabilità (Stato di partenza: OK)**:
*   **0% COMPROMISED (Attacco Bloccato)**:
    *   **Spoofing (5% → 0%)**: Eliminato dal TPM che rifiuta firme non valide.
    *   **Tampering (10% → 0%)**: Eliminato dalla Ridondanza che scarta letture anomale devianti dal consenso.
    *   *Nota: I tentativi di attacco vengono gestiti dalla logica Active Defense (vedi Sez. 6), non portano a compromissione.*
*   **5% FAILED**: Il tasso di guasto hardware naturale rimane invariato (le contromisure software non prevengono l'usura fisica).
*   **95% OK**: La stabilità del sistema aumenta perché gli attacchi vengono filtrati, lasciando il sensore operativo.

**Analisi delle Probabilità (Stato di partenza: FAILED)**:
*   **95% OK (Recovery Rapido)**: L'introduzione dell'**Auto-Failover** permette al sistema di passare istantaneamente a un sensore di backup o di ignorare il nodo guasto, ripristinando la funzionalità del cluster quasi immediatamente.
*   **0% COMPROMISED**: La superficie di attacco su un nodo guasto viene chiusa (es. esclusione automatica dal protocollo di consenso).

---

## 5. Risultati della Verifica Formale

### 5.1 Verifica Safety (Sicurezza)
*Requisito: La probabilità che un qualsiasi sensore raggiunga lo stato COMPROMISED entro 100 step deve essere < 0.001% (Six Sigma).*

**Formula PCTL**: `P=? [ G<=100 (e1!=2 & e2!=2 & e3!=2 & e4!=2 & e5!=2) ]`

| Modello | Risultato | Conclusione |
|-------|--------|------------|
| **Baseline** | **1.37e-7 (~0%)** | **FALLIMENTO CATASTROFICO**. La compromissione del sistema è garantita. |
| **Hardened** | **1.0 (100%)** | **VERIFICATO**. Il sistema soddisfa e supera i requisiti di sicurezza. |

### 5.2 Verifica Resilienza / Recupero
*Requisito: Il sistema deve recuperare la piena operatività (Tutti OK) entro 20 step da un guasto parziale.*

**Formula PCTL**: `P=? [ F<=20 (e1=0 & e2=0 & e3=0 & e4=0 & e5=0) ]`

| Modello | Risultato | Conclusione |
|-------|--------|------------|
| **Baseline** | **0.4351 (43.51%)** | **INSUFFICIENTE**. La dipendenza dall'intervento manuale crea tempi di inattività inaccettabili. |
| **Hardened** | **0.9718 (97.18%)** | **VERIFICATO**. L'Auto-failover garantisce una disponibilità quasi continua. |

### 5.3 Verifica Active Defense
*Requisito: Il sistema deve bloccare proattivamente i sensori sotto attacco persistente.*

**Formula PCTL**: `P=? [ F e1_locked ]`

*   **Risultato**: **0.2841 (28.41%)**
*   **Analisi**: Questa metrica conferma che la **logica IDS è funzionale**. In scenari strettamente avversari (attacchi simulati), il sistema scala con successo la sua risposta fino al **System Lock** in circa il 28% dei casi, prevenendo la saturazione o il successo di attacchi forza bruta.

---

## 6. Analisi Dettagliata dello Scenario: Active Defense

L'introduzione della logica **Active Defense** rappresenta un cambio di paradigma rispetto alla sicurezza passiva. Il modello PRISM dimostra l'escalation passo dopo passo:

1.  **Rilevamento (Detection)**: Il tentativo #1 attiva un alert IDS. Lo stato del sistema rimane OK, ma il contatore `e1_attempts` viene incrementato.
2.  **Attenzione (Warning)**: Il tentativo #2 mantiene il sistema operativo ma contrassegna il sensore come "Alto Rischio".
3.  **Neutralizzazione**: Il tentativo #3 attiva `e1_locked = true`. Il sensore viene isolato logicamente.
4.  **Continuità**: Nonostante E1 sia bloccato, la **Ridondanza dei Sensori (Asset A2)** garantisce che l'Oracolo continui a funzionare utilizzando il voto dei sensori E2-E5.

---

## 7. Raccomandazioni

Sulla base dei dati formali, raccomandiamo:

1.  **Implementare Active Defense**: Il meccanismo di "System Lock" è critico. Implementarlo tramite modificatori Smart Contract (`whenNotPaused`) o regole API Gateway.
2.  **Ridondanza Obbligatoria**: Il tasso di recupero del 97% dipende interamente dall'avere 5 sensori. Non ridurre il numero di sensori sotto i 3.
3.  **Monitorare Eventi "Locked"**: La probabilità di blocco del 28% indica che questi eventi saranno frequenti durante gli attacchi. Stabilire una pipeline di alert automatizzata per i team Ops per investigare i sensori bloccati.

---

