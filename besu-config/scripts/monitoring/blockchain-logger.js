/**
 * Blockchain Logger - Sistema di logging avanzato per rete Besu
 * 
 * Fornisce logging strutturato per:
 * - Deployment contratti
 * - Transazioni con dettagli gas/ETH
 * - Report aggregati
 * - Export JSON per analisi
 */

const fs = require('fs');
const path = require('path');

const LOG_DIR = path.join(__dirname, '..', '..', 'logs');

// Crea directory logs se non esiste
if (!fs.existsSync(LOG_DIR)) {
    fs.mkdirSync(LOG_DIR, { recursive: true });
}

// File di log - TUTTI IN FORMATO .TXT
const LOG_FILES = {
    deployment: path.join(LOG_DIR, 'deployment.txt'),           // Deploy contratti
    transactions: path.join(LOG_DIR, 'transactions.txt'),       // Transazioni generiche
    gasReport: path.join(LOG_DIR, 'gas_report.txt'),            // Report gas CSV
    network: path.join(LOG_DIR, 'network_traffic.txt'),         // Traffico rete/failover
    sessionJson: path.join(LOG_DIR, 'session_summary.json'),    // Summary JSON
    errors: path.join(LOG_DIR, 'errors.txt')                    // Errori
};

// Stato sessione corrente
let currentSession = {
    sessionId: null,
    chainId: null,
    deployer: null,
    startTime: null,
    contract: null,
    transactions: [],
    totals: {
        count: 0,
        gasUsed: 0,
        costEth: 0,
        valueTransferred: 0
    }
};

/**
 * Formatta un numero grande con separatori migliaia
 */
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

/**
 * Converte Wei in ETH con precisione
 */
function weiToEth(wei) {
    const weiBigInt = typeof wei === 'bigint' ? wei : BigInt(wei || 0);
    return Number(weiBigInt) / 1e18;
}

/**
 * Converte Wei in Gwei
 */
function weiToGwei(wei) {
    const weiBigInt = typeof wei === 'bigint' ? wei : BigInt(wei || 0);
    return Number(weiBigInt) / 1e9;
}

/**
 * Timestamp formattato in italiano (Europa/Roma)
 */
