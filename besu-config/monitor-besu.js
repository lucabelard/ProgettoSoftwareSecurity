let Web3 = require('web3');
// Compatibilità per diverse versioni di Web3 (1.x vs 4.x)
if (Web3.Web3) {
    Web3 = Web3.Web3;
}
const web3 = new Web3('http://127.0.0.1:8545');

console.log("👀 Avvio Monitor Transazioni BESU...");
console.log("-----------------------------------------");
console.log("In attesa di nuove transazioni (Premi Ctrl+C per uscire)...");

let lastBlockProcessed = 0;

async function monitor() {
    try {
        // Ottieni l'ultimo blocco minato
        let currentBlockNumber = await web3.eth.getBlockNumber();
        // Converti BigInt in Number se necessario (Web3 4.x restituisce BigInt)
        if (typeof currentBlockNumber === 'bigint') {
            currentBlockNumber = Number(currentBlockNumber);
        }

        // Se è la prima esecuzione, inizia dall'attuale meno 5 blocchi per vedere subito qualcosa
        if (lastBlockProcessed === 0) {
            lastBlockProcessed = Math.max(0, currentBlockNumber - 5);
        }

        // Processa tutti i blocchi mancanti fino ad oggi
        while (lastBlockProcessed <= currentBlockNumber) {
            try {
                const block = await web3.eth.getBlock(lastBlockProcessed, true);
                
                if (block && block.transactions.length > 0) {
                    console.log(`\n📦 BLOCCO ${block.number} (Minato alle ${new Date(Number(block.timestamp) * 1000).toLocaleTimeString()})`);
                    console.log(`   Transazioni idonee: ${block.transactions.length}`);
                    
                    block.transactions.forEach((tx, index) => {
                        console.log(`   🔸 Tx #${index + 1}: ${tx.hash}`);
                        console.log(`      Da:      ${tx.from}`);
                        console.log(`      A:       ${tx.to || "Creazione Contratto"}`);
                        
                        // Cerca di indovinare l'azione basandosi sul "TO" o sui dati (opzionale - semplice euristica)
                        // In futuro si potrebbe decodificare l'input data se abbiamo l'ABI
                        console.log(`      Valore:  ${web3.utils.fromWei(tx.value, 'ether')} ETH`);
                        console.log("      ------------------------------------------------");
                    });
                } 
                // else {  // Decommenta per vedere anche i blocchi vuoti (molto verboso su BESU Dev)
                //    process.stdout.write("."); // Feedback visivo mining
                // }

                lastBlockProcessed++;
            } catch (err) {
                console.error("Errore lettura blocco:", err);
                // Non incrementare lastBlockProcessed per riprovare
                await new Promise(r => setTimeout(r, 1000));
            }
        }
    } catch (e) {
        console.error("Errore connessione:", e.message);
    }

    // Polling ogni 2 secondi
    setTimeout(monitor, 2000);
}

monitor();
