// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./BNCore.sol";

/**
 * @title BNGestoreSpedizioni
 * @notice Gestisce la creazione e tracciamento delle spedizioni
 * @dev Estende BNCore - ISOLAMENTO della logica di gestione spedizioni
 */
contract BNGestoreSpedizioni is BNCore {
    
    // === RUOLI ===
    bytes32 public constant RUOLO_MITTENTE = keccak256("RUOLO_MITTENTE");
    bytes32 public constant RUOLO_SENSORE = keccak256("RUOLO_SENSORE");
    
    // === STATI ===
    enum StatoSpedizione { InAttesa, Pagata }
    
    // === STRUTTURE ===
    struct Spedizione {
        address mittente;
        address corriere;
        uint256 importoPagamento;
        StatoSpedizione stato;
        StatoEvidenze evidenze;
    }
    
    // === STORAGE ===
    mapping(uint256 => Spedizione) public spedizioni;
    uint256 public _contatoreIdSpedizione;
    
    // === EVENTI ===
    event SpedizioneCreata(uint256 indexed id, address indexed mittente, address indexed corriere, uint256 importo);
    event EvidenzaInviata(uint256 indexed id, uint8 indexed evidenza, bool valore, address indexed sensore);
    
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
        require(msg.value > 0, "Pagamento > 0");
        require(_corriere != address(0), "Corriere non valido");
        
        _contatoreIdSpedizione++;
        uint256 id = _contatoreIdSpedizione;
        
        spedizioni[id] = Spedizione({
            mittente: msg.sender,
            corriere: _corriere,
            importoPagamento: msg.value,
            stato: StatoSpedizione.InAttesa,
            evidenze: StatoEvidenze(false,false,false,false,false,false,false,false,false,false)
        });

        emit SpedizioneCreata(id, msg.sender, _corriere, msg.value);
        return id;
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
        require(s.mittente != address(0), "Spedizione non esistente");
        require(s.stato == StatoSpedizione.InAttesa, "Spedizione non in attesa");
        
        if (_idEvidenza == 1) {
            s.evidenze.E1_ricevuta = true;
            s.evidenze.E1_valore = _valore;
        } else if (_idEvidenza == 2) {
            s.evidenze.E2_ricevuta = true;
            s.evidenze.E2_valore = _valore;
        } else if (_idEvidenza == 3) {
            s.evidenze.E3_ricevuta = true;
            s.evidenze.E3_valore = _valore;
        } else if (_idEvidenza == 4) {
            s.evidenze.E4_ricevuta = true;
            s.evidenze.E4_valore = _valore;
        } else if (_idEvidenza == 5) {
            s.evidenze.E5_ricevuta = true;
            s.evidenze.E5_valore = _valore;
        } else revert("ID evidenza non valido (1-5)");
        
        emit EvidenzaInviata(_idSpedizione, _idEvidenza, _valore, msg.sender);
    }
    
    /**
     * @notice Verifica se tutte le evidenze sono state ricevute
     * @param _id ID della spedizione
     * @return true se tutte le evidenze sono presenti
     */
    function _tutteEvidenzeRicevute(uint256 _id) internal view returns (bool) {
        StatoEvidenze memory e = spedizioni[_id].evidenze;
        return e.E1_ricevuta && e.E2_ricevuta && e.E3_ricevuta && 
               e.E4_ricevuta && e.E5_ricevuta;
    }
}
