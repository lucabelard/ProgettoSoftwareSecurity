const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

async function main() {
    const rpcUrl = "http://127.0.0.1:8545";
    console.log(`Connecting to Besu at ${rpcUrl}...`);
    const web3 = new Web3(rpcUrl);

    try {
        const networkId = await web3.eth.net.getId();
        console.log(`✅ Connected! Network ID: ${networkId}`);
        
        const blockNumber = await web3.eth.getBlockNumber();
        console.log(`📦 Current Block: ${blockNumber}`);

        // Load contract artifact
        const artifactPath = path.join(__dirname, '..', 'build', 'contracts', 'BNCalcolatoreOnChain.json');
        if (!fs.existsSync(artifactPath)) {
            throw new Error(`Artifact not found at ${artifactPath}`);
        }
        
        const artifact = JSON.parse(fs.readFileSync(artifactPath));
        const deployment = artifact.networks[networkId];

        if (!deployment) {
            console.error(`❌ Contract NOT deployed on network ${networkId}`);
            process.exit(1);
        }

        console.log(`✅ Contract Address found in artifact: ${deployment.address}`);

        // Verify code at address
        const code = await web3.eth.getCode(deployment.address);
        if (code === '0x') {
            console.error('❌ No code at contract address! Deployment might have failed or not synced.');
        } else {
            console.log(`✅ Code found at address (${code.length} bytes)`);
            
            // Try calling a view function
            const contract = new web3.eth.Contract(artifact.abi, deployment.address);
            try {
                // Assuming there is an admin or similar check, or just check basic var
                // Based on previous file reads, there is _contatoreIdSpedizione
                const counter = await contract.methods._contatoreIdSpedizione().call();
                console.log(`✅ Contract call successful! _contatoreIdSpedizione: ${counter}`);
            } catch (e) {
                console.log(`⚠️  Contract call failed (might be expected if method doesn't exist): ${e.message}`);
            }
        }

    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

main();
