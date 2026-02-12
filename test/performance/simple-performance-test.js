/**
 * Simple Performance Test - UNROLLED VERSION
 * Tests 3 Bayesian Network variants and saves metrics to CSV
 */

const fs = require('fs');
const path = require('path');

const CSV_PATH = path.join(__dirname, 'results', 'performance-data.csv');

// Initialize CSV
function initCSV() {
    const dir = path.dirname(CSV_PATH);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    
    // Check if file exists to avoid overwriting header
    if (!fs.existsSync(CSV_PATH)) {
        const header = 'Contract,Facts,Evidences,Size(bytes),DeployGas,DeployTime(ms),ConfigGas,ConfigTime(ms),CalcGas,CalcTime(ms)\n';
        fs.writeFileSync(CSV_PATH, header);
        console.log(`📊 CSV initialized: ${CSV_PATH}\n`);
    }
}

// Append to CSV
function appendToCSV(data) {
    const row = `${data.contract},${data.facts},${data.evidences},${data.size},${data.deployGas},${data.deployTime},${data.configGas},${data.configTime},${data.calcGas},${data.calcTime}\n`;
    fs.appendFileSync(CSV_PATH, row);
}

// Generate CPT for testing
function generateCPT(numFacts) {
    if (numFacts === 1) {
        return { p_F: 10, p_T: 95 };
    } else if (numFacts === 2) {
        return { p_FF: 10, p_FT: 30, p_TF: 30, p_TT: 95 };
    }
}

// Generate evidences for testing
function generateEvidences(numEvidences) {
    const evidences = {};
    for (let i = 1; i <= numEvidences; i++) {
        evidences[`E${i}_ricevuta`] = true;
        evidences[`E${i}_valore`] = true;
    }
    return evidences;
}

initCSV();

// 1. BN_Simple
contract('BN_Simple - Performance Test', (accounts) => {
    let instance;
    const admin = accounts[0];
    const name = 'BN_Simple';
    const facts = 1;
    const evidences = 2;
    let testData = {};
    
    describe(`Testing ${name}`, function() {
        this.timeout(0); 

        it('1. Deploy and measure', async () => {
            console.log(`\n🚀 Deploying ${name}...`);
            const Contract = artifacts.require(name);
            const bytecodeSize = Contract.bytecode.length / 2;
            
            const startTime = Date.now();
            instance = await Contract.new({ from: admin });
            const deployTime = Date.now() - startTime;
            
            const receipt = await web3.eth.getTransactionReceipt(instance.transactionHash);
            const deployGas = receipt.gasUsed;
            
            console.log(`   📦 Size: ${bytecodeSize.toLocaleString()} bytes`);
            console.log(`   ⛽ Deploy gas: ${deployGas.toLocaleString()}`);
            console.log(`   ⏱️  Deploy time: ${deployTime}ms`);
            
            testData = { contract: name, facts, evidences, size: bytecodeSize, deployGas, deployTime };
        });
        
        it('2. Configure and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n⚙️  Configuring ${name}...`);
            let configGas = 0;
            const startTime = Date.now();
            
            const tx = await instance.impostaProbabilitaAPriori(90, { from: admin });
            configGas += tx.receipt.gasUsed;
            
            const cpt = generateCPT(facts);
            for (let i = 1; i <= evidences; i++) {
                const tx = await instance.impostaCPT(i, cpt, { from: admin });
                configGas += tx.receipt.gasUsed;
            }
            
            const configTime = Date.now() - startTime;
            console.log(`   ⛽ Config gas: ${configGas.toLocaleString()}`);
            console.log(`   ⏱️  Config time: ${configTime}ms`);
            
            testData.configGas = configGas;
            testData.configTime = configTime;
        });
        
        it('3. Calculate and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n🧮 Calculating probabilities for ${name}...`);
            const testEvidences = generateEvidences(evidences);
            
            const startTime = Date.now();
            const calcGas = await instance.validaEvidenze.estimateGas(testEvidences, { from: admin });
            const calcTime = Date.now() - startTime;
            
            console.log(`   ⛽ Calc gas: ${calcGas.toLocaleString()}`);
            console.log(`   ⏱️  Calc time: ${calcTime}ms`);
            
            testData.calcGas = calcGas;
            testData.calcTime = calcTime;
        });
        
        it('4. Save results', async function() {
            if (!testData.deployGas) this.skip();
            console.log(`\n💾 Saving results for ${name}...`);
            appendToCSV(testData);
            console.log(`   ✅ Saved to ${CSV_PATH}\n`);
            console.log('═'.repeat(60));
        });
    });
});

