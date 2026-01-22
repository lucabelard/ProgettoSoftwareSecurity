const { Web3 } = require('web3');

// Connect to Besu Node 1
const web3 = new Web3('http://127.0.0.1:8545');

async function monitorTransactions() {
    console.log("🔍 Inizio monitoraggio transazioni Besu...");
    console.log("Ascolto nuovi blocchi...\n");

    let lastBlock = await web3.eth.getBlockNumber();
    // Ensure lastBlock is BigInt (Web3 v4 usually returns BigInt)
    lastBlock = BigInt(lastBlock);

    setInterval(async () => {
        try {
            const currentBlock = await web3.eth.getBlockNumber();
            const currentBlockBigInt = BigInt(currentBlock);
            
            if (currentBlockBigInt > lastBlock) {
                // Process all new blocks
                for (let i = lastBlock + 1n; i <= currentBlockBigInt; i++) {
                    const block = await web3.eth.getBlock(i, true); // true = include full transactions
                    
                    if (block && block.transactions && block.transactions.length > 0) {
                        const timestamp = Number(block.timestamp); // Convert BigInt timestamp to Number for Date
                        console.log(`\n📦 Block #${i} | ${new Date(timestamp * 1000).toLocaleString()}`);
                        console.log(`   Miner: ${block.miner}`);
                        console.log(`   Transazioni: ${block.transactions.length}`);
                        
                        block.transactions.forEach((tx, index) => {
                            console.log(`   ---------------------------------------------------`);
                            console.log(`   TX #${index + 1}: ${tx.hash}`);
                            console.log(`     From:   ${tx.from}`);
                            console.log(`     To:     ${tx.to || '[Contract Deployment]'}`);
                            console.log(`     Value:  ${web3.utils.fromWei(tx.value, 'ether')} ETH`);
                            console.log(`     Gas:    ${tx.gas.toString()} (Price: ${tx.gasPrice.toString()})`);
                            console.log(`     Input:  ${tx.input ? (tx.input.substring(0, 50) + (tx.input.length > 50 ? '...' : '')) : 'N/A'}`);
                        });
                        console.log(`   ---------------------------------------------------\n`);
                    } else {
                        // Optional: Log empty blocks or skip
                        // process.stdout.write(`.`); 
                    }
                }
                lastBlock = currentBlockBigInt;
            }
        } catch (error) {
            console.error("Errore:", error.message);
        }
    }, 2000); // Check every 2 seconds
}

monitorTransactions();
