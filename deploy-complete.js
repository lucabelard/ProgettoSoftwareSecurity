// Script di deploy COMPLETO con assegnazione ruoli e LOGGING AVANZATO
const { Web3 } = require('web3');
const fs = require('fs');
const path = require('path');

// Import del Logger avanzato
const logger = require('./besu-config/scripts/monitoring/blockchain-logger');

const web3 = new Web3('http://127.0.0.1:8545');

// Account dalla genesis - QUESTI CORRISPONDONO ALL'ORDINE IN METAMASK_ACCOUNTS.txt
const accounts = {
    admin: {
        privateKey: '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63',
        address: '0xfe3b557e8fb62b89f4916b721be55ceb828dbd73',
        name: 'Admin/Oracolo'
    },
    sensore: {
        privateKey: '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3',
        address: '0x627306090abaB3A6e1400e9345bC60c78a8BEf57',
        name: 'Sensore'
    },
    mittente: {
        privateKey: '0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f',
        address: '0xf17f52151EbEF6C7334FAD080c5704D77216b732',
        name: 'Mittente'
    },
    corriere: {
        privateKey: '0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1',
        address: '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef',
        name: 'Corriere'
    }
};

// Aggiungi l'account admin al wallet
const adminAccount = web3.eth.accounts.privateKeyToAccount(accounts.admin.privateKey);
web3.eth.accounts.wallet.add(adminAccount);

async function deployAndSetup() {
    console.log('\n=== DEPLOY E SETUP SMART CONTRACT ===\n');

    try {
        const chainId = await web3.eth.getChainId();
        const initialBalance = await web3.eth.getBalance(adminAccount.address);
        const gasPrice = await web3.eth.getGasPrice();
        
        logger.startDeploymentSession(chainId, adminAccount.address, initialBalance);

        // Carica l'artifact del contratto
        const contractPath = path.join(__dirname, 'build', 'contracts', 'BNCalcolatoreOnChain.json');
        const contractJson = JSON.parse(fs.readFileSync(contractPath, 'utf8'));

        console.log('📦 Deploying BNCalcolatoreOnChain...');

        // Deploy del contratto
        const contract = new web3.eth.Contract(contractJson.abi);
        const deployTx = contract.deploy({ data: contractJson.bytecode });

        let txStartTime = Date.now();
        const deployedContract = await deployTx.send({
            from: adminAccount.address,
            gas: 8000000,
            gasPrice: gasPrice
        });

        // Log del deployment
        const blockNumber = await web3.eth.getBlockNumber();
        const block = await web3.eth.getBlock(blockNumber, true);
        if (block && block.transactions && block.transactions.length > 0) {
            const deployTxData = block.transactions.find(tx => !tx.to);
            if (deployTxData) {
                const receipt = await web3.eth.getTransactionReceipt(deployTxData.hash);
                if (receipt) {
                    logger.logContractDeployment(
                        receipt, 
                        'BNCalcolatoreOnChain', 
                        deployedContract.options.address,
                        txStartTime
                    );
                }
            }
        }

        console.log(`✅ Contratto deployato a: ${deployedContract.options.address}\n`);

        // Aggiorna file JSON
        contractJson.networks = contractJson.networks || {};
        contractJson.networks[chainId.toString()] = {
            events: {},
            links: {},
            address: deployedContract.options.address
        };
        fs.writeFileSync(contractPath, JSON.stringify(contractJson, null, 2));

        // Copia nell'interfaccia web
        const webInterfacePath = path.join(__dirname, 'web-interface', 'BNCalcolatoreOnChain.json');
        fs.copyFileSync(contractPath, webInterfacePath);

        console.log('👥 Assegnazione Ruoli...');

        const RUOLO_SENSORE = await deployedContract.methods.RUOLO_SENSORE().call();
        const RUOLO_MITTENTE = await deployedContract.methods.RUOLO_MITTENTE().call();

        async function sendAndLog(method, methodName) {
            txStartTime = Date.now();
            const result = await method.send({
                from: adminAccount.address,
                gas: 300000,
                gasPrice: gasPrice
            });
            const receipt = await web3.eth.getTransactionReceipt(result.transactionHash);
            logger.logTransaction(receipt, methodName, 0, txStartTime);
            return result;
        }

        await sendAndLog(
            deployedContract.methods.grantRole(RUOLO_SENSORE, accounts.sensore.address),
            'grantRole(SENSORE)'
        );
        
        await sendAndLog(
            deployedContract.methods.grantRole(RUOLO_MITTENTE, accounts.mittente.address),
            'grantRole(MITTENTE)'
        );

        console.log('✓ Ruoli assegnati correttametne.\n');

        console.log('⚙️  Configurazione Probabilità (CPT)...');

        await sendAndLog(
            deployedContract.methods.impostaProbabilitaAPriori(99, 99),
            'impostaProbabilitaAPriori'
        );

        const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };
        const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

        await sendAndLog(deployedContract.methods.impostaCPT(1, cptPositiva), 'impostaCPT(E1)');
        await sendAndLog(deployedContract.methods.impostaCPT(2, cptPositiva), 'impostaCPT(E2)');
        await sendAndLog(deployedContract.methods.impostaCPT(3, cptNegativa), 'impostaCPT(E3)');
        await sendAndLog(deployedContract.methods.impostaCPT(4, cptNegativa), 'impostaCPT(E4)');
        await sendAndLog(deployedContract.methods.impostaCPT(5, cptPositiva), 'impostaCPT(E5)');

        console.log('✓ CPT configurate.\n');

        const finalBalance = await web3.eth.getBalance(adminAccount.address);
        const summary = logger.endDeploymentSession(finalBalance);

        console.log('========================================');
        console.log('SETUP COMPLETATO CON SUCCESSO');
        console.log('========================================');
        console.log(`Gas Totale: ${logger.formatNumber(summary.totals.gasUsed)}`);
        console.log(`Costo:      ${summary.totals.costEth.toFixed(8)} ETH`);
        console.log(`Tempo:      ${summary.totals.durationSeconds.toFixed(1)}s`);
        console.log('\nLog salvati in besu-config/logs/');

    } catch (error) {
        console.error('\n❌ ERRORE:', error.message);
        process.exit(1);
    }
}

deployAndSetup();
