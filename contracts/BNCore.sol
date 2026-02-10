// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

// Custom Errors
error EvidenzaIDInvalida();

/**
 * @title BNCore
 * @author Blockchain Shipment Tracking Team
 * @notice Contratto base con logica della Rete Bayesiana
 * @dev Contiene solo i calcoli probabilistici - ISOLAMENTO della logica
 */
contract BNCore is AccessControl {
    
    // === COSTANTI ===
    /// @notice Fattore di precisione per i calcoli probabilistici (100 = 100%)
    uint256 public constant PRECISIONE = 100;
    /// @notice Soglia minima di probabilità per validare una spedizione (95 = 95%)
    uint8 public constant SOGLIA_PROBABILITA = 95; // 95%
    
    // === RUOLI ===
    /// @notice Identificatore del ruolo per gli oracoli autorizzati a configurare la rete bayesiana
    bytes32 public constant RUOLO_ORACOLO = keccak256("RUOLO_ORACOLO");
    
    // === PROBABILITÀ A PRIORI ===
    /// @notice Probabilità a priori che il fatto F1 (consegna corretta) sia vero (0-100)
    uint256 public p_F1_T; // P(F1=True)
    /// @notice Probabilità a priori che il fatto F2 (conformità condizioni) sia vero (0-100)
    uint256 public p_F2_T; // P(F2=True)
    
    // === CPT (Conditional Probability Tables) ===
    struct CPT {
        uint256 p_FF; // P(E=T | F1=F, F2=F)
        uint256 p_FT; // P(E=T | F1=F, F2=T)
        uint256 p_TF; // P(E=T | F1=T, F2=F)
        uint256 p_TT; // P(E=T | F1=T, F2=T)
    }
    
    // OFFUSCAMENTO: CPT private - solo auditor autorizzati possono leggerle
    CPT private cpt_E1;
    CPT private cpt_E2;
    CPT private cpt_E3;
    CPT private cpt_E4;
    CPT private cpt_E5;
    
    // === EVENTI DI MONITORAGGIO ===
    
    /// @notice Emesso quando le probabilità a priori vengono impostate dall'oracolo
    /// @param p_F1_T Probabilità a priori che F1 sia vero (0-100)
    /// @param p_F2_T Probabilità a priori che F2 sia vero (0-100)
    /// @param admin Indirizzo dell'amministratore che ha impostato le probabilità
    event ProbabilitaAPrioriImpostate(uint256 indexed p_F1_T, uint256 indexed p_F2_T, address indexed admin);
    
    /// @notice Emesso quando una CPT viene configurata per un'evidenza
    /// @param evidenza ID dell'evidenza (1-5)
    /// @param admin Indirizzo dell'amministratore che ha impostato la CPT
    /// @param timestamp Timestamp dell'operazione
    event CPTImpostata(uint8 indexed evidenza, address indexed admin, uint256 indexed timestamp);
    
    /// @notice Emesso durante la validazione con le probabilità calcolate
    /// @param id ID della spedizione
    /// @param probF1 Probabilità calcolata per F1 (0-100)
    /// @param probF2 Probabilità calcolata per F2 (0-100)
    event ProbabilitaValidazione(uint256 indexed id, uint256 indexed probF1, uint256 probF2);
    
    /// @notice Emesso quando le probabilità non superano la soglia di validazione
    /// @param id ID della spedizione
    /// @param probF1 Probabilità calcolata per F1 (sotto soglia)
    /// @param probF2 Probabilità calcolata per F2 (sotto soglia)
    event SogliaValidazioneNonSuperata(uint256 indexed id, uint256 indexed probF1, uint256 probF2);
    
    // === STRUTTURE DATI ===
    struct StatoEvidenze {
        bool E1_ricevuta;
        bool E2_ricevuta;
        bool E3_ricevuta;
        bool E4_ricevuta;
        bool E5_ricevuta;
        bool E1_valore;
        bool E2_valore;
        bool E3_valore;
        bool E4_valore;
        bool E5_valore;
    }
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(RUOLO_ORACOLO, msg.sender);
    }
    
    // === FUNZIONI AMMINISTRATIVE ===
    /**
     * @notice Imposta le probabilità a priori per i fatti F1 e F2
     * @param _p_F1_T Probabilità che F1 sia vero (0-100)
     * @param _p_F2_T Probabilità che F2 sia vero (0-100)
     */
    function impostaProbabilitaAPriori(uint256 _p_F1_T, uint256 _p_F2_T)
        external
        onlyRole(RUOLO_ORACOLO)
    {
        p_F1_T = _p_F1_T;
        p_F2_T = _p_F2_T;
        emit ProbabilitaAPrioriImpostate(_p_F1_T, _p_F2_T, msg.sender);
    }
    
    /**
     * @notice Imposta la tabella di probabilità condizionata per un'evidenza
     * @param _idEvidenza ID dell'evidenza (1-5)
     * @param _cpt Struttura CPT con probabilità condizionate
     */
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt)
        external
        onlyRole(RUOLO_ORACOLO)
    {
        // ✅ VALIDAZIONE INPUT: Tutti i valori CPT devono essere validi (0-100)
        require(_cpt.p_FF <= PRECISIONE, "CPT: p_FF invalido");
        require(_cpt.p_FT <= PRECISIONE, "CPT: p_FT invalido");
        require(_cpt.p_TF <= PRECISIONE, "CPT: p_TF invalido");
        require(_cpt.p_TT <= PRECISIONE, "CPT: p_TT invalido");
        
        if (_idEvidenza == 1) cpt_E1 = _cpt;
        else if (_idEvidenza == 2) cpt_E2 = _cpt;
        else if (_idEvidenza == 3) cpt_E3 = _cpt;
        else if (_idEvidenza == 4) cpt_E4 = _cpt;
        else if (_idEvidenza == 5) cpt_E5 = _cpt;
        else revert EvidenzaIDInvalida();
        
        emit CPTImpostata(_idEvidenza, msg.sender, block.timestamp);
    }
    
    // === GETTER CPT CON ACCESS CONTROL (OFFUSCAMENTO) ===
    /**
     * @notice Legge CPT per evidenza E1 - solo admin
     * @return Struttura CPT per E1
     */
    function getCPT_E1() external view onlyRole(DEFAULT_ADMIN_ROLE) returns (CPT memory) {
        return cpt_E1;
    }
    
    /**
     * @notice Legge CPT per evidenza E2 - solo admin
     * @return Struttura CPT per E2
     */
    function getCPT_E2() external view onlyRole(DEFAULT_ADMIN_ROLE) returns (CPT memory) {
        return cpt_E2;
    }
    
    /**
     * @notice Legge CPT per evidenza E3 - solo admin
     * @return Struttura CPT per E3
     */
    function getCPT_E3() external view onlyRole(DEFAULT_ADMIN_ROLE) returns (CPT memory) {
        return cpt_E3;
    }
    
    /**
     * @notice Legge CPT per evidenza E4 - solo admin
     * @return Struttura CPT per E4
     */
    function getCPT_E4() external view onlyRole(DEFAULT_ADMIN_ROLE) returns (CPT memory) {
        return cpt_E4;
    }
    
    /**
     * @notice Legge CPT per evidenza E5 - solo admin
     * @return Struttura CPT per E5
     */
    function getCPT_E5() external view onlyRole(DEFAULT_ADMIN_ROLE) returns (CPT memory) {
        return cpt_E5;
    }
    
    // === LOGICA BAYESIANA (PROTETTA) ===
    
    /**
     * @notice Legge il valore della CPT in base all'evidenza osservata
     * @param _valEvidenza Valore booleano dell'evidenza (true/false)
     * @param _p_T Probabilità che l'evidenza sia vera dato lo stato dei fatti
     * @return Probabilità corrispondente al valore dell'evidenza
     * @dev Se evidenza è true ritorna _p_T, altrimenti ritorna (100 - _p_T)
     */
    function _leggiValoreCPT(bool _valEvidenza, uint256 _p_T) internal pure returns (uint256) {
        if (_valEvidenza == true) {
            return _p_T;
        } else {
            return PRECISIONE - _p_T;
        }
    }
    
    /**
     * @notice Applica CPT per una singola evidenza
     * @param _ricevuta Se l'evidenza è stata ricevuta
     * @param _valore Valore dell'evidenza
     * @param _f1 Stato ipotizzato di F1
     * @param _f2 Stato ipotizzato di F2
     * @param _cpt Tabella CPT per questa evidenza
     * @return Probabilità dell'evidenza dato lo stato dei fatti
     */
    function _applicaCPT(
        bool _ricevuta,
        bool _valore,
        bool _f1,
        bool _f2,
        CPT memory _cpt
    ) internal pure returns (uint256) {
        if (!_ricevuta) return PRECISIONE;
        
        uint256 p_T;
        if (_f1 == false && _f2 == false) p_T = _cpt.p_FF;
        else if (_f1 == false && _f2 == true) p_T = _cpt.p_FT;
        else if (_f1 == true && _f2 == false) p_T = _cpt.p_TF;
        else if (_f1 == true && _f2 == true) p_T = _cpt.p_TT;
        
        return _leggiValoreCPT(_valore, p_T);
    }
    
    /**
     * @notice Calcola la probabilità combinata di osservare tutte le evidenze
     * @param _evidenze Struttura contenente stato e valori di tutte le evidenze E1-E5
     * @param _f1 Ipotesi per il fatto F1 (true se F1 è considerato vero)
     * @param _f2 Ipotesi per il fatto F2 (true se F2 è considerato vero)
     * @return Probabilità combinata normalizzata (0-100)
     * @dev Implementa il prodotto delle probabilità condizionate P(E1,..,E5|F1,F2)
     */
    function _calcolaProbabilitaCombinata(StatoEvidenze memory _evidenze, bool _f1, bool _f2) 
        internal view returns (uint256) 
    {
        uint256 probCombinata = PRECISIONE;
        
        // Applica CPT per ogni evidenza
        probCombinata = (probCombinata * _applicaCPT(_evidenze.E1_ricevuta, _evidenze.E1_valore, _f1, _f2, cpt_E1)) / PRECISIONE;
        probCombinata = (probCombinata * _applicaCPT(_evidenze.E2_ricevuta, _evidenze.E2_valore, _f1, _f2, cpt_E2)) / PRECISIONE;
        probCombinata = (probCombinata * _applicaCPT(_evidenze.E3_ricevuta, _evidenze.E3_valore, _f1, _f2, cpt_E3)) / PRECISIONE;
        probCombinata = (probCombinata * _applicaCPT(_evidenze.E4_ricevuta, _evidenze.E4_valore, _f1, _f2, cpt_E4)) / PRECISIONE;
        probCombinata = (probCombinata * _applicaCPT(_evidenze.E5_ricevuta, _evidenze.E5_valore, _f1, _f2, cpt_E5)) / PRECISIONE;

        return probCombinata;
    }
    
    /**
     * @notice Calcola le probabilità posteriori di F1 e F2 usando inferenza Bayesiana
     * @param evidenze Struttura contenente tutte le evidenze osservate
     * @return probF1 Probabilità che F1 sia vero date le evidenze (0-100)
     * @return probF2 Probabilità che F2 sia vero date le evidenze (0-100)
     * @dev Applica la formula di Bayes: P(F|E) = P(E|F)*P(F) / P(E)
     * @dev Considera tutti e 4 i casi: (F1=T,F2=T), (F1=T,F2=F), (F1=F,F2=T), (F1=F,F2=F)
     */
    function _calcolaProbabilitaPosteriori(StatoEvidenze memory evidenze) 
        internal view 
        returns (uint256, uint256) 
    {
        uint256 pF1_T = p_F1_T;
        uint256 pF1_F = PRECISIONE - pF1_T;
        uint256 pF2_T = p_F2_T;
        uint256 pF2_F = PRECISIONE - pF2_T;

        // Termini della formula di Bayes
        uint256 termine_TT = _calcolaProbabilitaCombinata(evidenze, true, true);
        termine_TT = (termine_TT * pF1_T * pF2_T) / (PRECISIONE * PRECISIONE);

        uint256 termine_TF = _calcolaProbabilitaCombinata(evidenze, true, false);
        termine_TF = (termine_TF * pF1_T * pF2_F) / (PRECISIONE * PRECISIONE);
        
        uint256 termine_FT = _calcolaProbabilitaCombinata(evidenze, false, true);
        termine_FT = (termine_FT * pF1_F * pF2_T) / (PRECISIONE * PRECISIONE);

        uint256 termine_FF = _calcolaProbabilitaCombinata(evidenze, false, false);
        termine_FF = (termine_FF * pF1_F * pF2_F) / (PRECISIONE * PRECISIONE);

        uint256 normalizzatore = termine_TT + termine_TF + termine_FT + termine_FF;
        
        if (normalizzatore == 0) return (0, 0);

        uint256 probF1_True = ((termine_TT + termine_TF) * PRECISIONE) / normalizzatore;
        uint256 probF2_True = ((termine_TT + termine_FT) * PRECISIONE) / normalizzatore;

        return (probF1_True, probF2_True);
    }
}
