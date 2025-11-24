// ===== CONFIGURATION =====
const GANACHE_URL = 'http://127.0.0.1:7545';
const CONTRACT_ABI_PATH = './BNCalcolatoreOnChain.json';

// ===== STATE =====
let web3;
let contract;
let currentAccount;
let contractAddress;
let networkId;
let accounts = [];
let eventListenersSetup = false;

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', async () => {
    setupEventListeners();
    await initWeb3();
});

// ===== WEB3 INITIALIZATION =====
async function initWeb3() {
    try {
        // Check if MetaMask is installed
        if (typeof window.ethereum !== 'undefined') {
            web3 = new Web3(window.ethereum);
            console.log('MetaMask rilevato');
            showToast('MetaMask rilevato! Clicca su "Connect Wallet" per connettere.', 'info');
        } else {
            // Fallback to Ganache
            console.log('MetaMask non trovato, connessione a Ganache...');
            web3 = new Web3(new Web3.providers.HttpProvider(GANACHE_URL));
            showToast('Connesso a Ganache locale', 'success');
            await connectWallet(); // Auto-connect to Ganache
        }
    } catch (error) {
        console.error('Errore inizializzazione Web3:', error);
        showToast('Errore di connessione. Assicurati che Ganache sia in esecuzione.', 'error');
    }
}

