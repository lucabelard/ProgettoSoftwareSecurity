const http = require('http');

// Configurazione
const LISTENING_PORT = 8545;
const NODES = [
    { name: 'Node 1', port: 8551 }, // Node 1 spostato su 8551
    { name: 'Node 2', port: 8546 },
    { name: 'Node 3', port: 8547 },
    { name: 'Node 4', port: 8548 }
];

let currentNodeIndex = 0;

// Funzione per testare se un nodo è vivo
function checkNode(port) {
    return new Promise((resolve) => {
        const req = http.request({
            hostname: '127.0.0.1',
            port: port,
            path: '/',
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            timeout: 2000 // Timeout rapido per check interno
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
    // Prima prova il nodo corrente (se diverso da quello che ha appena fallito, ma qui viene chiamato quando ha fallito)
    // Quindi cerchiamo subito alternative
    
    // Cerca round-robin partendo dall'indice corrente + 1
    for (let i = 0; i < NODES.length; i++) {
        // Calcola indice ciclico
        const idx = (currentNodeIndex + i) % NODES.length;
        
        // Evita di ritestare subito il nodo che sappiamo essere morto se siamo nel monitor
        // ma la funzione checkNode è veloce quindi testiamo tutto per sicurezza
        
        if (await checkNode(NODES[idx].port)) {
            // Se troviamo un nodo diverso da quello attuale, lo segnaliamo
            if (idx !== currentNodeIndex) {
                 console.log(`[Proxy] ✅ Switch to ${NODES[idx].name} (Port ${NODES[idx].port})`);
            }
            return idx;
        }
    }
    return -1; // Nessun nodo attivo
}

const server = http.createServer(async (clientReq, clientRes) => {
    // Bufferizzare il body della richiesta per poterlo riusare nei retry
    const chunks = [];
    clientReq.on('data', chunk => chunks.push(chunk));
    clientReq.on('end', async () => {
        const bodyBuffer = Buffer.concat(chunks);
        
        // Funzione per inviare la richiesta a un nodo specifico
        const sendRequest = (nodeIndex, isRetry = false) => {
            const targetNode = NODES[nodeIndex];
            
            const options = {
                hostname: '127.0.0.1',
                port: targetNode.port,
                path: clientReq.url,
                method: clientReq.method,
                headers: clientReq.headers
            };
            
            // Rimuove l'header host per evitare conflitti o host errati
            if (options.headers.host) delete options.headers.host;
            // Aggiorna content-length se necessario (dovrebbe essere uguale)
            options.headers['Content-Length'] = bodyBuffer.length;

            const proxyReq = http.request(options, (proxyRes) => {
                clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);
                proxyRes.pipe(clientRes, { end: true });
            });

            proxyReq.on('error', async (e) => {
                const isConnectionRefused = e.code === 'ECONNREFUSED';
                // Logghiamo solo se non è un retry già fallito o se è una connessione rifiutata (chiaro segno di nodo down)
                if (!isRetry || isConnectionRefused) {
                     console.error(`[Proxy] ⚠️ Errore su ${targetNode.name} (${e.code})...`);
                }

                if (!isRetry) {
                    console.log(`[Proxy] 🔄 Tento failover...`);
                    const newIndex = await findActiveNode();
                    
                    if (newIndex !== -1 && newIndex !== nodeIndex) {
                        currentNodeIndex = newIndex;
                        console.log(`[Proxy] � Riprovo su ${NODES[currentNodeIndex].name}...`);
                        sendRequest(currentNodeIndex, true); // Retry ricorsivo (una sola volta grazie a isRetry se volessimo, ma qui permettiamo 1 livello)
                        return;
                    }
                }
                
                // Se siamo qui: o è fallito anche il retry, o non ci sono nodi
                if (!clientRes.headersSent) {
                    clientRes.writeHead(502);
                    clientRes.end(JSON.stringify({error: "Proxy Error: All nodes down or unreachable"}));
                }
            });
            
            // Timeout gestione per evitare hanging
            proxyReq.on('timeout', () => {
                proxyReq.destroy();
            });

            // Scrive il body bufferizzato
            proxyReq.write(bodyBuffer);
            proxyReq.end();
        };

        // Primo tentativo
        const activeIndex = await findActiveNode(); 
        // Nota: ottimizzazione, se findActiveNode è costoso potremmo saltarlo e provare currentNodeIndex, 
        // ma dato che abbiamo buffering, meglio trovare un nodo vivo subito se il corrente è sospetto.
        // O semplicemente provare currentNodeIndex:
        
        // Usiamo currentNodeIndex direttamente per velocità, il failover scatterà su errore
        sendRequest(currentNodeIndex);
    });
});

// MONITORAGGIO ATTIVO (Ogni 3 secondi) - Rimane invariato
setInterval(async () => {
    const targetNode = NODES[currentNodeIndex];
    // console.log(`[Monitor] Controllo stato ${targetNode.name}...`);
    const isAlive = await checkNode(targetNode.port);
    
    if (!isAlive) {
        // console.log(`[Monitor] ⚠️ Node ${targetNode.name} NON RISPONDE!`);
        // Silenzioso qui per non spammare, il proxyReq loggerà errore reale
        
        // Ma facciamo update attivo se monitor rileva down
        const newIndex = await findActiveNode();
        if (newIndex !== -1 && newIndex !== currentNodeIndex) {
             currentNodeIndex = newIndex;
             console.log(`[Monitor] ⚠️ Rilevato nodo down. Switch preventivo a ${NODES[currentNodeIndex].name}`);
        }
    }
}, 3000);


server.listen(LISTENING_PORT, () => {
    console.log('===================================================');
    console.log(` BESU FAILOVER PROXY`);
    console.log(` Listening on: http://127.0.0.1:${LISTENING_PORT}`);
    console.log('===================================================');
    console.log(`Nodes configured:`);
    NODES.forEach(n => console.log(` - ${n.name}: Port ${n.port}`));
    console.log('\n[Monitor] Controllo attivo avviato (ogni 3s)...');
    console.log('Waiting for requests or failures...\n');
});
