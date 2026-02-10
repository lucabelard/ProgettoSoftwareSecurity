// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./BNCore.sol";

// Custom Errors
error PagamentoNullo();
error CorriereNonValido();
error SpedizioneNonEsistente();
error SpedizioneNonInAttesa();
error EvidenzaGiaInviata();
error EvidenzeMancanti();
error SoloMittenteAnnullare();
error EvidenzeGiaInviate();
error RimborsoFallito();
error SoloMittenteRimborso();
error CondizioniRimborsoNonSoddisfatte();
error HashDettagliNonValido();

/**
 * @title BNGestoreSpedizioni
 * @author Blockchain Shipment Tracking Team
 * @notice Gestisce la creazione e tracciamento delle spedizioni
 * @dev Estende BNCore - ISOLAMENTO della logica di gestione spedizioni
 */
contract BNGestoreSpedizioni is BNCore {
    
    // === RUOLI ===
    /// @notice Identificatore del ruolo per i mittenti autorizzati a creare spedizioni
    bytes32 public constant RUOLO_MITTENTE = keccak256("RUOLO_MITTENTE");
    /// @notice Identificatore del ruolo per i sensori autorizzati a inviare evidenze
    bytes32 public constant RUOLO_SENSORE = keccak256("RUOLO_SENSORE");
    
    // === STATI ===
    enum StatoSpedizione { 
        InAttesa,      // 0 - In attesa di completamento
        Pagata,        // 1 - Pagamento completato al corriere
        Annullata,     // 2 - Annullata dal mittente
        Rimborsata     // 3 - Rimborsata al mittente per validazione fallita
    }
    
    // === COSTANTI PER TIMEOUT ===
    /// @notice Tempo massimo di attesa (7 giorni) dopo il quale il mittente può richiedere rimborso se le evidenze non sono complete
    uint256 public constant TIMEOUT_RIMBORSO = 7 days; // Dopo 7 giorni senza evidenze, rimborso possibile
    
    // === STRUTTURE ===
    struct Spedizione {
        address mittente;
        address corriere;
        uint256 importoPagamento;
        StatoSpedizione stato;
        StatoEvidenze evidenze;
        uint256 timestampCreazione; // Timestamp creazione per timeout
        uint256 tentativiValidazioneFalliti; // Contatore tentativi falliti
        bytes32 hashedDetails; // OFFUSCAMENTO: Hash dei dettagli sensibili (salvati off-chain)
    }
    
    // === STORAGE ===
    /// @notice Mapping che associa ID spedizione alla struttura Spedizione completa
    mapping(uint256 => Spedizione) public spedizioni;
    /// @notice Contatore incrementale per generare ID univoci per ogni nuova spedizione
    uint256 public _contatoreIdSpedizione;
    
    // === EVENTI ===
    
    /// @notice Emesso quando viene creata una nuova spedizione
    /// @param id ID univoco della spedizione
    /// @param mittente Indirizzo del mittente che ha creato la spedizione
    /// @param corriere Indirizzo del corriere assegnato
    /// @param importo Importo in wei depositato in escrow
    event SpedizioneCreata(uint256 indexed id, address indexed mittente, address indexed corriere, uint256 importo);
    
    /// @notice Emesso quando un sensore invia un'evidenza
    /// @param id ID della spedizione
    /// @param evidenza ID dell'evidenza inviata (1-5)
    /// @param valore Valore booleano dell'evidenza
    /// @param sensore Indirizzo del sensore che ha inviato l'evidenza
    event EvidenzaInviata(uint256 indexed id, uint8 indexed evidenza, bool indexed valore, address sensore);
    
    /// @notice Emesso quando una spedizione viene annullata dal mittente
    /// @param id ID della spedizione annullata
    /// @param mittente Indirizzo del mittente che ha annullato
    /// @param importoRimborsato Importo rimborsato al mittente
    event SpedizioneAnnullata(uint256 indexed id, address indexed mittente, uint256 importoRimborsato);
    
    /// @notice Emesso quando viene effettuato un rimborso al mittente
    /// @param id ID della spedizione
    /// @param mittente Indirizzo del mittente rimborsato
    /// @param importo Importo rimborsato in wei
    /// @param motivo Motivo del rimborso
    event RimborsoEffettuato(uint256 indexed id, address indexed mittente, uint256 importo, string motivo);
    
    /// @notice Emesso quando un tentativo di validazione fallisce
    /// @param id ID della spedizione
    /// @param numeroTentativi Numero totale di tentativi falliti
    event TentativoValidazioneFallito(uint256 indexed id, uint256 numeroTentativi);
    
    /// @notice Emesso quando vengono salvati dettagli con hash (offuscamento)
    /// @param id ID della spedizione
    /// @param hashedDetails Hash dei dettagli sensibili
    event DettagliHashatiSalvati(uint256 indexed id, bytes32 indexed hashedDetails);
    
    // === EVENTI DI RUNTIME MONITORING ===
    
    /// @notice Evento di monitoraggio per ricezione evidenza
    /// @param shipmentId ID della spedizione
    /// @param evidenceId ID dell'evidenza ricevuta
    /// @param value Valore dell'evidenza
    event EvidenceReceived(uint256 indexed shipmentId, uint8 indexed evidenceId, bool indexed value);
    
    /// @notice Evento di monitoraggio per richieste di rimborso
    /// @param shipmentId ID della spedizione
    /// @param requester Indirizzo del richiedente
    /// @param reason Motivo della richiesta
    event MonitorRefundRequest(uint256 indexed shipmentId, address indexed requester, string reason);
    
    constructor() {
        _grantRole(RUOLO_MITTENTE, msg.sender);
        _grantRole(RUOLO_SENSORE, msg.sender);
    }
    
    /**
     * @notice Crea una nuova spedizione con pagamento in escrow
     * @param _corriere Indirizzo del corriere responsabile
     * @return id ID della spedizione creata
     */
    function creaSpedizione(address _corriere)
        external
        payable
        onlyRole(RUOLO_MITTENTE)
        returns (uint256)
    {
        if (msg.value == 0) revert PagamentoNullo();
        if (_corriere == address(0)) revert CorriereNonValido();
        
        ++_contatoreIdSpedizione;
        uint256 id = _contatoreIdSpedizione;
        
        spedizioni[id] = Spedizione({
            mittente: msg.sender,
            corriere: _corriere,
            importoPagamento: msg.value,
            stato: StatoSpedizione.InAttesa,
            evidenze: StatoEvidenze(false,false,false,false,false,false,false,false,false,false),
            timestampCreazione: block.timestamp,
            tentativiValidazioneFalliti: 0,
            hashedDetails: bytes32(0) // Nessun hash per questa versione
        });

        emit SpedizioneCreata(id, msg.sender, _corriere, msg.value);
        return id;
    }
    
    /**
     * @notice Crea spedizione con hash dei dettagli sensibili (OFFUSCAMENTO)
     * @param _corriere Indirizzo del corriere responsabile
     * @param _hashedDetails Hash dei dettagli sensibili (calcolato off-chain)
     * @return id ID della spedizione creata
     * @dev I dettagli in chiaro NON vengono salvati on-chain, solo il loro hash
     */
    function creaSpedizioneConHash(address _corriere, bytes32 _hashedDetails)
        external
        payable
        onlyRole(RUOLO_MITTENTE)
        returns (uint256)
    {
        if (msg.value == 0) revert PagamentoNullo();
        if (_corriere == address(0)) revert CorriereNonValido();
        if (_hashedDetails == bytes32(0)) revert HashDettagliNonValido();
        
        ++_contatoreIdSpedizione;
        uint256 id = _contatoreIdSpedizione;
        
        spedizioni[id] = Spedizione({
            mittente: msg.sender,
            corriere: _corriere,
            importoPagamento: msg.value,
            stato: StatoSpedizione.InAttesa,
            evidenze: StatoEvidenze(false,false,false,false,false,false,false,false,false,false),
            timestampCreazione: block.timestamp,
            tentativiValidazioneFalliti: 0,
            hashedDetails: _hashedDetails // OFFUSCAMENTO: salva solo hash
        });

        emit SpedizioneCreata(id, msg.sender, _corriere, msg.value);
        emit DettagliHashatiSalvati(id, _hashedDetails);
        return id;
    }
    
    /**
     * @notice Verifica se i dettagli forniti corrispondono all'hash salvato
     * @param _id ID della spedizione
     * @param _dettagli Dettagli in chiaro da verificare
     * @return true se l'hash corrisponde, false altrimenti
     * @dev Funzione view - chiunque può verificare se conosce i dettagli originali
     */
    function verificaDettagli(uint256 _id, string memory _dettagli) 
        public 
        view 
        returns (bool) 
    {
        if (spedizioni[_id].mittente == address(0)) revert SpedizioneNonEsistente();
        
        bytes32 computedHash = keccak256(abi.encodePacked(_dettagli));
        return spedizioni[_id].hashedDetails == computedHash;
    }
    
    /**
     * @notice Invia un'evidenza per una spedizione
     * @param _idSpedizione ID della spedizione
     * @param _idEvidenza ID dell'evidenza (1-5)
     * @param _valore Valore booleano dell'evidenza
     */
    function inviaEvidenza(uint256 _idSpedizione, uint8 _idEvidenza, bool _valore)

        public
        onlyRole(RUOLO_SENSORE)
    {
        Spedizione storage s = spedizioni[_idSpedizione];
        if (s.mittente == address(0)) revert SpedizioneNonEsistente();
        if (s.stato != StatoSpedizione.InAttesa) revert SpedizioneNonInAttesa();
        
        if (_idEvidenza == 1) {
            s.evidenze.E1_ricevuta = true;
            s.evidenze.E1_valore = _valore;
            emit EvidenceReceived(_idSpedizione, 1, _valore);
        } else if (_idEvidenza == 2) {
            s.evidenze.E2_ricevuta = true;
            s.evidenze.E2_valore = _valore;
            emit EvidenceReceived(_idSpedizione, 2, _valore);
        } else if (_idEvidenza == 3) {
            s.evidenze.E3_ricevuta = true;
            s.evidenze.E3_valore = _valore;
            emit EvidenceReceived(_idSpedizione, 3, _valore);
        } else if (_idEvidenza == 4) {
            s.evidenze.E4_ricevuta = true;
            s.evidenze.E4_valore = _valore;
            emit EvidenceReceived(_idSpedizione, 4, _valore);
        } else if (_idEvidenza == 5) {
            s.evidenze.E5_ricevuta = true;
            s.evidenze.E5_valore = _valore;
            emit EvidenceReceived(_idSpedizione, 5, _valore);
        } else revert EvidenzaIDInvalida();
        
        emit EvidenzaInviata(_idSpedizione, _idEvidenza, _valore, msg.sender);
    }
    
    /**
     * @notice Invia tutte le evidenze (E1-E5) in una sola transazione
     * @param _idSpedizione ID della spedizione
     * @param _valori Array di 5 valori booleani per E1, E2, E3, E4, E5
     * @dev Questa funzione permette di inviare tutte le evidenze con una sola conferma MetaMask
     */
    function inviaTutteEvidenze(uint256 _idSpedizione, bool[5] calldata _valori)
        external
        onlyRole(RUOLO_SENSORE)
    {
        Spedizione storage s = spedizioni[_idSpedizione];
        if (s.mittente == address(0)) revert SpedizioneNonEsistente();
        if (s.stato != StatoSpedizione.InAttesa) revert SpedizioneNonInAttesa();
        
        // Invia E1
        s.evidenze.E1_ricevuta = true;
        s.evidenze.E1_valore = _valori[0];
        emit EvidenceReceived(_idSpedizione, 1, _valori[0]);
        emit EvidenzaInviata(_idSpedizione, 1, _valori[0], msg.sender);
        
        // Invia E2
        s.evidenze.E2_ricevuta = true;
        s.evidenze.E2_valore = _valori[1];
        emit EvidenceReceived(_idSpedizione, 2, _valori[1]);
        emit EvidenzaInviata(_idSpedizione, 2, _valori[1], msg.sender);
        
        // Invia E3
        s.evidenze.E3_ricevuta = true;
        s.evidenze.E3_valore = _valori[2];
        emit EvidenceReceived(_idSpedizione, 3, _valori[2]);
        emit EvidenzaInviata(_idSpedizione, 3, _valori[2], msg.sender);
        
        // Invia E4
        s.evidenze.E4_ricevuta = true;
        s.evidenze.E4_valore = _valori[3];
        emit EvidenceReceived(_idSpedizione, 4, _valori[3]);
        emit EvidenzaInviata(_idSpedizione, 4, _valori[3], msg.sender);
        
        // Invia E5
        s.evidenze.E5_ricevuta = true;
        s.evidenze.E5_valore = _valori[4];
        emit EvidenceReceived(_idSpedizione, 5, _valori[4]);
        emit EvidenzaInviata(_idSpedizione, 5, _valori[4], msg.sender);
    }
    
    /**
     * @notice Verifica se tutte le 5 evidenze sono state ricevute per una spedizione
     * @param _id ID della spedizione da verificare
     * @return true se tutte le evidenze E1-E5 sono presenti, false altrimenti
     * @dev Controlla i flag E1_ricevuta through E5_ricevuta nello struct evidenze
     */
    function _tutteEvidenzeRicevute(uint256 _id) internal view returns (bool) {
        StatoEvidenze memory e = spedizioni[_id].evidenze;
        return e.E1_ricevuta && e.E2_ricevuta && e.E3_ricevuta && 
               e.E4_ricevuta && e.E5_ricevuta;
    }
    
    /**
     * @notice Permette al mittente di annullare una spedizione prima che le evidenze siano inviate
     * @param _id ID della spedizione
     * @dev Solo il mittente può annullare e solo se non ci sono evidenze ancora
     */
    function annullaSpedizione(uint256 _id) external {
        Spedizione storage s = spedizioni[_id];
        
        // SAFETY MONITOR: Solo mittente può annullare
        if (s.mittente != msg.sender) revert SoloMittenteAnnullare();
        
        // SAFETY MONITOR: Solo spedizioni in attesa
        if (s.stato != StatoSpedizione.InAttesa) revert SpedizioneNonInAttesa();
        
        // SAFETY MONITOR: Solo se nessuna evidenza è stata inviata
        bool nessunaEvidenza = !s.evidenze.E1_ricevuta && !s.evidenze.E2_ricevuta && 
                                !s.evidenze.E3_ricevuta && !s.evidenze.E4_ricevuta && 
                                !s.evidenze.E5_ricevuta;
        if (!nessunaEvidenza) revert EvidenzeGiaInviate();
        
        uint256 importo = s.importoPagamento;
        s.stato = StatoSpedizione.Annullata;
        
        emit MonitorRefundRequest(_id, msg.sender, "Annullamento spedizione");
        emit SpedizioneAnnullata(_id, msg.sender, importo);
        
        // Rimborsa il mittente
        (bool success, ) = s.mittente.call{value: importo}("");
        if (!success) revert RimborsoFallito();
    }
    
    /**
     * @notice Permette al mittente di richiedere un rimborso dopo validazione fallita o timeout
     * @param _id ID della spedizione
     * @dev Rimborso possibile se:
     *      1. Validazione fallita più volte (tentativiValidazioneFalliti >= 3)
     *      2. Timeout scaduto senza tutte le evidenze
     */
    function richiediRimborso(uint256 _id) external {
        Spedizione storage s = spedizioni[_id];
        
        // SAFETY MONITOR S1: Solo mittente può richiedere rimborso
        if (s.mittente != msg.sender) revert SoloMittenteRimborso();
        emit MonitorRefundRequest(_id, msg.sender, "Richiesta rimborso");
        
        // SAFETY MONITOR S2: Solo spedizioni in attesa
        if (s.stato != StatoSpedizione.InAttesa) revert SpedizioneNonInAttesa();
        
        bool rimborsoValido = false;
        string memory motivo;
        
        // Condizione 1: Tentativi validazione falliti >= 3
        if (s.tentativiValidazioneFalliti >= 3) {
            rimborsoValido = true;
            motivo = "Validazione fallita 3+ volte";
        }
        
        // Condizione 2: Timeout scaduto senza tutte le evidenze
        if (block.timestamp >= s.timestampCreazione + TIMEOUT_RIMBORSO && !_tutteEvidenzeRicevute(_id)) {
            rimborsoValido = true;
            motivo = "Timeout scaduto senza evidenze complete";
        }
        
        // Condizione 3: Tutte le evidenze ricevute ma validazione non tentata e timeout scaduto
        if (_tutteEvidenzeRicevute(_id) && 
            s.tentativiValidazioneFalliti == 0 && 
            block.timestamp >= s.timestampCreazione + TIMEOUT_RIMBORSO * 2) {
            rimborsoValido = true;
            motivo = "Evidenze ricevute ma corriere non ha validato";
        }
        
        if (!rimborsoValido) revert CondizioniRimborsoNonSoddisfatte();
        
        uint256 importo = s.importoPagamento;
        s.stato = StatoSpedizione.Rimborsata;
        
        emit RimborsoEffettuato(_id, msg.sender, importo, motivo);
        
        // Rimborsa il mittente
        (bool success, ) = s.mittente.call{value: importo}("");
        if (!success) revert RimborsoFallito();
    }
    
    /**
     * @notice Registra un tentativo di validazione fallito per una spedizione
     * @param _id ID della spedizione
     * @dev Incrementa il contatore tentativiValidazioneFalliti
     * @dev Dopo 3 tentativi falliti, il mittente può richiedere rimborso
     */
    function _registraTentativoFallito(uint256 _id) internal {
        spedizioni[_id].tentativiValidazioneFalliti++;
        emit TentativoValidazioneFallito(_id, spedizioni[_id].tentativiValidazioneFalliti);
    }
}
