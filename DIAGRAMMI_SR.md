# 🎯 Diagrammi SR (Strategic Rationale) - Sistema Blockchain Spedizioni

## 📋 Panoramica

I diagrammi SR mostrano la **struttura interna** di ogni attore, includendo:
- **Goal** (🎯) - Obiettivi da raggiungere
- **Task** (🔷) - Compiti specifici da eseguire
- **Resource** (📦) - Risorse necessarie o prodotte
- **Softgoal** (☁️) - Obiettivi di qualità non funzionali

Le relazioni interne possono essere:
- **Means-End** - Un mezzo per raggiungere un fine
- **Task Decomposition** - Scomposizione di un task in sottoelementi
- **Contribution** - Contributo positivo o negativo a softgoal

---

## 👤 SR Diagram: Mittente

### Goal Principale
🎯 **Effettuare Spedizione Sicura**

### Decomposizione Interna

```
Mittente
├─ 🎯 Effettuare Spedizione Sicura [GOAL]
│  ├─ [AND]
│  │  ├─ 🔷 Creazione Spedizione [TASK]
│  │  │  ├─ 📦 Dati Merce [RESOURCE]
│  │  │  ├─ 📦 Dati Destinatario [RESOURCE]
│  │  │  └─ 🔷 Interazione Smart Contract [TASK]
│  │  │
│  │  ├─ 🎯 Validazione Evidenze [GOAL]
│  │  │  ├─ [OR]
│  │  │  │  ├─ 🔷 Validazione Automatica [TASK]
│  │  │  │  └─ 🔷 Richiesta Validazione Admin [TASK]
│  │  │
│  │  └─ 🔷 Pagamento Automatico [TASK]
│  │     ├─ 📦 Smart Contract Escrow [RESOURCE]
│  │     └─ 🔷 Rilascio Fondi [TASK]
│  │
│  └─ Contributi:
│     └─ ☁️ Tracciabilità Immutabile [SOFTGOAL] [++]
│        ├─ contributo da: Creazione Spedizione
│        └─ contributo da: Validazione Evidenze
│
└─ 🎯 Consegna Fisica Merce [GOAL] (dipendenza esterna → Corriere)
   └─ 📦 Informazioni Destinatario [RESOURCE] (fornita da Corriere)
```

### Relazioni Chiave
- **Creazione Spedizione** contribuisce positivamente a **Tracciabilità Immutabile**
- **Validazione Evidenze** può essere raggiunto tramite validazione automatica O richiesta ad admin
- **Pagamento Automatico** dipende dallo Smart Contract Escrow

---

## ⛓️ SR Diagram: Sistema_Blockchain

### Goal Principale
🎯 **Garantire Sistema di Spedizioni Affidabile**

### Decomposizione Interna

```
Sistema_Blockchain
├─ 🎯 Garantire Sistema di Spedizioni Affidabile [GOAL]
│  ├─ [AND]
│  │  ├─ 🔷 Gestione Spedizioni [TASK]
│  │  │  ├─ 📦 Registro Blockchain [RESOURCE]
│  │  │  ├─ 🔷 Memorizzazione Dati [TASK]
│  │  │  ├─ 🔷 Validazione Transazioni [TASK]
│  │  │  └─ 📦 Hash Spedizioni [RESOURCE]
│  │  │
│  │  ├─ 🔷 Gestione Evidenze [TASK]
│  │  │  ├─ 📦 Evidenze Fotografiche [RESOURCE]
│  │  │  ├─ 📦 IPFS Hash [RESOURCE]
│  │  │  ├─ 🔷 Memorizzazione Off-Chain [TASK]
│  │  │  └─ 🎯 Approvazione Evidenze [GOAL] (dipendenza da Admin)
│  │  │
│  │  ├─ 🔷 Gestione Pagamenti [TASK]
│  │  │  ├─ 📦 Smart Contract Escrow [RESOURCE]
│  │  │  ├─ 🔷 Blocco Fondi [TASK]
│  │  │  ├─ 🔷 Rilascio Fondi [TASK]
│  │  │  └─ 📦 Conferma Consegna [RESOURCE] (dipendenza da Corriere)
│  │  │
│  │  ├─ 🔷 Monitoraggio Ambientale [TASK]
│  │  │  ├─ 📦 Letture Ambientali [RESOURCE] (dipendenza da Sensore)
│  │  │  ├─ 📦 Timestamp Certificato [RESOURCE] (dipendenza da Sensore)
│  │  │  ├─ 🔷 Verifica Condizioni [TASK]
│  │  │  └─ ☁️ Dati Affidabili [SOFTGOAL] (dipendenza da Sensore)
│  │  │
│  │  └─ 🔷 Gestione Autorizzazioni [TASK]
│  │     ├─ 📦 Access Control List [RESOURCE]
│  │     ├─ 🔷 Gestione Ruoli [TASK] (con Admin)
│  │     └─ 🔷 Configurazione Sistema [TASK] (dipendenza da Admin)
│  │
│  └─ Contributi Softgoal:
│     ├─ ☁️ Sicurezza [SOFTGOAL] [++]
│     ├─ ☁️ Trasparenza [SOFTGOAL] [++]
│     ├─ ☁️ Immutabilità [SOFTGOAL] [++]
│     └─ ☁️ Decentralizzazione [SOFTGOAL] [+]
```

