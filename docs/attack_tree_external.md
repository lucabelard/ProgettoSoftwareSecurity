# Attack Tree: Attaccante Esterno

## Goal: Compromettere Sistema Supply Chain

### OR: Rubare Fondi
├── AND: Compromettere Wallet Mittente
│   ├── Phishing Credenziali [P: Media, I: Alto, D: Media]
│   ├── Keylogger/Malware [P: Bassa, I: Alto, D: Alta]
│   ├── Social Engineering [P: Media, I: Alto, D: Bassa]
│   └── Brute Force Password [P: Molto Bassa, I: Alto, D: Molto Alta]
│
├── AND: Sfruttare Vulnerabilità Smart Contract
│   ├── Reentrancy Attack [P: Bassa, I: Critico, D: Alta]
│   ├── Integer Overflow/Underflow [P: Bassa, I: Alto, D: Media]
│   ├── Front-Running [P: Media, I: Medio, D: Bassa]
│   ├── Access Control Bypass [P: Bassa, I: Critico, D: Alta]
│   └── Logic Flaw Exploitation [P: Bassa, I: Critico, D: Molto Alta]
│
└── AND: Attacco Man-in-the-Middle
    ├── ARP Spoofing [P: Media, I: Alto, D: Media]
    ├── DNS Hijacking [P: Bassa, I: Alto, D: Alta]
    └── SSL Stripping [P: Media, I: Alto, D: Media]

### OR: Manipolare Dati
├── AND: Compromettere Sensore
│   ├── Accesso Fisico al Dispositivo [P: Bassa, I: Alto, D: Bassa]
│   ├── Exploit Firmware Sensore [P: Bassa, I: Alto, D: Alta]
│   ├── Jamming Segnale [P: Media, I: Medio, D: Bassa]
│   └── Sostituzione Sensore [P: Molto Bassa, I: Alto, D: Bassa]
│
├── Replay Attack Dati Sensore [P: Media, I: Medio, D: Media]
│
└── AND: Falsificare Transazioni
    ├── Intercettare Comunicazioni [P: Bassa, I: Alto, D: Alta]
    ├── Modificare Payload [P: Bassa, I: Alto, D: Molto Alta]
    └── Firmare con Chiave Compromessa [P: Molto Bassa, I: Critico, D: Alta]

### OR: Interrompere Servizio
├── DDoS su Nodi Blockchain [P: Media, I: Medio, D: Media]
├── Spam Transazioni (Gas Exhaustion) [P: Alta, I: Basso, D: Bassa]
├── Eclipse Attack [P: Bassa, I: Alto, D: Molto Alta]
└── Sybil Attack [P: Bassa, I: Medio, D: Alta]

---

## Legenda
- **P (Probabilità)**: Molto Bassa | Bassa | Media | Alta | Molto Alta
- **I (Impatto)**: Basso | Medio | Alto | Critico
- **D (Difficoltà)**: Molto Bassa | Bassa | Media | Alta | Molto Alta

## Contromisure Principali
1. **Wallet Security**: Multi-signature, hardware wallets, 2FA
2. **Smart Contract**: Audit formale, test coverage >90%, bug bounty
3. **Sensor Security**: Tamper-proof hardware, firma digitale dati
4. **Network**: TLS/SSL, VPN, certificate pinning
5. **Monitoring**: IDS/IPS, anomaly detection, logging immutabile
