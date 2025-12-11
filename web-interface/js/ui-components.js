/**
 * @file ui-components.js
 * @description Gestisce il rendering e aggiornamento dei componenti UI
 */

import { getCurrentAccount } from './web3-connection.js';
import { getWeb3 } from './web3-connection.js';

// ===== TOAST NOTIFICATIONS =====
export function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    
    const icons = {
        success: '✅',
        error: '❌',
        info: 'ℹ️',
        warning: '⚠️'
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
export function showLoading(text = 'Elaborazione in corso...') {
    const overlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');
    loadingText.textContent = text;
    overlay.classList.add('active');
}

export function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    overlay.classList.remove('active');
}

// ===== UPDATE UI =====
export function updateAccountUI() {
    const account = getCurrentAccount();
    const accountElement = document.getElementById('accountAddress');
    
    if (account) {
        accountElement.textContent = `${account.substring(0, 6)}...${account.substring(38)}`;
        document.getElementById('connectWallet').textContent = 'Connesso';
        document.getElementById('connectWallet').disabled = true;
    }
}

export function updateNetworkStatus(connected, networkId) {
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

// ===== SHIPMENT RENDERING =====
export function renderShipmentCard(id, shipment) {
    const shipmentsGrid = document.getElementById('shipmentsGrid');
    const web3 = getWeb3();
    
    // Remove empty state
    const emptyState = shipmentsGrid.querySelector('.empty-state');
    if (emptyState) {
        emptyState.remove();
    }
    
    // Map numeric state to string
    const stateMap = ['InAttesa', 'Pagata', 'Annullata', 'Rimborsata'];
    const statusText = stateMap[shipment.stato] || 'Sconosciuto';
    const statusClass = statusText.toLowerCase().replace(/\s/g, '-');
    
    const evidences = shipment.evidenze;
    const evidenceFields = ['E1_ricevuta', 'E2_ricevuta', 'E3_ricevuta', 'E4_ricevuta', 'E5_ricevuta'];
    const evidenceValues = ['E1_valore', 'E2_valore', 'E3_valore', 'E4_valore', 'E5_valore'];
    const goodValues = [true, true, false, false, true];
    
    const evidenceHTML = ['E1', 'E2', 'E3', 'E4', 'E5'].map((name, index) => {
        const received = evidences[evidenceFields[index]];
        const value = evidences[evidenceValues[index]];
        
        if (!received) {
            return `<div class="evidence-indicator pending">${name}</div>`;
        }
        
        const isGood = value === goodValues[index];
        const className = isGood ? 'received good' : 'received bad';
        const icon = isGood ? '✓' : '✗';
        
        return `<div class="evidence-indicator ${className}">${name} ${icon}</div>`;
    }).join('');
    
    // Calculate days elapsed and format date
    const creationTime = Number(shipment.timestampCreazione);
    const now = Math.floor(Date.now() / 1000);
    const daysElapsed = Math.floor((now - creationTime) / 86400);
    const creationDate = new Date(creationTime * 1000).toLocaleString('it-IT', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    
    const card = document.createElement('div');
    card.className = 'shipment-card';
    card.dataset.shipmentId = id;
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
            <div class="info-row">
                <span class="info-label">Data creazione:</span>
                <span class="info-value">${creationDate}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Giorni trascorsi:</span>
                <span class="info-value">${daysElapsed} giorni</span>
            </div>
            ${shipment.tentativiValidazioneFalliti > 0 ? `
            <div class="info-row">
                <span class="info-label">Tentativi falliti:</span>
                <span class="info-value warning">${shipment.tentativiValidazioneFalliti}</span>
            </div>
            ${shipment.tentativiValidazioneFalliti >= 3 && shipment.stato == 0 ? `
            <div class="failed-attempts-badge">⚠️ Rimborso disponibile (3+ tentativi falliti)</div>
            ` : ''}
            ` : ''}
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

export function clearShipmentsGrid() {
    const shipmentsGrid = document.getElementById('shipmentsGrid');
    shipmentsGrid.innerHTML = `
        <div class="empty-state">
            <div class="empty-icon">📭</div>
            <h3>Nessuna spedizione trovata</h3>
            <p>Crea una nuova spedizione per iniziare</p>
        </div>
    `;
}

// ===== PANEL MANAGEMENT =====
export function showPanel(panelId) {
    // Hide all panels
    document.querySelectorAll('.panel').forEach(panel => {
        panel.style.display = 'none';
    });
    
    // Show selected panel
    if (panelId) {
        document.getElementById(panelId).style.display = 'block';
    }
}

export function updateRoleSelection(role) {
    // Update active state
    document.querySelectorAll('.role-card').forEach(card => {
        card.classList.remove('active');
    });
    document.querySelector(`.role-card[data-role="${role}"]`)?.classList.add('active');
    
    // Panel mapping
    const panelMap = {
        'admin': 'adminPanel',
        'mittente': 'mittentePanel',  // NEW: now separate panel
        'sensore': 'sensorPanel',
        'corriere': 'courierPanel'
    };
    
    showPanel(panelMap[role]);
}

// ===== ROLE BADGE DISPLAY =====
export function updateRoleBadges(roles) {
    const container = document.getElementById('roleBadges');
    if (!container) return;
    
    container.innerHTML = '';
    
    const roleIcons = {
        'admin': '👑',
        'oracolo': '🔮',
        'mittente': '📦',
        'sensore': '📡',
        'corriere': '🚚'
    };
    
    const roleLabels = {
        'admin': 'Admin',
        'oracolo': 'Oracolo',
        'mittente': 'Mittente',
        'sensore': 'Sensore',
        'corriere': 'Corriere'
    };
    
    // If no contract roles, show Corriere (since anyone can be a courier)
    if (roles.length === 0) {
        const badge = document.createElement('span');
        badge.className = 'role-badge role-corriere';
        badge.textContent = '🚚 Corriere';
        container.appendChild(badge);
        return;
    }
    
    roles.forEach(role => {
        const badge = document.createElement('span');
        badge.className = `role-badge role-${role}`;
        badge.textContent = `${roleIcons[role] || '🔑'} ${roleLabels[role] || role}`;
        container.appendChild(badge);
    });
}

// ===== PANEL FILTERING BY ROLE =====
export function filterPanelsByRole(roles) {
    const isAdminUser = roles.includes('admin') || roles.includes('oracolo');
    
    // Hide all role cards first
    document.querySelectorAll('.role-card').forEach(card => {
        card.style.display = 'none';
    });
    
    // Admin sees everything
    if (isAdminUser) {
        document.querySelectorAll('.role-card').forEach(card => {
            card.style.display = 'block';
        });
        return;
    }
    
    // Show only cards for roles user has
    if (roles.includes('mittente')) {
        const mittenteCard = document.querySelector('.role-card[data-role="mittente"]');
        if (mittenteCard) mittenteCard.style.display = 'block';
    }
    
    if (roles.includes('sensore')) {
        const sensoreCard = document.querySelector('.role-card[data-role="sensore"]');
        if (sensoreCard) sensoreCard.style.display = 'block';
    }
    
    // Show Corriere card ONLY if user has no specific roles
    // (i.e., they are just a courier without Mittente/Sensore roles)
    const hasSpecificRole = roles.includes('mittente') || roles.includes('sensore');
    if (!hasSpecificRole) {
        const corriereCard = document.querySelector('.role-card[data-role="corriere"]');
        if (corriereCard) corriereCard.style.display = 'block';
    }
}




