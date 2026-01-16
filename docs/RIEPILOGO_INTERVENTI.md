# 📝 Riepilogo Interventi e Fix

Data: 16 Gennaio 2026

## 1. Risoluzione Bug "Validazione Fallita"

**Problema:** Il corriere riceveva sempre "Validazione Fallita" anche con spedizioni conformi.

**Analisi e Fix:**
1.  **Mancata Inizializzazione**: Le probabilità a priori (`p_F1_T`, `p_F2_T`) e le tabelle CPT erano a 0 di default nel contratto. Senza inizializzazione da parte dell'Admin, il calcolo bayesiano restituiva sempre 0%.
    *   *Soluzione*: Identificata la necessità di eseguire il setup Admin pre-validazione.
2.  **Logica CPT Invertita**: Per le evidenze **E3 (Shock)** ed **E4 (Luce)**, il valore `false` indica conformità (Nessuno shock, Nessuna apertura). Tuttavia, le CPT erano configurate assumendo `true` come valore positivo.
    *   *Soluzione*: Invertite le CPT per E3 ed E4. Ora `p_TT` (Probabilità True dato Stato True) per queste evidenze deve essere bassa (es. 1%), mentre `p_FF` deve essere alta (es. 99%).

## 2. Attivazione e Configurazione Hyperledger BESU

**Problema:** L'ambiente BESU presente nel repository non funzionava (file mancanti, config errate).

**Interventi:**
1.  **Ripristino Genesis**: Il file `besu-config/genesis.json` era mancante. È stato ricreato, ma successivamente si è optato per la modalità `--network=dev` di BESU che auto-configura un ambiente di test stabile.
2.  **Fix Truffle Config**:
    *   Aggiornato `truffle-config.js` per la rete `besu`.
    *   Corretto il `network_id` da `1337` a `2018` (ID interno di Besu Dev), per permettere il deploy.
    *   Reinserito Chain ID `1337` per compatibilità MetaMask/Ganache su richiesta.
3.  **Configurazione Account**:
    *   Recuperate le chiavi private degli account pre-funded di BESU Dev Mode (diversi da quelli di Ganache).
    *   Creato file `besu-config/ACCOUNTS.txt` con le credenziali corrette.
    *   Mappati correttamente i ruoli (Admin, Sensore, Mittente, Corriere) agli indirizzi specifici usati nello script di migrazione.
4.  **Frontend**:
    *   Spostato il server web sulla porta **3000**.
    *   Verificato il flusso completo (Deploy -> Web -> Transazione su Besu -> Conferma blocco).

## 3. Aggiornamento Documentazione

*   Aggiornato `SCELTE_TECNOLOGICHE.md` inserendo la sezione **5.4 Architettura Sicura e Pattern**, documentando formalmente come l'uso di BESU soddisfi i requisiti di architettura distribuita, ridondante e diversificata.
*   Creata questa guida di riepilogo e il tutorial di avvio.

## Stato Attuale
Il progetto è ora pienamente funzionante su blockchain **Hyperledger Besu**, rispettando i requisiti architetturali avanzati del corso.
