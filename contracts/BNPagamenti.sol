// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BNGestoreSpedizioni} from "./BNGestoreSpedizioni.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @notice Errore: il chiamante non è il corriere assegnato alla spedizione
error NonSeiIlCorriere();
/// @notice Errore: il trasferimento di ETH al corriere è fallito
error PagamentoFallito();

/**
 * @title BNPagamenti
 * @author Blockchain Shipment Tracking Team
 * @notice Gestisce la validazione e i pagamenti delle spedizioni
 * @dev Estende BNGestoreSpedizioni - ISOLAMENTO della logica di pagamento
 */
contract BNPagamenti is BNGestoreSpedizioni, ReentrancyGuard {
    
    // === EVENTI ===
    
    /// @notice Emesso quando una spedizione viene pagata al corriere
    /// @param id ID della spedizione pagata
    /// @param corriere Indirizzo del corriere che ha ricevuto il pagamento
    /// @param importo Importo pagato in wei
    event SpedizionePagata(uint256 indexed id, address indexed corriere, uint256 importo);
    
    /// @notice Emesso quando un tentativo di pagamento fallisce
    /// @param id ID della spedizione
    /// @param richiedente Indirizzo che ha tentato il pagamento
    /// @param motivo Motivo del fallimento
    event TentativoPagamentoFallito(uint256 indexed id, address indexed richiedente, string motivo);
    
    // === EVENTI DI RUNTIME MONITORING ===
    
    /// @notice Evento di monitoraggio per violazioni di safety properties
    /// @param property Nome della property violata
    /// @param shipmentId ID della spedizione
    /// @param caller Indirizzo che ha causato la violazione
    /// @param reason Motivo della violazione
    event MonitorSafetyViolation(string indexed property, uint256 indexed shipmentId, address indexed caller, string reason);
    
    /// @notice Evento di monitoraggio per guarantee properties soddisfatte
    /// @param property Nome della property garantita
    /// @param shipmentId ID della spedizione
    event MonitorGuaranteeSuccess(string indexed property, uint256 indexed shipmentId);
    
    /// @notice Evento di tracking per probabilità calcolate
    /// @param shipmentId ID della spedizione
    /// @param probF1 Probabilità calcolata per F1
    /// @param probF2 Probabilità calcolata per F2
    event ProbabilityCalculated(uint256 indexed shipmentId, uint256 indexed probF1, uint256 probF2);
    
    /**
     * @notice Valida le evidenze e paga il corriere se conformi
     * @param _id ID della spedizione da validare
     * @dev Verifica tutte le evidenze, calcola probabilità Bayesiane e paga se >= 95%
     */
    function validaEPaga(uint256 _id) external nonReentrant whenNotPaused {
        Spedizione storage s = spedizioni[_id];
        // ACCESS CONTROL: Courier Authorization
        if (s.corriere != msg.sender) {
            emit MonitorSafetyViolation("CourierAuth", _id, msg.sender, "Non sei il corriere");
            emit TentativoPagamentoFallito(_id, msg.sender, "Non sei il corriere");
            revert NonSeiIlCorriere();
        }
        
        // SAFETY MONITOR S2: State Exclusivity
        if (s.stato != StatoSpedizione.InAttesa) {
            emit MonitorSafetyViolation("S2:StateExclusivity", _id, msg.sender, "Spedizione non in attesa");
            emit TentativoPagamentoFallito(_id, msg.sender, "Spedizione non in attesa");
            revert SpedizioneNonInAttesa();
        }
        
        // SAFETY MONITOR S3: Evidence Before Payment
        if (!_tutteEvidenzeRicevute(_id)) {
            emit MonitorSafetyViolation("S3:EvidenceBeforePayment", _id, msg.sender, "Evidenze mancanti");
            emit TentativoPagamentoFallito(_id, msg.sender, "Evidenze mancanti");
            revert EvidenzeMancanti();
        }
        
        // Calcola probabilità posteriori usando la logica di BNCore
        (uint256 probF1, uint256 probF2) = _calcolaProbabilitaPosteriori(s.evidenze);
        
        // Emetti evento di tracking calcolo probabilità
        emit ProbabilityCalculated(_id, probF1, probF2);
        emit ProbabilitaValidazione(_id, probF1, probF2);
        
        // SAFETY MONITOR S5: Probability Threshold
        if (probF1 < SOGLIA_PROBABILITA || probF2 < SOGLIA_PROBABILITA) {
            // SAFETY MONITOR S4: Bounded Failed Attempts (Registra tentativo fallito per permettere rimborso dopo 3 tentativi)
            _registraTentativoFallito(_id);
            
            emit MonitorSafetyViolation("S5:ProbabilityThreshold", _id, msg.sender, "Requisiti di conformita non superati");
            emit SogliaValidazioneNonSuperata(_id, probF1, probF2);
            emit TentativoPagamentoFallito(_id, msg.sender, "Requisiti di conformita non superati");
            
            // IMPORTANT: Return instead of revert to allow counter increment to persist
            return;
        }
        // GUARANTEE MONITOR G1: Payment Upon Valid Evidence
        uint256 importo = s.importoPagamento;
        s.stato = StatoSpedizione.Pagata;
        emit MonitorGuaranteeSuccess("G1:PaymentValidity", _id);
        emit SpedizionePagata(_id, s.corriere, importo);
        // Trasferisci fondi
        (bool success, ) = s.corriere.call{value: importo}("");
        if (!success) revert PagamentoFallito();
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
