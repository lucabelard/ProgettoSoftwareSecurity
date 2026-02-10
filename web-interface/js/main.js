/**
 * @file main.js
 * @description Entry point dell'applicazione - coordina tutti i moduli
 */

import { initWeb3, connectWallet, getCurrentAccount, getNetworkId, getWeb3 } from './web3-connection.js';

import { loadContract, createShipment, setPriorProbabilities, setCPT, sendEvidence, validateAndPay, getShipment, getShipmentCounter, getUserRoles, isAdmin, isMittente, isSensore, requestRefund, getContract, pauseContract, unpauseContract, isContractPaused, checkRateLimit, recordEvidenceSent } from './contract-interaction.js';
import { showToast, showLoading, hideLoading, updateAccountUI, updateNetworkStatus, renderShipmentCard, clearShipmentsGrid, showPanel, updateRoleSelection, updateRoleBadges, filterPanelsByRole } from './ui-components.js';
import { handleCancelShipment, handleRequestRefund, checkRefundEligibility, checkCancellationEligibility } from './refund-manager.js';

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Inizializzazione applicazione...');
    initializeTheme();
    setupEventListeners();
    await initializeApp();
});

async function initializeApp() {
    const result = await initWeb3();

    if (result.success) {
        showToast(`Web3 pronto. Connetti il wallet per accedere a Filiera Sicura.`, 'info');
    } else {
        showToast('Errore di connessione. Assicurati che il nodo Besu sia in esecuzione.', 'error');
    }
}

// ===== THEME FUNCTIONS =====
function initializeTheme() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'light') {
        document.body.classList.add('light-theme');
    }
}

function toggleTheme() {
    document.body.classList.toggle('light-theme');
    const isLight = document.body.classList.contains('light-theme');
    localStorage.setItem('theme', isLight ? 'light' : 'dark');
    showToast(`Tema ${isLight ? 'chiaro' : 'scuro'} attivato`, 'info');
}

// ===== EVENT LISTENERS SETUP =====
function setupEventListeners() {
    // Theme Toggle
    document.getElementById('themeToggle').addEventListener('click', toggleTheme);

    // Connect Wallet
    document.getElementById('connectWallet')?.addEventListener('click', handleConnectWallet);
    document.getElementById('connectWalletHero')?.addEventListener('click', handleConnectWallet);

    // Role Selection
    document.querySelectorAll('.role-card').forEach(card => {
        card.addEventListener('click', () => handleRoleSelection(card.dataset.role));
    });

    // Admin Panel
    document.getElementById('setPriorBtn')?.addEventListener('click', handleSetPrior);
    document.getElementById('setCPTBtn')?.addEventListener('click', handleSetCPT);
    document.getElementById('pauseContractBtn')?.addEventListener('click', handlePauseContract);
    document.getElementById('unpauseContractBtn')?.addEventListener('click', handleUnpauseContract);

    // Mittente Panel
    document.getElementById('createShipmentBtn')?.addEventListener('click', handleCreateShipment);
    document.getElementById('cancelShipmentBtn')?.addEventListener('click', handleCancelShipmentBtn);
    document.getElementById('requestRefundBtn')?.addEventListener('click', handleRequestRefundBtn);

    // Sensor Panel (simplified - full version would include all evidences)
    document.querySelectorAll('[data-evidence]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const evidenceId = parseInt(e.target.dataset.evidence);
            handleSendEvidence(evidenceId);
        });
    });
    document.getElementById('sendAllEvidencesBtn')?.addEventListener('click', handleSendAllEvidences);

    // Evidence toggle dynamic labels
    document.querySelectorAll('.evidence-toggle').forEach(toggle => {
        toggle.addEventListener('change', (e) => {
            const textSpan = e.target.closest('.toggle-label').querySelector('.toggle-text');
            if (textSpan) {
                textSpan.textContent = e.target.checked ? textSpan.dataset.on : textSpan.dataset.off;
            }
        });
    });

    // Courier Panel
    document.getElementById('validatePaymentBtn')?.addEventListener('click', handleValidatePayment);

    // Search and Filter
    document.getElementById('searchInput')?.addEventListener('input', filterShipments);
    document.getElementById('filterStatus')?.addEventListener('change', filterShipments);

    // Web3 Events
    window.addEventListener('accountChanged', async (event) => {
        updateAccountUI();

        // Reload user roles for the new account
        const account = getCurrentAccount();
        const roles = await getUserRoles(account);
        console.log('New account roles:', roles);

        // Update UI with new roles
        updateRoleBadges(roles);
        filterPanelsByRole(roles);

        // Auto-select appropriate panel based on new account's roles
        const isAdmin = roles.includes('admin') || roles.includes('oracolo');
        if (isAdmin) {
            handleRoleSelection('admin');
        } else if (roles.includes('mittente')) {
            handleRoleSelection('mittente');
        } else if (roles.includes('sensore')) {
            handleRoleSelection('sensore');
        } else {
            handleRoleSelection('corriere');
        }

        // Reload shipments with new account context
        await loadShipments();

        showToast(`Account cambiato (${roles.join(', ')})`, 'success');
    });

    window.addEventListener('chainChanged', () => {
        showToast('Rete cambiata, ricaricamento...', 'info');
        setTimeout(() => window.location.reload(), 1000);
    });
}

