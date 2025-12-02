# 🏥 Sistema Oracolo Bayesiano per Catena del Freddo Farmaceutica

Sistema blockchain-based per garantire la conformità delle spedizioni farmaceutiche utilizzando Smart Contract, Sensori IoT e Bayesian Network.

## 🚀 Quick Start (5 minuti)

### Prerequisiti
- ✅ Node.js v14+ installato
- ✅ Ganache installato e in esecuzione
- ✅ MetaMask installato nel browser

### Installazione Rapida

```bash
# 1. Clone del repository
git clone https://github.com/lucabelard/ProgettoSoftwareSecurity.git
cd ProgettoSoftwareSecurity

# 2. Installa dipendenze
npm install

# 3. Avvia Ganache (GUI o CLI)
# Assicurati che sia su porta 7545

# 4. Deploy del contratto
truffle migrate --reset

# 5. Copia ABI nell'interfaccia web
# Windows PowerShell:
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force

# Linux/Mac:
cp build/contracts/BNCalcolatoreOnChain.json web-interface/

# 6. Avvia interfaccia web
cd web-interface
python -m http.server 8000
# Oppure: npx http-server -p 8000
```

### Configurazione MetaMask

1. **Aggiungi Rete Ganache**:
   - Nome: `Ganache Local`
   - RPC URL: `http://127.0.0.1:7545`
   - Chain ID: `1337`
   - Simbolo: `ETH`

2. **Importa Account**:
   - Apri Ganache
   - Copia la chiave privata del primo account
   - In MetaMask: Importa Account → Incolla chiave

3. **Apri l'interfaccia**: http://localhost:8000

## 📖 Documentazione

- 📘 [**Guida Installazione e Troubleshooting**](./GUIDA_INSTALLAZIONE_E_TROUBLESHOOTING.md) - Setup completo e risoluzione problemi
- 📖 [**Manuale Utente**](./MANUALE_UTENTE.md) - Guida all'utilizzo del sistema
- 🎯 [**Analisi i* e Sicurezza**](./docs/istar_diagrams.md) - Diagrammi SD/SR e alberi di attacco
- 🛡️ [**Analisi STRIDE-DUA**](./DUAL_STRIDE_ANALYSIS.md) - Analisi minacce estesa
- 🏗️ [**Design Asset e Verifica Formale**](./docs/ASSET_DESIGN_AND_VERIFICATION.md) - Design asset (OWASP/Saltzer & Schroeder/Sommerville), Modello Markov Chain e Verifica PRISM (Safety/Guarantee)

## 🏗️ Architettura

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  Mittente   │─────▶│Smart Contract│◀─────│  Corriere   │
│ (Farmacia)  │      │  (Ethereum)  │      │ (Trasporto) │
└─────────────┘      └──────────────┘      └─────────────┘
                            ▲
                            │
                     ┌──────┴──────┐
                     │ Sensori IoT │
                     │   E1 - E5   │
                     └─────────────┘
```

### Componenti Principali

- **Smart Contract**: `BNCalcolatoreOnChain.sol` - Gestisce escrow e calcolo Bayesiano
- **Web Interface**: `web-interface/` - Dashboard per interazione utente
- **Bayesian Network**: Calcola P(F1, F2 | E1...E5) per validare conformità
- **Sensori IoT**: 5 evidenze (Temperatura, Sigillo, Shock, Luce, Scan)

## 🧪 Testing

### Scenario di Test Positivo

1. **Connetti Wallet** (usa account[0] di Ganache)
2. **Crea Spedizione**:
   - Corriere: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`
   - Importo: `1 ETH`
3. **Invia Evidenze** (ID Spedizione: 1):
   - E1: ✅ True (Temperatura OK)
   - E2: ✅ True (Sigillo intatto)
   - E3: ❌ False (Nessuno shock)
   - E4: ❌ False (Nessuna apertura)
   - E5: ✅ True (Scan arrivo)
4. **Valida Pagamento** (cambia account → corriere)
   - Risultato: ✅ Pagamento di 1 ETH ricevuto

### Scenario di Test Negativo

Ripeti con evidenze sbagliate:
- E1: ❌ False (Temperatura fuori range)
- E3: ✅ True (Shock rilevato)

Risultato: ❌ "Requisiti di conformità non superati"

## 🔧 Troubleshooting

### "Contract not deployed"
```bash
truffle migrate --reset
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force
# Ricarica pagina con Ctrl+Shift+R
```

### "Returned error: Internal JSON-RPC error"
- Verifica di usare `accounts[0]` (ha tutti i ruoli)
- Verifica che tutte e 5 le evidenze siano state inviate
- Controlla la console del browser (F12) per dettagli

### MetaMask non si connette
- Verifica che Ganache sia in esecuzione
- Verifica di essere sulla rete "Ganache Local"
- Resetta account MetaMask se necessario

## 📊 Funzionalità Principali

### Ruoli e Permessi

| Ruolo | Account | Funzionalità |
|-------|---------|--------------|
| **Admin/Oracolo** | accounts[0] | Imposta probabilità e CPT |
| **Mittente** | accounts[0], accounts[2] | Crea spedizioni, deposita ETH |
| **Sensore** | accounts[0], accounts[1] | Invia evidenze E1-E5 |
| **Corriere** | Qualsiasi | Valida e riceve pagamento |

### Bayesian Network

Il sistema calcola:
```
P(F1=True | E1...E5) ≥ 95%  (Temperatura conforme)
P(F2=True | E1...E5) ≥ 95%  (Imballaggio integro)
```

Se entrambe le condizioni sono soddisfatte → **Pagamento approvato** ✅  
Altrimenti → **Pagamento rifiutato** ❌

## 🛡️ Sicurezza

- ✅ **Access Control**: Ruoli gestiti con OpenZeppelin
- ✅ **Escrow**: ETH bloccato fino a validazione
- ✅ **Immutabilità**: Evidenze registrate on-chain
- ✅ **Crittografia**: Firma digitale sensori (pianificato)
- ✅ **Audit**: Contratto verificabile e trasparente

## 📚 Tecnologie Utilizzate

- **Blockchain**: Ethereum (Ganache per sviluppo)
- **Smart Contract**: Solidity 0.8.19
- **Framework**: Truffle Suite
- **Librerie**: OpenZeppelin Contracts
- **Frontend**: HTML5, CSS3, JavaScript (Web3.js)
- **Testing**: Truffle Test, MetaMask

## 👥 Team

- Luca Belard
- [Altri membri del team]

## 📄 Licenza

MIT License - Vedi [LICENSE](./LICENSE) per dettagli

## 🤝 Contribuire

1. Fork del repository
2. Crea un branch (`git checkout -b feature/AmazingFeature`)
3. Commit delle modifiche (`git commit -m 'Add AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📞 Supporto

Per problemi o domande:
- 📧 Email: [inserisci email]
- 🐛 Issues: [GitHub Issues](https://github.com/lucabelard/ProgettoSoftwareSecurity/issues)
- 📖 Wiki: [GitHub Wiki](https://github.com/lucabelard/ProgettoSoftwareSecurity/wiki)

---

**Progetto**: Software Security - Università [Nome]  
**Anno Accademico**: 2024/2025  
**Versione**: 1.0
