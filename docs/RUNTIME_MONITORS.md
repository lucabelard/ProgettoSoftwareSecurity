# Runtime Enforcement Monitors

## Introduzione

Questo documento descrive i **Runtime Enforcement Monitors** implementati nello smart contract `BNCalcolatoreOnChain.sol` per garantire il rispetto di proprietà di sicurezza critiche durante l'esecuzione.

I monitor sono divisi in due categorie:
- **Safety Properties**: Garantiscono che eventi pericolosi non accadano mai
- **Guarantee/Response Properties**: Garantiscono che determinate azioni vengano completate

---

## Safety Properties

### S1: Access Control Enforcement

**Descrizione**: Solo gli utenti con i ruoli appropriati possono eseguire funzioni privilegiate.

**Implementazione**:
```solidity
modifier onlyRole(bytes32 role) // Da OpenZeppelin AccessControl
```

**Proprietà Formale**:
```
∀ funzione f ∈ {impostaProbabilitaAPriori, impostaCPT, creaSpedizione, inviaEvidenza}:
    NEVER (chiamante_senza_ruolo_richiesto può eseguire f)
```

**Monitor**:
- Modifier `onlyRole()` verifica ruolo prima dell'esecuzione
- `AccessControl` di OpenZeppelin gestisce i permessi

**Casi di Violazione**:
- Utente senza `RUOLO_ORACOLO` tenta di chiamare `impostaCPT`
- Utente senza `RUOLO_MITTENTE` tenta di creare spedizione
- Utente senza `RUOLO_SENSORE` tenta di inviare evidenze

**Risposta alla Violazione**:
- ❌ Transaction revert con messaggio "AccessControl: account ... is missing role ..."
- 📊 Evento `MonitorSafetyViolation` emesso (nuovo)

**Test di Verifica**:
```javascript
it("S1: Solo ORACOLO può impostare CPT", async () => {
    await expectRevert(
        contract.impostaCPT(1, cpt, {from: nonOracolo}),
        "missing role"
    );
});
```

---

### S2: Single Payment Enforcement

**Descrizione**: Una spedizione può essere pagata al massimo una volta.

**Implementazione**:
```solidity
function validaEPaga(uint256 _id) external {
    require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa");
    // ...
    s.stato = StatoSpedizione.Pagata;
}
```

**Proprietà Formale**:
```
∀ spedizione s:
    NEVER (s.stato == Pagata AND validaEPaga(s) succeeds)
```

**Monitor**:
- Check dello stato prima del pagamento
- Transizione di stato irreversibile (InAttesa → Pagata)

**Casi di Violazione**:
- Tentativo di chiamare `validaEPaga` su spedizione già pagata
- Replay attack dello stesso pagamento

**Risposta alla Violazione**:
- ❌ Transaction revert "Spedizione non in attesa"
- 📊 Evento `MonitorSafetyViolation("SinglePayment", ...)` (nuovo)

**Test di Verifica**:
```javascript
it("S2: Previene doppio pagamento", async () => {
    await contract.validaEPaga(1);
    await expectRevert(
        contract.validaEPaga(1),
        "Spedizione non in attesa"
    );
});
```

---

### S3: Complete Evidence Required

**Descrizione**: Tutte le 5 evidenze devono essere ricevute prima che il pagamento possa essere effettuato.

**Implementazione**:
```solidity
require(
    s.evidenze.E1_ricevuta && s.evidenze.E2_ricevuta &&
    s.evidenze.E3_ricevuta && s.evidenze.E4_ricevuta &&
    s.evidenze.E5_ricevuta, 
    "Evidenze mancanti"
);
```

**Proprietà Formale**:
```
∀ spedizione s:
    NEVER (pagamento_eseguito(s) AND ∃ evidenza e: e.ricevuta == false)
```

**Monitor**:
- Verifica booleana AND di tutte le flags `E*_ricevuta`
- Check obbligatorio prima del calcolo probabilità

**Casi di Violazione**:
- Tentativo di pagamento con meno di 5 evidenze
- Evidenze parziali

**Risposta alla Violazione**:
- ❌ Transaction revert "Evidenze mancanti"
- 📊 Evento `MonitorSafetyViolation("CompleteEvidence", ...)` (nuovo)