// ===== VIEW MANAGEMENT =====
function toggleAppView(showApp) {
    const landingHero = document.getElementById('landingHero');
    const appContent = document.getElementById('appContentContainer');
    
    if (showApp) {
        landingHero.style.display = 'none';
        appContent.style.display = 'block';
    } else {
        landingHero.style.display = 'block';
        appContent.style.display = 'none';
    }
}

// ===== WALLET CONNECTION =====
async function handleConnectWallet() {
    showLoading('Connessione al wallet...');

    const result = await connectWallet();

    if (result.success) {
        const loadResult = await loadContract();

        if (loadResult.success) {
            updateAccountUI();
            const networkId = await getNetworkId();
            updateNetworkStatus(true, networkId);
            
            // Switch to App View
            toggleAppView(true);

            // Detect user roles
            const account = getCurrentAccount();
            const roles = await getUserRoles(account);
            console.log('User roles:', roles);

            // Update UI with roles
            updateRoleBadges(roles);
            filterPanelsByRole(roles);

            // Auto-select appropriate panel based on roles
            const isAdmin = roles.includes('admin') || roles.includes('oracolo');
            if (isAdmin) {
                // Admin: auto-select Admin panel (RESTRICTED access to CPTs only)
                handleRoleSelection('admin');
                showToast(`Benvenuto Amministratore. Accesso configurazione CPT abilitato.`, 'success');
            } else if (roles.includes('mittente')) {
                // Auto-select Mittente panel
                handleRoleSelection('mittente');
                showToast(`Benvenuto Mittente. Pannello spedizioni attivo.`, 'success');
            } else if (roles.includes('sensore')) {
                // Auto-select Sensore panel
                handleRoleSelection('sensore');
                showToast(`Benvenuto Sensore. Pannello IoT attivo.`, 'success');
            } else {
                // No specific role, show Corriere by default
                handleRoleSelection('corriere');
                // No toast needed - user sees they're connected as Corriere from the badge
            }

            await loadShipments();
        } else {
            showToast(`Errore caricamento contratto: ${loadResult.error}`, 'error');
        }
    } else {
        showToast(`Errore connessione: ${result.error}`, 'error');
    }

    hideLoading();
}

// ===== ROLE SELECTION =====
function handleRoleSelection(role) {
    updateRoleSelection(role);
    showToast(`Ruolo selezionato: ${role}`, 'info');
    if (role === 'admin' || role === 'oracolo') {
        updateCircuitBreakerUI();
    }
}