### Relazioni Chiave
- **Gestione Spedizioni** è il core task, decomposto in memorizzazione e validazione
- **Gestione Evidenze** richiede approvazione da Admin
- **Gestione Pagamenti** dipende dalla conferma del Corriere
- **Monitoraggio Ambientale** dipende da dati affidabili dal Sensore
- Tutti i task contribuiscono fortemente ai softgoal di Sicurezza, Trasparenza, Immutabilità

---

## 🚚 SR Diagram: Corriere

### Goal Principale
🎯 **Completare Consegna e Ricevere Pagamento**

### Decomposizione Interna

```
Corriere
├─ 🎯 Completare Consegna e Ricevere Pagamento [GOAL]
│  ├─ [AND]
│  │  ├─ 🔷 Gestione Consegna [TASK]
│  │  │  ├─ 📦 Informazioni Destinatario [RESOURCE] (da Mittente)
│  │  │  ├─ 🔷 Pianificazione Percorso [TASK]
│  │  │  ├─ 🔷 Trasporto Merce [TASK]
│  │  │  └─ 🔷 Consegna Fisica [TASK]
│  │  │
│  │  ├─ 🔷 Registrazione Consegna [TASK]
│  │  │  ├─ 🔷 Acquisizione Prova [TASK]
│  │  │  │  ├─ 📦 Foto Consegna [RESOURCE]
│  │  │  │  ├─ 📦 Firma Destinatario [RESOURCE]
│  │  │  │  └─ 📦 Geolocalizzazione [RESOURCE]
│  │  │  │
│  │  │  ├─ 🔷 Caricamento Evidenze [TASK]
│  │  │  │  ├─ 🔷 Upload IPFS [TASK]
│  │  │  │  └─ 📦 Prova di Conformità [RESOURCE]
│  │  │  │
│  │  │  └─ 🔷 Transazione Blockchain [TASK]
│  │  │     └─ 📦 Conferma Consegna [RESOURCE] (verso Sistema)
│  │  │
│  │  └─ 🎯 Ricezione Pagamento [GOAL]
│  │     ├─ 🔷 Verifica Rilascio Escrow [TASK]
│  │     └─ 📦 Pagamento Automatico [RESOURCE]
│  │
│  └─ Contributi Softgoal:
│     ├─ ☁️ Puntualità [SOFTGOAL] [++]
│     │  └─ contributo da: Pianificazione Percorso
│     └─ ☁️ Professionalità [SOFTGOAL] [+]
│        └─ contributo da: Acquisizione Prova
```

### Relazioni Chiave
- **Gestione Consegna** richiede informazioni dal Mittente
- **Registrazione Consegna** produce la Prova di Conformità
- **Ricezione Pagamento** dipende dal completamento della registrazione
- **Pianificazione Percorso** contribuisce a softgoal Puntualità

---

## 📡 SR Diagram: Sensore

### Goal Principale
🎯 **Fornire Monitoraggio Ambientale Affidabile**

### Decomposizione Interna

