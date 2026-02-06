/*
 * Truffle configuration file
 * Configura la connessione a Ganache, Besu e il compilatore Solidity
 */

const HDWalletProvider = require('@truffle/hdwallet-provider');

// Global error handler to suppress benign network errors during shutdown
process.on('uncaughtException', (err) => {
  if (err.message && (err.message.includes('ESOCKETTIMEDOUT') || err.message.includes('PollingBlockTracker'))) {
    // Suppress
    return;
  }
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  if (reason.message && (reason.message.includes('ESOCKETTIMEDOUT') || reason.message.includes('PollingBlockTracker'))) {
    // Suppress
    return;
  }
  console.error('Unhandled Rejection:', reason);
});

// Chiavi private degli account precaricati nel genesis di Besu
// ATTENZIONE: Questi sono account di TEST pubblici - NON usare in produzione!
const besuPrivateKeys = [
  '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63', // Account 0
  '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3', // Account 1
  '0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f', // Account 2
  '0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1'  // Account 3
];

module.exports = {
  paths: {
    contracts: "./contracts",
    migrations: "./migrations",
    artifacts: "./build/contracts",
  },

  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 6721975,
      gasPrice: 20000000000,
      websockets: true,
      networkCheckTimeout: 10000,
      timeoutBlocks: 200
    },
    besu: {
      provider: () => {
        const provider = new HDWalletProvider({
          privateKeys: besuPrivateKeys,
          providerOrUrl: "http://127.0.0.1:8551",
          numberOfAddresses: 4,
          pollingInterval: 4000,  // Check every 4 seconds (Besu block time is ~2s)
          timeout: 600000         // 10 minutes timeout
        });
        // Suppress unhandled "ESOCKETTIMEDOUT" errors from polling
        provider.engine.on('error', (err) => {
          console.log('[Ignored Provider Error]:', err.message);
        });
        return provider;
      },
      network_id: "2025",  // BESU IBFT network uses 2025
      gas: 8000000,
      gasPrice: 1000,
      networkCheckTimeout: 600000,
      timeoutBlocks: 500,
      deploymentPollingInterval: 8000,
      skipDryRun: true,
      disableConfirmationListener: true
    },
    // Alternative: BESU con account diretto (senza HDWalletProvider)
    besu_dev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "2025",  // IBFT network ID
      gas: 8000000,
      gasPrice: 1000,
      from: "0xfe3b557e8fb62b89f4916b721be55ceb828dbd73",
      networkCheckTimeout: 60000,
      timeoutBlocks: 500
    },
  },

  compilers: {
    solc: {
      version: "0.8.20",
      settings: {              // Disabilita optimizer per evitare bug del compilatore
        optimizer: {
          enabled: false,
          runs: 200,
        },
        evmVersion: "paris"
      },
    },
  },

  // Impostazioni per i test
  mocha: {
    // timeout: 100000
  },

  // Disabilitazione di Truffle DB (non necessario per la maggior parte dei progetti)
  db: {
    enabled: false,
  },
};