const http = require('http');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Import Logger Avanzato
const logger = require('./blockchain-logger');

console.log('>>> PROXY VERSION: 2.1 - DEBUG ENABLED <<<');

// Configurazione
const LISTENING_PORT = 8545;
const NODES = [
    { name: 'Node 1', port: 8551 },
    { name: 'Node 2', port: 8546 },
    { name: 'Node 3', port: 8547 },
    { name: 'Node 4', port: 8548 }
];

let currentNodeIndex = 0;

// Usa i file di log dal logger centralizzato
const LOG_FILE = logger.LOG_FILES.network;
const TX_LOG_FILE = logger.LOG_FILES.transactions;

function logToFile(file, message) {
    const timestamp = new Date().toISOString();
    const logLine = `[${timestamp}] ${message}\n`;
    try {
        fs.appendFileSync(file, logLine);
    } catch (e) {
        console.error("Error writing to log file:", e.message);
    }
}

// Funzione per testare se un nodo è vivo
function checkNode(port) {
    return new Promise((resolve) => {
        const req = http.request({
            hostname: '127.0.0.1',
            port: port,
            path: '/',
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            timeout: 2000
        }, (res) => {
            resolve(res.statusCode === 200);
        });
        
        req.on('error', () => resolve(false));
        req.on('timeout', () => { req.destroy(); resolve(false); });
        req.write(JSON.stringify({ jsonrpc: '2.0', method: 'eth_blockNumber', params: [], id: 1 }));
        req.end();
    });
}

// Trova il miglior nodo attivo
async function findActiveNode() {
    for (let i = 0; i < NODES.length; i++) {
        const idx = (currentNodeIndex + i) % NODES.length;
        if (await checkNode(NODES[idx].port)) {
            if (idx !== currentNodeIndex) {
                 const msg = `[Proxy] ✅ Switch to ${NODES[idx].name} (Port ${NODES[idx].port})`;
                 console.log(msg);
                 logToFile(LOG_FILE, msg);
            }
            return idx;
        }
    }
    return -1;
}

// Funzione per recuperare receipt E dettagli transazione
function fetchAndLogReceipt(txHash, nodePort, retries = 0) {
    if (retries > 10) { // Aumentati retry a 10
        console.log(`[Log] ⚠️ Receipt non trovata dopo 10 tentativi per ${txHash.substring(0, 20)}...`);
        return;
    }
    
    // 1. Richiedi Receipt
    const requestRpc = (method, params, callback) => {
        const req = http.request({
            hostname: '127.0.0.1',
            port: nodePort,
            path: '/',
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const json = JSON.parse(data);
                    callback(null, json);
                } catch (e) { callback(e, null); }
            });
        });
        req.on('error', (e) => callback(e, null));
        req.write(JSON.stringify({
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: Date.now()
        }));
        req.end();
    };

    // Chain di chiamate: Receipt -> Transaction -> Log
    requestRpc('eth_getTransactionReceipt', [txHash], (err, receiptJson) => {
        if (err || !receiptJson || !receiptJson.result) {
            // Riprova se non c'è ancora la receipt
            setTimeout(() => fetchAndLogReceipt(txHash, nodePort, retries + 1), 2000);
            return;
        }

        const receipt = receiptJson.result;
        
        // 2. Richiedi dettagli Transazione (per avere il Value)
        requestRpc('eth_getTransactionByHash', [txHash], (err, txJson) => {
            let valueWei = '0';
            if (!err && txJson && txJson.result && txJson.result.value) {
                valueWei = txJson.result.value;
            }

            // 3. Logga con tutti i dati
            try {
                // Passiamo anche il value (convertito da hex a stringa decimale o lasciato hex per logger)
                const logResult = logger.logProxyTransaction(receipt, valueWei);
                console.log(`[Log] ${logResult.type} | Value: ${logResult.valueEth.toFixed(4)} ETH | Gas: ${logger.formatNumber(logResult.gasUsed)} | Cost: ${logResult.costEth.toFixed(6)} ETH`);
            } catch (e) {
                console.error(`[ERROR] Logging failed: ${e.message}`);
            }
        });
    });
}