// ===== CONNECT WALLET =====
async function connectWallet() {
    try {
        showLoading('Connessione al wallet...');
        
        if (typeof window.ethereum !== 'undefined') {
            // Request account access
            accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            currentAccount = accounts[0];
            
            console.log('Account connesso:', currentAccount);
            
            // Remove old listeners to avoid duplicates
            if (window.ethereum.removeAllListeners) {
                window.ethereum.removeAllListeners('accountsChanged');
                window.ethereum.removeAllListeners('chainChanged');
            }
            
            // Listen for account changes
            window.ethereum.on('accountsChanged', handleAccountsChanged);
            window.ethereum.on('chainChanged', handleChainChanged);
        } else {
            // Use Ganache accounts
            accounts = await web3.eth.getAccounts();
            currentAccount = accounts[0];
            console.log('Ganache account:', currentAccount);
        }
        
        // Load contract after getting accounts
        await loadContract();
        updateUI();
        hideLoading();
        
    } catch (error) {
        console.error('Errore connessione wallet:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

// ===== LOAD CONTRACT =====
async function loadContract() {
    try {
        console.log('Caricamento contratto...');
        
        // Fetch contract artifact
        const response = await fetch(CONTRACT_ABI_PATH);
        if (!response.ok) {
            throw new Error(`Impossibile caricare il contratto: ${response.statusText}`);
        }
        
        const contractData = await response.json();
        
        // Get network ID with retry logic
        let retries = 3;
        while (retries > 0) {
            try {
                networkId = await web3.eth.net.getId();
                if (networkId !== undefined && networkId !== null) {
                    break;
                }
                console.log('Network ID undefined, retry...');
                await new Promise(resolve => setTimeout(resolve, 500));
                retries--;
            } catch (e) {
                console.error('Errore getting network ID:', e);
                retries--;
                if (retries > 0) {
                    await new Promise(resolve => setTimeout(resolve, 500));
                }
            }
        }
        
        if (networkId === undefined || networkId === null) {
            throw new Error('Impossibile ottenere il Network ID. Assicurati che MetaMask sia connesso alla rete Ganache.');
        }
        
        console.log('Network ID:', networkId);
        
        // Convert BigInt to Number if needed
        const networkIdStr = networkId.toString();
        
        // Get contract address
        if (contractData.networks[networkIdStr] || contractData.networks[networkId]) {
            const networkData = contractData.networks[networkIdStr] || contractData.networks[networkId];
            contractAddress = networkData.address;
            contract = new web3.eth.Contract(contractData.abi, contractAddress);
            
            console.log('Contratto caricato:', contractAddress);
            
            updateNetworkStatus(true);
            showToast('Contratto caricato con successo!', 'success');
            
            // Load shipments
            await loadShipments();
            
        } else {
            const availableNetworks = Object.keys(contractData.networks).join(', ');
            throw new Error(`Contratto non deployato sulla rete ${networkIdStr}. Reti disponibili: ${availableNetworks || 'nessuna'}. Esegui 'truffle migrate --reset'`);
        }
    } catch (error) {
        console.error('Errore caricamento contratto:', error);
        showToast(`Errore: ${error.message}`, 'error');
        updateNetworkStatus(false);
        throw error;
    }
}

// ===== CHAIN CHANGE HANDLER =====
function handleChainChanged(chainId) {
    console.log('Chain cambiata:', chainId);
    showToast('Rete cambiata, ricaricamento...', 'info');
    setTimeout(() => window.location.reload(), 1000);
}

// ===== UPDATE UI =====
function updateUI() {
    const accountElement = document.getElementById('accountAddress');
    if (currentAccount) {
        accountElement.textContent = `${currentAccount.substring(0, 6)}...${currentAccount.substring(38)}`;
        document.getElementById('connectWallet').textContent = 'Connesso';
        document.getElementById('connectWallet').disabled = true;
    }
}

function updateNetworkStatus(connected) {
    const statusElement = document.getElementById('networkStatus');
    const networkNameElement = document.getElementById('networkName');
    const statusDot = statusElement.querySelector('.status-dot');
    
    if (connected) {
        statusDot.classList.add('connected');
        networkNameElement.textContent = networkId === 5777n || networkId === 5777 ? 'Ganache' : `Network ${networkId}`;
    } else {
        statusDot.classList.remove('connected');
        networkNameElement.textContent = 'Disconnected';
    }
}

// ===== ACCOUNT CHANGE HANDLER =====
function handleAccountsChanged(newAccounts) {
    if (newAccounts.length === 0) {
        showToast('Wallet disconnesso', 'info');
        currentAccount = null;
    } else {
        currentAccount = newAccounts[0];
        updateUI();
        loadShipments();
        showToast('Account cambiato', 'info');
    }
}

// ===== EVENT LISTENERS =====
function setupEventListeners() {
    // Prevent duplicate setup
    if (eventListenersSetup) {
        console.log('Event listeners già configurati');
        return;
    }
    
    console.log('Configurazione event listeners...');
    
    // Connect Wallet
    const connectBtn = document.getElementById('connectWallet');
    if (connectBtn) {
        connectBtn.addEventListener('click', connectWallet);
    }
    
    // Role Selection
    document.querySelectorAll('.role-card').forEach(card => {
        card.addEventListener('click', () => selectRole(card.dataset.role));
    });
    
    // Admin Panel
    const setPriorBtn = document.getElementById('setPriorBtn');
    if (setPriorBtn) {
        setPriorBtn.addEventListener('click', setPriorProbabilities);
    }
    
    const setCPTBtn = document.getElementById('setCPTBtn');
    if (setCPTBtn) {
        setCPTBtn.addEventListener('click', setCPT);
    }
    
    // Create Shipment
    const createShipmentBtn = document.getElementById('createShipmentBtn');
    if (createShipmentBtn) {
        createShipmentBtn.addEventListener('click', createShipment);
    }
    
    // Send Evidence
    document.querySelectorAll('[data-evidence]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const evidenceId = e.target.dataset.evidence;
            sendEvidence(evidenceId);
        });
    });
    
    // Send All Evidences
    const sendAllEvidencesBtn = document.getElementById('sendAllEvidencesBtn');
    if (sendAllEvidencesBtn) {
        sendAllEvidencesBtn.addEventListener('click', sendAllEvidences);
    }
    
    // Validate Payment
    const validatePaymentBtn = document.getElementById('validatePaymentBtn');
    if (validatePaymentBtn) {
        validatePaymentBtn.addEventListener('click', validateAndPay);
    }
    
    // Search and Filter
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', filterShipments);
    }
    
    const filterStatus = document.getElementById('filterStatus');
    if (filterStatus) {
        filterStatus.addEventListener('change', filterShipments);
    }
    
    // Toggle switches
    setupToggleSwitches();
    
    eventListenersSetup = true;
    console.log('Event listeners configurati con successo');
}

