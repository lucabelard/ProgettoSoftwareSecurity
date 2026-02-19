// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
/* solhint-disable contract-name-capwords */
/**
 * @title BN_Simple
 * @author Blockchain Shipment Tracking Team
 * @notice Bayesian Network semplificata: 1 fatto, 2 evidenze
 * @dev Per performance testing
 */
contract BN_Simple is AccessControl {
    
    /// @notice Soglia minima di probabilità (95%) per validare una spedizione
    uint8 public constant SOGLIA_PROBABILITA = 95;
    
    /// @notice Tabella di probabilità condizionata per un'evidenza dato F1
    struct CPT {
        uint8 p_F;  ///< P(E=T | F1=F)
        uint8 p_T;  ///< P(E=T | F1=T)
    }
    
    /// @notice Stato di ricezione e valore delle 2 evidenze per una spedizione
    struct StatoEvidenze {
        bool E1_ricevuta;
        bool E2_ricevuta;
        bool E1_valore;
        bool E2_valore;
    }
    
    /// @notice Probabilità a priori che il fatto F1 (consegna corretta) sia vero (0-100)
    uint8 public p_F1_T;
    
    CPT private cpt_E1;
    CPT private cpt_E2;
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @notice Imposta la probabilità a priori per F1
     * @param _p_F1_T Probabilità che F1 sia vero (0-100)
     */
    function impostaProbabilitaAPriori(uint8 _p_F1_T) external onlyRole(DEFAULT_ADMIN_ROLE) {
        p_F1_T = _p_F1_T;
    }
    
    /**
     * @notice Imposta la tabella CPT per una specifica evidenza
     * @param _idEvidenza ID dell'evidenza (1-2)
     * @param _cpt Struttura CPT con le probabilità condizionate
     */
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_idEvidenza == 1) cpt_E1 = _cpt;
        else if (_idEvidenza == 2) cpt_E2 = _cpt;
        else revert("ID evidenza non valido");
    }
    
    /**
     * @notice Valida le evidenze usando inferenza Bayesiana semplificata (1 fatto)
     * @param evidenze Struttura con stato e valori delle 2 evidenze
     * @return true se la probabilità posteriore di F1 supera la soglia del 95%
     */
    function validaEvidenze(StatoEvidenze memory evidenze) external view returns (bool) {
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
