/**
 * @file refund-manager.js
 * @description Gestisce la logica di rimborso e annullamento spedizioni
 */

import { cancelShipment, requestRefund, getShipment, getTimeoutValue } from './contract-interaction.js';
import { showToast, showLoading, hideLoading } from './ui-components.js';
import { getCurrentAccount } from './web3-connection.js';

// ===== CHECK REFUND CONDITIONS =====
export async function checkRefundEligibility(shipmentId) {
    try {
        const shipment = await getShipment(shipmentId);
        const currentAccount = getCurrentAccount();
        
        console.log('🔍 Checking refund eligibility for shipment:', shipmentId);
        console.log('Shipment data:', shipment);
        console.log('Failed attempts:', Number(shipment.tentativiValidazioneFalliti));
        
        // Check if user is the sender
        if (shipment.mittente.toLowerCase() !== currentAccount.toLowerCase()) {
            return { eligible: false, reason: 'Non sei il mittente' };
        }
        
        // Check if shipment is in waiting state
        if (shipment.stato != 0) {
            return { eligible: false, reason: 'Spedizione non in attesa' };
        }
        
        const now = Math.floor(Date.now() / 1000);
        const creationTime = Number(shipment.timestampCreazione);
        const timeoutSec = Number(await getTimeoutValue());
        const failedAttempts = Number(shipment.tentativiValidazioneFalliti);
        
        console.log('Conditions check:', {
            failedAttempts,
            required: 3,
            eligible: failedAttempts >= 3
        });
        
        // Check conditions
        const conditions = {
            failedAttempts: failedAttempts >= 3,
            timeout: now >= (creationTime + timeoutSec),
            noEvidence: !hasAllEvidence(shipment),
            courierTimeout: now >= (creationTime + timeoutSec * 2) && hasAllEvidence(shipment) && failedAttempts === 0
        };
        
        console.log('All conditions:', conditions);
        
        if (conditions.failedAttempts) {
            console.log('✅ Refund eligible: Failed attempts >= 3');
            return { eligible: true, reason: `Validazione fallita ${failedAttempts} volte` };
        }
        
        if (conditions.timeout && conditions.noEvidence) {
            const daysElapsed = Math.floor((now - creationTime) / 86400);
            return { eligible: true, reason: `Timeout (${daysElapsed} giorni) senza evidenze complete` };
        }
        
        if (conditions.courierTimeout) {
            const daysElapsed = Math.floor((now - creationTime) / 86400);
            return { eligible: true, reason: `Corriere inattivo da ${daysElapsed} giorni` };
        }
        
        console.log('❌ Refund NOT eligible - no conditions met');
        return { eligible: false, reason: 'Condizioni non soddisfatte', conditions };
        
    } catch (error) {
        console.error('Errore check eligibility:', error);
        return { eligible: false, reason: error.message };
    }
}

function hasAllEvidence(shipment) {
    const e = shipment.evidenze;
    return e.E1_ricevuta && e.E2_ricevuta && e.E3_ricevuta && e.E4_ricevuta && e.E5_ricevuta;
}

// ===== CHECK CANCELLATION ELIGIBILITY =====
export async function checkCancellationEligibility(shipmentId) {
    try {
        const shipment = await getShipment(shipmentId);
        const currentAccount = getCurrentAccount();
        
        if (shipment.mittente.toLowerCase() !== currentAccount.toLowerCase()) {
            return { eligible: false, reason: 'Non sei il mittente' };
        }
        
        if (shipment.stato != 0) {
            return { eligible: false, reason: 'Spedizione non in attesa' };
        }
        
        const e = shipment.evidenze;
        const hasNoEvidence = !e.E1_ricevuta && !e.E2_ricevuta && !e.E3_ricevuta && 
                               !e.E4_ricevuta && !e.E5_ricevuta;
        
        if (!hasNoEvidence) {
            return { eligible: false, reason: 'Evidenze già inviate' };
        }
        
        return { eligible: true, reason: 'Puoi annullare la spedizione' };
        
    } catch (error) {
        return { eligible: false, reason: error.message };
    }
}

// ===== CANCEL SHIPMENT =====
export async function handleCancelShipment(shipmentId) {
    try {
        showLoading('Annullamento spedizione...');
        
        const eligibility = await checkCancellationEligibility(shipmentId);
        
        if (!eligibility.eligible) {
            showToast(`Impossibile annullare: ${eligibility.reason}`, 'error');
            hideLoading();
            return { success: false, reason: eligibility.reason };
        }
        
        const receipt = await cancelShipment(shipmentId);
        
        showToast(`✅ Spedizione #${shipmentId} annullata! Rimborso effettuato.`, 'success');
        hideLoading();
        
        return { success: true, receipt };
        
    } catch (error) {
        console.error('Errore annullamento:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
        return { success: false, error: error.message };
    }
}

// ===== REQUEST REFUND =====
export async function handleRequestRefund(shipmentId) {
    try {
        showLoading('Richiesta rimborso...');
        
        const eligibility = await checkRefundEligibility(shipmentId);
        
        if (!eligibility.eligible) {
            let message = `Rimborso non disponibile: ${eligibility.reason}`;
            
            if (eligibility.conditions) {
                const { failedAttempts, timeout, noEvidence, courierTimeout } = eligibility.conditions;
                message += `\n\nCondizioni:\n`;
                message += `- Tentativi falliti (>= 3): ${failedAttempts ? '✅' : '❌'}\n`;
                message += `- Timeout (7 giorni): ${timeout ? '✅' : '❌'}\n`;
                message += `- Evidenze mancanti: ${noEvidence ? '✅' : '❌'}\n`;
                message += `- Corriere inattivo (14 giorni): ${courierTimeout ? '✅' : '❌'}`;
            }
            
            showToast(message, 'warning');
            hideLoading();
            return { success: false, reason: eligibility.reason };
        }
        
        const receipt = await requestRefund(shipmentId);
        
        showToast(`✅ Rimborso richiesto con successo! Motivo: ${eligibility.reason}`, 'success');
        hideLoading();
        
        return { success: true, receipt, reason: eligibility.reason };
        
    } catch (error) {
        console.error('Errore rimborso:', error);
        
        // Extract revert reason
        let errorMessage = error.message;
        if (error.message.includes('revert')) {
            const match = error.message.match(/revert (.+?)"/);
            if (match) {
                errorMessage = match[1];
            }
        }
        
        showToast(`Errore: ${errorMessage}`, 'error');
        hideLoading();
        return { success: false, error: errorMessage };
    }
}