// ===== ADMIN FUNCTIONS =====
async function handleSetPrior() {
    if (!getCurrentAccount()) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza.', 'warning');
            return;
        }

        showLoading('Impostazione probabilità a priori...');

        const pF1T = document.getElementById('pF1T').value;
        const pF2T = document.getElementById('pF2T').value;

        await setPriorProbabilities(pF1T, pF2T);

        showToast('Probabilità a priori impostate!', 'success');
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

async function handleSetCPT() {
    if (!getCurrentAccount()) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza.', 'warning');
            return;
        }

        showLoading('Impostazione CPT...');

        const evidenceId = document.getElementById('cptEvidenceSelect').value;
        const cpt = {
            p_FF: document.getElementById('cptFF').value,
            p_FT: document.getElementById('cptFT').value,
            p_TF: document.getElementById('cptTF').value,
            p_TT: document.getElementById('cptTT').value
        };

        await setCPT(evidenceId, cpt);

        showToast(`CPT per E${evidenceId} impostata!`, 'success');
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

// ===== MITTENTE FUNCTIONS =====
async function handleCreateShipment() {
    if (!getCurrentAccount()) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza. Riprova più tardi.', 'warning');
            return;
        }

        showLoading('Creazione spedizione...');

        const corriereAddress = document.getElementById('corriereAddress').value;
        const paymentAmount = document.getElementById('paymentAmount').value;

        const web3 = getWeb3();
        if (!web3.utils.isAddress(corriereAddress)) {
            showToast('Indirizzo corriere non valido', 'error');
            hideLoading();
            return;
        }

        const receipt = await createShipment(corriereAddress, paymentAmount);
        const shipmentId = receipt.events.SpedizioneCreata.returnValues.id;

        showToast(`Spedizione #${shipmentId} creata con successo!`, 'success');

        // Clear form
        document.getElementById('corriereAddress').value = '';
        document.getElementById('paymentAmount').value = '1';

        await loadShipments();
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

async function handleCancelShipmentBtn() {
    const shipmentId = document.getElementById('refundShipmentId').value;

    if (!shipmentId) {
        showToast('Inserisci ID spedizione', 'error');
        return;
    }

    // Check eligibility first
    const eligibility = await checkCancellationEligibility(shipmentId);

    if (!eligibility.eligible) {
        showToast(`${eligibility.reason}`, 'warning');
        return;
    }

    // Confirm
    if (!confirm(`Confermi l'annullamento della spedizione #${shipmentId}?`)) {
        return;
    }

    const result = await handleCancelShipment(shipmentId);

    if (result.success) {
        document.getElementById('refundShipmentId').value = '';
        await loadShipments();
    }
}

async function handleRequestRefundBtn() {
    const shipmentId = document.getElementById('refundShipmentId').value;

    if (!shipmentId) {
        showToast('Inserisci ID spedizione', 'error');
        return;
    }

    // Check eligibility first
    const eligibility = await checkRefundEligibility(shipmentId);

    if (!eligibility.eligible) {
        showToast(`Rimborso non disponibile: ${eligibility.reason}`, 'warning');
        return;
    }

    // Show eligibility reason
    showToast(`Rimborso disponibile: ${eligibility.reason}`, 'info');

    // Confirm
    if (!confirm(`Confermi la richiesta di rimborso per la spedizione #${shipmentId}?\nMotivo: ${eligibility.reason}`)) {
        return;
    }

    const result = await handleRequestRefund(shipmentId);

    if (result.success) {
        document.getElementById('refundShipmentId').value = '';
        await loadShipments();
    }
}

