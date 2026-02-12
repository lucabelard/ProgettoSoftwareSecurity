// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title BN_Simple
 * @notice Bayesian Network semplificata: 1 fatto, 2 evidenze
 * @dev Per performance testing
 */
contract BN_Simple is AccessControl {
    
    // Costanti
    uint8 public constant SOGLIA_PROBABILITA = 95;
    
    // Strutture
    struct CPT {
        uint8 p_F;  // P(E=T | F1=F)
        uint8 p_T;  // P(E=T | F1=T)
    }
    
    struct StatoEvidenze {
        bool E1_ricevuta;
        bool E2_ricevuta;
        bool E1_valore;
        bool E2_valore;
    }
    
    // Probabilità a priori
    uint8 public p_F1_T;
    
    // CPT per le evidenze
    CPT private cpt_E1;
    CPT private cpt_E2;
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function impostaProbabilitaAPriori(uint8 _p_F1_T) external onlyRole(DEFAULT_ADMIN_ROLE) {
        p_F1_T = _p_F1_T;
    }
    
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_idEvidenza == 1) cpt_E1 = _cpt;
        else if (_idEvidenza == 2) cpt_E2 = _cpt;
        else revert("ID evidenza non valido");
    }
    
    function validaEvidenze(StatoEvidenze memory evidenze) external view returns (bool) {
        // Calcola probabilità posteriori
        uint256 pF1_T = p_F1_T;
        uint256 pF1_F = 100 - pF1_T;
        
        // P(E|F=F)
        uint256 prob_F = 100;
        if (evidenze.E1_ricevuta) {
            uint8 p = evidenze.E1_valore ? cpt_E1.p_F : (100 - cpt_E1.p_F);
            prob_F = (prob_F * p) / 100;
        }
        if (evidenze.E2_ricevuta) {
            uint8 p = evidenze.E2_valore ? cpt_E2.p_F : (100 - cpt_E2.p_F);
            prob_F = (prob_F * p) / 100;
        }
        
        // P(E|F=T)
        uint256 prob_T = 100;
        if (evidenze.E1_ricevuta) {
            uint8 p = evidenze.E1_valore ? cpt_E1.p_T : (100 - cpt_E1.p_T);
            prob_T = (prob_T * p) / 100;
        }
        if (evidenze.E2_ricevuta) {
            uint8 p = evidenze.E2_valore ? cpt_E2.p_T : (100 - cpt_E2.p_T);
            prob_T = (prob_T * p) / 100;
        }
        
        // Normalizza
        uint256 termine_F = (prob_F * pF1_F) / 100;
        uint256 termine_T = (prob_T * pF1_T) / 100;
        uint256 normalizzatore = termine_F + termine_T;
        
        if (normalizzatore == 0) return false;
        
        uint256 probF1 = (termine_T * 100) / normalizzatore;
        
        return probF1 >= SOGLIA_PROBABILITA;
    }
}
