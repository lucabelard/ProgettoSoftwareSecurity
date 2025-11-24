# 📦 Blockchain Shipment Tracker - Interfaccia Web

Interfaccia web moderna per interagire con il sistema di tracciamento spedizioni basato su blockchain con validazione Bayesiana.

## 🌟 Caratteristiche

- **Dashboard Interattiva**: Visualizza tutte le spedizioni in tempo reale
- **Gestione Multi-Ruolo**: Interfacce dedicate per Admin, Mittente, Sensore e Corriere
- **Design Moderno**: UI premium con glassmorphism, animazioni fluide e dark mode
- **Integrazione Web3**: Connessione a MetaMask o Ganache locale
- **Validazione Bayesiana**: Calcolo on-chain delle probabilità basato su evidenze IoT

## 🚀 Setup Rapido

### Prerequisiti

1. **Ganache** in esecuzione sulla porta `7545`
2. **Contratto deployato**: Esegui `truffle migrate` nella directory principale del progetto
3. **Browser moderno** con supporto ES6+
4. **MetaMask** (opzionale, per connessione wallet)

### Installazione

1. Il progetto è già configurato nella cartella `web-interface/`
2. Apri `index.html` con un server locale (vedi sotto)

### Avvio dell'Interfaccia

#### Opzione 1: Live Server (Raccomandato)

Se usi VS Code, installa l'estensione "Live Server" e clicca con il tasto destro su `index.html` → "Open with Live Server"

#### Opzione 2: Python HTTP Server

```bash
cd web-interface
python -m http.server 8000
```

Poi apri il browser su `http://localhost:8000`

#### Opzione 3: Node.js HTTP Server

```bash
npx http-server web-interface -p 8000
```

## 📖 Guida all'Uso

### 1️⃣ Connessione

1. Assicurati che Ganache sia in esecuzione
2. Clicca su **"Connect Wallet"** nell'header
3. Se usi MetaMask, configura la rete custom:
   - **Network Name**: Ganache
   - **RPC URL**: `http://127.0.0.1:7545`
   - **Chain ID**: `5777` (o `1337` a seconda della configurazione)
   - **Currency Symbol**: ETH

### 2️⃣ Ruolo Admin/Oracolo ⚙️

**Funzioni:**
- Impostare le probabilità a priori (P(F1=True), P(F2=True))
- Configurare le tabelle CPT per ogni evidenza (E1-E5)

**Come usare:**
1. Seleziona il ruolo "Admin/Oracolo"
2. Inserisci i valori per le probabilità a priori (default: 95%)
3. Clicca "Imposta Probabilità A Priori"
4. Seleziona un'evidenza dal menu a tendina
5. Inserisci i 4 valori della CPT (p_FF, p_FT, p_TF, p_TT)
6. Clicca "Imposta CPT"

