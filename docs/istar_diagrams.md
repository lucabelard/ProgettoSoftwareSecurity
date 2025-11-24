# 🎯 Analisi i* - Sistema Oracolo Bayesiano per Catena del Freddo

## Indice

1. [SD/SR Supply Chain SENZA Sistema](#1-sdsr-supply-chain-senza-sistema)
2. [SD/SR Supply Chain CON Sistema](#2-sdsr-supply-chain-con-sistema)
3. [SD/SR Sistema e Attaccanti](#3-sdsr-sistema-e-attaccanti)
4. [Alberi di Attacco](#4-alberi-di-attacco)

---

## 1. SD/SR Supply Chain SENZA Sistema

### Strategic Dependency (SD) Model - Scenario AS-IS

```mermaid
graph TB
    subgraph Attori
        M[Mittente<br/>Farmacia/Produttore]
        C[Corriere]
        D[Destinatario<br/>Ospedale/Farmacia]
    end
    
    M -->|Consegna Farmaco| C
    C -->|Farmaco Integro| D
    M -->|Pagamento| C
    C -->|Conferma Consegna| M
    D -->|Ricevuta| M
    
    style M fill:#e1f5ff
    style C fill:#ffe1e1
    style D fill:#e1ffe1
```

### Strategic Rationale (SR) Model - Mittente AS-IS

```mermaid
graph TB
    subgraph "Mittente (AS-IS)"
        G1[Goal: Consegnare<br/>Farmaco Integro]
        
        T1[Task: Preparare<br/>Spedizione]
        T2[Task: Imballare<br/>con Ghiaccio]
        T3[Task: Affidarsi<br/>al Corriere]
        
        SG1[Softgoal: Minimizzare<br/>Costi]
        SG2[Softgoal: Garantire<br/>Qualità]
        
        R1[Resource: Contenitore<br/>Termico]
        R2[Resource: Ghiaccio<br/>Secco]
        
        G1 --> T1
        G1 --> T2
        G1 --> T3
        
        T1 -.->|--| SG1
        T2 -.->|++| SG2
        T2 --> R1
        T2 --> R2
        
        T3 -.->|??| SG2
    end
    
    style G1 fill:#90EE90
    style SG1 fill:#FFB6C1
    style SG2 fill:#FFB6C1
    style T3 fill:#FFA500
```

**Problemi Identificati (AS-IS):**
- ❌ **Nessuna Garanzia**: Il mittente non ha garanzie sulla conformità
- ❌ **Fiducia Cieca**: Deve fidarsi completamente del corriere
- ❌ **Nessun Monitoraggio**: Non può verificare temperatura/integrità
- ❌ **Dispute**: Difficile risolvere controversie su responsabilità
- ❌ **Pagamento Anticipato**: Rischio di pagare per servizio non conforme

### Strategic Rationale (SR) Model - Corriere AS-IS

```mermaid
graph TB
    subgraph "Corriere (AS-IS)"
        G2[Goal: Consegnare<br/>Pacco]
        
        T4[Task: Trasportare<br/>Pacco]
        T5[Task: Mantenere<br/>Temperatura]
        T6[Task: Evitare<br/>Shock]
        
        SG3[Softgoal: Massimizzare<br/>Profitto]
        SG4[Softgoal: Ridurre<br/>Tempi]
        
        G2 --> T4
        G2 --> T5
        G2 --> T6
        
        T5 -.->|--| SG3
        T5 -.->|--| SG4
        T6 -.->|--| SG4
        
        T4 -.->|++| SG3
    end
    
    style G2 fill:#90EE90
    style SG3 fill:#FFB6C1
    style SG4 fill:#FFB6C1
    style T5 fill:#FFA500
    style T6 fill:#FFA500
```

**Problemi Identificati (AS-IS):**
- ⚠️ **Conflitto di Interessi**: Profitto vs. Qualità
- ⚠️ **Incentivi Sbagliati**: Pagato anche se non conforme
- ⚠️ **Nessuna Responsabilità**: Difficile provare negligenza
- ⚠️ **Moral Hazard**: Può risparmiare su qualità senza conseguenze

---

## 2. SD/SR Supply Chain CON Sistema

### Strategic Dependency (SD) Model - Scenario TO-BE

```mermaid
graph TB
    subgraph Attori
        M[Mittente]
        C[Corriere]
        D[Destinatario]
        SC[Smart Contract<br/>Oracolo]
        S[Sensori IoT]
    end
    
    M -->|Deposita ETH| SC
    M -->|Configura Spedizione| SC
    S -->|Evidenze E1-E5| SC
    C -->|Trasporta con Sensori| S
    SC -->|Pagamento Condizionale| C
    SC -->|Garanzia Conformità| M
    C -->|Farmaco + Dati| D
    
    style M fill:#e1f5ff
    style C fill:#ffe1e1
    style D fill:#e1ffe1
    style SC fill:#fff4e1
    style S fill:#e1e1ff
```

### Strategic Rationale (SR) Model - Mittente TO-BE

```mermaid
graph TB
    subgraph "Mittente (TO-BE)"
        G1[Goal: Garantire<br/>Consegna Conforme]
        
        T1[Task: Depositare<br/>ETH in Escrow]
        T2[Task: Configurare<br/>Sensori IoT]
        T3[Task: Monitorare<br/>Evidenze]
        
        SG1[Softgoal: Ridurre<br/>Rischi]
        SG2[Softgoal: Trasparenza]
        
        R1[Resource: Smart<br/>Contract]
        R2[Resource: Dashboard<br/>Web]
        
        G1 --> T1
        G1 --> T2
        G1 --> T3
        
        T1 --> R1
        T3 --> R2
        
        T1 -.->|++| SG1
        T3 -.->|++| SG2
        
        R1 -.->|++| SG1
    end
    
    style G1 fill:#90EE90
    style SG1 fill:#98FB98
    style SG2 fill:#98FB98
    style R1 fill:#87CEEB
```

**Miglioramenti (TO-BE):**
- ✅ **Garanzia Crittografica**: Smart contract garantisce conformità
- ✅ **Monitoraggio Real-Time**: Visibilità completa su temperatura/integrità
- ✅ **Pagamento Condizionale**: ETH rilasciato solo se P(F1,F2) ≥ 95%
- ✅ **Dispute Resolution**: Evidenze immutabili on-chain
- ✅ **Riduzione Rischi**: Incentivi allineati

### Strategic Rationale (SR) Model - Corriere TO-BE

```mermaid
graph TB
    subgraph "Corriere (TO-BE)"
        G2[Goal: Ricevere<br/>Pagamento]
        
        T4[Task: Mantenere<br/>Conformità]
        T5[Task: Monitorare<br/>Sensori]
        T6[Task: Validare<br/>Evidenze]
        
        SG3[Softgoal: Massimizzare<br/>Qualità]
        SG4[Softgoal: Reputazione]
        
        R3[Resource: Sensori<br/>IoT]
        R4[Resource: Bayesian<br/>Network]
        
        G2 --> T4
        G2 --> T5
        G2 --> T6
        
        T4 --> R3
        T6 --> R4
        
        T4 -.->|++| SG3
        T4 -.->|++| SG4
        
        R4 -.->|Verifica| T6
    end
    
    style G2 fill:#90EE90
    style SG3 fill:#98FB98
    style SG4 fill:#98FB98
    style R4 fill:#87CEEB
```

**Miglioramenti (TO-BE):**
- ✅ **Incentivi Allineati**: Pagato SOLO se conforme
- ✅ **Responsabilità Chiara**: Evidenze provano negligenza
- ✅ **Reputazione On-Chain**: Storia trasparente
- ✅ **Qualità Premiata**: Migliore servizio = più contratti

---

## 3. SD/SR Sistema e Attaccanti

### Strategic Dependency (SD) Model - Attaccanti

```mermaid
graph TB
    subgraph Sistema
        SC[Smart Contract]
        UI[Web Interface]
        BC[Blockchain]
        S[Sensori IoT]
    end
    
    subgraph Attaccanti
        AI[Attaccante<br/>Interno]
        AE[Attaccante<br/>Esterno]
        UM[Utente<br/>Maldestro]
    end
    
    AI -.->|Manipola| S
    AI -.->|Falsifica| S
    AE -.->|Hacking| UI
    AE -.->|DoS| BC
    UM -.->|Errori| UI
    UM -.->|Chiavi Perse| UI
    
    SC -->|Protegge| BC
    UI -->|Autentica| SC
    S -->|Firma| SC
    
    style AI fill:#ff6b6b
    style AE fill:#ff8787
    style UM fill:#ffa94d
    style SC fill:#51cf66
    style BC fill:#51cf66
```

### Strategic Rationale (SR) - Attaccante Interno

```mermaid
graph TB
    subgraph "Attaccante Interno (Corriere Disonesto)"
        G_AI[Goal: Ricevere Pagamento<br/>Senza Conformità]
        
        T_AI1[Task: Manipolare<br/>Sensori]
        T_AI2[Task: Falsificare<br/>Dati]
        T_AI3[Task: Sostituire<br/>Sensori]
        
        SG_AI1[Softgoal: Evitare<br/>Rilevamento]
        
        R_AI1[Resource: Accesso<br/>Fisico]
        R_AI2[Resource: Conoscenza<br/>Sistema]
        
        G_AI --> T_AI1
        G_AI --> T_AI2
        G_AI --> T_AI3
        
        T_AI1 --> R_AI1
        T_AI2 --> R_AI2
        
        T_AI1 -.->|??| SG_AI1
        T_AI2 -.->|??| SG_AI1
    end
    
    style G_AI fill:#ff6b6b
    style SG_AI1 fill:#ffa94d
    style T_AI1 fill:#ff8787
    style T_AI2 fill:#ff8787
    style T_AI3 fill:#ff8787
```

**Contromisure:**
- 🛡️ **Firma Crittografica**: Sensori firmano dati con chiave privata
- 🛡️ **Tamper-Evident Seals**: Sigilli antimanomissione
- 🛡️ **Ridondanza**: Multipli sensori cross-validano
- 🛡️ **Bayesian Network**: Rileva incoerenze statistiche

### Strategic Rationale (SR) - Attaccante Esterno

```mermaid
graph TB
    subgraph "Attaccante Esterno (Hacker)"
        G_AE[Goal: Rubare ETH<br/>o Dati]
        
        T_AE1[Task: Exploit<br/>Smart Contract]
        T_AE2[Task: Phishing<br/>Chiavi Private]
        T_AE3[Task: DoS<br/>Blockchain]
        T_AE4[Task: Man-in-the-Middle<br/>Web Interface]
        
        SG_AE1[Softgoal: Anonimato]
        
        R_AE1[Resource: Vulnerabilità<br/>Software]
        R_AE2[Resource: Social<br/>Engineering]
        
        G_AE --> T_AE1
        G_AE --> T_AE2
        G_AE --> T_AE3
        G_AE --> T_AE4
        
        T_AE1 --> R_AE1
        T_AE2 --> R_AE2
        
        T_AE1 -.->|??| SG_AE1
        T_AE2 -.->|++| SG_AE1
    end
    
    style G_AE fill:#ff8787
    style SG_AE1 fill:#ffa94d
    style T_AE1 fill:#ff6b6b
    style T_AE2 fill:#ff6b6b
    style T_AE3 fill:#ff6b6b
    style T_AE4 fill:#ff6b6b
```

**Contromisure:**
- 🛡️ **Audit Smart Contract**: OpenZeppelin, formal verification
- 🛡️ **HTTPS/TLS**: Crittografia end-to-end
- 🛡️ **Rate Limiting**: Protezione DoS
- 🛡️ **MetaMask**: Gestione sicura chiavi private
- 🛡️ **Immutabilità Blockchain**: Dati non modificabili

### Strategic Rationale (SR) - Utente Maldestro

```mermaid
graph TB
    subgraph "Utente Maldestro"
        G_UM[Goal: Usare<br/>Sistema]
        
        T_UM1[Task: Inserire<br/>Dati]
        T_UM2[Task: Gestire<br/>Chiavi]
        T_UM3[Task: Approvare<br/>Transazioni]
        
        SG_UM1[Softgoal: Facilità<br/>d'Uso]
        
        E_UM1[Error: Perdere<br/>Chiave Privata]
        E_UM2[Error: Inviare a<br/>Indirizzo Sbagliato]
        E_UM3[Error: Approvare<br/>Transazione Malevola]
        
        G_UM --> T_UM1
        G_UM --> T_UM2
        G_UM --> T_UM3
        
        T_UM1 -.->|Può causare| E_UM2
        T_UM2 -.->|Può causare| E_UM1
        T_UM3 -.->|Può causare| E_UM3
        
        SG_UM1 -.->|Riduce| E_UM1
        SG_UM1 -.->|Riduce| E_UM2
    end
    
    style G_UM fill:#ffa94d
    style SG_UM1 fill:#98FB98
    style E_UM1 fill:#ff6b6b
    style E_UM2 fill:#ff6b6b
    style E_UM3 fill:#ff6b6b
```

**Contromisure:**
- 🛡️ **UI Intuitiva**: Design chiaro e guidato
- 🛡️ **Validazione Input**: Controlli pre-transazione
- 🛡️ **Conferme Multiple**: "Sei sicuro?" per azioni critiche
- 🛡️ **Recovery Seed**: Backup chiave privata
- 🛡️ **Messaggi Chiari**: Errori comprensibili

---

## 4. Alberi di Attacco

### 4.1 Albero di Attacco - Attaccante Interno

```mermaid
graph TD
    ROOT[Ricevere Pagamento<br/>Senza Conformità]
    
    A1[Manipolare<br/>Temperatura]
    A2[Falsificare<br/>Evidenze]
    A3[Corrompere<br/>Sensori]
    
    A1_1[Aprire Pacco<br/>Durante Trasporto]
    A1_2[Sostituire<br/>Ghiaccio]
    A1_3[Esporre a<br/>Temperatura Sbagliata]
    
    A2_1[Modificare Dati<br/>Sensore]
    A2_2[Replay Attack<br/>Dati Vecchi]
    A2_3[Sostituire<br/>Sensore]
    
    A3_1[Firmware<br/>Malware]
    A3_2[Hardware<br/>Tampering]
    
    ROOT --> A1
    ROOT --> A2
    ROOT --> A3
    
    A1 --> A1_1
    A1 --> A1_2
    A1 --> A1_3
    
    A2 --> A2_1
    A2 --> A2_2
    A2 --> A2_3
    
    A3 --> A3_1
    A3 --> A3_2
    
    style ROOT fill:#ff6b6b
    style A1 fill:#ff8787
    style A2 fill:#ff8787
    style A3 fill:#ff8787
    style A1_1 fill:#ffa94d
    style A2_1 fill:#ffa94d
    style A3_1 fill:#ffa94d
```

**Contromisure per Ogni Nodo:**

| Attacco | Contromisura | Implementazione |
|---------|--------------|-----------------|
| **A1_1**: Aprire Pacco | Sigillo Elettronico (E2) | Sensore luce (E4) rileva apertura |
| **A1_2**: Sostituire Ghiaccio | Logger Temperatura (E1) | Monitoraggio continuo 2-8°C |
| **A1_3**: Temperatura Sbagliata | Bayesian Network | P(F1\|E) < 95% → Pagamento negato |
| **A2_1**: Modificare Dati | Firma Crittografica | Sensori firmano con chiave privata |
| **A2_2**: Replay Attack | Timestamp (E5) | Verifica temporale coerente |
| **A2_3**: Sostituire Sensore | Certificato Sensore | Whitelist sensori autorizzati |
| **A3_1**: Firmware Malware | Secure Boot | Firmware verificato all'avvio |
| **A3_2**: Hardware Tampering | Tamper-Evident Seal | Sigillo fisico antimanomissione |

### 4.2 Albero di Attacco - Attaccante Esterno

```mermaid
graph TD
    ROOT2[Rubare ETH<br/>o Compromettere Sistema]
    
    B1[Exploit Smart<br/>Contract]
    B2[Rubare Chiavi<br/>Private]
    B3[Attacco<br/>Rete]
    
    B1_1[Reentrancy<br/>Attack]
    B1_2[Integer<br/>Overflow]
    B1_3[Access Control<br/>Bypass]
    
    B2_1[Phishing<br/>MetaMask]
    B2_2[Keylogger]
    B2_3[Social<br/>Engineering]
    
    B3_1[DoS<br/>Blockchain]
    B3_2[Man-in-the-Middle<br/>Web Interface]
    B3_3[DNS<br/>Spoofing]
    
    ROOT2 --> B1
    ROOT2 --> B2
    ROOT2 --> B3
    
    B1 --> B1_1
    B1 --> B1_2
    B1 --> B1_3
    
    B2 --> B2_1
    B2 --> B2_2
    B2 --> B2_3
    
    B3 --> B3_1
    B3 --> B3_2
    B3 --> B3_3
    
    style ROOT2 fill:#ff8787
    style B1 fill:#ffa94d
    style B2 fill:#ffa94d
    style B3 fill:#ffa94d
    style B1_1 fill:#ffd93d
    style B2_1 fill:#ffd93d
    style B3_1 fill:#ffd93d
```

**Contromisure per Ogni Nodo:**

| Attacco | Contromisura | Implementazione |
|---------|--------------|-----------------|
| **B1_1**: Reentrancy | Checks-Effects-Interactions | Pattern Solidity sicuro |
| **B1_2**: Integer Overflow | SafeMath / Solidity 0.8+ | Controlli automatici overflow |
| **B1_3**: Access Control | OpenZeppelin AccessControl | Modifier `onlyRole()` |
| **B2_1**: Phishing | Educazione Utenti | Warning su transazioni sospette |
| **B2_2**: Keylogger | Hardware Wallet | Ledger/Trezor per chiavi critiche |
| **B2_3**: Social Engineering | 2FA / Multi-sig | Richiede multiple approvazioni |
| **B3_1**: DoS Blockchain | Gas Limit / Rate Limiting | Limiti per transazione |
| **B3_2**: MITM | HTTPS/TLS | Certificato SSL valido |
| **B3_3**: DNS Spoofing | DNSSEC / IPFS | Hosting decentralizzato |

### 4.3 Albero di Attacco - Utente Maldestro

```mermaid
graph TD
    ROOT3[Perdere Fondi<br/>o Accesso]
    
    C1[Perdere<br/>Chiave Privata]
    C2[Inviare a<br/>Indirizzo Sbagliato]
    C3[Approvare<br/>Transazione Errata]
    
    C1_1[Nessun<br/>Backup]
    C1_2[Backup<br/>Insicuro]
    C1_3[Dimenticare<br/>Password]
    
    C2_1[Typo<br/>Indirizzo]
    C2_2[Copia/Incolla<br/>Malware]
    C2_3[QR Code<br/>Sbagliato]
    
    C3_1[Non Leggere<br/>Dettagli]
    C3_2[Fretta]
    C3_3[Confusione<br/>UI]
    
    ROOT3 --> C1
    ROOT3 --> C2
    ROOT3 --> C3
    
    C1 --> C1_1
    C1 --> C1_2
    C1 --> C1_3
    
    C2 --> C2_1
    C2 --> C2_2
    C2 --> C2_3
    
    C3 --> C3_1
    C3 --> C3_2
    C3 --> C3_3
    
    style ROOT3 fill:#ffa94d
    style C1 fill:#ffd93d
    style C2 fill:#ffd93d
    style C3 fill:#ffd93d
    style C1_1 fill:#ffe066
    style C2_1 fill:#ffe066
    style C3_1 fill:#ffe066
```

**Contromisure per Ogni Nodo:**

| Errore | Contromisura | Implementazione |
|--------|--------------|-----------------|
| **C1_1**: Nessun Backup | Recovery Seed Obbligatorio | MetaMask forza backup seed |
| **C1_2**: Backup Insicuro | Educazione Sicurezza | Tutorial su storage sicuro |
| **C1_3**: Password Dimenticata | Password Manager | Suggerimento uso 1Password/Bitwarden |
| **C2_1**: Typo Indirizzo | Checksum Validation | Verifica checksum Ethereum |
| **C2_2**: Malware Clipboard | Conferma Visiva | Mostra indirizzo completo |
| **C2_3**: QR Code Sbagliato | Doppia Verifica | Mostra indirizzo + QR |
| **C3_1**: Non Leggere | UI Chiara | Highlight info critiche |
| **C3_2**: Fretta | Cooldown Period | Ritardo 5s per conferma |
| **C3_3**: Confusione UI | UX Testing | Design intuitivo e testato |

---

## 5. Matrice di Rischio

### Valutazione Rischi Pre-Mitigazione

| Attacco | Probabilità | Impatto | Rischio | Priorità |
|---------|-------------|---------|---------|----------|
| Manipolazione Sensori | Alta | Alto | **Critico** | 🔴 P1 |
| Exploit Smart Contract | Media | Critico | **Alto** | 🟠 P2 |
| Phishing Chiavi | Alta | Alto | **Critico** | 🔴 P1 |
| Perdita Chiave Privata | Alta | Medio | **Alto** | 🟠 P2 |
| DoS Blockchain | Bassa | Medio | **Medio** | 🟡 P3 |
| Typo Indirizzo | Media | Medio | **Medio** | 🟡 P3 |

### Valutazione Rischi Post-Mitigazione

| Attacco | Probabilità | Impatto | Rischio Residuo | Status |
|---------|-------------|---------|-----------------|--------|
| Manipolazione Sensori | Bassa | Alto | **Medio** | ✅ Mitigato |
| Exploit Smart Contract | Molto Bassa | Critico | **Basso** | ✅ Mitigato |
| Phishing Chiavi | Media | Alto | **Medio** | ⚠️ Monitorare |
| Perdita Chiave Privata | Bassa | Medio | **Basso** | ✅ Mitigato |
| DoS Blockchain | Molto Bassa | Medio | **Basso** | ✅ Mitigato |
| Typo Indirizzo | Bassa | Medio | **Basso** | ✅ Mitigato |

---

## 6. Conclusioni

### Miglioramenti Chiave del Sistema

1. **Allineamento Incentivi**: Pagamento condizionale elimina moral hazard
2. **Trasparenza**: Evidenze immutabili on-chain
3. **Automazione**: Smart contract elimina intermediari
4. **Sicurezza Multi-Livello**: Crittografia + Bayesian Network + IoT
5. **Responsabilità Chiara**: Evidenze provano negligenza

### Raccomandazioni Finali

| Area | Raccomandazione | Priorità |
|------|-----------------|----------|
| **Sensori** | Implementare firma crittografica | 🔴 Alta |
| **Smart Contract** | Audit formale da terze parti | 🔴 Alta |
| **UI/UX** | User testing con utenti reali | 🟠 Media |
| **Backup** | Sistema recovery multi-firma | 🟠 Media |
| **Monitoring** | Dashboard real-time anomalie | 🟡 Bassa |

---

**Documento creato per**: Progetto Software Security  
**Data**: 24 Novembre 2024  
**Versione**: 1.0
