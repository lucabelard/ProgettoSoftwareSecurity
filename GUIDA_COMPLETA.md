# 🚀 Guida Completa all'Avvio del Progetto

Questa guida ti accompagnerà passo dopo passo nell'installazione, configurazione e utilizzo della Blockchain Besu e della DApp di monitoraggio spedizioni.

---

## 1️⃣ Installazione Hyperledger Besu

Se non hai ancora Besu installato:
1. Scarica l'ultima versione di Besu (zip) da [GitHub Releases](https://github.com/hyperledger/besu/releases).
2. Estrai lo zip in una cartella a piacere (es: `C:\Besu`).
3. **Importante**: Aggiungi la cartella `bin` di Besu alle Variabili d'Ambiente di Windows (PATH):
   - Cerca "Modifica le variabili di ambiente relative al sistema".
   - Clicca su "Variabili d'ambiente".
   - In "Variabili di sistema" (o utente), trova `Path`, selezionalo e clicca "Modifica".
   - Clicca "Nuovo" e incolla il percorso completo della cartella `bin` (es: `C:\Besu\besu-24.x.x\bin`).
   - Conferma tutto con OK.
4. Verifica aprendo un terminale (PowerShell o CMD) e digitando `besu --version`. Se vedi la versione, sei pronto!

---

## 2️⃣ Avvio della Rete Blockchain

Ho creato degli script automatici per facilitare tutto. Non devi digitare comandi complessi.

1. Vai nella cartella principale del progetto.
2. Fai doppio click su **`avvia-rete-besu.bat`**.

**Cosa succederà:**
- Si apriranno 4 finestre (una per ogni nodo validatore).
- Una finestra principale coordinerà l'avvio e connetterà i nodi tra loro.
- Attendi che appaia la scritta "RETE AVVIATA!".

> **Nota**: I nodi resteranno aperti. Non chiudere le finestre dei nodi!

---

## 3️⃣ Configurazione MetaMask

Ora connettiamo il tuo browser alla blockchain locale.

1. Installa l'estensione **MetaMask** sul tuo browser.
2. Clicca sull'icona della rete in alto a sinistra (di solito dice "Ethereum Mainnet") -> **Aggiungi rete** -> **Aggiungi rete manualmente**.
3. Inserisci questi dati:
   - **Nome Rete**: `Besu Local`
   - **Nuovo URL RPC**: `http://127.0.0.1:8545`
   - **Chain ID**: `2024`
   - **Simbolo Valuta**: `ETH`
4. Salva.

### Importare gli Account con Fondi
Il progetto ha degli account pre-caricati con ETH (finti) per fare test.
Apri il file **`METAMASK_ACCOUNTS.txt`** nella cartella del progetto: troverai le Chiavi Private.

1. In MetaMask, clicca sul cerchio colorato del tuo account -> **Importa account**.
2. Incolla la **Chiave Privata** del primo account ("Account 1 - Admin/Mittente") dal file di testo.
3. Ripeti per importare anche l'account del Corriere e del Sensore se vuoi testare quei ruoli.

---

## 4️⃣ Avvio Monitor e Sito Web

1. **Monitor Transazioni (Opzionale ma consigliato)**:
   - Fai doppio click su **`guarda-transazioni.bat`**.
   - Si aprirà una finestra nera che ti mostrerà in tempo reale ogni transazione che fai sul sito.

2. **Avvio Sito Web**:
   - Fai doppio click su **`avvia-sito.bat`**.
   - Si aprirà il browser (o ti verrà detto l'indirizzo, solitamente `http://127.0.0.1:8080`).

---

## 5️⃣ Utilizzo dell'Applicazione

Ora sei pronto a testare!

1. **Connetti Wallet**: Clicca "Connect Wallet" sul sito. Assicurati di essere su "Besu Local" in MetaMask.
2. **Dashboard**: Vedrai il tuo ruolo (Admin, Mittente, ecc.) in base all'account che stai usando.
3. **Crea Spedizione**: Come "Mittente", puoi creare una nuova spedizione specificando l'indirizzo del Corriere.
   - *Tip*: Copia l'indirizzo del "Account 2" che hai importato in MetaMask per usarlo come corriere.
4. **Agisci**: 
   - Cambia account in MetaMask (seleziona il Corriere).
   - Il sito si aggiornerà. Potrai vedere le spedizioni assegnate a te.
   - Usa il Monitor Transazioni per vedere i dettagli tecnici di ogni click!

---

### 🆘 Risoluzione Problemi Comuni

- **Errore "Internal JSON-RPC error" o Gas**: Abbiamo applicato un fix per usare transazioni "Legacy". Se capita, prova a resettare l'account in MetaMask (Impostazioni -> Avanzate -> Cancella dati attività scheda) per pulire lo storico delle nonce.
- **I nodi non si connettono**: Chiudi tutte le finestre dei nodi e riavvia `avvia-rete-besu.bat`.
- **Git non fa push**: Se capita ancora, usa i comandi `git add .`, `git commit` e `git push` come spiegato nel fix precedente.
