/**
 * @file contract-interaction.js
 * @description Gestisce tutte le interazioni con lo smart contract
 */

import { getWeb3, getCurrentAccount } from './web3-connection.js';

const CONTRACT_ABI_PATH = './BNCalcolatoreOnChain.json';

// ===== STATE =====
export let contract;
export let contractAddress;

// ===== LOAD CONTRACT =====
export async function loadContract() {
    try {
        console.log('Caricamento contratto...');
        const web3 = getWeb3();
        
        if (!web3) {
            throw new Error('Web3 non inizializzato');
        }
        
        // Fetch contract artifact
        const response = await fetch(CONTRACT_ABI_PATH);
        if (!response.ok) {
            throw new Error(`Impossibile caricare il contratto: ${response.statusText}`);
        }
        
        const contractData = await response.json();
        
        // Get network ID
        const networkId = await web3.eth.net.getId();
        const networkIdStr = networkId.toString();
        
        // Get contract address
        if (contractData.networks[networkIdStr] || contractData.networks[networkId]) {
            const networkData = contractData.networks[networkIdStr] || contractData.networks[networkId];
            contractAddress = networkData.address;
            contract = new web3.eth.Contract(contractData.abi, contractAddress);
            
            console.log('Contratto caricato:', contractAddress);
            return { success: true, address: contractAddress };
        } else {
            const availableNetworks = Object.keys(contractData.networks).join(', ');
            throw new Error(`Contratto non deployato sulla rete ${networkIdStr}. Esegui 'truffle migrate --reset'`);
        }
    } catch (error) {
        console.error('Errore caricamento contratto:', error);
        return { success: false, error: error.message };
    }
}

// ===== ADMIN FUNCTIONS =====
export async function setPriorProbabilities(pF1T, pF2T) {
    const account = getCurrentAccount();
    return await contract.methods.impostaProbabilitaAPriori(pF1T, pF2T)
        .send({ from: account, gas: 200000 });
}

export async function setCPT(evidenceId, cpt) {
    const account = getCurrentAccount();
    return await contract.methods.impostaCPT(evidenceId, cpt)
        .send({ from: account, gas: 200000 });
}

// ===== MITTENTE FUNCTIONS =====
export async function createShipment(courierAddress, paymentAmount) {
    const account = getCurrentAccount();
    const web3 = getWeb3();
    const weiAmount = web3.utils.toWei(paymentAmount, 'ether');
    
    return await contract.methods.creaSpedizione(courierAddress)
        .send({ from: account, value: weiAmount, gas: 500000 });
}

// ===== NEW REFUND FUNCTIONS =====
export async function cancelShipment(shipmentId) {
    const account = getCurrentAccount();
    return await contract.methods.annullaSpedizione(shipmentId)
        .send({ from: account, gas: 200000 });
}

export async function requestRefund(shipmentId) {
    const account = getCurrentAccount();
    return await contract.methods.richiediRimborso(shipmentId)
        .send({ from: account, gas: 300000 });
}

// ===== SENSOR FUNCTIONS =====
export async function sendEvidence(shipmentId, evidenceId, value) {
    const account = getCurrentAccount();
    return await contract.methods.inviaEvidenza(shipmentId, evidenceId, value)
        .send({ from: account, gas: 150000 });
}

// ===== COURIER FUNCTIONS =====
export async function validateAndPay(shipmentId) {
    const account = getCurrentAccount();
    return await contract.methods.validaEPaga(shipmentId)
        .send({ from: account, gas: 800000 }); // Increased from 500000
}

export async function checkValidity(shipmentId) {
    return await contract.methods.verificaValidita(shipmentId).call();
}

// ===== QUERY FUNCTIONS =====
export async function getShipment(shipmentId) {
    return await contract.methods.spedizioni(shipmentId).call();
}

export async function getShipmentCounter() {
    return await contract.methods._contatoreIdSpedizione().call();
}

export async function getTimeoutValue() {
    // TIMEOUT_RIMBORSO = 7 days in Solidity = 7 * 24 * 60 * 60 = 604800 seconds
    // Public constants in Solidity may not always generate getter functions in all versions
    // Using hardcoded value for reliability
    return 604800; // 7 days in seconds
}

export function getContract() {
    return contract;
}

export function getContractAddress() {
    return contractAddress;
}

// ===== ROLE DETECTION FUNCTIONS =====
/**
 * Checks if an account has a specific role
 * @param {string} roleHash - The keccak256 hash of the role name
 * @param {string} account - The account address to check
 * @returns {Promise<boolean>} True if account has the role
 */
export async function hasRole(roleHash, account) {
    try {
        return await contract.methods.hasRole(roleHash, account).call();
    } catch (error) {
        console.error('Error checking role:', error);
        return false;
    }
}

/**
 * Gets all role hashes from the contract
 * Role hashes are keccak256 of role names like "RUOLO_MITTENTE"
 */
export function getRoleHashes() {
    const web3 = getWeb3();
    return {
        DEFAULT_ADMIN_ROLE: '0x0000000000000000000000000000000000000000000000000000000000000000',
        RUOLO_ORACOLO: web3.utils.keccak256('RUOLO_ORACOLO'),
        RUOLO_MITTENTE: web3.utils.keccak256('RUOLO_MITTENTE'),
        RUOLO_SENSORE: web3.utils.keccak256('RUOLO_SENSORE')
    };
}

/**
 * Gets all roles for a specific account
 * @param {string} account - The account address
 * @returns {Promise<Array<string>>} Array of role names
 */
export async function getUserRoles(account) {
    const roleHashes = getRoleHashes();
    const roles = [];
    
    // Check each role
    if (await hasRole(roleHashes.DEFAULT_ADMIN_ROLE, account)) {
        roles.push('admin');
    }
    if (await hasRole(roleHashes.RUOLO_ORACOLO, account)) {
        roles.push('oracolo');
    }
    if (await hasRole(roleHashes.RUOLO_MITTENTE, account)) {
        roles.push('mittente');
    }
    if (await hasRole(roleHashes.RUOLO_SENSORE, account)) {
        roles.push('sensore');
    }
    
    return roles;
}

/**
 * Checks if account is admin
 */
export async function isAdmin(account) {
    const roleHashes = getRoleHashes();
    return await hasRole(roleHashes.DEFAULT_ADMIN_ROLE, account) || 
           await hasRole(roleHashes.RUOLO_ORACOLO, account);
}

/**
 * Checks if account has mittente role
 */
export async function isMittente(account) {
    const roleHashes = getRoleHashes();
    return await hasRole(roleHashes.RUOLO_MITTENTE, account);
}

/**
 * Checks if account has sensore role
 */
export async function isSensore(account) {
    const roleHashes = getRoleHashes();
    return await hasRole(roleHashes.RUOLO_SENSORE, account);
}
