# 🔷 Diagramma i* Completo - Sistema Blockchain Spedizioni

## 📊 Diagramma con Tutte le Dipendenze

![Diagramma i* Completo](/Users/lucabelard/.gemini/antigravity/brain/d88530a1-c4f7-44fb-8bcb-caa90ae03244/istar_complete_diagram_1764342397304.png)

---

## 📋 Legenda Forme

| Forma | Tipo | Significato |
|-------|------|-------------|
| 🔷 **Esagono** | **[TASK]** | Compito specifico da eseguire |
| 🎯 **Ovale** | **[GOAL]** | Obiettivo da raggiungere |
| ☁️ **Nuvola** | **[SOFTGOAL]** | Obiettivo non funzionale (qualità) |
| 📦 **Rettangolo** | **[RESOURCE]** | Risorsa informativa o fisica |

---

## 🔗 Elenco Completo Dipendenze

### 👤 Mittente → ⛓️ Sistema_Blockchain

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[TASK]** | 🔷 Esagono | Creazione Spedizione |
| **[GOAL]** | 🎯 Ovale | Validazione Evidenze |
| **[TASK]** | 🔷 Esagono | Pagamento Automatico |
| **[SOFTGOAL]** | ☁️ Nuvola | Tracciabilità Immutabile |

---

### 🚚 Corriere → ⛓️ Sistema_Blockchain

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[TASK]** | 🔷 Esagono | Registrazione Consegna |
| **[GOAL]** | 🎯 Ovale | Ricezione Pagamento |
| **[RESOURCE]** | 📦 Rettangolo | Prova di Conformità |

---

### 📡 Sensore → ⛓️ Sistema_Blockchain

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[TASK]** | 🔷 Esagono | Invio Dati Ambientali |
| **[RESOURCE]** | 📦 Rettangolo | Timestamp Certificato |

---

### 👨‍💼 Admin → ⛓️ Sistema_Blockchain

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[TASK]** | 🔷 Esagono | Gestione Ruoli |
| **[TASK]** | 🔷 Esagono | Validazione Manuale Evidenze |

---

### ⛓️ Sistema_Blockchain → 👨‍💼 Admin

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[GOAL]** | 🎯 Ovale | Approvazione Evidenze |
| **[TASK]** | 🔷 Esagono | Configurazione Sistema |

---

### ⛓️ Sistema_Blockchain → 📡 Sensore

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[SOFTGOAL]** | ☁️ Nuvola | Dati Affidabili |
| **[RESOURCE]** | 📦 Rettangolo | Letture Ambientali |

---

### ⛓️ Sistema_Blockchain → 🚚 Corriere

| Tipo | Forma | Nome Dipendenza |
|------|-------|-----------------|
| **[RESOURCE]** | 📦 Rettangolo | Conferma Consegna |

---

### 👤 Mittente ↔️ 🚚 Corriere

| Da | A | Tipo | Forma | Nome Dipendenza |
|----|---|------|-------|-----------------|
| Mittente | Corriere | **[GOAL]** | 🎯 Ovale | Consegna Fisica Merce |
| Corriere | Mittente | **[RESOURCE]** | 📦 Rettangolo | Informazioni Destinatario |

---

## 📊 Riepilogo Statistiche

### Per Tipo di Dipendenza

| Tipo | Simbolo | Quantità |
|------|---------|----------|
| **TASK** | 🔷 | 7 |
| **GOAL** | 🎯 | 4 |
| **RESOURCE** | 📦 | 5 |
| **SOFTGOAL** | ☁️ | 2 |
| **TOTALE** | | **18** |

### Per Attore (Dipendenze in Uscita)

| Attore | Task | Goal | Resource | Softgoal | Totale |
|--------|------|------|----------|----------|--------|
| **Mittente** | 2 | 2 | 0 | 1 | **5** |
| **Corriere** | 1 | 1 | 2 | 0 | **4** |
| **Sensore** | 1 | 0 | 1 | 0 | **2** |
| **Admin** | 2 | 0 | 0 | 0 | **2** |
| **Sistema_Blockchain** | 1 | 1 | 3 | 1 | **6** |

---

## 🎯 Analisi Centralità

**Sistema_Blockchain** è l'attore centrale:
- ✅ **11 dipendenze in entrata** (da Mittente, Corriere, Sensore, Admin)
- ✅ **6 dipendenze in uscita** (verso Admin, Sensore, Corriere)
- ✅ Totale: **17 connessioni** su 18 dipendenze totali

---

## 💡 Note di Design

> [!IMPORTANT]
> **Dipendenze Bidirezionali**
> - Sistema_Blockchain ↔️ Admin (forte interdipendenza amministrativa)
> - Sistema_Blockchain ↔️ Sensore (ciclo di dati ambientali)
> - Mittente ↔️ Corriere (scambio informazioni consegna)

> [!NOTE]
> **Softgoal (Obiettivi di Qualità)**
> - "Tracciabilità Immutabile" dal Mittente
> - "Dati Affidabili" dal Sistema verso Sensore
> 
> Questi rappresentano requisiti non funzionali critici per il sistema blockchain.

---

## 📁 File Correlati

- **[istar_model.json](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/istar_model.json)** - Modello importabile su piStar
- **[istar_dependencies.txt](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/istar_dependencies.txt)** - Formato testuale
- **[GUIDA_ISTAR.md](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/GUIDA_ISTAR.md)** - Guida completa
