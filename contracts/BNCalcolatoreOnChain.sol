// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./BNPagamenti.sol";

/**
 * @title BNCalcolatoreOnChain
 * @author Blockchain Shipment Tracking Team
 * @notice Contratto principale che unifica tutti i moduli
 * @dev Architettura modulare per sicurezza e manutenibilità:
 *      - BNCore: Logica Bayesiana
 *      - BNGestoreSpedizioni: Gestione spedizioni ed evidenze
 *      - BNPagamenti: Validazione e pagamenti
 *      - Questo contratto: Entry point unificato
 */
contract BNCalcolatoreOnChain is BNPagamenti {
    
    // Questo contratto eredita tutte le funzionalità dai moduli
    // mantenendo l'interfaccia pubblica compatibile con il sistema esistente
    
    constructor() {
        // I ruoli sono già configurati nei contratti parent
    }
    
    /**
          * @notice Restituisce informazioni sul sistema
     * @return nome Nome del sistema di calcolo
     * @return versione Versione corrente del sistema
     * @return architettura Architettura modulare utilizzata
     * @return nome Nome del sistema di calcolo`r`n     * @return versione Versione corrente del sistema`r`n     * @return architettura Architettura modulare utilizzata`r`n     */
    function getSystemInfo() external pure returns (
        string memory nome,
        string memory versione,
        string memory architettura
    ) {
        return (
            "BN Calcolatore On-Chain",
            "2.0.0 - Modular",
            "BNCore -> BNGestoreSpedizioni -> BNPagamenti"
        );
    }
}
