const http = require('http');
const fs = require('fs');
const path = require('path');

// Configurazione
const LISTENING_PORT = 8545;
const NODES = [
    { name: 'Node 1', port: 8551 },
    { name: 'Node 2', port: 8546 },
    { name: 'Node 3', port: 8547 },
    { name: 'Node 4', port: 8548 }
];

let currentNodeIndex = 0;

// Logging Setup
const LOG_DIR = path.join(__dirname, '..', 'logs');
if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
const LOG_FILE = path.join(LOG_DIR, 'network_traffic.log');
const TX_LOG_FILE = path.join(LOG_DIR, 'transactions.log');

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

        // LOGGING RICHIESTE TX
        if (requestData.method === 'eth_sendRawTransaction' || requestData.method === 'eth_sendTransaction') {
            const paramsStr = JSON.stringify(requestData.params || []).substring(0, 150);
            const msg = `📝 TX SUBMITTED | Method: ${requestData.method} | Params: ${paramsStr}...`;
            console.log(msg);
            logToFile(TX_LOG_FILE, msg);
        }

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
                // Intercettiamo la risposta per i log del Gas
                if (requestData.method === 'eth_getTransactionReceipt') {
                    const resChunks = [];
                    proxyRes.on('data', chunk => resChunks.push(chunk));
                    proxyRes.on('end', () => {
                        const resBuffer = Buffer.concat(resChunks);
                        clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);
                        clientRes.write(resBuffer);
                        clientRes.end();

                        try {
                            const responseJson = JSON.parse(resBuffer.toString());
                            if (responseJson.result) {
                                const receipt = responseJson.result;
                                const gasUsedDecimal = parseInt(receipt.gasUsed, 16);
                                const status = receipt.status === '0x1' ? 'SUCCESS' : 'FAILED';
                                const msg = `⛽ TX RECEIPT | Hash: ${receipt.transactionHash} | Status: ${status} | Gas Used: ${gasUsedDecimal} | Block: ${parseInt(receipt.blockNumber, 16)}`;
                                console.log(`[Log] ${msg}`);
                                logToFile(TX_LOG_FILE, msg);
                            }
                        } catch (e) { /* ignore logging errors */ }
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

// MONITORAGGIO ATTIVO (Ogni 3 secondi)
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

server.listen(LISTENING_PORT, () => {
    console.log('===================================================');
    console.log(` BESU FAILOVER PROXY + LOGGER`);
    console.log(` Listening on: http://127.0.0.1:${LISTENING_PORT}`);
    console.log(` Logging to:   besu-config/logs/`);
    console.log('===================================================');
    console.log(`Nodes configured:`);
    NODES.forEach(n => console.log(` - ${n.name}: Port ${n.port}`));
    console.log('\n[Monitor] Controllo attivo avviato (ogni 3s)...');
});