const server = http.createServer(async (clientReq, clientRes) => {
    // Bufferizzare il body della richiesta
    const chunks = [];
    clientReq.on('data', chunk => chunks.push(chunk));
    clientReq.on('end', async () => {
        const bodyBuffer = Buffer.concat(chunks);
        let requestData = {};
        try {
            const bodyString = bodyBuffer.toString();
            if (bodyString) requestData = JSON.parse(bodyString);
        } catch (e) { /* ignore parse error */ }



        const sendRequest = (nodeIndex, isRetry = false) => {
            const targetNode = NODES[nodeIndex];
            
            const options = {
                hostname: '127.0.0.1',
                port: targetNode.port,
                path: clientReq.url,
                method: clientReq.method,
                headers: clientReq.headers
            };
            
            if (options.headers.host) delete options.headers.host;
            options.headers['Content-Length'] = bodyBuffer.length;

            const proxyReq = http.request(options, (proxyRes) => {
                // Intercettiamo le risposte per logging delle transazioni
                const shouldIntercept = requestData.method === 'eth_getTransactionReceipt' || 
                                        requestData.method === 'eth_sendRawTransaction' ||
                                        requestData.method === 'eth_sendTransaction';
                
                if (shouldIntercept) {
                    const resChunks = [];
                    proxyRes.on('data', chunk => resChunks.push(chunk));
                    proxyRes.on('end', () => {
                        const resBuffer = Buffer.concat(resChunks);
                        clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);
                        clientRes.write(resBuffer);
                        clientRes.end();

                        // Decomprimi se gzip e processa
                        const contentEncoding = proxyRes.headers['content-encoding'];
                        
                        const processJsonData = (data) => {
                            try {
                                const responseStr = data.toString().trim();
                                const jsonStart = responseStr.indexOf('{');
                                if (jsonStart >= 0) {
                                    const jsonStr = responseStr.substring(jsonStart);
                                    const responseJson = JSON.parse(jsonStr);
                                    
                                    // Log transazioni - Intercetta Receipt
                                    if (requestData.method === 'eth_getTransactionReceipt' && 
                                        responseJson.result && responseJson.result.transactionHash) {
                                        try {
                                            const receipt = responseJson.result;
                                            const logResult = logger.logProxyTransaction(receipt);
                                            console.log(`[Log] ${logResult.type} | Value: ${logResult.valueEth.toFixed(4)} ETH | Gas: ${logger.formatNumber(logResult.gasUsed)} | Cost: ${logResult.costEth.toFixed(6)} ETH`);
                                        } catch (logErr) {
                                            // Silently ignore log errors or log to file only
                                        }
                                    }
                                    
                                    // Intercetta invio TX per fetch asincrono
                                    if ((requestData.method === 'eth_sendRawTransaction' || 
                                         requestData.method === 'eth_sendTransaction') && 
                                        responseJson.result) {
                                        const txHash = responseJson.result;
                                        // Non logghiamo nulla qui in console per pulizia, il log avverrà al fetch
                                        setTimeout(() => {
                                            fetchAndLogReceipt(txHash, NODES[currentNodeIndex].port);
                                        }, 4000);
                                    }
                                }
                            } catch (e) {
                                // Ignora errori parse
                            }
                        };

                        if (contentEncoding === 'gzip') {
                            zlib.gunzip(resBuffer, (err, decoded) => {
                                if (!err) processJsonData(decoded);
                            });
                        } else {
                            processJsonData(resBuffer);
                        }
                    });
                } else {
                    clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);
                    proxyRes.pipe(clientRes, { end: true });
                }
            });

            proxyReq.on('error', async (e) => {
                const isConnectionRefused = e.code === 'ECONNREFUSED';
                if (!isRetry || isConnectionRefused) {
                     const errMsg = `[Proxy] ⚠️ Errore su ${targetNode.name} (${e.code})...`;
                     console.error(errMsg);
                     logToFile(LOG_FILE, errMsg);
                }

                if (!isRetry) {
                    const newIndex = await findActiveNode();
                    if (newIndex !== -1 && newIndex !== nodeIndex) {
                        currentNodeIndex = newIndex;
                        const retryMsg = `[Proxy] 🔄 Failover a ${NODES[currentNodeIndex].name}... Riprovo richiesta.`;
                        console.log(retryMsg);
                        logToFile(LOG_FILE, retryMsg);
                        sendRequest(currentNodeIndex, true); 
                        return;
                    }
                }
                
                if (!clientRes.headersSent) {
                    clientRes.writeHead(502);
                    clientRes.end(JSON.stringify({error: "Proxy Error: All nodes down or unreachable"}));
                }
            });
            
            proxyReq.on('timeout', () => { proxyReq.destroy(); });
            proxyReq.write(bodyBuffer);
            proxyReq.end();
        };

        const activeIndex = await findActiveNode(); 
        // Se activeIndex è -1, sendRequest fallirà gracefully, o potremmo gestire qui
        if (activeIndex === -1) {
             clientRes.writeHead(503);
             clientRes.end(JSON.stringify({error: "No active nodes"}));
             return;
        }
        
        currentNodeIndex = activeIndex;
        sendRequest(currentNodeIndex);
    });
});