// ===== SENSOR FUNCTIONS =====
async function handleSendEvidence(evidenceId) {
    const shipmentId = document.getElementById('shipmentIdSensor').value;

    if (!shipmentId) {
        showToast('Inserisci ID spedizione', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza.', 'warning');
            return;
        }

        // Rate Limit pre-check (synchronous - no contract call)
        const rateStatus = checkRateLimit();
        if (!rateStatus.allowed) {
            showToast(`⏱️ RATE LIMIT: Devi attendere ancora ${rateStatus.secondsRemaining} secondi prima di inviare nuove evidenze.`, 'warning');
            return;
        }

        // Pre-validate shipment state and evidence status
        showLoading('Verifica spedizione...');
        const shipment = await getShipment(shipmentId);

        // Check if shipment exists
        if (!shipment || !shipment.mittente || shipment.mittente === '0x0000000000000000000000000000000000000000') {
            showToast('Spedizione non trovata', 'error');
            hideLoading();
            return;
        }

        // Check if shipment is cancelled
        if (shipment.stato == 2) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione annullata', 'error');
            hideLoading();
            return;
        }

        // Check if shipment is already paid or refunded
        if (shipment.stato == 1) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione già pagata', 'warning');
            hideLoading();
            return;
        }

        if (shipment.stato == 3) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione già rimborsata', 'warning');
            hideLoading();
            return;
        }

        // Check if evidence was already submitted
        const evidenceField = `E${evidenceId}_ricevuta`;
        if (shipment.evidenze[evidenceField]) {
            showToast(`⚠️ Evidenza E${evidenceId} già inviata - non può essere modificata`, 'warning');
            hideLoading();
            return;
        }

        showLoading(`Invio evidenza E${evidenceId}...`);

        const valueElement = document.getElementById(`e${evidenceId}Value`);
        const value = valueElement?.checked ?? true;

        await sendEvidence(shipmentId, evidenceId, value);

        recordEvidenceSent(); // Track timestamp for rate limiting
        showToast(`✅ Evidenza E${evidenceId} inviata!`, 'success');
        await loadShipments();
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

async function handleSendAllEvidences() {
    const shipmentId = document.getElementById('shipmentIdSensor').value;

    if (!shipmentId) {
        showToast('Inserisci ID spedizione', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza.', 'warning');
            return;
        }

        // Rate Limit pre-check (synchronous - no contract call)
        const rateStatus = checkRateLimit();
        if (!rateStatus.allowed) {
            showToast(`⏱️ RATE LIMIT: Devi attendere ancora ${rateStatus.secondsRemaining} secondi prima di inviare nuove evidenze.`, 'warning');
            return;
        }

        // Pre-validate shipment state
        showLoading('Verifica spedizione...');
        const shipment = await getShipment(shipmentId);

        // Check if shipment exists
        if (!shipment || !shipment.mittente || shipment.mittente === '0x0000000000000000000000000000000000000000') {
            showToast('Spedizione non trovata', 'error');
            hideLoading();
            return;
        }

        // Check if shipment is cancelled or completed
        if (shipment.stato == 2) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione annullata', 'error');
            hideLoading();
            return;
        }

        if (shipment.stato == 1) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione già pagata', 'warning');
            hideLoading();
            return;
        }

        if (shipment.stato == 3) {
            showToast('⚠️ Impossibile inviare evidenze: spedizione già rimborsata', 'warning');
            hideLoading();
            return;
        }

        showLoading('Invio tutte le evidenze in una transazione...');

        // Gather all evidence values
        const values = [
            document.getElementById('e1Value')?.checked ?? true,  // E1
            document.getElementById('e2Value')?.checked ?? true,  // E2
            document.getElementById('e3Value')?.checked ?? false, // E3
            document.getElementById('e4Value')?.checked ?? false, // E4
            document.getElementById('e5Value')?.checked ?? true   // E5
        ];

        // Import the new batch function
        const { sendAllEvidencesBatch } = await import('./contract-interaction.js');

        // Send all evidences in ONE transaction
        await sendAllEvidencesBatch(shipmentId, values);

        recordEvidenceSent(); // Track timestamp for rate limiting
        showToast('✅ Tutte le evidenze inviate in una sola transazione!', 'success');
        await loadShipments();
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

