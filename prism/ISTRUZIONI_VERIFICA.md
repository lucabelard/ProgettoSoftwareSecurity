# Istruzioni Verifica PRISM: Sistema Escrow

## 1. Caricamento su PRISM (Modalità GUI)

1.  **Avvia PRISM** (`xprism` su Linux, `prism.bat` su Windows, o doppio clic su `prism.jar`).
2.  Nel menu **Model**, seleziona **Open Model...**.
    *   Scegli il file: `escrow_system.prism`
    *   Verifica che in basso a destra appaia: `Model type: DTMC`.
3.  Nel menu **Properties**, seleziona **Open properties list...**.
    *   Scegli il file: `escrow_properties.pctl`
4.  Dovresti vedere la lista delle proprietà (S1, S2... G1, G2...).

## 2. Esecuzione della Verifica

1.  Fai clic destro su una proprietà (es. `S1: Single Payment`).
2.  Scegli **Verify**.
3.  Attendi il risultato nella colonna "Result".

---

## 3. Risultati Attesi e Interpretazione

Ecco i valori che devi aspettarti se il modello è corretto:

| ID | Proprietà | Risultato Atteso | Significato |
|----|-----------|------------------|-------------|
| **S1** | Single Payment (Safety) | **1.0** (Vero) | È impossibile pagare due volte la stessa spedizione. |
| **S2** | State Exclusivity | **1.0** (Vero) | La spedizione non può essere contemporaneamente Pagata e Rimborsata. |
| **S3** | Evidence Required | **1.0** (Vero) | Impossibile pagare se le evidenze non sono complete. |
| **S6** | Cancellation Condition | **1.0** (Vero) | Annullamento possibile solo con 0 evidenze inviate. |
| **G1** | Eventual Resolution | **> 0.99** (~0.999) | Quasi certezza che la spedizione si chiuda (Pagata/Rimborsata/Annullata) entro 14gg. |
| **G2** | Refund on Timeout (7gg) | **> 0.95** (~0.95) | Se scade il timeout senza evidenze, il rimborso è disponibile (95% prob. richiesta). |
| **G3** | Refund on 3 Failures | **> 0.90** (~0.90) | Dopo 3 validazioni fallite, il rimborso è disponibile. |
| **G4** | Refund on Inactivity (14gg) | **> 0.85** (~0.85) | Se il corriere non valida entro 14gg (con evidenze pronte), il rimborso è disponibile. |
| **R** | Expected Resolution Time | **~72.3** | Tempo medio atteso (in ore) prima della risoluzione. |

### Note sui Risultati Probabilistici (G1-G4)
I valori `< 1.0` per le proprietà di Guarantee (G1-G4) sono corretti perché il modello assume che il mittente debba *richiedere manualmente* il rimborso (probabilità 95%). Se fosse automatico, sarebbero 1.0.

---

## 4. Verifica da Riga di Comando (CLI)

Se preferisci usare il terminale:

```bash
# Verifica Safety (S1)
prism escrow_system.prism escrow_properties.pctl -prop safety_single_payment

# Verifica Risoluzione (G1)
prism escrow_system.prism escrow_properties.pctl -prop guarantee_eventual_resolution

# Verifica tutte le proprietà
prism escrow_system.prism escrow_properties.pctl
```
