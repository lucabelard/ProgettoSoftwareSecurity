# 🚀 Istruzioni Test Performance

Questo sistema permette di testare le performance di 3 varianti di Smart Contract Bayesian Network:
1. **BN_Simple** (1 Fatto, 2 Evidenze)
2. **BN_Medium** (2 Fatti, 3 Evidenze)
3. **BN_Complex** (2 Fatti, 5 Evidenze)

> 📂 **Nota**: I contratti di esempio sono stati creati appositamente nella cartella `contracts/performance/`.

## 🔬 Metodologia di Test

I test vengono eseguiti sequenzialmente su una rete locale (Besu) e misurano tre fasi critiche del ciclo di vita del contratto:

1. **Deploy**:
   - Viene misurato il gas necessario per il deployment del contratto.
   - Viene calcolata la dimensione del bytecode in bytes.

2. **Configurazione (Setup)**:
   - Viene misurato il gas cumulativo per impostare le probabilità a priori e le tabelle CPT (Conditional Probability Tables).
   - Più complessa è la rete, più transazioni di configurazione sono necessarie.

3. **Calcolo (Inferenza)**:
   - Viene simulata la ricezione di tutte le evidenze.
   - Viene misurato il gas per la funzione `validaEvidenze` (utilizzando `estimateGas` poiché è una funzione `view`).

Tutti i dati vengono salvati in un CSV e poi visualizzati nel report HTML.

## 🏃‍♂️ Come Avviare i Test

### Su Windows 🪟
Fai doppio click sul file:
`test\performance\run_performance_suite.bat`

Oppure da terminale:
```cmd
.\test\performance\run_performance_suite.bat
```

### Su Mac / Linux 🍎
Da terminale:
```bash
# Dai i permessi di esecuzione (solo la prima volta)
chmod +x test/performance/run_performance_tests.sh

# Esegui
./test/performance/run_performance_tests.sh
```

---

## 📊 Output e Risultati

Il sistema genera automaticamente due file nella cartella `results`:

1. **`performance-data.csv`**: I dati grezzi.

2. **`report.html`**: Un report grafico interattivo.
   - Apri questo file nel browser dopo i test per vedere i grafici di Gas e Tempo.

## ✅ Risultati Attesi

Dovresti vedere 3 esecuzioni di test ("Passing") e infine la generazione del report.

I valori tipici di riferimento (Gas Calcolo):
- **BN_Simple**: ~35,000 gas
- **BN_Medium**: ~57,000 gas
- **BN_Complex**: ~75,000 gas

Se vedi questi valori, il sistema funziona correttamente!
