// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./BNGestoreSpedizioni.sol";

/**
 * @title BNPagamenti
 * @notice Gestisce la validazione e i pagamenti delle spedizioni
 * @dev Estende BNGestoreSpedizioni - ISOLAMENTO della logica di pagamento
 */
contract BNPagamenti is BNGestoreSpedizioni {
    
    // === EVENTI ===
    event SpedizionePagata(uint256 indexed id, address indexed corriere, uint256 importo);
    event TentativoPagamentoFallito(uint256 indexed id, address indexed richiedente, string motivo);
    
    /**
     * @notice Valida le evidenze e paga il corriere se i requisiti sono soddisfatti
     * @param _id ID della spedizione
     */
    function validaEPaga(uint256 _id) external {
        Spedizione storage s = spedizioni[_id];
        
        // Verifica 1: Solo il corriere può richiedere il pagamento
        if (s.corriere != msg.sender) {
            emit TentativoPagamentoFallito(_id, msg.sender, "Non sei il corriere");
            revert("Non sei il corriere");
        }
        
        // Verifica 2: Spedizione in attesa
        if (s.stato != StatoSpedizione.InAttesa) {
            emit TentativoPagamentoFallito(_id, msg.sender, "Spedizione non in attesa");
            revert("Spedizione non in attesa");
        }
        
        // Verifica 3: Tutte le evidenze presenti
        if (!_tutteEvidenzeRicevute(_id)) {
            emit TentativoPagamentoFallito(_id, msg.sender, "Evidenze mancanti");
            revert("Evidenze mancanti");
        }
        
        // Calcola probabilità posteriori usando la logica di BNCore
        (uint256 probF1, uint256 probF2) = _calcolaProbabilitaPosteriori(s.evidenze);
        
        // Emetti evento di monitoraggio
        emit ProbabilitaValidazione(_id, probF1, probF2);
        
        // Verifica 4: Soglie di conformità
        if (probF1 < SOGLIA_PROBABILITA || probF2 < SOGLIA_PROBABILITA) {
            emit SogliaValidazioneNonSuperata(_id, probF1, probF2);
            emit TentativoPagamentoFallito(_id, msg.sender, "Requisiti di conformita non superati");
            revert("Requisiti di conformita non superati");
        }
        
        // Aggiorna stato
        uint256 importo = s.importoPagamento;
        s.stato = StatoSpedizione.Pagata;
        
        emit SpedizionePagata(_id, s.corriere, importo);
        
        // Trasferisci fondi
        (bool success, ) = s.corriere.call{value: importo}("");
        require(success, "Pagamento fallito");
    }
    
    /**
     * @notice Visualizza lo stato di validazione di una spedizione
     * @param _id ID della spedizione
     * @return probF1 Probabilità che F1 sia vera
     * @return probF2 Probabilità che F2 sia vera
     * @return valida true se supera le soglie
     */
    function verificaValidita(uint256 _id) 
        external 
        view 
        returns (uint256 probF1, uint256 probF2, bool valida) 
    {
        Spedizione storage s = spedizioni[_id];
        
        if (!_tutteEvidenzeRicevute(_id)) {
            return (0, 0, false);
        }
        
        (probF1, probF2) = _calcolaProbabilitaPosteriori(s.evidenze);
        valida = (probF1 >= SOGLIA_PROBABILITA && probF2 >= SOGLIA_PROBABILITA);
        
        return (probF1, probF2, valida);
    }
}
