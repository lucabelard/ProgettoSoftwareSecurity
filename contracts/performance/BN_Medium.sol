// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
/* solhint-disable contract-name-capwords */
/**
 * @title BN_Medium
 * @author Blockchain Shipment Tracking Team
 * @notice Bayesian Network media: 2 fatti, 3 evidenze
 * @dev Per performance testing
 */
contract BN_Medium is AccessControl {
    
    /// @notice Soglia minima di probabilità (95%) per validare una spedizione
    uint8 public constant SOGLIA_PROBABILITA = 95;
    
    /// @notice Tabella di probabilità condizionata per un'evidenza dati F1 e F2
    struct CPT {
        uint8 p_FF;  ///< P(E=T | F1=F, F2=F)
        uint8 p_FT;  ///< P(E=T | F1=F, F2=T)
        uint8 p_TF;  ///< P(E=T | F1=T, F2=F)
        uint8 p_TT;  ///< P(E=T | F1=T, F2=T)
    }
    
    /// @notice Stato di ricezione e valore delle 3 evidenze per una spedizione
    struct StatoEvidenze {
        bool E1_ricevuta;
        bool E2_ricevuta;
        bool E3_ricevuta;
        bool E1_valore;
        bool E2_valore;
        bool E3_valore;
    }
    
    /// @notice Probabilità a priori che F1 (consegna corretta) sia vero (0-100)
    uint8 public p_F1_T;
    /// @notice Probabilità a priori che F2 (conformità condizioni) sia vero (0-100)
    uint8 public p_F2_T;
    
    CPT private cpt_E1;
    CPT private cpt_E2;
    CPT private cpt_E3;
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @notice Imposta le probabilità a priori per F1 e F2
     * @param _p_F1_T Probabilità che F1 sia vero (0-100)
     * @param _p_F2_T Probabilità che F2 sia vero (0-100)
     */
    function impostaProbabilitaAPriori(uint8 _p_F1_T, uint8 _p_F2_T) external onlyRole(DEFAULT_ADMIN_ROLE) {
        p_F1_T = _p_F1_T;
        p_F2_T = _p_F2_T;
    }
    
    /**
     * @notice Imposta la tabella CPT per una specifica evidenza
     * @param _idEvidenza ID dell'evidenza (1-3)
     * @param _cpt Struttura CPT con le probabilità condizionate
     */
    function impostaCPT(uint8 _idEvidenza, CPT calldata _cpt) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_idEvidenza == 1) cpt_E1 = _cpt;
        else if (_idEvidenza == 2) cpt_E2 = _cpt;
        else if (_idEvidenza == 3) cpt_E3 = _cpt;
        else revert("ID evidenza non valido");
    }
    
    /**
     * @notice Valida le evidenze usando inferenza Bayesiana con 2 fatti e 3 evidenze
     * @param evidenze Struttura con stato e valori delle 3 evidenze
     * @return true se le probabilità posteriori di F1 e F2 superano la soglia del 95%
     */
    function validaEvidenze(StatoEvidenze memory evidenze) external view returns (bool) {
        uint256 pF1_T = p_F1_T;
        uint256 pF1_F = 100 - pF1_T;
        uint256 pF2_T = p_F2_T;
        uint256 pF2_F = 100 - pF2_T;
        
        // Calcola per tutte le combinazioni (FF, FT, TF, TT)
        uint256 prob_FF = _calcolaProbEvidenze(evidenze, false, false);
        uint256 prob_FT = _calcolaProbEvidenze(evidenze, false, true);
        uint256 prob_TF = _calcolaProbEvidenze(evidenze, true, false);
        uint256 prob_TT = _calcolaProbEvidenze(evidenze, true, true);
        
        uint256 termine_FF = (prob_FF * pF1_F * pF2_F) / 10000;
        uint256 termine_FT = (prob_FT * pF1_F * pF2_T) / 10000;
        uint256 termine_TF = (prob_TF * pF1_T * pF2_F) / 10000;
        uint256 termine_TT = (prob_TT * pF1_T * pF2_T) / 10000;
        
        uint256 normalizzatore = termine_FF + termine_FT + termine_TF + termine_TT;
        if (normalizzatore == 0) return false;
        
        uint256 probF1 = ((termine_TF + termine_TT) * 100) / normalizzatore;
        uint256 probF2 = ((termine_FT + termine_TT) * 100) / normalizzatore;
        
        return (probF1 >= SOGLIA_PROBABILITA && probF2 >= SOGLIA_PROBABILITA);
    }
    
    /**
     * @notice Calcola la probabilità combinata delle evidenze per una combinazione F1/F2
     * @param e Struttura con stato e valori delle evidenze
     * @param f1 Valore ipotizzato di F1
     * @param f2 Valore ipotizzato di F2
     * @return Probabilità combinata normalizzata (0-100)
     */
    function _calcolaProbEvidenze(StatoEvidenze memory e, bool f1, bool f2) private view returns (uint256) {
        uint256 prob = 100;
        
        if (e.E1_ricevuta) {
            uint8 p = _getCPTValue(cpt_E1, f1, f2);
            prob = (prob * (e.E1_valore ? p : (100 - p))) / 100;
        }
        if (e.E2_ricevuta) {
            uint8 p = _getCPTValue(cpt_E2, f1, f2);
            prob = (prob * (e.E2_valore ? p : (100 - p))) / 100;
        }
        if (e.E3_ricevuta) {
            uint8 p = _getCPTValue(cpt_E3, f1, f2);
            prob = (prob * (e.E3_valore ? p : (100 - p))) / 100;
        }
        
        return prob;
    }
    
    /**
     * @notice Legge il valore corretto dalla CPT in base allo stato di F1 e F2
     * @param cpt Tabella CPT da leggere
     * @param f1 Stato ipotizzato di F1
     * @param f2 Stato ipotizzato di F2
     * @return Probabilità condizionata corrispondente (0-100)
     */
    function _getCPTValue(CPT memory cpt, bool f1, bool f2) private pure returns (uint8) {
        if (!f1 && !f2) return cpt.p_FF;
        if (!f1 && f2) return cpt.p_FT;
        if (f1 && !f2) return cpt.p_TF;
        return cpt.p_TT;
    }
}