// MONITORAGGIO ATTIVO (Ogni 3 secondi) - Parte dopo 30 secondi per dare tempo ai nodi di avviarsi
console.log('\n[Monitor] In attesa di 30 secondi per avvio nodi...');
setTimeout(async () => {
    console.log('[Monitor] Avvio controllo attivo dei nodi...');
    
    // Primo check - prova tutti i nodi per trovarne uno attivo
    let connectedNode = null;
    for (let i = 0; i < NODES.length; i++) {
        const isAlive = await checkNode(NODES[i].port);
        if (isAlive) {
            connectedNode = NODES[i];
            currentNodeIndex = i;
            break;
        }
    }
    
    if (connectedNode) {
        const successMsg = `[Monitor] ✅ CONNESSIONE RIUSCITA! Nodo attivo: ${connectedNode.name} (Porta ${connectedNode.port})`;
        console.log(successMsg);
        logToFile(LOG_FILE, successMsg);
    } else {
        const errMsg = `[Monitor] ❌ ATTENZIONE: Nessun nodo risponde al primo controllo. Riprovo...`;
        console.log(errMsg);
        logToFile(LOG_FILE, errMsg);
    }

    setInterval(async () => {
        const targetNode = NODES[currentNodeIndex];
        const isAlive = await checkNode(targetNode.port);
        
        if (!isAlive) {
            const warnMsg = `[Monitor] ⚠️ Node ${targetNode.name} (${targetNode.port}) NON RISPONDE!`;
            console.log(warnMsg);
            logToFile(LOG_FILE, warnMsg);
            
            console.log(`[Monitor] 🔄 Avvio failover automatico...`);
            
            const newIndex = await findActiveNode();
            if (newIndex !== -1) {
                 currentNodeIndex = newIndex;
                 // Log switch già fatto da findActiveNode
            } else {
                const errMsg = `[Monitor] ❌ ERRORE: Nessun nodo disponibile!`;
                console.log(errMsg);
                logToFile(LOG_FILE, errMsg);
            }
        }
    }, 3000);
}, 30000); // 30 Secondi di attesa iniziale

server.listen(LISTENING_PORT, () => {
    console.log('===================================================');
    console.log(` BESU FAILOVER PROXY + LOGGER`);
    console.log(` Listening on: http://127.0.0.1:${LISTENING_PORT}`);
    console.log(` Logging to:   besu-config/logs/`);
    console.log('===================================================');
    console.log(`Nodes configured:`);
    NODES.forEach(n => console.log(` - ${n.name}: Port ${n.port}`));
});