// ===== COURIER FUNCTIONS =====
async function handleValidatePayment() {
    const shipmentId = document.getElementById('shipmentIdCourier').value;

    if (!shipmentId) {
        showToast('Inserisci ID spedizione', 'error');
        return;
    }

    try {
        if (await isContractPaused()) {
            showToast('⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza.', 'warning');
            return;
        }

        showLoading('Validazione e pagamento...');

        // First, try to simulate the call to get the revert reason if it fails
        const account = getCurrentAccount();
        const contract = getContract();
        try {
            await contract.methods.validaEPaga(shipmentId).call({ from: account });
            console.log('✅ Validation will succeed, proceeding with transaction...');
        } catch (callError) {
            console.error('Call simulation failed:', callError);
            throw callError; // Re-throw to be caught by outer catch
        }

        const receipt = await validateAndPay(shipmentId);
        const event = receipt.events.SpedizionePagata;
        const web3 = getWeb3();
        const amount = web3.utils.fromWei(event.returnValues.importo, 'ether');

        showToast(`✅ Pagamento di ${amount} ETH ricevuto!`, 'success');

        document.getElementById('shipmentIdCourier').value = '';
        await loadShipments();
        hideLoading();
    } catch (error) {
        handleContractError(error);
        hideLoading();
    }
}

// ===== LOAD SHIPMENTS =====
async function loadShipments() {
    try {
        const counter = await getShipmentCounter();
        const totalShipments = Number(counter);
        const currentAccount = getCurrentAccount();
        const userRoles = await getUserRoles(currentAccount);

        clearShipmentsGrid();

        if (totalShipments === 0) {
            return;
        }

        for (let i = 1; i <= totalShipments; i++) {
            const shipment = await getShipment(i);

            // Skip if shipment doesn't exist
            if (!shipment || !shipment.mittente || shipment.mittente === '0x0000000000000000000000000000000000000000') {
                continue;
            }

            // Role-based filtering
            const isAdmin = userRoles.includes('admin') || userRoles.includes('oracolo');
            const isMittente = userRoles.includes('mittente');
            const isSensore = userRoles.includes('sensore');

            if (isAdmin || isSensore) {
                // Admin and Sensore see all shipments
                renderShipmentCard(i, shipment);
            } else if (isMittente) {
                // Mittente sees only their sent shipments
                if (shipment.mittente.toLowerCase() === currentAccount.toLowerCase()) {
                    renderShipmentCard(i, shipment);
                }
            } else {
                // Users without specific roles (couriers) see only their assigned shipments
                if (shipment.corriere.toLowerCase() === currentAccount.toLowerCase()) {
                    renderShipmentCard(i, shipment);
                }
            }
        }
    } catch (error) {
        console.error('Errore caricamento spedizioni:', error);
        showToast(`Errore: ${error.message}`, 'error');
    }
}

// ===== FILTER SHIPMENTS =====
function filterShipments() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('filterStatus').value;

    const cards = document.querySelectorAll('.shipment-card');

    cards.forEach(card => {
        const text = card.textContent.toLowerCase();
        const statusBadge = card.querySelector('.status-badge');
        const status = statusBadge ? statusBadge.textContent.trim() : '';

        const matchesSearch = text.includes(searchTerm);
        const matchesStatus = statusFilter === 'all' || status === statusFilter;

        card.style.display = matchesSearch && matchesStatus ? 'block' : 'none';
    });
}

