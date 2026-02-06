const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

module.exports = async function (deployer, network, accounts) {
    const admin = accounts[0];

    console.log("----------------------------------------------------");
    console.log("2. Deploying BNCalcolatoreOnChain...");
    console.log("----------------------------------------------------");

    // DEPLOY DEL CONTRATTO
    await deployer.deploy(BNCalcolatoreOnChain, { from: admin, overwrite: false });
    const instance = await BNCalcolatoreOnChain.deployed();
    console.log("Contratto deployato a:", instance.address);
};