```
Sensore
├─ 🎯 Fornire Monitoraggio Ambientale Affidabile [GOAL]
│  ├─ [AND]
│  │  ├─ 🔷 Acquisizione Dati [TASK]
│  │  │  ├─ 📦 Sensore Temperatura [RESOURCE]
│  │  │  ├─ 📦 Sensore Umidità [RESOURCE]
│  │  │  ├─ 📦 Sensore Movimento [RESOURCE]
│  │  │  └─ 🔷 Lettura Periodica [TASK]
│  │  │
│  │  ├─ 🔷 Invio Dati Ambientali [TASK]
│  │  │  ├─ 🔷 Formattazione Dati [TASK]
│  │  │  ├─ 🔷 Trasmissione Sicura [TASK]
│  │  │  │  ├─ 📦 Crittografia [RESOURCE]
│  │  │  │  └─ 📦 Firma Digitale [RESOURCE]
│  │  │  │
│  │  │  └─ 📦 Timestamp Certificato [RESOURCE] (verso Sistema)
│  │  │
│  │  └─ 🔷 Calibrazione [TASK]
│  │     ├─ 🔷 Auto-Calibrazione [TASK]
│  │     └─ 🔷 Verifica Accuratezza [TASK]
│  │
│  └─ Contributi Softgoal:
│     ├─ ☁️ Dati Affidabili [SOFTGOAL] [++]
│     │  ├─ contributo da: Calibrazione
│     │  └─ contributo da: Trasmissione Sicura
│     │
│     ├─ ☁️ Accuratezza [SOFTGOAL] [++]
│     │  └─ contributo da: Verifica Accuratezza
│     │
│     └─ ☁️ Integrità Dati [SOFTGOAL] [++]
│        └─ contributo da: Firma Digitale
```

### Relazioni Chiave
- **Acquisizione Dati** richiede sensori hardware funzionanti
- **Invio Dati Ambientali** richiede trasmissione sicura con crittografia
- **Calibrazione** contribuisce fortemente al softgoal Dati Affidabili
- **Timestamp Certificato** garantisce la tracciabilità temporale

---

## 👨‍💼 SR Diagram: Admin

### Goal Principale
🎯 **Amministrare Sistema in Modo Efficace**

### Decomposizione Interna

```
Admin
├─ 🎯 Amministrare Sistema in Modo Efficace [GOAL]
│  ├─ [AND]
│  │  ├─ 🔷 Gestione Ruoli [TASK]
│  │  │  ├─ 🔷 Creazione Ruoli [TASK]
│  │  │  │  ├─ 📦 Role: Mittente [RESOURCE]
│  │  │  │  ├─ 📦 Role: Corriere [RESOURCE]
│  │  │  │  └─ 📦 Role: Admin [RESOURCE]
│  │  │  │
│  │  │  ├─ 🔷 Assegnazione Permessi [TASK]
│  │  │  │  └─ 📦 Access Control Matrix [RESOURCE]
│  │  │  │
│  │  │  └─ 🔷 Revoca Accessi [TASK]
│  │  │
│  │  ├─ 🔷 Validazione Manuale Evidenze [TASK]
│  │  │  ├─ 🔷 Verifica Foto [TASK]
│  │  │  ├─ 🔷 Controllo Conformità [TASK]
│  │  │  │  ├─ 📦 Checklist Requisiti [RESOURCE]
│  │  │  │  └─ 📦 Standard Qualità [RESOURCE]
│  │  │  │
│  │  │  └─ 🎯 Approvazione Evidenze [GOAL] (verso Sistema)
│  │  │     ├─ [OR]
│  │  │     │  ├─ 🔷 Approva Evidenza [TASK]
│  │  │     │  └─ 🔷 Rifiuta Evidenza [TASK]
│  │  │
│  │  ├─ 🔷 Configurazione Sistema [TASK]
│  │  │  ├─ 🔷 Impostazione Parametri [TASK]
│  │  │  │  ├─ 📦 Soglie Ambientali [RESOURCE]
│  │  │  │  ├─ 📦 Tempi Scadenza [RESOURCE]
│  │  │  │  └─ 📦 Fee Sistema [RESOURCE]
│  │  │  │
│  │  │  ├─ 🔷 Deploy Smart Contract [TASK]
│  │  │  └─ 🔷 Update Sistema [TASK]
│  │  │
│  │  └─ 🔷 Monitoraggio Sistema [TASK]
│  │     ├─ 📦 Dashboard Admin [RESOURCE]
│  │     ├─ 🔷 Analisi Log [TASK]
│  │     └─ 🔷 Generazione Report [TASK]
│  │
│  └─ Contributi Softgoal:
│     ├─ ☁️ Sicurezza Sistema [SOFTGOAL] [++]
│     │  ├─ contributo da: Gestione Ruoli
│     │  └─ contributo da: Validazione Manuale
│     │
│     ├─ ☁️ Qualità Evidenze [SOFTGOAL] [++]
│     │  └─ contributo da: Controllo Conformità
│     │
│     └─ ☁️ Flessibilità [SOFTGOAL] [+]
│        └─ contributo da: Configurazione Sistema
```

