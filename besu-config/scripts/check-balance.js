const { Web3 } = require('web3');

// Configurazione
const RPC_URL = 'http://127.0.0.1:8545';

// Indirizzi da controllare
const ACCOUNTS = [
    { name: 'Admin/Oracolo', address: '0xfe3b557e8fb62b89f4916b721be55ceb828dbd73' },
    { name: 'Account 1/Sensore', address: '0x627306090abaB3A6e1400e9345bC60c78a8BEf57' },
    { name: 'Account 2/Mittente', address: '0xf17f52151EbEF6C7334FAD080c5704D77216b732' },
    { name: 'Account 3/Corriere', address: '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef' }
];

async function checkBalances() {
    console.log(`[*] Connessione a ${RPC_URL}...`);
    const web3 = new Web3(RPC_URL);

    try {
        const isListening = await web3.eth.net.isListening();
        console.log(`[OK] Nodo connesso!`);

        const chainId = await web3.eth.getChainId();
        console.log(`[INFO] Chain ID rilevato: ${chainId} (Atteso: 2025)`);

        console.log('\n--- SALDI RILEVATI SULLA BLOCKCHAIN ---');
        for (const acc of ACCOUNTS) {
            const balanceWei = await web3.eth.getBalance(acc.address);
            const balanceEth = web3.utils.fromWei(balanceWei, 'ether');
            console.log(`${acc.name}: ${acc.address}`);
            console.log(`   -> ${balanceEth} ETH`);
            console.log(`   -> (${balanceWei} Wei)`);
            console.log('---------------------------------------');
        }

    } catch (error) {
        console.error(`[ERROR] Impossibile connettersi al nodo:`, error.message);
        console.log('Assicurati che la rete Besu sia avviata con ./start-all.sh');
    }
}

checkBalances();