function setupToggleSwitches() {
    const toggles = [
        { id: 'e1Value', textId: 'e1Text', trueText: 'OK', falseText: 'Fuori Range' },
        { id: 'e2Value', textId: 'e2Text', trueText: 'OK', falseText: 'Rotto' },
        { id: 'e3Value', textId: 'e3Text', trueText: 'Shock', falseText: 'No Shock' },
        { id: 'e4Value', textId: 'e4Text', trueText: 'Aperto', falseText: 'Chiuso' },
        { id: 'e5Value', textId: 'e5Text', trueText: 'In Orario', falseText: 'In Ritardo' }
    ];
    
    toggles.forEach(toggle => {
        const input = document.getElementById(toggle.id);
        if (input) {
            input.addEventListener('change', (e) => {
                const textElement = e.target.parentElement.querySelector('.toggle-text');
                textElement.textContent = e.target.checked ? toggle.trueText : toggle.falseText;
            });
        }
    });
}

// ===== ROLE SELECTION =====
function selectRole(role) {
    // Update active state
    document.querySelectorAll('.role-card').forEach(card => {
        card.classList.remove('active');
    });
    event.target.closest('.role-card').classList.add('active');
    
    // Hide all panels
    document.querySelectorAll('.panel').forEach(panel => {
        panel.style.display = 'none';
    });
    
    // Show selected panel
    const panelMap = {
        'admin': 'adminPanel',
        'mittente': 'createPanel',
        'sensore': 'sensorPanel',
        'corriere': 'courierPanel'
    };
    
    const panelId = panelMap[role];
    if (panelId) {
        document.getElementById(panelId).style.display = 'block';
    }
    
    showToast(`Ruolo selezionato: ${role}`, 'info');
}

