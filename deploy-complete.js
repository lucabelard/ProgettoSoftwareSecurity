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
    console.log('\n========================================');
    console.log('DEPLOY E SETUP COMPLETO (CON LOGGING)');
    console.log('========================================\n');

    try {
        // Verifica connessione
        const chainId = await web3.eth.getChainId();
        console.log(`✓ Connesso a Chain ID: ${chainId}`);

        const initialBalance = await web3.eth.getBalance(adminAccount.address);
        console.log(`✓ Admin: ${adminAccount.address}`);
        console.log(`✓ Balance: ${web3.utils.fromWei(initialBalance, 'ether')} ETH`);

        // Get Gas Price for Legacy Transactions
        const gasPrice = await web3.eth.getGasPrice();
        console.log(`✓ Gas Price: ${gasPrice} wei\n`);

        // ============ INIZIO SESSIONE LOGGING ============
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

        // Log del deployment - ottieni receipt dal blocco più recente
        const blockNumber = await web3.eth.getBlockNumber();
        const block = await web3.eth.getBlock(blockNumber, true);
        if (block && block.transactions && block.transactions.length > 0) {
            // Trova la transazione di deployment (quella senza 'to')
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

        console.log(`✅ Contratto deployato!`);
        console.log(`📍 Indirizzo: ${deployedContract.options.address}\n`);

        // Salva l'indirizzo
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

        console.log('👥 Assegnazione Ruoli...\n');

        // Ottieni i ruoli hash
        const RUOLO_SENSORE = await deployedContract.methods.RUOLO_SENSORE().call();
        const RUOLO_MITTENTE = await deployedContract.methods.RUOLO_MITTENTE().call();

        // Helper per eseguire transazione con logging
        async function sendAndLog(method, methodName) {
            txStartTime = Date.now();
            const result = await method.send({
                from: adminAccount.address,
                gas: 300000,
                gasPrice: gasPrice
            });
            
            // Ottieni receipt
            const receipt = await web3.eth.getTransactionReceipt(result.transactionHash);
            logger.logTransaction(receipt, methodName, 0, txStartTime);
            
            return result;
        }

        // Assegna ruolo SENSORE
        await sendAndLog(
            deployedContract.methods.grantRole(RUOLO_SENSORE, accounts.sensore.address),
            'grantRole(SENSORE)'
        );
        console.log(`✓ Ruolo SENSORE assegnato a: ${accounts.sensore.address} (${accounts.sensore.name})`);

        // Assegna ruolo MITTENTE  
        await sendAndLog(
            deployedContract.methods.grantRole(RUOLO_MITTENTE, accounts.mittente.address),
            'grantRole(MITTENTE)'
        );
        console.log(`✓ Ruolo MITTENTE assegnato a: ${accounts.mittente.address} (${accounts.mittente.name})`);

        console.log(`\n✓ Admin mantiene ruoli DEFAULT_ADMIN_ROLE e RUOLO_ORACOLO`);
        console.log(`✓ Corriere (${accounts.corriere.address}) non ha ruoli speciali\n`);

        console.log('⚙️  Setup Probabilità (CPT)...\n');

        // Probabilità a priori
        await sendAndLog(
            deployedContract.methods.impostaProbabilitaAPriori(99, 99),
            'impostaProbabilitaAPriori'
        );
        console.log('✓ Probabilità a priori impostate (P(F1)=99%, P(F2)=99%)');

        // CPT per evidenze positive (E1, E2, E5)
        const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };

        // CPT per evidenze negative (E3, E4)
        const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

        // E1 (Temperatura)
        await sendAndLog(
            deployedContract.methods.impostaCPT(1, cptPositiva),
            'impostaCPT(E1_Temperatura)'
        );

        // E2 (Sigillo)
        await sendAndLog(
            deployedContract.methods.impostaCPT(2, cptPositiva),
            'impostaCPT(E2_Sigillo)'
        );

        // E3 (Shock)
        await sendAndLog(
            deployedContract.methods.impostaCPT(3, cptNegativa),
            'impostaCPT(E3_Shock)'
        );

        // E4 (Luce)
        await sendAndLog(
            deployedContract.methods.impostaCPT(4, cptNegativa),
            'impostaCPT(E4_Luce)'
        );

        // E5 (Scan)
        await sendAndLog(
            deployedContract.methods.impostaCPT(5, cptPositiva),
            'impostaCPT(E5_Scan)'
        );

        console.log('✓ Setup delle CPT per E1-E5 completato\n');

        // ============ FINE SESSIONE LOGGING ============
        const finalBalance = await web3.eth.getBalance(adminAccount.address);
        const summary = logger.endDeploymentSession(finalBalance);

        console.log('========================================');
        console.log('✅ SETUP COMPLETATO CON SUCCESSO!');
        console.log('========================================');
        console.log('\n📋 RIEPILOGO ACCOUNT:\n');
        console.log(`  Admin/Oracolo: ${accounts.admin.address}`);
        console.log(`  Mittente:      ${accounts.mittente.address}`);
        console.log(`  Sensore:       ${accounts.sensore.address}`);
        console.log(`  Corriere:      ${accounts.corriere.address}`);
        console.log('\n📊 RIEPILOGO DEPLOYMENT:');
        console.log(`  Transazioni:   ${summary.totals.count}`);
        console.log(`  Gas Totale:    ${logger.formatNumber(summary.totals.gasUsed)}`);
        console.log(`  Costo Totale:  ${summary.totals.costEth.toFixed(8)} ETH`);
        console.log(`  Durata:        ${summary.totals.durationSeconds.toFixed(1)}s`);
        console.log('\n📁 LOG FILES GENERATI:');
        console.log(`  - besu-config/logs/deployment.log`);
        console.log(`  - besu-config/logs/gas_report.log`);
        console.log(`  - besu-config/logs/session_summary.json`);
        console.log('\n✨ Ora puoi connettere MetaMask con questi account!\n');

    } catch (error) {
        console.error('\n❌ ERRORE durante il deploy:');
        console.error(error.message);
        console.error(error.stack);
        process.exit(1);
    }
}

deployAndSetup();
