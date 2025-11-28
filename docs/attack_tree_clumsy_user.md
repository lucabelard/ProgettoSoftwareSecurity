# Attack Tree: Utente Maldestro (Admin o Mittente Negligente)

## Goal: Causare Vulnerabilità per Negligenza

### OR: Compromettere Chiavi Private
├── AND: Salvare Chiavi in Chiaro
│   ├── Salvare su File di Testo [P: Alta, I: Critico, D: Molto Bassa]
│   ├── Salvare su Cloud Non Cifrato [P: Media, I: Critico, D: Molto Bassa]
│   ├── Screenshot con Chiave Visibile [P: Media, I: Critico, D: Molto Bassa]
│   └── Backup Non Protetto [P: Alta, I: Critico, D: Molto Bassa]
│
├── AND: Condividere Chiavi Involontariamente
│   ├── Inviare via Email [P: Media, I: Critico, D: Molto Bassa]
│   ├── Condividere via Chat/Slack [P: Media, I: Critico, D: Molto Bassa]
│   ├── Commit su Repository Pubblico [P: Bassa, I: Critico, D: Molto Bassa]
│   └── Condividere Schermo in Videochiamata [P: Media, I: Critico, D: Molto Bassa]
│
└── AND: Usare Password Deboli
    ├── Password Comune (password123) [P: Alta, I: Alto, D: Molto Bassa]
    ├── Riutilizzare Password [P: Molto Alta, I: Alto, D: Molto Bassa]
    ├── Password Basata su Info Personali [P: Alta, I: Alto, D: Molto Bassa]
    └── Non Usare 2FA [P: Molto Alta, I: Alto, D: Molto Bassa]

### OR: Errori di Validazione (Admin)
├── AND: Approvare Senza Verificare
│   ├── Approvare in Massa [P: Media, I: Alto, D: Molto Bassa]
│   ├── Non Controllare Dati Sensore [P: Alta, I: Alto, D: Molto Bassa]
│   ├── Fidarsi Ciecamente del BN [P: Media, I: Medio, D: Molto Bassa]
│   └── Approvare Sotto Deadline [P: Alta, I: Alto, D: Molto Bassa]
│
├── AND: Ignorare Anomalie
│   ├── Dismissare Alert di Sicurezza [P: Alta, I: Alto, D: Molto Bassa]
│   ├── Non Investigare Pattern Sospetti [P: Media, I: Alto, D: Molto Bassa]
│   ├── Ignorare Valori Fuori Range [P: Media, I: Medio, D: Molto Bassa]
│   └── Non Leggere Log [P: Molto Alta, I: Medio, D: Molto Bassa]
│
└── AND: Validare Sotto Pressione
    ├── Approvare Rapidamente per Urgenza [P: Alta, I: Alto, D: Molto Bassa]
    ├── Cedere a Pressioni Esterne [P: Media, I: Alto, D: Bassa]
    └── Saltare Procedure Standard [P: Media, I: Alto, D: Molto Bassa]

### OR: Errori di Configurazione
├── AND: Configurazione Insicura Sistema
│   ├── Usare Configurazione Default [P: Alta, I: Alto, D: Molto Bassa]
│   ├── Lasciare Porte/Servizi Aperti [P: Media, I: Alto, D: Molto Bassa]
│   ├── Permessi Troppo Permissivi [P: Alta, I: Alto, D: Molto Bassa]
│   └── Non Cambiare Credenziali Default [P: Media, I: Critico, D: Molto Bassa]
│
├── AND: Non Aggiornare Software
│   ├── Rimandare Patch di Sicurezza [P: Molto Alta, I: Alto, D: Molto Bassa]
│   ├── Usare Librerie Obsolete [P: Alta, I: Alto, D: Molto Bassa]
│   ├── Ignorare Vulnerability Alerts [P: Alta, I: Alto, D: Molto Bassa]
│   └── Non Aggiornare Firmware Sensori [P: Media, I: Medio, D: Molto Bassa]
│
└── AND: Disabilitare Sicurezza per "Comodità"
    ├── Disabilitare 2FA [P: Media, I: Alto, D: Molto Bassa]
    ├── Disabilitare Firewall [P: Bassa, I: Critico, D: Molto Bassa]
    ├── Disabilitare Logging [P: Bassa, I: Alto, D: Molto Bassa]
    └── Ridurre Timeout Sessione [P: Media, I: Medio, D: Molto Bassa]

### OR: Errori Operativi
├── AND: Gestione Inadeguata Wallet
│   ├── Non Fare Backup [P: Media, I: Critico, D: Molto Bassa]
│   ├── Perdere Seed Phrase [P: Media, I: Critico, D: Molto Bassa]
│   ├── Usare Wallet su Dispositivo Compromesso [P: Media, I: Critico, D: Bassa]
│   └── Non Verificare Indirizzo Destinatario [P: Alta, I: Alto, D: Molto Bassa]
│
├── AND: Phishing Susceptibility
│   ├── Cliccare Link Sospetti [P: Alta, I: Alto, D: Molto Bassa]
│   ├── Scaricare Allegati Malevoli [P: Media, I: Alto, D: Molto Bassa]
│   ├── Inserire Credenziali su Siti Fake [P: Media, I: Critico, D: Molto Bassa]
│   └── Rispondere a Email di Spear Phishing [P: Media, I: Alto, D: Bassa]
│
└── AND: Social Engineering Vulnerability
    ├── Rivelare Info Sensibili al Telefono [P: Media, I: Alto, D: Molto Bassa]
    ├── Fidarsi di "Supporto Tecnico" Falso [P: Media, I: Alto, D: Bassa]
    ├── Fornire Accesso Remoto a Sconosciuti [P: Bassa, I: Critico, D: Bassa]
    └── Condividere Codici OTP [P: Media, I: Alto, D: Molto Bassa]

### OR: Errori di Deployment
├── Esporre Chiavi API in Codice [P: Media, I: Critico, D: Molto Bassa]
├── Deploy su Rete Sbagliata (Mainnet vs Testnet) [P: Media, I: Alto, D: Molto Bassa]
├── Non Testare Prima di Deploy [P: Alta, I: Alto, D: Molto Bassa]
└── Hardcodare Credenziali [P: Media, I: Critico, D: Molto Bassa]

---

## Legenda
- **P (Probabilità)**: Molto Bassa | Bassa | Media | Alta | Molto Alta
- **I (Impatto)**: Basso | Medio | Alto | Critico
- **D (Difficoltà)**: Molto Bassa | Bassa | Media | Alta | Molto Alta

## Caratteristiche Distintive
- **Alta Probabilità**: Gli errori umani sono molto comuni
- **Difficoltà Molto Bassa**: Non richiede competenze tecniche
- **Impatto Variabile**: Da medio a critico
- **Non Intenzionale**: Mancanza di conoscenza/attenzione, non malevolenza

## Contromisure Principali
1. **User Education**: Training di sicurezza, awareness programs, phishing simulations
2. **Secure Defaults**: Configurazioni sicure out-of-the-box, wizard guidati
3. **Fail-Safe Design**: Conferme multiple, undo operations, rate limiting
4. **Key Management**: Hardware wallets obbligatori, key management systems
5. **Validation Assistance**: Checklist obbligatorie, automated checks, peer review
6. **Access Control**: Principle of least privilege, separation of duties
7. **Monitoring & Alerts**: Anomaly detection, real-time alerts, audit logs
8. **UI/UX Design**: Warning chiari, prevenzione errori, feedback immediato
