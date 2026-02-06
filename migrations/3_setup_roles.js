const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

const delay = ms => new Promise(res => setTimeout(res, ms));

module.exports = async function (deployer, network, accounts) {
    const admin = accounts[0];
    const indirizzoSensore = accounts[1];
    const indirizzoMittente = accounts[2];

    console.log("----------------------------------------------------");
    console.log("3. Setting up Roles (Safe Mode)...");
    console.log("----------------------------------------------------");

    const instance = await BNCalcolatoreOnChain.deployed();
    const SENSORE = await instance.RUOLO_SENSORE();
    const MITTENTE = await instance.RUOLO_MITTENTE();

    // Helper function: Tries to grant role, checks state on error
    async function safeGrantRole(roleName, roleBytes, accountAddress) {
        // 1. Check if already granted
        if (await instance.hasRole(roleBytes, accountAddress)) {
            console.log(`[OK] ${roleName} already granted to ${accountAddress}`);
            return;
        }

        console.log(`Granting ${roleName} to ${accountAddress}...`);
        try {
            await instance.grantRole(roleBytes, accountAddress, { from: admin });
            console.log(`[SUCCESS] Granted ${roleName}`);
        } catch (e) {
            console.log(`[WARN] Error granting ${roleName}: ${e.message}`);
            console.log("Verifying if transaction succeeded despite error...");

            await delay(10000); // Give it a moment to mine if pending

            if (await instance.hasRole(roleBytes, accountAddress)) {
                console.log(`[RECOVERY] ${roleName} was granted successfully!`);
            } else {
                console.log(`[FAILURE] Role not granted. Retrying once...`);
                await delay(5000);
                await instance.grantRole(roleBytes, accountAddress, { from: admin });
            }
        }
        // Final wait to let connection rest
        await delay(3000);
    }

    // Execute safely
    await safeGrantRole("SENSORE", SENSORE, indirizzoSensore);
    await safeGrantRole("MITTENTE", MITTENTE, indirizzoMittente);
};
