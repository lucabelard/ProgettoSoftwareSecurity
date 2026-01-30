# 🚀 Guida Avvio Sistema Completo

Segui questi 3 passaggi per avviare l'intero sistema da zero.

## 1. Avvio Rete Blockchain (Besu + Proxy)
Avvia la rete locale con i 4 nodi e il proxy di failover.

*   **Script:** `.\besu-config\scripts\windows\start-all-nodes-failover.bat`
*   **Cosa fa:**
    *   Pulisce le porte occupate.
    *   Avvia il "Failover Proxy" su `localhost:8545`.
    *   Avvia i 4 Nodi Besu.
*   **Verifica:**
    *   Attendi che tutti i nodi siano partiti.
    *   La finestra del proxy deve mostrare "Monitoring active...".

---

## 2. Deploy e Setup Contratti
Compila i contratti, li pubblica sulla blockchain appena avviata e configura automaticamente i ruoli e le probabilità (CPT).

*   **Comando:**
    ```powershell
    truffle compile
    node deploy-complete.js
    ```
    *(Nota: `truffle compile` serve solo se hai modificato i contratti Solidity, ma è buona norma farlo)*

*   **Cosa fa:**
    *   Deploy del contratto `BNCalcolatoreOnChain`.
    *   Assegna i ruoli (Sensore, Mittente).
    *   Configura le tabelle di probabilità (CPT) per le evidenze.
    *   Salva l'indirizzo aggiornato per il sito web.

---

## 3. Avvio Sito Web
Lancia il server web locale per l'interfaccia utente.

*   **Script:** `.\avvia-sito.bat`
*   **Cosa fa:**
    *   Avvia un server HTTP locale.
    *   Ti mostrerà un link (solitamente `http://127.0.0.1:8080`).
*   **Utilizzo:**
    *   Apri il link nel browser.
    *   Assicurati che **MetaMask** sia connesso a `Localhost 8545` (Chain ID 2024).

---

## 🛠️ Risoluzione Problemi Rapida

*   **Errore "Genesis mismatch"?**: Esegui `.\besu-config\scripts\windows\clean-data.bat` e riavvia dal punto 1.
*   **MetaMask non connette?**: Resetta l'account in MetaMask (Impostazioni -> Avanzate -> Cancella dati attività tab/cronologia) per allineare il `nonce` alla nuova blockchain locale.
