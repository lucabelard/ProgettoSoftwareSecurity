# 📊 Modello i* - Sistema Blockchain Spedizioni

## 🎯 Panoramica

Questo modello i* rappresenta le dipendenze strategiche tra gli attori del sistema blockchain per la gestione delle spedizioni.

![Diagramma i* Dipendenze](/Users/lucabelard/.gemini/antigravity/brain/d88530a1-c4f7-44fb-8bcb-caa90ae03244/istar_dependencies_diagram_1764342039635.png)

## 📁 File Disponibili

1. **[istar_model.json](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/istar_model.json)** - Modello in formato iStarML compatibile con piStar
2. **[istar_dependencies.txt](file:///Applications/MAMP/htdocs/ProgettoSoftwareSecurity/istar_dependencies.txt)** - File in formato testuale Pi*

## 🚀 Come Importare in piStar

### Metodo 1: Importazione Diretta JSON

1. Vai su **[piStar Tool](https://www.pistar.org/)**
2. Clicca su **"Examples"** → **"Load"**
3. Seleziona **"Load from File"**
4. Carica il file `istar_model.json`

### Metodo 2: Creazione Manuale

Segui le indicazioni del file `istar_dependencies.txt` per creare il modello manualmente nel tool.

---

## 👥 Attori del Sistema

| Attore | Descrizione |
|--------|-------------|
| **Mittente** | Utente che crea e gestisce le spedizioni |
| **Corriere** | Responsabile della consegna fisica |
| **Sensore** | Dispositivo IoT per monitoraggio ambientale |
| **Admin** | Amministratore del sistema |
| **Sistema_Blockchain** | Sistema centrale basato su blockchain |

---

## 🔗 Dipendenze per Tipo

### 🔷 Task (Esagoni)
Compiti specifici che devono essere eseguiti:

| Da | A | Task |
|----|---|------|
| Mittente | Sistema_Blockchain | Creazione Spedizione |
| Mittente | Sistema_Blockchain | Pagamento Automatico |
| Corriere | Sistema_Blockchain | Registrazione Consegna |
| Sensore | Sistema_Blockchain | Invio Dati Ambientali |
| Admin | Sistema_Blockchain | Gestione Ruoli |
| Admin | Sistema_Blockchain | Validazione Manuale Evidenze |
| Sistema_Blockchain | Admin | Configurazione Sistema |

### 🎯 Goal (Ovali)
Obiettivi da raggiungere:

| Da | A | Goal |
|----|---|------|
| Mittente | Sistema_Blockchain | Validazione Evidenze |
| Corriere | Sistema_Blockchain | Ricezione Pagamento |
| Sistema_Blockchain | Admin | Approvazione Evidenze |
| Mittente | Corriere | Consegna Fisica Merce |

### ☁️ Softgoal (Nuvole)
Obiettivi non funzionali (qualità):

| Da | A | Softgoal |
|----|---|----------|
| Mittente | Sistema_Blockchain | Tracciabilità Immutabile |
| Sistema_Blockchain | Sensore | Dati Affidabili |

### 📦 Resource (Rettangoli)
Risorse informative o fisiche:

| Da | A | Resource |
|----|---|----------|
| Corriere | Sistema_Blockchain | Prova di Conformità |
| Sensore | Sistema_Blockchain | Timestamp Certificato |
| Sistema_Blockchain | Sensore | Letture Ambientali |
| Sistema_Blockchain | Corriere | Conferma Consegna |
| Corriere | Mittente | Informazioni Destinatario |

---

## 📊 Analisi Dipendenze per Attore

### 👤 Mittente

**Dipende da:**
- ⛓️ Sistema_Blockchain (4 dipendenze)
  - 🔷 Creazione Spedizione
  - 🎯 Validazione Evidenze
  - 🔷 Pagamento Automatico
  - ☁️ Tracciabilità Immutabile
- 🚚 Corriere (1 dipendenza)
  - 🎯 Consegna Fisica Merce

**Fornisce a:**
- 🚚 Corriere
  - 📦 Informazioni Destinatario

### 🚚 Corriere

**Dipende da:**
- ⛓️ Sistema_Blockchain (3 dipendenze)
  - 🔷 Registrazione Consegna
  - 🎯 Ricezione Pagamento
  - 📦 Prova di Conformità
- 👤 Mittente (1 dipendenza)
  - 📦 Informazioni Destinatario

**Fornisce a:**
- ⛓️ Sistema_Blockchain
  - 📦 Conferma Consegna
- 👤 Mittente
  - 🎯 Consegna Fisica Merce

### 📡 Sensore

**Dipende da:**
- ⛓️ Sistema_Blockchain (2 dipendenze)
  - 🔷 Invio Dati Ambientali
  - 📦 Timestamp Certificato

**Fornisce a:**
- ⛓️ Sistema_Blockchain
  - ☁️ Dati Affidabili
  - 📦 Letture Ambientali

### 👨‍💼 Admin

**Dipende da:**
- ⛓️ Sistema_Blockchain (2 dipendenze)
  - 🔷 Gestione Ruoli
  - 🔷 Validazione Manuale Evidenze

**Fornisce a:**
- ⛓️ Sistema_Blockchain
  - 🎯 Approvazione Evidenze
  - 🔷 Configurazione Sistema

### ⛓️ Sistema_Blockchain

**Dipende da:**
- 👨‍💼 Admin (2 dipendenze)
  - 🎯 Approvazione Evidenze
  - 🔷 Configurazione Sistema
- 📡 Sensore (2 dipendenze)
  - ☁️ Dati Affidabili
  - 📦 Letture Ambientali
- 🚚 Corriere (1 dipendenza)
  - 📦 Conferma Consegna

**Fornisce a:**
- 👤 Mittente (4 dipendenze)
- 🚚 Corriere (3 dipendenze)
- 📡 Sensore (2 dipendenze)
- 👨‍💼 Admin (2 dipendenze)

---

## 📈 Statistiche Modello

- **Totale Attori:** 5
- **Totale Dipendenze:** 18
  - Task: 7
  - Goal: 4
  - Softgoal: 2
  - Resource: 5

**Attore più dipendente:** Mittente (5 dipendenze in uscita)  
**Attore più richiesto:** Sistema_Blockchain (11 dipendenze in entrata)

---

## 🔍 Legenda Simboli

| Simbolo | Tipo | Descrizione |
|---------|------|-------------|
| 🔷 | Task | Compito specifico da eseguire |
| 🎯 | Goal | Obiettivo da raggiungere |
| ☁️ | Softgoal | Obiettivo non funzionale (qualità) |
| 📦 | Resource | Risorsa informativa o fisica |
| ⭕ | Actor | Entità attiva nel sistema |
| ➖➖➖> | Dependency | Relazione di dipendenza |

---

## 💡 Note Importanti

> [!IMPORTANT]
> Il **Sistema_Blockchain** è l'attore centrale del modello, con 11 dipendenze in entrata e 11 in uscita, confermando il suo ruolo di coordinatore principale del sistema.

> [!NOTE]
> Le dipendenze bidirezionali tra Mittente-Corriere e Sistema_Blockchain-Admin indicano una forte interdipendenza operativa.

> [!TIP]
> Per modificare il modello, usa piStar online oppure modifica il file JSON direttamente e ricaricalo.
