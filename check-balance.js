// Script rapido per verificare i bilanci sulla blockchain
const { Web3 } = require('web3');

const web3 = new Web3('http://127.0.0.1:8545');

const accounts = [
    { name: 'Account 1 (Admin)', address: '0xfe3b557e8fb62b89f4916b721be55ceb828dbd73' },
    { name: 'Account 2 (Mittente)', address: '0x627306090abaB3A6e1400e9345bC60c78a8BEf57' },
    { name: 'Account 3 (Sensore)', address: '0xf17f52151EbEF6C7334FAD080c5704D77216b732' },
    { name: 'Account 4 (Corriere)', address: '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef' }
];

async function checkBalances() {
    console.log('\n========================================');
    console.log('VERIFICA BILANCI SULLA BLOCKCHAIN');
    console.log('========================================\n');

    try {
        // Verifica Chain ID
        const chainId = await web3.eth.getChainId();
        console.log(`Chain ID: ${chainId}`);

        // Verifica block number
        const blockNumber = await web3.eth.getBlockNumber();
        console.log(`Block Number: ${blockNumber}\n`);

        console.log('BILANCI ACCOUNT:');
        console.log('----------------------------------------');

        for (const acc of accounts) {
            const balance = await web3.eth.getBalance(acc.address);
            const ethBalance = web3.utils.fromWei(balance, 'ether');
            console.log(`${acc.name}:`);
            console.log(`  Address: ${acc.address}`);
            console.log(`  Balance: ${ethBalance} ETH`);
            console.log('');
        }

    } catch (error) {
        console.error('ERRORE:', error.message);
        console.log('\nLa rete Besu potrebbe non essere in esecuzione su http://127.0.0.1:8545');
    }
}

checkBalances();
