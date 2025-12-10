/**
 * @file web3-connection.js
 * @description Gestisce la connessione a Web3, MetaMask e la rete blockchain
 */

// ===== STATE =====
export let web3;
export let currentAccount;
export let networkId;
export let accounts = [];

// ===== INITIALIZATION =====
export async function initWeb3() {
    try {
        if (typeof window.ethereum !== 'undefined') {
            web3 = new Web3(window.ethereum);
            console.log('MetaMask rilevato');
            return { success: true, provider: 'MetaMask' };
        } else {
            // Fallback to Ganache
            const GANACHE_URL = 'http://127.0.0.1:7545';
            web3 = new Web3(new Web3.providers.HttpProvider(GANACHE_URL));
            console.log('MetaMask non trovato, connessione a Ganache...');
            return { success: true, provider: 'Ganache' };
        }
    } catch (error) {
        console.error('Errore inizializzazione Web3:', error);
        return { success: false, error: error.message };
    }
}

// ===== CONNECT WALLET =====
export async function connectWallet() {
    try {
        if (typeof window.ethereum !== 'undefined') {
            // Request account access
            accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            currentAccount = accounts[0];
            
            // Remove old listeners
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
        }
        
        return { success: true, account: currentAccount };
    } catch (error) {
        console.error('Errore connessione wallet:', error);
        return { success: false, error: error.message };
    }
}

// ===== EVENT HANDLERS =====
function handleAccountsChanged(newAccounts) {
    if (newAccounts.length === 0) {
        currentAccount = null;
        window.dispatchEvent(new CustomEvent('walletDisconnected'));
    } else {
        currentAccount = newAccounts[0];
        window.dispatchEvent(new CustomEvent('accountChanged', { detail: { account: currentAccount } }));
    }
}

function handleChainChanged(chainId) {
    console.log('Chain cambiata:', chainId);
    window.dispatchEvent(new CustomEvent('chainChanged', { detail: { chainId } }));
}

// ===== NETWORK INFO =====
export async function getNetworkId() {
    if (!web3) return null;
    
    try {
        networkId = await web3.eth.net.getId();
        return networkId;
    } catch (error) {
        console.error('Errore getting network ID:', error);
        return null;
    }
}

export function getWeb3() {
    return web3;
}

export function getCurrentAccount() {
    return currentAccount;
}
