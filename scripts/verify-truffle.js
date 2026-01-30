const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

module.exports = async function(callback) {
  try {
    console.log("🔍 Checking Besu connection...");
    const networkId = await web3.eth.net.getId();
    console.log(`✅ Connected to network ID: ${networkId}`);

    console.log("🔍 Loading contract...");
    const instance = await BNCalcolatoreOnChain.deployed();
    console.log(`✅ Contract deployed at: ${instance.address}`);

    console.log("🔍 Checking code at address...");
    const code = await web3.eth.getCode(instance.address);
    if (code === '0x') {
      throw new Error("❌ No code at address! Deployment failed?");
    }
    console.log(`✅ Code found (${code.length} bytes)`);

    console.log("🔍 Calling view function...");
    const counter = await instance._contatoreIdSpedizione();
    console.log(`✅ Call successful! Counter value: ${counter.toString()}`);

    callback();
  } catch (error) {
    console.error(error);
    callback(error);
  }
};