// ===== ADMIN FUNCTIONS =====
async function setPriorProbabilities() {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        showLoading('Impostazione probabilità a priori...');
        
        const pF1T = document.getElementById('pF1T').value;
        const pF2T = document.getElementById('pF2T').value;
        
        await contract.methods.impostaProbabilitaAPriori(pF1T, pF2T)
            .send({ from: currentAccount, gas: 200000 });
        
        showToast('Probabilità a priori impostate con successo!', 'success');
        hideLoading();
    } catch (error) {
        console.error('Errore:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

async function setCPT() {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        showLoading('Impostazione CPT...');
        
        const evidenceId = document.getElementById('cptEvidenceSelect').value;
        const cpt = {
            p_FF: document.getElementById('cptFF').value,
            p_FT: document.getElementById('cptFT').value,
            p_TF: document.getElementById('cptTF').value,
            p_TT: document.getElementById('cptTT').value
        };
        
        await contract.methods.impostaCPT(evidenceId, cpt)
            .send({ from: currentAccount, gas: 200000 });
        
        showToast(`CPT per E${evidenceId} impostata con successo!`, 'success');
        hideLoading();
    } catch (error) {
        console.error('Errore:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

// ===== CREATE SHIPMENT =====
async function createShipment() {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        showLoading('Creazione spedizione...');
        
        const corriereAddress = document.getElementById('corriereAddress').value;
        const paymentAmount = document.getElementById('paymentAmount').value;
        
        if (!web3.utils.isAddress(corriereAddress)) {
            showToast('Indirizzo corriere non valido', 'error');
            hideLoading();
            return;
        }
        
        const weiAmount = web3.utils.toWei(paymentAmount, 'ether');
        
        const receipt = await contract.methods.creaSpedizione(corriereAddress)
            .send({ from: currentAccount, value: weiAmount, gas: 500000 });
        
        // Get shipment ID from event
        const event = receipt.events.SpedizioneCreata;
        const shipmentId = event.returnValues.id;
        
        showToast(`Spedizione #${shipmentId} creata con successo!`, 'success');
        
        // Clear form
        document.getElementById('corriereAddress').value = '';
        document.getElementById('paymentAmount').value = '1';
        
        // Reload shipments
        await loadShipments();
        hideLoading();
    } catch (error) {
        console.error('Errore:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

// ===== SEND EVIDENCE =====
async function sendEvidence(evidenceId) {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        showLoading(`Invio evidenza E${evidenceId}...`);
        
        const shipmentId = document.getElementById('shipmentIdSensor').value;
        
        if (!shipmentId || shipmentId.trim() === '') {
            showToast('Inserisci l\'ID della spedizione', 'error');
            hideLoading();
            return;
        }
        
        // Verifica lo stato della spedizione PRIMA di inviare la transazione
        console.log('Verifica stato spedizione ID:', shipmentId);
        const shipment = await contract.methods.spedizioni(shipmentId).call();
        console.log('Stato spedizione:', shipment.stato);
        
        // Controlla se la spedizione esiste
        if (shipment.mittente === '0x0000000000000000000000000000000000000000') {
            showToast('Spedizione non esistente', 'error');
            hideLoading();
            return;
        }
        
        // Controlla se la spedizione è già stata pagata
        if (shipment.stato != 0 && shipment.stato !== '0') {
            showToast('La spedizione è già stata pagata. Non è possibile inviare altre evidenze.', 'error');
            hideLoading();
            return;
        }
        
        const valueElement = document.getElementById(`e${evidenceId}Value`);
        const value = valueElement.checked;
        
        await contract.methods.inviaEvidenza(shipmentId, evidenceId, value)
            .send({ from: currentAccount, gas: 150000 });
        
        showToast(`Evidenza E${evidenceId} inviata con successo!`, 'success');
        
        // Reload shipments
        await loadShipments();
        hideLoading();
    } catch (error) {
        console.error('Errore:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

// ===== SEND ALL EVIDENCES =====
async function sendAllEvidences() {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        const shipmentId = document.getElementById('shipmentIdSensor').value;
        
        if (!shipmentId || shipmentId.trim() === '') {
            showToast('Inserisci l\'ID della spedizione', 'error');
            return;
        }
        
        // Verifica lo stato della spedizione PRIMA di inviare
        console.log('Verifica stato spedizione ID:', shipmentId);
        const shipment = await contract.methods.spedizioni(shipmentId).call();
        
        // Controlla se la spedizione esiste
        if (shipment.mittente === '0x0000000000000000000000000000000000000000') {
            showToast('Spedizione non esistente', 'error');
            return;
        }
        
        // Controlla se la spedizione è già stata pagata
        if (shipment.stato != 0 && shipment.stato !== '0') {
            showToast('La spedizione è già stata pagata. Non è possibile inviare altre evidenze.', 'error');
            return;
        }
        
        showLoading('Invio di tutte le evidenze in corso...');
        
        // Raccogli i valori di tutte le evidenze
        const evidences = [
            { id: 1, value: document.getElementById('e1Value').checked },
            { id: 2, value: document.getElementById('e2Value').checked },
            { id: 3, value: document.getElementById('e3Value').checked },
            { id: 4, value: document.getElementById('e4Value').checked },
            { id: 5, value: document.getElementById('e5Value').checked }
        ];
        
        let successCount = 0;
        let failedEvidence = null;
        
        // Invia tutte le evidenze in sequenza
        for (const evidence of evidences) {
            try {
                console.log(`Invio evidenza E${evidence.id}: ${evidence.value}`);
                
                await contract.methods.inviaEvidenza(shipmentId, evidence.id, evidence.value)
                    .send({ from: currentAccount, gas: 150000 });
                
                successCount++;
                
                // Aggiorna il messaggio di loading
                showLoading(`Evidenze inviate: ${successCount}/5...`);
                
            } catch (error) {
                console.error(`Errore invio E${evidence.id}:`, error);
                failedEvidence = evidence.id;
                break; // Ferma se c'è un errore
            }
        }
        
        hideLoading();
        
        if (successCount === 5) {
            showToast('✅ Tutte le 5 evidenze inviate con successo!', 'success');
        } else {
            showToast(`⚠️ Inviate ${successCount}/5 evidenze. Errore su E${failedEvidence}`, 'error');
        }
        
        // Reload shipments
        await loadShipments();
        
    } catch (error) {
        console.error('Errore:', error);
        showToast(`Errore: ${error.message}`, 'error');
        hideLoading();
    }
}

// ===== VALIDATE AND PAY =====
async function validateAndPay() {
    if (!contract || !currentAccount) {
        showToast('Connetti prima il wallet', 'error');
        return;
    }
    
    try {
        showLoading('Validazione e pagamento in corso...');
        
        const shipmentId = document.getElementById('shipmentIdCourier').value;
        
        if (!shipmentId || shipmentId.trim() === '') {
            showToast('Inserisci l\'ID della spedizione', 'error');
            hideLoading();
            return;
        }
        
        // Verifica lo stato della spedizione prima di procedere
        console.log('Verifica spedizione ID:', shipmentId);
        const shipment = await contract.methods.spedizioni(shipmentId).call();
        console.log('Dati spedizione:', shipment);
        console.log('Account corrente:', currentAccount);
        console.log('Corriere spedizione:', shipment.corriere);
        console.log('Stato spedizione:', shipment.stato);
        console.log('Evidenze:', shipment.evidenze);
        
        // Verifica che sei il corriere
        if (shipment.corriere.toLowerCase() !== currentAccount.toLowerCase()) {
            showToast('Solo il corriere può validare e ricevere il pagamento', 'error');
            hideLoading();
            return;
        }
        
        // Verifica che tutte le evidenze siano state inviate
        const allEvidencesReceived = 
            shipment.evidenze.E1_ricevuta && 
            shipment.evidenze.E2_ricevuta && 
            shipment.evidenze.E3_ricevuta && 
            shipment.evidenze.E4_ricevuta && 
            shipment.evidenze.E5_ricevuta;
        
        if (!allEvidencesReceived) {
            showToast('Non tutte le evidenze sono state inviate', 'error');
            hideLoading();
            return;
        }
        
        const receipt = await contract.methods.validaEPaga(shipmentId)
            .send({ from: currentAccount, gas: 500000 });
        
        // Get payment event
        const event = receipt.events.SpedizionePagata;
        const amount = web3.utils.fromWei(event.returnValues.importo, 'ether');
        
        showToast(`Pagamento di ${amount} ETH ricevuto con successo!`, 'success');
        
        // Clear form
        document.getElementById('shipmentIdCourier').value = '';
        
        // Reload shipments
        await loadShipments();
        hideLoading();
    } catch (error) {
        console.error('Errore completo:', error);
        
        // Estrai il messaggio di errore reale dal contratto
        let errorMessage = error.message;
        if (error.message.includes('revert')) {
            const match = error.message.match(/revert (.+?)"/);
            if (match) {
                errorMessage = match[1];
            }
        }
        
        showToast(`Errore: ${errorMessage}`, 'error');
        hideLoading();
    }
}

// ===== LOAD SHIPMENTS =====
async function loadShipments() {
    if (!contract) return;
    
    try {
        const shipmentsGrid = document.getElementById('shipmentsGrid');
        shipmentsGrid.innerHTML = '';
        
        // Get shipment counter
        const counter = await contract.methods._contatoreIdSpedizione().call();
        const totalShipments = Number(counter);
        
        console.log('Contatore spedizioni:', totalShipments);
        
        if (totalShipments === 0) {
            shipmentsGrid.innerHTML = `
                <div class="empty-state">
                    <div class="empty-icon">📭</div>
                    <h3>Nessuna spedizione trovata</h3>
                    <p>Crea una nuova spedizione per iniziare</p>
                </div>
            `;
            return;
        }
        
        // Load all shipments
        for (let i = 1; i <= totalShipments; i++) {
            console.log('Caricamento spedizione ID:', i);
            const shipment = await contract.methods.spedizioni(i).call();
            console.log('Spedizione caricata:', shipment);
            renderShipmentCard(i, shipment);
        }
    } catch (error) {
        console.error('Errore caricamento spedizioni:', error);
        showToast(`Errore caricamento spedizioni: ${error.message}`, 'error');
    }
}

// ===== RENDER SHIPMENT CARD =====
function renderShipmentCard(id, shipment) {
    const shipmentsGrid = document.getElementById('shipmentsGrid');
    
    // Remove empty state if present
    const emptyState = shipmentsGrid.querySelector('.empty-state');
    if (emptyState) {
        emptyState.remove();
    }
    
    const statusText = (shipment.stato == 0 || shipment.stato === '0') ? 'In Attesa' : 'Pagata';
    const statusClass = (shipment.stato == 0 || shipment.stato === '0') ? 'in-attesa' : 'pagata';
    
    const evidences = shipment.evidenze;
    const evidenceFields = ['E1_ricevuta', 'E2_ricevuta', 'E3_ricevuta', 'E4_ricevuta', 'E5_ricevuta'];
    const evidenceHTML = ['E1', 'E2', 'E3', 'E4', 'E5'].map((name, index) => {
        const received = evidences[evidenceFields[index]]; // Access by field name
        const className = received ? 'received' : 'pending';
        return `<div class="evidence-indicator ${className}">${name}</div>`;
    }).join('');
    
    const card = document.createElement('div');
    card.className = 'shipment-card';
    card.innerHTML = `
        <div class="shipment-header">
            <div class="shipment-id">Spedizione #${id}</div>
            <span class="status-badge ${statusClass}">${statusText}</span>
        </div>
        <div class="shipment-info">
            <div class="info-row">
                <span class="info-label">Mittente:</span>
                <span class="info-value">${shipment.mittente.substring(0, 10)}...</span>
            </div>
            <div class="info-row">
                <span class="info-label">Corriere:</span>
                <span class="info-value">${shipment.corriere.substring(0, 10)}...</span>
            </div>
            <div class="info-row">
                <span class="info-label">Importo:</span>
                <span class="info-value">${web3.utils.fromWei(shipment.importoPagamento, 'ether')} ETH</span>
            </div>
        </div>
        <div class="evidence-status">
            <h4>Stato Evidenze</h4>
            <div class="evidence-indicators">
                ${evidenceHTML}
            </div>
        </div>
    `;
    
    shipmentsGrid.appendChild(card);
}

// ===== FILTER SHIPMENTS =====
function filterShipments() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('filterStatus').value;
    
    const cards = document.querySelectorAll('.shipment-card');
    
    cards.forEach(card => {
        const text = card.textContent.toLowerCase();
        const status = card.querySelector('.status-badge').classList.contains('in-attesa') ? 'InAttesa' : 'Pagata';
        
        const matchesSearch = text.includes(searchTerm);
        const matchesStatus = statusFilter === 'all' || status === statusFilter;
        
        card.style.display = matchesSearch && matchesStatus ? 'block' : 'none';
    });
}

// ===== TOAST NOTIFICATIONS =====
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    
    const icons = {
        success: '✅',
        error: '❌',
        info: 'ℹ️'
    };
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div class="toast-icon">${icons[type]}</div>
        <div class="toast-message">${message}</div>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s ease-out reverse';
        setTimeout(() => toast.remove(), 300);
    }, 5000);
}

// ===== LOADING OVERLAY =====
function showLoading(text = 'Elaborazione in corso...') {
    const overlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');
    loadingText.textContent = text;
    overlay.classList.add('active');
}

function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    overlay.classList.remove('active');
}
