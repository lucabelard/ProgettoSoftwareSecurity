const Web3 = require('web3');

// Configurazione
const RPC_URL = 'http://127.0.0.1:8545';
const ADMIN_PRIVATE_KEY = '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63';
const AMOUNT_TO_SEND = '10'; // 10 ETH

async function topUp() {
    const targetAddress = process.argv[2];
    if (!targetAddress) {
        console.error('Usage: node top-up.js <ADDRESS>');
        process.exit(1);
    }

    const web3 = new Web3(RPC_URL);
    const adminAccount = web3.eth.accounts.privateKeyToAccount(ADMIN_PRIVATE_KEY);

    console.log(`[*] Connessione a ${RPC_URL}...`);
    console.log(`[*] Admin: ${adminAccount.address}`);
    console.log(`[*] Target: ${targetAddress}`);
    console.log(`[*] Inviando ${AMOUNT_TO_SEND} ETH...`);

    const tx = {
        from: adminAccount.address,
        to: targetAddress,
        value: web3.utils.toWei(AMOUNT_TO_SEND, 'ether'),
        gas: 21000,
        gasPrice: 1000
    };

    try {
        const signedTx = await adminAccount.signTransaction(tx);
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log(`[SUCCESS] Transazione confermata! Hash: ${receipt.transactionHash}`);
        console.log(`[INFO] Ora l'account ${targetAddress} ha ricevuto i fondi.`);
    } catch (error) {
        console.error(`[ERROR] Errore durante il trasferimento:`, error.message);
    }
}

topUp();