function getTimestamp() {
    return new Date().toLocaleString('it-IT', { 
        timeZone: 'Europe/Rome',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
}

/**
 * Timestamp solo orario in italiano
 */
function getTimeOnly() {
    return new Date().toLocaleTimeString('it-IT', { 
        timeZone: 'Europe/Rome',
        hour12: false 
    });
}

/**
 * Scrive su file di log
 */
function writeToLog(file, content) {
    try {
        fs.appendFileSync(file, content);
    } catch (e) {
        console.error(`[Logger] Errore scrittura log: ${e.message}`);
    }
}

/**
 * Inizia una nuova sessione di deployment
 */
function startDeploymentSession(chainId, deployerAddress, initialBalance) {
    currentSession = {
        sessionId: getTimestamp(),
        chainId: chainId,
        deployer: deployerAddress,
        initialBalance: weiToEth(initialBalance),
        startTime: Date.now(),
        contract: null,
        transactions: [],
        totals: {
            count: 0,
            gasUsed: 0,
            costEth: 0,
            valueTransferred: 0
        }
    };

    const header = `
================================================================================
📦 DEPLOYMENT SESSION - ${currentSession.sessionId}
================================================================================
Chain ID:        ${chainId}
Deployer:        ${deployerAddress}
Initial Balance: ${currentSession.initialBalance.toFixed(6)} ETH
================================================================================

`;
    writeToLog(LOG_FILES.deployment, header);
    console.log(`[Logger] 📝 Sessione deployment iniziata: ${currentSession.sessionId}`);
    
    // Inizializza header CSV se file vuoto
    if (!fs.existsSync(LOG_FILES.gasReport) || fs.statSync(LOG_FILES.gasReport).size === 0) {
        const csvHeader = 'timestamp,type,hash,method,from,to,gas_used,gas_price_gwei,cost_eth,value_eth,block,status,duration_ms\n';
        writeToLog(LOG_FILES.gasReport, csvHeader);
    }

    return currentSession.sessionId;
}

/**
 * Registra un deployment di contratto
 */
function logContractDeployment(receipt, contractName, contractAddress, startTime) {
    const duration = Date.now() - startTime;
    const gasUsed = parseInt(receipt.gasUsed);
    const gasPrice = parseInt(receipt.effectiveGasPrice || '1000000000');
    const costWei = BigInt(gasUsed) * BigInt(gasPrice);
    const costEth = weiToEth(costWei);

    currentSession.contract = {
        name: contractName,
        address: contractAddress
    };

    currentSession.transactions.push({
        type: 'DEPLOY',
        hash: receipt.transactionHash,
        method: 'constructor',
        gasUsed: gasUsed,
        costEth: costEth,
        block: parseInt(receipt.blockNumber),
        duration: duration
    });

    currentSession.totals.count++;
    currentSession.totals.gasUsed += gasUsed;
    currentSession.totals.costEth += costEth;

    // Log formattato
    const logEntry = `[${getTimeOnly()}] 📄 CONTRACT DEPLOYMENT: ${contractName}
           Hash:     ${receipt.transactionHash}
           Address:  ${contractAddress}
           Gas Used: ${formatNumber(gasUsed)}
           Gas Cost: ${costEth.toFixed(8)} ETH
           Duration: ${(duration / 1000).toFixed(1)}s

`;
    writeToLog(LOG_FILES.deployment, logEntry);

    // CSV entry
    const csvEntry = `${getTimestamp()},DEPLOY,${receipt.transactionHash},constructor,${receipt.from},${contractAddress},${gasUsed},${weiToGwei(gasPrice)},${costEth.toFixed(12)},0,${parseInt(receipt.blockNumber)},SUCCESS,${duration}\n`;
    writeToLog(LOG_FILES.gasReport, csvEntry);

    console.log(`[Logger] 📄 Contract deployed: ${contractName} | Gas: ${formatNumber(gasUsed)} | Cost: ${costEth.toFixed(6)} ETH`);
}

/**
 * Registra una transazione generica
 */
function logTransaction(receipt, methodName, valueWei = 0, startTime = null) {
    const duration = startTime ? Date.now() - startTime : 0;
    const gasUsed = parseInt(receipt.gasUsed);
    const gasPrice = parseInt(receipt.effectiveGasPrice || '1000000000');
    const costWei = BigInt(gasUsed) * BigInt(gasPrice);
    const costEth = weiToEth(costWei);
    const valueEth = weiToEth(valueWei);
    // Web3.js v4 restituisce status come true/false, 1n/0n, oppure 1/0
    const status = (receipt.status === true || receipt.status === 1 || receipt.status === 1n || receipt.status === '0x1') ? 'SUCCESS' : 'FAILED';

    currentSession.transactions.push({
        type: 'TX',
        hash: receipt.transactionHash,
        method: methodName,
        gasUsed: gasUsed,
        costEth: costEth,
        valueEth: valueEth,
        block: parseInt(receipt.blockNumber),
        status: status,
        duration: duration
    });

    currentSession.totals.count++;
    currentSession.totals.gasUsed += gasUsed;
    currentSession.totals.costEth += costEth;
    currentSession.totals.valueTransferred += valueEth;

    // Log formattato
    const valueStr = valueEth > 0 ? `\n           Value:    ${valueEth.toFixed(6)} ETH` : '';
    const logEntry = `[${getTimeOnly()}] ➡️ TRANSACTION: ${methodName}
           Hash:     ${receipt.transactionHash}
           Status:   ${status}
           Gas Used: ${formatNumber(gasUsed)}
           Gas Cost: ${costEth.toFixed(8)} ETH${valueStr}

`;
    writeToLog(LOG_FILES.deployment, logEntry);

    // CSV entry
    const csvEntry = `${getTimestamp()},TX,${receipt.transactionHash},${methodName},${receipt.from},${receipt.to},${gasUsed},${weiToGwei(gasPrice)},${costEth.toFixed(12)},${valueEth.toFixed(12)},${parseInt(receipt.blockNumber)},${status},${duration}\n`;
    writeToLog(LOG_FILES.gasReport, csvEntry);

    console.log(`[Logger] ➡️ TX ${methodName} | Gas: ${formatNumber(gasUsed)} | Cost: ${costEth.toFixed(6)} ETH`);
}

/**
 * Registra una transazione intercettata dal proxy (formato receipt Besu)
 */
/**
 * Registra una transazione intercettata dal proxy (formato receipt Besu)
 */
function logProxyTransaction(receipt, valueWei = 0) {
    const gasUsed = parseInt(receipt.gasUsed, 16);
    const gasPrice = receipt.effectiveGasPrice ? parseInt(receipt.effectiveGasPrice, 16) : 1000000000;
    const costWei = BigInt(gasUsed) * BigInt(gasPrice);
    const costEth = weiToEth(costWei);
    const valueEth = weiToEth(valueWei);
    const status = receipt.status === '0x1' ? 'SUCCESS' : 'FAILED';
    const blockNumber = parseInt(receipt.blockNumber, 16);
    
    // Determina tipo transazione
    let txType = 'TX';
    let target = receipt.to;
    if (!receipt.to && receipt.contractAddress) {
        txType = 'DEPLOY';
        target = receipt.contractAddress;
    }

    // Log dettagliato nel file transazioni
    const separator = '─'.repeat(80);
    const valueStr = valueEth > 0 ? `Value:        ${valueEth.toFixed(6)} ETH\n` : '';
    
    const logEntry = `
${separator}
[${getTimestamp()}] ${txType === 'DEPLOY' ? '📄 CONTRACT DEPLOYMENT' : '➡️ TRANSACTION'}
${separator}
Status:       ${status}
Hash:         ${receipt.transactionHash}
Block:        ${blockNumber}
From:         ${receipt.from}
To:           ${target}
${valueStr}Gas Used:     ${formatNumber(gasUsed)}
Gas Price:    ${formatNumber(gasPrice)} wei (${weiToGwei(gasPrice).toFixed(2)} Gwei)
Total Cost:   ${costEth.toFixed(12)} ETH
${separator}
`;
    writeToLog(LOG_FILES.transactions, logEntry);

    // CSV entry
    const csvEntry = `${getTimestamp()},${txType},${receipt.transactionHash},unknown,${receipt.from},${target},${gasUsed},${weiToGwei(gasPrice)},${costEth.toFixed(12)},${valueEth.toFixed(12)},${blockNumber},${status},0\n`;
    writeToLog(LOG_FILES.gasReport, csvEntry);

    return {
        type: txType,
        gasUsed: gasUsed,
        costEth: costEth,
        valueEth: valueEth,
        status: status
    };
}

/**
 * Chiude la sessione di deployment e genera il summary
 */
function endDeploymentSession(finalBalance) {
    const totalDuration = (Date.now() - currentSession.startTime) / 1000;
    const finalBalanceEth = weiToEth(finalBalance);

    // Summary formattato
    const summary = `
================================================================================
📊 DEPLOYMENT SUMMARY
================================================================================
Total Transactions: ${currentSession.totals.count}
Total Gas Used:     ${formatNumber(currentSession.totals.gasUsed)}
Total Cost:         ${currentSession.totals.costEth.toFixed(8)} ETH
Total Duration:     ${totalDuration.toFixed(1)}s
Final Balance:      ${finalBalanceEth.toFixed(6)} ETH
Balance Change:     -${(currentSession.initialBalance - finalBalanceEth).toFixed(6)} ETH
================================================================================

`;
    writeToLog(LOG_FILES.deployment, summary);

    // JSON summary
    const jsonSummary = {
        sessionId: currentSession.sessionId,
        chainId: currentSession.chainId,
        deployer: currentSession.deployer,
        initialBalance: currentSession.initialBalance,
        finalBalance: finalBalanceEth,
        contract: currentSession.contract,
        transactions: currentSession.transactions,
        totals: {
            count: currentSession.totals.count,
            gasUsed: currentSession.totals.gasUsed,
            costEth: currentSession.totals.costEth,
            valueTransferred: currentSession.totals.valueTransferred,
            durationSeconds: totalDuration
        }
    };

    // BigInt non è serializzabile in JSON, quindi convertiamo a stringa
    const jsonString = JSON.stringify(jsonSummary, (key, value) =>
        typeof value === 'bigint' ? value.toString() : value
    , 2);
    fs.writeFileSync(LOG_FILES.sessionJson, jsonString);
    
    console.log(`[Logger] 📊 Sessione completata: ${currentSession.totals.count} TX | Gas: ${formatNumber(currentSession.totals.gasUsed)} | Cost: ${currentSession.totals.costEth.toFixed(6)} ETH`);

    return jsonSummary;
}

/**
 * Log di rete/proxy
 */
function logNetwork(message) {
    const logLine = `[${getTimestamp()}] ${message}\n`;
    writeToLog(LOG_FILES.network, logLine);
}

/**
 * Esporta le funzioni
 */
module.exports = {
    LOG_FILES,
    startDeploymentSession,
    logContractDeployment,
    logTransaction,
    logProxyTransaction,
    endDeploymentSession,
    logNetwork,
    formatNumber,
    weiToEth,
    weiToGwei,
    getTimestamp
};
