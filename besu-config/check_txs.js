const Web3 = require('web3');
const web3 = new Web3('http://127.0.0.1:8545');

async function checkBlocks() {
    try {
        const latest = await web3.eth.getBlockNumber();
        console.log(`Latest block: ${latest}`);
        
        let txCount = 0;
        // Check last 200 blocks
        for (let i = 0; i < 200; i++) {
            const blockNum = latest - i;
            if (blockNum < 0) break;
            
            const block = await web3.eth.getBlock(blockNum, true);
            if (block && block.transactions.length > 0) {
                console.log(`\n📦 BLOCK ${block.number} (${block.transactions.length} txs)`);
                block.transactions.forEach(tx => {
                    console.log(`   - Hash: ${tx.hash}`);
                    console.log(`     From: ${tx.from}`);
                    console.log(`     To:   ${tx.to}`);
                    console.log(`     Val:  ${web3.utils.fromWei(tx.value, 'ether')} ETH`);
                });
                txCount += block.transactions.length;
            }
        }
        
        if (txCount === 0) {
            console.log("\nNo transactions found in the last 200 blocks.");
        } else {
            console.log(`\nTotal transactions found: ${txCount}`);
        }
    } catch (e) {
        console.error("Error:", e);
    }
}

checkBlocks();
