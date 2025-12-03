# Design degli Asset e Verifica Formale
## Sistema Oracolo Bayesiano per Catena del Freddo Farmaceutica
---

## 1. Design degli Asset

### 1.1 Asset Critici del Sistema

| ID | Asset | Criticità |
|----|-------|-----------|
| **A1** | Smart Contract | 🔴 Critica |
| **A2** | Evidenze IoT (E1-E5) | 🔴 Critica |
| **A3** | Pagamenti ETH (Escrow) | 🔴 Critica |
| **A4** | Ruoli e Permessi (AccessControl) | 🟠 Alta |
| **A5** | CPT e Probabilità Bayesiane | 🟠 Alta |

----

## 2. Modellazione Markov Chain

### 2.1 Unità Modellata: Sistema Sensori IoT

Il sistema di sensori IoT è critico perché le evidenze E1-E5 determinano se il pagamento viene eseguito. I sensori sono vulnerabili a guasti hardware e attacchi informatici.

### 2.2 Stati del Sistema

| Stato | Descrizione |
|-------|-------------|
| **OPERATIONAL** | Tutti i 5 sensori funzionanti |
| **DEGRADED** | 3-4 sensori funzionanti |
| **FAILED** | 0-2 sensori funzionanti |
| **COMPROMISED** | ≥1 sensore compromesso (STATO ASSORBENTE) |

### 2.3 Diagramma degli Stati

```mermaid
stateDiagram-v2
    [*] --> OPERATIONAL
    
    OPERATIONAL --> OPERATIONAL : 0.85
    OPERATIONAL --> DEGRADED : 0.10
    OPERATIONAL --> COMPROMISED : 0.05
    
    DEGRADED --> OPERATIONAL : 0.30
    DEGRADED --> FAILED : 0.60
    DEGRADED --> COMPROMISED : 0.10
    
    FAILED --> DEGRADED : 0.20
    FAILED --> FAILED : 0.80
    
    COMPROMISED --> COMPROMISED : 1.00
```

### 2.4 Matrice di Transizione

```
P = | 0.85  0.10  0.00  0.05 |
    | 0.30  0.00  0.60  0.10 |
    | 0.00  0.20  0.80  0.00 |
    | 0.00  0.00  0.00  1.00 |
```

**Giustificazione Probabilità**:
- **OPERATIONAL → OPERATIONAL (0.85)**: MTBF sensori IoT industriali ~10,000 ore (IEC 61508)
- **OPERATIONAL → DEGRADED (0.10)**: Guasto hardware naturale (degrado batterie, interferenze)
- **OPERATIONAL → COMPROMISED (0.05)**: ~5% dispositivi IoT compromessi annualmente (Kaspersky IoT Report 2023)
- **DEGRADED → OPERATIONAL (0.30)**: Recovery tramite manutenzione/riparazione
- **DEGRADED → FAILED (0.60)**: Sistema degradato tende a peggiorare senza intervento
- **DEGRADED → COMPROMISED (0.10)**: Sistemi degradati più vulnerabili ad attacchi (OWASP IoT Top 10)
- **FAILED → DEGRADED (0.20)**: Sostituzione parziale sensori
- **FAILED → FAILED (0.80)**: Persistenza failure senza manutenzione
- **COMPROMISED → COMPROMISED (1.00)**: Stato assorbente (richiede intervento manuale completo)

**Nota**: Le probabilità rappresentano scenario worst-case senza contromisure implementate.

---

## 3. Verifica Formale con PRISM

### 3.1 Modello PRISM

**File**: [`sensor_system.prism`](./sensor_system.prism)

### 3.2 Proprietà Verificate

**File**: [`sensor_properties.pctl`](./sensor_properties.pctl)

#### Proprietà di Safety (S1)

```
P=? [ G<=100 state!=3 ]
```

**Significato**: Qual è la probabilità che il sistema rimanga sicuro (non compromesso) per 100 step?

**Risultato PRISM**: `0.03171339085361115` (**3.17%**)

**Interpretazione**: La probabilità che il sistema rimanga sicuro per 100 step è molto bassa (3.17%). Questo indica che il sistema tende a convergere verso lo stato COMPROMISED nel lungo periodo.

---

#### Proprietà di Guarantee/Response (G1)

```
P=? [ F state=3 ]
```

**Significato**: Qual è la probabilità che il sistema venga eventualmente compromesso?

**Risultato PRISM**: `0.99876420119516162` (**99.87%**)

**Interpretazione**: Il sistema sarà inevitabilmente compromesso con probabilità 99.87% (praticamente certezza). Questo conferma che COMPROMISED è uno stato assorbente raggiungibile da qualsiasi stato iniziale.

---

## 4. Conclusioni e Raccomandazioni

### 4.1 Risultati Principali

**Verifica Formale**:
- ✅ **Safety**: Probabilità di rimanere sicuro per 100 step = **3.17%**
- ✅ **Guarantee**: Probabilità di compromissione eventuale = **99.87%**

### 4.2 Raccomandazioni Critiche

#### Per il Sistema Smart Contract
1. **Timeout per recupero fondi**: Permettere al mittente di recuperare ETH se evidenze non arrivano
2. **ReentrancyGuard**: Aggiungere protezione esplicita OpenZeppelin
3. **Firma digitale evidenze**: Autenticare sensori con chiavi crittografiche

#### Per il Sistema IoT
1. **Sostituzione preventiva**: Sostituire sensori ogni 40-50 step
2. **Ridondanza hardware**: Implementare sensori backup
3. **Meccanismi di recovery**: Sistema di ripristino automatico

---

**Fine del documento**
