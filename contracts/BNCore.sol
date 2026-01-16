// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

// Custom Errors
error EvidenzaIDInvalida();

/**
 * @title BNCore
 * @notice Contratto base con logica della Rete Bayesiana
 * @dev Contiene solo i calcoli probabilistici - ISOLAMENTO della logica
 */

contract BNCore is AccessControl {
    
    // === COSTANTI ===
    uint256 public constant PRECISIONE = 100;
    uint8 public constant SOGLIA_PROBABILITA = 95; // 95%
    
    // === RUOLI ===
    bytes32 public constant RUOLO_ORACOLO = keccak256("RUOLO_ORACOLO");
    
    // === PROBABILITÀ A PRIORI ===
    uint256 public p_F1_T; // P(F1=True)
    uint256 public p_F2_T; // P(F2=True)
    
    // === CPT (Conditional Probability Tables) ===
    struct CPT {
        uint256 p_FF; // P(E=T | F1=F, F2=F)
        uint256 p_FT; // P(E=T | F1=F, F2=T)
        uint256 p_TF; // P(E=T | F1=T, F2=F)
        uint256 p_TT; // P(E=T | F1=T, F2=T)
    }
    
    CPT public cpt_E1;
    CPT public cpt_E2;
    CPT public cpt_E3;
    CPT public cpt_E4;
    CPT public cpt_E5;
    
    // === EVENTI DI MONITORAGGIO ===
    event ProbabilitaAPrioriImpostate(uint256 p_F1_T, uint256 p_F2_T, address indexed admin);
    event CPTImpostata(uint8 indexed evidenza, address indexed admin, uint256 timestamp);
    event ProbabilitaValidazione(uint256 indexed id, uint256 probF1, uint256 probF2);
    event SogliaValidazioneNonSuperata(uint256 indexed id, uint256 probF1, uint256 probF2);
    
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
    function impostaProbabilitaAPriori(uint256 _p_F1_T, uint256 _p_F2_T)
        external
        onlyRole(RUOLO_ORACOLO)
    {
        p_F1_T = _p_F1_T;
        p_F2_T = _p_F2_T;
        emit ProbabilitaAPrioriImpostate(_p_F1_T, _p_F2_T, msg.sender);
    }
    
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt)
        external
        onlyRole(RUOLO_ORACOLO)
    {
        if (_idEvidenza == 1) cpt_E1 = _cpt;
        else if (_idEvidenza == 2) cpt_E2 = _cpt;
        else if (_idEvidenza == 3) cpt_E3 = _cpt;
        else if (_idEvidenza == 4) cpt_E4 = _cpt;
        else if (_idEvidenza == 5) cpt_E5 = _cpt;
        else revert EvidenzaIDInvalida();
        
        emit CPTImpostata(_idEvidenza, msg.sender, block.timestamp);
    }

    
    // === LOGICA BAYESIANA (PROTETTA) ===
    
    function _leggiValoreCPT(bool _valEvidenza, uint256 _p_T) internal pure returns (uint256) {
        if (_valEvidenza == true) {
            return _p_T;
        } else {
            return PRECISIONE - _p_T;
        }
    }
    
    function _calcolaProbabilitaCombinata(StatoEvidenze memory _evidenze, bool _f1, bool _f2) 
        internal view returns (uint256) 
    {
        uint256 probCombinata = PRECISIONE; 
        uint256 p_T;
        uint256 p_e;

        // --- E1 ---
        if (_evidenze.E1_ricevuta) {
            if (_f1 == false && _f2 == false) p_T = cpt_E1.p_FF;
            else if (_f1 == false && _f2 == true)  p_T = cpt_E1.p_FT;
            else if (_f1 == true  && _f2 == false) p_T = cpt_E1.p_TF;
            else if (_f1 == true  && _f2 == true)  p_T = cpt_E1.p_TT;
            p_e = _leggiValoreCPT(_evidenze.E1_valore, p_T);
            probCombinata = (probCombinata * p_e) / PRECISIONE;
        }
        
        // --- E2 ---
        if (_evidenze.E2_ricevuta) {
            if (_f1 == false && _f2 == false) p_T = cpt_E2.p_FF;
            else if (_f1 == false && _f2 == true)  p_T = cpt_E2.p_FT;
            else if (_f1 == true  && _f2 == false) p_T = cpt_E2.p_TF;
            else if (_f1 == true  && _f2 == true)  p_T = cpt_E2.p_TT;
            p_e = _leggiValoreCPT(_evidenze.E2_valore, p_T);
            probCombinata = (probCombinata * p_e) / PRECISIONE;
        }
        
        // --- E3 ---
        if (_evidenze.E3_ricevuta) {
            if (_f1 == false && _f2 == false) p_T = cpt_E3.p_FF;
            else if (_f1 == false && _f2 == true)  p_T = cpt_E3.p_FT;
            else if (_f1 == true  && _f2 == false) p_T = cpt_E3.p_TF;
            else if (_f1 == true  && _f2 == true)  p_T = cpt_E3.p_TT;
            p_e = _leggiValoreCPT(_evidenze.E3_valore, p_T);
            probCombinata = (probCombinata * p_e) / PRECISIONE;
        }
        
        // --- E4 ---
        if (_evidenze.E4_ricevuta) {
            if (_f1 == false && _f2 == false) p_T = cpt_E4.p_FF;
            else if (_f1 == false && _f2 == true)  p_T = cpt_E4.p_FT;
            else if (_f1 == true  && _f2 == false) p_T = cpt_E4.p_TF;
            else if (_f1 == true  && _f2 == true)  p_T = cpt_E4.p_TT;
            p_e = _leggiValoreCPT(_evidenze.E4_valore, p_T);
            probCombinata = (probCombinata * p_e) / PRECISIONE;
        }
        
        // --- E5 ---
        if (_evidenze.E5_ricevuta) {
            if (_f1 == false && _f2 == false) p_T = cpt_E5.p_FF;
            else if (_f1 == false && _f2 == true)  p_T = cpt_E5.p_FT;
            else if (_f1 == true  && _f2 == false) p_T = cpt_E5.p_TF;
            else if (_f1 == true  && _f2 == true)  p_T = cpt_E5.p_TT;
            p_e = _leggiValoreCPT(_evidenze.E5_valore, p_T);
            probCombinata = (probCombinata * p_e) / PRECISIONE;
        }

        return probCombinata;
    }
    
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