### Relazioni Chiave
- **Gestione Ruoli** è fondamentale per la sicurezza del sistema
- **Validazione Manuale Evidenze** produce Approvazione o Rifiuto (OR decomposition)
- **Configurazione Sistema** permette di adattare parametri e soglie
- **Monitoraggio Sistema** fornisce visibilità sullo stato complessivo
- Tutte le attività contribuiscono a Sicurezza Sistema e Qualità

---

## 📊 Riepilogo Complessità SR

| Attore | Goal Interni | Task Interni | Resource Interne | Softgoal Interni |
|--------|--------------|--------------|------------------|-------------------|
| **Mittente** | 3 | 6 | 4 | 1 |
| **Sistema_Blockchain** | 2 | 12 | 8 | 5 |
| **Corriere** | 2 | 10 | 7 | 2 |
| **Sensore** | 1 | 8 | 6 | 3 |
| **Admin** | 2 | 14 | 9 | 3 |

---

## 🔍 Tipi di Relazioni SR

### 1. **Means-End Links** (Mezzo-Fine)
Un task o goal è un mezzo per raggiungere un goal di livello superiore.

Esempio:
- `Validazione Automatica` [TASK] → `Validazione Evidenze` [GOAL]

### 2. **Task Decomposition** (Decomposizione)
Un task viene scomposto in sottotask, subgoal, o resource necessarie.

Possono essere:
- **AND decomposition**: tutti gli elementi sono necessari
- **OR decomposition**: almeno uno degli elementi è sufficiente

Esempio AND:
- `Gestione Consegna` [TASK]
  - AND: `Pianificazione Percorso`, `Trasporto Merce`, `Consegna Fisica`

Esempio OR:
- `Approvazione Evidenze` [GOAL]
  - OR: `Approva Evidenza`, `Rifiuta Evidenza`

### 3. **Contribution Links** (Contributi)
Un elemento contribuisce positivamente o negativamente a un softgoal.

Tipi di contributo:
- `++` (make) - Contributo molto positivo
- `+` (help) - Contributo positivo
- `-` (hurt) - Contributo negativo
- `--` (break) - Contributo molto negativo

Esempio:
- `Calibrazione` [TASK] → [++] → `Dati Affidabili` [SOFTGOAL]

---

## 💡 Note di Design

> [!IMPORTANT]
> **Decomposizioni AND vs OR**
> - **AND**: Tutti i sottoelementi devono essere completati (esempio: tutti i task di Gestione Consegna)
> - **OR**: Almeno un sottoelemento deve essere completato (esempio: Approva O Rifiuta evidenza)

> [!TIP]
> **Softgoal Achievement**
> I softgoal non hanno condizioni di soddisfazione precise come i goal. Vengono "sufficiently satisfied" attraverso i contributi positivi dai vari task e goal.

> [!NOTE]
> **Dipendenze Esterne**
> Le dipendenze verso altri attori (già definite nel modello SD) sono indicate con "(dipendenza da/verso Attore)" e collegano elementi interni con elementi esterni.

---

## 📁 File Correlati

- **[istar_model.json](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/istar_model.json)** - Modello SD completo
- **[DIAGRAMMA_ISTAR_COMPLETO.md](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/DIAGRAMMA_ISTAR_COMPLETO.md)** - Diagrammi SD