**Test di Verifica**:
```javascript
it("S3: Richiede tutte le 5 evidenze", async () => {
    // Invia solo 4 evidenze
    await contract.inviaEvidenza(1, 1, true);
    await contract.inviaEvidenza(1, 2, true);
    await contract.inviaEvidenza(1, 3, true);
    await contract.inviaEvidenza(1, 4, true);
    // Manca E5
    
    await expectRevert(
        contract.validaEPaga(1),
        "Evidenze mancanti"
    );
});
```

---

### S4: Probability Threshold Enforcement

**Descrizione**: Il pagamento non può essere effettuato se le probabilità posteriori non superano la soglia del 95%.

**Implementazione**:
```solidity
require(
    probF1 >= SOGLIA_PROBABILITA && probF2 >= SOGLIA_PROBABILITA,
    "Requisiti di conformita non superati"
);
```

**Proprietà Formale**:
```
∀ spedizione s:
    NEVER (pagamento_eseguito(s) AND (P(F1|E) < 95% OR P(F2|E) < 95%))
```

**Monitor**:
- Calcolo Bayesiano delle probabilità a posteriori
- Confronto con `SOGLIA_PROBABILITA` (95)

**Casi di Violazione**:
- Evidenze indicano bassa probabilità di conformità
- Dati sensori incoerenti/danneggiati

**Risposta alla Violazione**:
- ❌ Transaction revert "Requisiti di conformita non superati"
- 📊 Evento `MonitorSafetyViolation("ProbabilityThreshold", ...)` (nuovo)

**Test di Verifica**:
```javascript
it("S4: Blocca pagamento con probabilità < 95%", async () => {
    // Configura CPT per generare basse probabilità
    // Invia evidenze negative
    await expectRevert(
        contract.validaEPaga(1),
        "Requisiti di conformita non superati"
    );
});
```

---

### S5: Courier Authorization

**Descrizione**: Solo il corriere designato può richiedere il pagamento.

**Implementazione**:
```solidity
require(s.corriere == msg.sender, "Non sei il corriere");
```

**Proprietà Formale**:
```
∀ spedizione s, ∀ utente u:
    NEVER (validaEPaga(s) succeeds AND u ≠ s.corriere)
```

**Monitor**:
- Verifica identità del chiamante contro `s.corriere`

**Casi di Violazione**:
- Utente non autorizzato tenta di richiedere pagamento
- Attacco di impersonificazione

**Risposta alla Violazione**:
- ❌ Transaction revert "Non sei il corriere"
- 📊 Evento `MonitorSafetyViolation("CourierAuth", ...)` (nuovo)

---

## Guarantee/Response Properties

### G1: Payment Upon Valid Evidence

**Descrizione**: Se tutte le evidenze sono valide e le probabilità >= 95%, il pagamento DEVE essere effettuato.

**Implementazione**:
```solidity
if (probF1 >= SOGLIA_PROBABILITA && probF2 >= SOGLIA_PROBABILITA) {
    uint256 importo = s.importoPagamento;
    s.stato = StatoSpedizione.Pagata;
    emit SpedizionePagata(_id, s.corriere, importo);
    (bool success, ) = s.corriere.call{value: importo}("");
    require(success, "Pagamento fallito");
}
```

**Proprietà Formale**:
```
∀ spedizione s:
    (tutte_evidenze_ricevute(s) AND P(F1|E) >= 95% AND P(F2|E) >= 95%)
    ⟹ EVENTUALLY pagamento_eseguito(s)
```

**Monitor**:
- Verifica condizioni di pagamento
- Esecuzione transfer ETH
- Emit evento `SpedizionePagata`

**Casi di Successo**:
- Tutte le 5 evidenze ricevute
- Calcolo Bayesiano conferma conformità
- Transfer ETH al corriere

**Risposta al Successo**:
- ✅ Stato → `Pagata`
- ✅ Evento `SpedizionePagata` emesso
- ✅ ETH trasferiti al corriere
- 📊 Evento `MonitorGuaranteeSuccess("PaymentOnValidEvidence", ...)` (nuovo)