**Nota:** Devi avere il ruolo `RUOLO_ORACOLO` nel contratto (di default l'account 0)

### 3️⃣ Ruolo Mittente 📦

**Funzioni:**
- Creare nuove spedizioni con pagamento in ETH

**Come usare:**
1. Seleziona il ruolo "Mittente"
2. Inserisci l'indirizzo del corriere (es. account 3 di Ganache)
3. Specifica l'importo del pagamento in ETH (default: 1 ETH)
4. Clicca "Crea Spedizione"
5. La nuova spedizione apparirà nella dashboard

**Nota:** Devi avere il ruolo `RUOLO_MITTENTE` nel contratto (di default l'account 0)

### 4️⃣ Ruolo Sensore 📊

**Funzioni:**
- Inviare evidenze dai sensori IoT (E1-E5) per una spedizione specifica

**Come usare:**
1. Seleziona il ruolo "Sensore"
2. Inserisci l'ID della spedizione
3. Per ogni evidenza:
   - **E1 (Temperatura)**: Toggle ON = OK, OFF = Fuori Range
   - **E2 (Sigillo)**: Toggle ON = OK, OFF = Rotto
   - **E3 (Shock)**: Toggle ON = Shock Rilevato, OFF = No Shock
   - **E4 (Luce)**: Toggle ON = Aperto, OFF = Chiuso
   - **E5 (Scan Arrivo)**: Toggle ON = In Orario, OFF = In Ritardo
4. Clicca sul pulsante "Invia" per ogni evidenza

**Nota:** Devi avere il ruolo `RUOLO_SENSORE` nel contratto (di default l'account 0)

### 5️⃣ Ruolo Corriere 🚚

**Funzioni:**
- Validare la spedizione e ricevere il pagamento

**Come usare:**
1. Seleziona il ruolo "Corriere"
2. Inserisci l'ID della spedizione
3. Clicca "Valida e Ricevi Pagamento"
4. Il contratto verificherà:
   - Tutte le 5 evidenze sono state ricevute
   - Le probabilità F1 e F2 superano la soglia del 95%
5. Se la validazione ha successo, riceverai il pagamento in ETH

**Nota:** Devi essere il corriere assegnato alla spedizione

## 🎨 Interfaccia

### Dashboard

La dashboard mostra tutte le spedizioni con:
- **ID Spedizione**
- **Stato** (In Attesa / Pagata)
- **Indirizzi** (Mittente e Corriere)
- **Importo** del pagamento
- **Stato Evidenze** (E1-E5) con indicatori visivi

### Filtri

- **Ricerca**: Cerca per ID o indirizzo
- **Filtro Stato**: Mostra solo spedizioni "In Attesa" o "Pagata"

## 🔧 Risoluzione Problemi

### "Contratto non trovato"

**Soluzione:**
```bash
cd ..
truffle migrate --reset
```

### "MetaMask non si connette"

**Soluzione:**
1. Apri MetaMask
2. Vai su Impostazioni → Reti → Aggiungi Rete
3. Inserisci i parametri di Ganache (vedi sopra)
4. Ricarica la pagina

### "Transazione fallita"

**Possibili cause:**
- Account non ha il ruolo necessario
- Gas insufficiente
- Parametri non validi
- Evidenze mancanti (per validazione)

**Soluzione:**
Controlla la console del browser (F12) per dettagli sull'errore

### "CORS Error"

**Soluzione:**
Non aprire `index.html` direttamente dal file system. Usa un server HTTP locale (vedi "Avvio dell'Interfaccia")

## 📝 Note Tecniche

### Ruoli nel Contratto

Il contratto usa `AccessControl` di OpenZeppelin con i seguenti ruoli:
- `DEFAULT_ADMIN_ROLE`: Amministratore principale
- `RUOLO_ORACOLO`: Può configurare CPT e probabilità
- `RUOLO_MITTENTE`: Può creare spedizioni
- `RUOLO_SENSORE`: Può inviare evidenze

Di default, l'account che ha deployato il contratto (account 0) ha tutti i ruoli.

### Evidenze

Le 5 evidenze rappresentano sensori IoT:
- **E1**: Temperatura (true = OK, false = Fuori Range)
- **E2**: Sigillo (true = Integro, false = Rotto)
- **E3**: Shock (true = Rilevato, false = Nessuno)
- **E4**: Luce (true = Aperto, false = Chiuso)
- **E5**: Scan Arrivo (true = In Orario, false = Ritardo)

### Rete Bayesiana

Il contratto calcola le probabilità posteriori P(F1|E) e P(F2|E) dove:
- **F1**: Integrità Temperatura
- **F2**: Integrità Imballaggio

Il pagamento viene effettuato solo se entrambe le probabilità superano il 95%.

## 🎯 Workflow Completo

1. **Admin** configura le CPT e le probabilità a priori
2. **Mittente** crea una spedizione con pagamento
3. **Sensore** invia le 5 evidenze durante il trasporto
4. **Corriere** richiede la validazione e il pagamento
5. Il contratto calcola le probabilità e, se conformi, paga il corriere

## 🛠️ Tecnologie Utilizzate

- **HTML5**: Struttura semantica
- **CSS3**: Glassmorphism, animazioni, responsive design
- **JavaScript ES6+**: Logica applicativa
- **Web3.js v4**: Interazione con blockchain
- **Google Fonts (Inter)**: Tipografia moderna

## 📄 Licenza

Questo progetto è parte di ProgettoSoftwareSecurity.

## 🤝 Supporto

Per problemi o domande, apri un issue su GitHub.
