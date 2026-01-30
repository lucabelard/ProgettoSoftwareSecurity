// Script di deploy diretto senza Truffle
const { Web3 } = require('web3');
const fs = require('fs');
const path = require('path');

const web3 = new Web3('http://127.0.0.1:8545');

// Account deployer (Admin) - dalla genesis
const deployerPrivateKey = '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63';
const deployerAccount = web3.eth.accounts.privateKeyToAccount(deployerPrivateKey);
web3.eth.accounts.wallet.add(deployerAccount);

async function deploy() {
    console.log('\n========================================');
    console.log('DEPLOY CONTRATTI SU BESU');
    console.log('========================================\n');

    try {
        // Verifica connessione
        const chainId = await web3.eth.getChainId();
        console.log(`✓ Connesso a Chain ID: ${chainId}`);

        const balance = await web3.eth.getBalance(deployerAccount.address);
        console.log(`✓ Deployer: ${deployerAccount.address}`);
        console.log(`✓ Balance: ${web3.utils.fromWei(balance, 'ether')} ETH\n`);

        // Carica l'artifact del contratto compilato
        const contractPath = path.join(__dirname, 'build', 'contracts', 'BNCalcolatoreOnChain.json');
        const contractJson = JSON.parse(fs.readFileSync(contractPath, 'utf8'));

        console.log('📦 Deploying BNCalcolatoreOnChain...');

        // Crea il contratto
        const contract = new web3.eth.Contract(contractJson.abi);

        // Deploy
        const deployTx = contract.deploy({
            data: contractJson.bytecode
        });

        const gas = await deployTx.estimateGas({ from: deployerAccount.address });
        console.log(`⛽ Gas stimato: ${gas}`);

        const deployedContract = await deployTx.send({
            from: deployerAccount.address,
            gas: 8000000, // Gas fisso invece di calcolo dinamico
            gasPrice: 0 // Gas price 0 per Besu
        });

        console.log(`\n✅ Contratto deployato!`);
        console.log(`📍 Indirizzo: ${deployedContract.options.address}`);
        console.log(`🔗 Transaction Hash: ${deployedContract.options.transactionHash || 'N/A'}\n`);

        // Salva l'indirizzo nel file JSON
        contractJson.networks = contractJson.networks || {};
        contractJson.networks[chainId.toString()] = {
            events: {},
            links: {},
            address: deployedContract.options.address,
            transactionHash: deployedContract.options.transactionHash || ''
        };

        fs.writeFileSync(contractPath, JSON.stringify(contractJson, null, 2));
        console.log('💾 Indirizzo salvato in build/contracts/BNCalcolatoreOnChain.json');

        // Copia nell'interfaccia web
        const webInterfacePath = path.join(__dirname, 'web-interface', 'BNCalcolatoreOnChain.json');
        fs.copyFileSync(contractPath, webInterfacePath);
        console.log('💾 File copiato in web-interface/');

        console.log('\n========================================');
        console.log('✅ DEPLOY COMPLETATO CON SUCCESSO!');
        console.log('========================================\n');

    } catch (error) {
        console.error('\n❌ ERRORE durante il deploy:');
        console.error(error.message);
        process.exit(1);
    }
}

deploy();
