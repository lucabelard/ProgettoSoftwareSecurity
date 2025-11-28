# Valutazione del Rischio - Diagrammi i* e Alberi di Attacco

## Panoramica
Questa documentazione contiene i diagrammi i* (Strategic Dependency e Strategic Rationale) per il sistema di supply chain basato su blockchain e Bayesian Network, insieme agli alberi di attacco per tre tipologie di attaccanti.

## Struttura dei File

### Diagrammi i* - Supply Chain SENZA Sistema
1. **`istar_SD_without_system.txt`** - Strategic Dependency Model
   - Mostra le dipendenze tra Mittente, Corriere e Sensore
   - Evidenzia goal, task, resource e softgoal scambiati

2. **`istar_SR_without_system.txt`** - Strategic Rationale Model
   - Dettaglio interno di ciascun attore
   - Decomposizione goal, means-end links, contributi a softgoal

### Diagrammi i* - Supply Chain CON Sistema
3. **`istar_SD_with_system.txt`** - Strategic Dependency Model
   - Include Sistema_Blockchain e Admin come nuovi attori
   - Mostra come il sistema media le interazioni

4. **`istar_SR_with_system.txt`** - Strategic Rationale Model
   - Razionale interno di tutti e 5 gli attori
   - Focus su automazione, trasparenza e trustless execution

### Diagrammi i* - Sistema con Attaccanti
5. **`istar_SD_with_attackers.txt`** - Strategic Dependency Model
   - Include 3 tipologie di attaccanti:
     * Attaccante Esterno
     * Attaccante Interno (Corriere Disonesto)
     * Utente Maldestro (Admin/Mittente Negligente)
   - Mostra dipendenze malevole e meccanismi difensivi

6. **`istar_SR_with_attackers.txt`** - Strategic Rationale Model
   - Strategie di attacco dettagliate per ciascun attaccante
   - Meccanismi difensivi del sistema

### Alberi di Attacco
7. **`attack_tree_external.md`** - Attaccante Esterno
   - Goal: Compromettere sistema, rubare fondi, manipolare dati
   - Include: phishing, exploit smart contract, compromissione sensori, DDoS

8. **`attack_tree_internal.md`** - Attaccante Interno
   - Goal: Ottenere pagamento senza conformità
   - Include: falsificazione evidenze, manipolazione sensori, collusione

9. **`attack_tree_clumsy_user.md`** - Utente Maldestro
   - Goal: Causare vulnerabilità per negligenza
   - Include: gestione chiavi, errori validazione, configurazioni insicure

## Come Usare i Diagrammi con piStar

### Importazione in piStar Tool
1. Visita https://www.cin.ufpe.br/~jhcp/pistar/
2. Per i file `.txt`:
   - Apri il file in un editor di testo
   - Copia il contenuto
   - In piStar, usa la funzione di import/text input
   - Oppure ricrea manualmente seguendo la struttura indicata

### Notazione Usata nei File
- `actor NomeAttore` - Definisce un attore
- `->` - Dipendenza (da → a)
- `[goal]` - Dipendenza di tipo goal
- `[task]` - Dipendenza di tipo task
- `[resource]` - Dipendenza di tipo resource
- `[softgoal]` - Dipendenza di tipo softgoal
- `-D->` - Decomposition link (SR)
- `-ME->` - Means-end link (SR)
- `+->` o `++->` - Contribution positiva a softgoal
- `-->` o `---->` - Contribution negativa a softgoal

## Attori del Sistema

### Mittente
- **Obiettivo**: Spedire merce con garanzie automatiche
- **Dipendenze**: Sistema per validazione, Corriere per consegna fisica

### Corriere
- **Obiettivo**: Consegnare merce e ricevere pagamento garantito
- **Dipendenze**: Sistema per registrazione e pagamento

### Sensore
- **Obiettivo**: Fornire dati certificati e immutabili
- **Dipendenze**: Sistema per timestamp e storage

### Admin
- **Obiettivo**: Gestire sistema e validare evidenze
- **Dipendenze**: Sistema per controllo accessi

### Sistema_Blockchain
- **Obiettivo**: Automatizzare processo supply chain
- **Componenti**: Smart Contract + Bayesian Network

## Tipologie di Attaccanti

### 1. Attaccante Esterno
- **Caratteristiche**: Nessun accesso legittimo al sistema
- **Obiettivi**: Rubare fondi, manipolare dati, interrompere servizio
- **Vettori**: Phishing, exploit, network attacks
- **Probabilità**: Media-Bassa | **Impatto**: Alto-Critico

### 2. Attaccante Interno
- **Caratteristiche**: Corriere con accesso legittimo
- **Obiettivi**: Ottenere pagamento senza conformità
- **Vettori**: Falsificazione evidenze, manipolazione sensori, collusione
- **Probabilità**: Media-Alta | **Impatto**: Alto

### 3. Utente Maldestro
- **Caratteristiche**: Admin/Mittente senza intenzioni malevole
- **Obiettivi**: Completare operazioni (con errori)
- **Vettori**: Gestione chiavi inadeguata, errori validazione, configurazioni insicure
- **Probabilità**: Alta-Molto Alta | **Impatto**: Medio-Critico

## Metriche degli Alberi di Attacco

Ogni nodo degli alberi include:
- **P (Probabilità)**: Molto Bassa → Molto Alta
- **I (Impatto)**: Basso → Critico
- **D (Difficoltà)**: Molto Bassa → Molto Alta

## Contromisure Principali

### Livello Applicativo
- Multi-signature wallets
- Hardware security modules
- Audit formale smart contract
- Bug bounty program

### Livello Sensori
- Tamper-proof hardware
- Firma digitale dati
- Attestazione remota
- Secure boot

### Livello Rete
- TLS/SSL end-to-end
- Certificate pinning
- VPN per comunicazioni critiche

### Livello Umano
- Security awareness training
- Phishing simulations
- Checklist obbligatorie
- Separation of duties

### Livello Sistema
- RBAC (Role-Based Access Control)
- Anomaly detection
- Immutable audit logs
- Rate limiting

## Riferimenti
- Progetto: Supply Chain con Smart Contract e Bayesian Network
- Attori: Admin, Mittente, Corriere, Sensore
- Tecnologie: Ethereum, Solidity, Web3, MetaMask