// ===== CIRCUIT BREAKER HANDLERS =====
async function handlePauseContract() {
    if (!confirm('Sei SICURO di voler mettere in PAUSA il contratto? Tutte le operazioni saranno bloccate.')) return;
    
    showLoading('Mettendo in pausa il contratto...');
    try {
        await pauseContract();
        showToast('Contratto messo in PAUSA con successo', 'warning');
        await updateCircuitBreakerUI();
    } catch (error) {
        showToast('Errore durante la messa in pausa: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

async function handleUnpauseContract() {
    showLoading('Ripristinando il contratto...');
    try {
        await unpauseContract();
        showToast('Contratto RIPRISTINATO con successo', 'success');
        await updateCircuitBreakerUI();
    } catch (error) {
        handleContractError(error);
    } finally {
        hideLoading();
    }
}

async function updateCircuitBreakerUI() {
    try {
        const isPaused = await isContractPaused();
        const statusText = document.querySelector('#circuitBreakerStatus .status-text');
        const statusIndicator = document.querySelector('#circuitBreakerStatus .status-indicator');
        const pauseBtn = document.getElementById('pauseContractBtn');
        const unpauseBtn = document.getElementById('unpauseContractBtn');

        if (!statusText || !statusIndicator) return;

        if (isPaused) {
            statusText.textContent = 'Stato Contratto: IN PAUSA ⚠️';
            statusText.style.color = 'red';
            statusIndicator.style.backgroundColor = 'red';
            pauseBtn.style.display = 'none';
            unpauseBtn.style.display = 'inline-block';
            
            // Show persistent warning if admin panel is visible
            if (document.getElementById('adminPanel') && document.getElementById('adminPanel').style.display !== 'none') {
                showToast('ATTENZIONE: Il contratto è attualmente in PAUSA', 'warning');
            }
        } else {
            statusText.textContent = 'Stato Contratto: ATTIVO ✅';
            statusText.style.color = 'green';
            statusIndicator.style.backgroundColor = 'green';
            pauseBtn.style.display = 'inline-block';
            unpauseBtn.style.display = 'none';
        }
    } catch (error) {
        console.error('Errore updateCircuitBreakerUI:', error);
    }
}

// ===== CENTRALIZED ERROR HANDLING =====
function handleContractError(error) {
    console.error('Contract Error:', error);
    
    let message = error.message || 'Errore sconosciuto';
    let type = 'error';
    
    // Check for "Pausable: paused" revert reason
    if (message.includes('Pausable: paused') || 
        (error.data && error.data.message && error.data.message.includes('Pausable: paused'))) {
        message = '⛔ OPERAZIONE BLOCCATA: Il contratto è in PAUSA di emergenza. Riprova più tardi.';
        type = 'warning';
        // Force update of the status indicator
        updateCircuitBreakerUI();
    }
    // Check for AccessControl errors
    else if (message.includes('AccessControl') || 
             (error.data && error.data.message && error.data.message.includes('AccessControl'))) {
        message = '🚫 ACCESSO NEGATO: Non hai i permessi necessari (serve Admin/Mittente/Corriere).';
    }
    // Check for Compliance Requirements (Probability < 95%)
    else if (message.includes('Requisiti di conformita non superati') ||
             (error.data && error.data.message && error.data.message.includes('Requisiti di conformita non superati'))) {
        message = '❌ Evidenze non valide - probabilità sotto la soglia del 95%';
    }
    // Check for Missing Evidences
    else if (message.includes('Evidenze mancanti') ||
             (error.data && error.data.message && error.data.message.includes('Evidenze mancanti'))) {
        message = '⚠️ Evidenze incomplete - attendi tutte le 5 evidenze';
    }
    // Check for Wrong Account (Courier validation)
    else if (message.includes('Non sei il corriere') ||
             (error.data && error.data.message && error.data.message.includes('Non sei il corriere'))) {
        message = '🚫 Solo il corriere assegnato può richiedere il pagamento';
    }
    // Check for Wrong State
    else if (message.includes('Spedizione non in attesa') ||
             (error.data && error.data.message && error.data.message.includes('Spedizione non in attesa'))) {
        message = '⚠️ Spedizione già processata o annullata';
    }
    // Check for Rate Limit errors
    else if (message.includes('RateLimitExceeded') || message.includes('Rate') ||
             (error.data && error.data.message && error.data.message.includes('RateLimitExceeded'))) {
        message = '⏱️ RATE LIMIT: Devi attendere almeno 1 minuto tra un invio di evidenze e il prossimo.';
        type = 'warning';
    }
    // Check for internal JSON-RPC error (often hides the real revert reason)
    else if (message.includes('Internal JSON-RPC error')) {
        if (error.data && error.data.message) {
            message = `❌ ${error.data.message}`;
        } else {
            message = '❌ Errore RPC - controlla console per dettagli';
        }
    }
    
    showToast(message, type);
}
