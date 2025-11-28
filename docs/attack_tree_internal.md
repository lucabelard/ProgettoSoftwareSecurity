# Attack Tree: Attaccante Interno (Corriere Disonesto)

## Goal: Ottenere Pagamento Senza Conformità

### OR: Falsificare Evidenze
├── AND: Modificare Dati Sensore
│   ├── Accesso Privilegiato al Sensore [P: Alta, I: Alto, D: Bassa]
│   ├── Manomissione Software Sensore [P: Media, I: Alto, D: Media]
│   ├── Intercettare e Modificare Trasmissione [P: Media, I: Alto, D: Media]
│   └── Iniettare Dati Falsi [P: Alta, I: Alto, D: Bassa]
│
├── AND: Sostituire Sensore
│   ├── Rimuovere Sensore Legittimo [P: Media, I: Alto, D: Bassa]
│   ├── Installare Sensore Modificato [P: Media, I: Alto, D: Media]
│   └── Clonare ID Sensore [P: Bassa, I: Alto, D: Alta]
│
└── AND: Replay Dati Validi
    ├── Registrare Spedizione Precedente Conforme [P: Alta, I: Medio, D: Bassa]
    ├── Estrarre Dati Sensore Validi [P: Alta, I: Medio, D: Bassa]
    └── Ritrasmettere Dati in Nuova Spedizione [P: Media, I: Alto, D: Media]

### OR: Manipolare Sensore Fisicamente
├── AND: Alterare Condizioni Ambientali Rilevate
│   ├── Isolare Sensore da Ambiente Reale [P: Alta, I: Alto, D: Bassa]
│   ├── Creare Microambiente Controllato [P: Media, I: Alto, D: Media]
│   └── Esporre Sensore a Condizioni Ideali [P: Alta, I: Alto, D: Bassa]
│
└── AND: Disabilitare Temporaneamente Sensore
    ├── Bloccare Alimentazione [P: Alta, I: Medio, D: Bassa]
    ├── Schermatura Segnale [P: Media, I: Medio, D: Bassa]
    └── Riattivare Prima della Consegna [P: Alta, I: Medio, D: Bassa]

### OR: Colludere con Altri Attori
├── AND: Corrompere Admin
│   ├── Offrire Tangente [P: Bassa, I: Critico, D: Media]
│   ├── Ricatto/Estorsione [P: Molto Bassa, I: Critico, D: Alta]
│   └── Ottenere Approvazione Manuale Fraudolenta [P: Bassa, I: Critico, D: Media]
│
├── AND: Accordo con Mittente
│   ├── Condividere Profitti [P: Bassa, I: Alto, D: Media]
│   ├── Simulare Conformità [P: Media, I: Alto, D: Bassa]
│   └── Evitare Controlli Rigorosi [P: Media, I: Medio, D: Bassa]
│
└── AND: Compromettere Fornitore Sensori
    ├── Ottenere Sensori Pre-Modificati [P: Molto Bassa, I: Critico, D: Molto Alta]
    ├── Backdoor nel Firmware [P: Molto Bassa, I: Critico, D: Molto Alta]
    └── Certificati Falsi [P: Bassa, I: Alto, D: Alta]

### OR: Sfruttare Debolezze Processo
├── Approfittare di Validazione Automatica [P: Media, I: Alto, D: Media]
├── Timing Attack (Inviare Dati Limite) [P: Alta, I: Medio, D: Bassa]
├── Sfruttare Soglie BN Permissive [P: Media, I: Alto, D: Media]
└── Creare Spedizioni "Borderline" [P: Alta, I: Medio, D: Bassa]

---

## Legenda
- **P (Probabilità)**: Molto Bassa | Bassa | Media | Alta | Molto Alta
- **I (Impatto)**: Basso | Medio | Alto | Critico
- **D (Difficoltà)**: Molto Bassa | Bassa | Media | Alta | Molto Alta

## Contromisure Principali
1. **Sensor Integrity**: Tamper-evident seals, secure boot, attestation remota
2. **Data Validation**: Controlli incrociati, pattern analysis, anomaly detection
3. **Replay Prevention**: Timestamp verification, nonce, sequence numbers
4. **Access Control**: Separation of duties, least privilege, audit trail
5. **Collusion Prevention**: Multi-party validation, random audits, whistleblower protection
6. **Bayesian Network**: Soglie conservative, multiple evidenze richieste, human oversight