**Test di Verifica**:
```javascript
it("G1: Garantisce pagamento con evidenze valide", async () => {
    // Setup con evidenze positive
    await contract.inviaEvidenza(1, 1, true);
    // ... tutte le 5 evidenze
    
    const result = await contract.validaEPaga(1);
    
    expectEvent(result, 'SpedizionePagata');
    expectEvent(result, 'MonitorGuaranteeSuccess', {
        property: 'PaymentOnValidEvidence'
    });
});
```

---

### G2: Evidence Reception Triggers State Update

**Descrizione**: Ogni evidenza ricevuta DEVE aggiornare lo stato della spedizione.

**Implementazione**:
```solidity
function inviaEvidenza(uint256 _idSpedizione, uint8 _idEvidenza, bool _valore) {
    if (_idEvidenza == 1) {
        s.evidenze.E1_ricevuta = true;
        s.evidenze.E1_valore = _valore;
        emit EvidenceReceived(_idSpedizione, 1, _valore);
    }
    // ... altre evidenze
}
```

**Proprietà Formale**:
```
∀ evidenza e, ∀ spedizione s:
    inviaEvidenza(s, e, v) succeeds
    ⟹ EVENTUALLY (s.evidenze.E{e}_ricevuta == true AND s.evidenze.E{e}_valore == v)
```

**Monitor**:
- Update atomico di `ricevuta` e `valore`
- Emit evento `EvidenceReceived` (nuovo)

**Test di Verifica**:
```javascript
it("G2: Evidenza ricevuta aggiorna stato", async () => {
    const result = await contract.inviaEvidenza(1, 3, true);
    
    expectEvent(result, 'EvidenceReceived', {
        shipmentId: '1',
        evidenceId: '3',
        value: true
    });
    
    const spedizione = await contract.spedizioni(1);
    assert.equal(spedizione.evidenze.E3_ricevuta, true);
    assert.equal(spedizione.evidenze.E3_valore, true);
});
```

---

## Eventi di Monitoring

### Nuovi Eventi Aggiunti

```solidity
// Safety violation tracking
event MonitorSafetyViolation(
    string indexed property,
    uint256 indexed shipmentId,
    address caller,
    string reason
);

// Guarantee success tracking
event MonitorGuaranteeSuccess(
    string indexed property,
    uint256 indexed shipmentId
);

// Evidence reception tracking
event EvidenceReceived(
    uint256 indexed shipmentId,
    uint8 indexed evidenceId,
    bool value
);

// Probability calculation tracking
event ProbabilityCalculated(
    uint256 indexed shipmentId,
    uint256 probF1,
    uint256 probF2
);
```

---

## Dashboard di Monitoring (Opzionale)

Per visualizzare i monitor in tempo reale, è possibile creare uno script che ascolta gli eventi:

```javascript
// scripts/monitor_dashboard.js
contract.on('MonitorSafetyViolation', (property, shipmentId, caller, reason) => {
    console.error(`🚨 SAFETY VIOLATION: ${property}`);
    console.error(`   Shipment: ${shipmentId}, Caller: ${caller}`);
    console.error(`   Reason: ${reason}`);
});

contract.on('MonitorGuaranteeSuccess', (property, shipmentId) => {
    console.log(`✅ GUARANTEE MET: ${property} for shipment ${shipmentId}`);
});
```

---

## Metriche di Monitoraggio

### KPI da Tracciare

1. **Safety Violations Rate**: % transazioni che violano safety properties
2. **Guarantee Success Rate**: % spedizioni che completano pagamento
3. **Evidence Completeness**: Tempo medio per ricevere tutte le 5 evidenze
4. **Probability Distribution**: Distribuzione probabilità P(F1|E) e P(F2|E)

### Query di Analisi

```javascript
// Conta violazioni S2 (doppio pagamento)
const violations = await contract.getPastEvents('MonitorSafetyViolation', {
    filter: { property: 'SinglePayment' },
    fromBlock: 0,
    toBlock: 'latest'
});
```

---

## Conclusioni

I Runtime Enforcement Monitors implementati garantiscono:

- ✅ **5 Safety Properties** sempre rispettate
- ✅ **2 Guarantee Properties** monitorate e verificate
- ✅ **Tracciabilità completa** tramite eventi
- ✅ **Testing automatizzato** di tutte le proprietà

Questo soddisfa i requisiti del progetto per la **sintesi di monitor di runtime enforcement** di proprietà Safety e Guarantee/Response.
