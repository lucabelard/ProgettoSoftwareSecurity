const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

const delay = ms => new Promise(res => setTimeout(res, ms));

module.exports = async function (deployer, network, accounts) {
    const indirizzoOracolo = accounts[0];

    console.log("----------------------------------------------------");
    console.log("4. Setting up CPT Probabilities (Safe Mode)...");
    console.log("----------------------------------------------------");

    const instance = await BNCalcolatoreOnChain.deployed();

    // Helper for CPT (Unfortunately we can't easily check CPT state without getters, 
    // but we can try-catch the transaction)
    async function safeTx(name, txPromise) {
        console.log(`Executing: ${name}...`);
        try {
            await txPromise;
            console.log(`[SUCCESS] ${name}`);
        } catch (e) {
            console.log(`[WARN] Error in ${name}: ${e.message}`);
            console.log("Ignoring error and proceeding... (Transaction likely minded but timed out)");
        }
        await delay(5000);
    }

    console.log("Setting Priors...");
    await safeTx("setProbabilitaAPriori", instance.impostaProbabilitaAPriori(99, 99, { from: indirizzoOracolo }));

    const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };
    const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

    await safeTx("setCPT(1)", instance.impostaCPT(1, cptPositiva, { from: indirizzoOracolo }));
    await safeTx("setCPT(2)", instance.impostaCPT(2, cptPositiva, { from: indirizzoOracolo }));
    await safeTx("setCPT(3)", instance.impostaCPT(3, cptNegativa, { from: indirizzoOracolo }));
    await safeTx("setCPT(4)", instance.impostaCPT(4, cptNegativa, { from: indirizzoOracolo }));
    await safeTx("setCPT(5)", instance.impostaCPT(5, cptPositiva, { from: indirizzoOracolo }));

    console.log("Setup delle CPT per E1-E5 completato (o tentato).");
};