// 2. BN_Medium
contract('BN_Medium - Performance Test', (accounts) => {
    let instance;
    const admin = accounts[0];
    const name = 'BN_Medium';
    const facts = 2;
    const evidences = 3;
    let testData = {};
    
    describe(`Testing ${name}`, function() {
        this.timeout(0); 

        it('1. Deploy and measure', async () => {
            console.log(`\n🚀 Deploying ${name}...`);
            const Contract = artifacts.require(name);
            const bytecodeSize = Contract.bytecode.length / 2;
            
            const startTime = Date.now();
            instance = await Contract.new({ from: admin });
            const deployTime = Date.now() - startTime;
            
            const receipt = await web3.eth.getTransactionReceipt(instance.transactionHash);
            const deployGas = receipt.gasUsed;
            
            console.log(`   📦 Size: ${bytecodeSize.toLocaleString()} bytes`);
            console.log(`   ⛽ Deploy gas: ${deployGas.toLocaleString()}`);
            console.log(`   ⏱️  Deploy time: ${deployTime}ms`);
            
            testData = { contract: name, facts, evidences, size: bytecodeSize, deployGas, deployTime };
        });
        
        it('2. Configure and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n⚙️  Configuring ${name}...`);
            let configGas = 0;
            const startTime = Date.now();
            
            const tx = await instance.impostaProbabilitaAPriori(90, 90, { from: admin });
            configGas += tx.receipt.gasUsed;
            
            const cpt = generateCPT(facts);
            for (let i = 1; i <= evidences; i++) {
                const tx = await instance.impostaCPT(i, cpt, { from: admin });
                configGas += tx.receipt.gasUsed;
            }
            
            const configTime = Date.now() - startTime;
            console.log(`   ⛽ Config gas: ${configGas.toLocaleString()}`);
            console.log(`   ⏱️  Config time: ${configTime}ms`);
            
            testData.configGas = configGas;
            testData.configTime = configTime;
        });
        
        it('3. Calculate and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n🧮 Calculating probabilities for ${name}...`);
            const testEvidences = generateEvidences(evidences);
            
            const startTime = Date.now();
            const calcGas = await instance.validaEvidenze.estimateGas(testEvidences, { from: admin });
            const calcTime = Date.now() - startTime;
            
            console.log(`   ⛽ Calc gas: ${calcGas.toLocaleString()}`);
            console.log(`   ⏱️  Calc time: ${calcTime}ms`);
            
            testData.calcGas = calcGas;
            testData.calcTime = calcTime;
        });
        
        it('4. Save results', async function() {
            if (!testData.deployGas) this.skip();
            console.log(`\n💾 Saving results for ${name}...`);
            appendToCSV(testData);
            console.log(`   ✅ Saved to ${CSV_PATH}\n`);
            console.log('═'.repeat(60));
        });
    });
});

// 3. BN_Complex
contract('BN_Complex - Performance Test', (accounts) => {
    let instance;
    const admin = accounts[0];
    const name = 'BN_Complex';
    const facts = 2;
    const evidences = 5;
    let testData = {};
    
    describe(`Testing ${name}`, function() {
        this.timeout(0); 

        it('1. Deploy and measure', async () => {
            console.log(`\n🚀 Deploying ${name}...`);
            const Contract = artifacts.require(name);
            const bytecodeSize = Contract.bytecode.length / 2;
            
            const startTime = Date.now();
            instance = await Contract.new({ from: admin });
            const deployTime = Date.now() - startTime;
            
            const receipt = await web3.eth.getTransactionReceipt(instance.transactionHash);
            const deployGas = receipt.gasUsed;
            
            console.log(`   📦 Size: ${bytecodeSize.toLocaleString()} bytes`);
            console.log(`   ⛽ Deploy gas: ${deployGas.toLocaleString()}`);
            console.log(`   ⏱️  Deploy time: ${deployTime}ms`);
            
            testData = { contract: name, facts, evidences, size: bytecodeSize, deployGas, deployTime };
        });
        
        it('2. Configure and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n⚙️  Configuring ${name}...`);
            let configGas = 0;
            const startTime = Date.now();
            
            const tx = await instance.impostaProbabilitaAPriori(90, 90, { from: admin });
            configGas += tx.receipt.gasUsed;
            
            const cpt = generateCPT(facts);
            for (let i = 1; i <= evidences; i++) {
                const tx = await instance.impostaCPT(i, cpt, { from: admin });
                configGas += tx.receipt.gasUsed;
            }
            
            const configTime = Date.now() - startTime;
            console.log(`   ⛽ Config gas: ${configGas.toLocaleString()}`);
            console.log(`   ⏱️  Config time: ${configTime}ms`);
            
            testData.configGas = configGas;
            testData.configTime = configTime;
        });
        
        it('3. Calculate and measure', async function() {
            if (!instance) this.skip();
            console.log(`\n🧮 Calculating probabilities for ${name}...`);
            const testEvidences = generateEvidences(evidences);
            
            const startTime = Date.now();
            const calcGas = await instance.validaEvidenze.estimateGas(testEvidences, { from: admin });
            const calcTime = Date.now() - startTime;
            
            console.log(`   ⛽ Calc gas: ${calcGas.toLocaleString()}`);
            console.log(`   ⏱️  Calc time: ${calcTime}ms`);
            
            testData.calcGas = calcGas;
            testData.calcTime = calcTime;
        });
        
        it('4. Save results', async function() {
            if (!testData.deployGas) this.skip();
            console.log(`\n💾 Saving results for ${name}...`);
            appendToCSV(testData);
            console.log(`   ✅ Saved to ${CSV_PATH}\n`);
            console.log('═'.repeat(60));
        });
    });
});
