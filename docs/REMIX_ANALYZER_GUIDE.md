# 🔍 Guida Completa: Analisi Statica con Remix IDE

## Passo 1: Aprire Remix IDE ✅

🌐 **URL**: https://remix.ethereum.org

Il browser si aprirà automaticamente con Remix caricato!

---

## Passo 2: Caricare i Tuoi Contratti 📁

### Metodo A: Drag & Drop (PIÙ VELOCE)

1. **Apri Finder** nel tuo Mac
2. **Vai a**: `/Applications/MAMP/htdocs/ProgettoSoftwareSecurity/contracts/`
3. **Seleziona questi 4 file**:
   - `BNCore.sol`
   - `BNGestoreSpedizioni.sol`
   - `BNPagamenti.sol`
   - `BNCalcolatoreOnChain.sol`
4. **Trascina** i file nella finestra di Remix (area FILE EXPLORER a sinistra)

### Metodo B: Crea Workspace e Upload

1. Nel **FILE EXPLORER** (icona documenti a sinistra)
2. Click su **"+"** (New File)
3. Per ogni contratto:
   - Copia il contenuto del file locale
   - Incolla in Remix
   - Salva con lo stesso nome

---

## Passo 3: Compilare i Contratti 🔨

1. **Click sull'icona "Solidity Compiler"** (seconda icona da sinistra, simbolo "S")
2. **Verifica la versione**: Dovrebbe essere `0.8.20` o simile
   - Se diversa, seleziona `0.8.20` dal dropdown
3. **Click sul bottone blu "Compile BNCalcolatoreOnChain.sol"**
4. **Aspetta** il segno di spunta verde ✅

---

## Passo 4: Eseguire Solidity Analyzer 🎯

### 4a. Attivare il Plugin

1. **Click sull'icona "Plugin Manager"** (icona plug in basso a sinistra)
2. **Cerca**: "Solidity static analysis"
3. **Click "Activate"** sul plugin "SOLIDITY STATIC ANALYSIS"

### 4b. Aprire l'Analyzer

1. **Nella sidebar sinistra**, apparirà una nuova icona con un lucchetto/scudo
2. **Click sull'icona** per aprire il pannello di analisi

### 4c. Eseguire l'Analisi

1. **Seleziona il file**: `BNCalcolatoreOnChain.sol` (dovrebbe essere già selezionato)
2. **Checkboxes**: Lascia tutto selezionato (tutti i check attivi)
3. **Click sul bottone "Run"** 🚀
4. **Aspetta** 2-5 secondi per i risultati

---

## Passo 5: Interpretare i Risultati 📊

I risultati sono divisi in categorie:

### 🟢 Informational (Verde)
- **Cosa sono**: Suggerimenti di best practice
- **Azione**: Opzionale, ma buono da considerare
- **Esempio**: "Use of now instead of block.timestamp"

### 🟡 Low (Giallo)
- **Cosa sono**: Potenziali miglioramenti
- **Azione**: Consigliato fixare se facile
- **Esempio**: "Unused state variable"

### 🟠 Medium (Arancione)
- **Cosa sono**: Issue di sicurezza moderate
- **Azione**: **DA FIXARE**
- **Esempio**: "Dangerous strict equality"

### 🔴 High (Rosso)
- **Cosa sono**: Vulnerabilità critiche
- **Azione**: **DA FIXARE IMMEDIATAMENTE**
- **Esempio**: "Reentrancy vulnerability"

---

## Passo 6: Documentare i Risultati 📝

Copia i risultati e crea questo file:

**`docs/STATIC_ANALYSIS_RESULTS.md`**:

```markdown
# Risultati Analisi Statica - Solidity Analyzer

**Data**: 2025-12-05
**Tool**: Remix IDE - Solidity Static Analysis
**Contratti Analizzati**: BNCalcolatoreOnChain.sol (+ moduli)

## Riepilogo

| Severity | Count | Status |
|----------|-------|--------|
| 🔴 High | 0 | ✅ |
| 🟠 Medium | X | ⚠️ |
| 🟡 Low | Y | ✅ |
| 🟢 Info | Z | ✅ |

## Dettagli per Categoria

### 🔴 High Severity Issues
_Nessuno trovato_ ✅

### 🟠 Medium Severity Issues
1. **Issue**: [Descrizione]
   - **File**: BNPagamenti.sol:42
   - **Problema**: [Spiegazione]
   - **Fix**: [Come risolto]
   - **Status**: ✅ Risolto / ⚠️ Da risolvere

[... altri issue ...]

### Raccomandazioni
- [Lista azioni intraprese]
```

---

## Passo 7: Eseguire Solhint (Opzionale ma Consigliato) 🔧

Nel **terminale Mac**:

```bash
# Installa Solhint globalmente
npm install -g solhint

# Vai nella directory del progetto
cd /Applications/MAMP/htdocs/ProgettoSoftwareSecurity

# Esegui Solhint
solhint 'contracts/**/*.sol'
```

**Output atteso**: Lista di warning/errori con numero linea

---

## Checklist Veloce ✅

- [ ] Remix aperto
- [ ] 4 contratti caricati
- [ ] Compilazione riuscita (✅ verde)
- [ ] Plugin "Solidity static analysis" attivato
- [ ] Analisi eseguita
- [ ] Risultati documentati in `docs/STATIC_ANALYSIS_RESULTS.md`
- [ ] (Opzionale) Solhint eseguito
- [ ] Issue critici risolti

---

## 🎯 Cosa Cercare Specificamente

### Issue Comuni da Fixare:

1. **Reentrancy**
   - Usa pattern Checks-Effects-Interactions ✅ (già fatto!)
   - Il tuo contratto usa `call` per transfer → verifica ordine operazioni

2. **Integer Overflow**
   - Solidity 0.8+ ha protezione built-in ✅ (già protetto!)

3. **Access Control**
   - Verifica che tutti i `onlyRole` siano corretti ✅ (già fatto!)

4. **Gas Optimization**
   - Variabili `public` vs `private`
   - Loop efficienti

---

## Tempo Stimato ⏱️

- Caricamento contratti: 2 min
- Compilazione: 1 min
- Attivazione plugin: 30 sec
- Esecuzione analisi: 30 sec
- Revisione risultati: 5-10 min
- Documentazione: 5 min

**TOTALE: ~15 minuti** ⚡

---

## Tips Pro 💡

1. **Esegui l'analisi su OGNI contratto** separatamente per dettagli migliori
2. **Compila PRIMA** di analizzare (importante!)
3. **Salva il workspace** in Remix per tornare dopo
4. **Screenshot dei risultati** per la documentazione
5. **Non ignorare i "Low"** - sono facili da fixare!

---

🎉 **Fatto! L'analisi statica è completata!**
