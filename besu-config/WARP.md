# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

A blockchain-based pharmaceutical cold chain compliance system using Smart Contracts, IoT sensors, and Bayesian Networks. The system automates escrow payments for shipments based on probabilistic validation of IoT evidence.

## Core Architecture

### Components
- **Smart Contract** (`contracts/BNCalcolatoreOnChain.sol`): Solidity 0.8.19+ contract managing escrow payments and Bayesian Network calculations on-chain
- **Web Interface** (`web-interface/`): Frontend using Web3.js v4 for blockchain interaction
- **Migration Scripts** (`migrations/2_deploy_oracolo.js`): Automated deployment with role assignment and CPT initialization
- **Oracle Simulator** (`simula_oracolo.js`): Off-chain script simulating sensors and creating test shipments

### Blockchain Stack
- **Development Network**: 
  - **Ganache** (legacy): port 7545, Chain ID 1337/5777
  - **Hyperledger Besu** (recommended): port 8545, Chain ID 1337
- **Framework**: Truffle Suite
- **Access Control**: OpenZeppelin AccessControl with 4 roles (RUOLO_ORACOLO, RUOLO_SENSORE, RUOLO_MITTENTE, DEFAULT_ADMIN_ROLE)
- **EVM Version**: Paris (configured in truffle-config.js)

### Bayesian Network Logic
The contract calculates two posterior probabilities from 5 IoT evidence inputs (E1-E5):
- **P(F1=True | E1...E5)**: Temperature compliance probability
- **P(F2=True | E1...E5)**: Package integrity probability

Payment is released only if BOTH probabilities ≥ 95% (threshold defined as `SOGLIA_PROBABILITA`).

Evidence meanings:
- E1: Temperature (true=OK, false=Out of Range)
- E2: Seal (true=Intact, false=Broken)
- E3: Shock (true=Detected, false=None)
- E4: Light (true=Exposed/Opened, false=Sealed)
- E5: Arrival Scan (true=On Time, false=Delayed)

## Development Commands

### Initial Setup
```bash
npm install                    # Install dependencies (Truffle, OpenZeppelin, Web3.js)
```

### Blockchain Development

#### Using Ganache (Legacy)
```bash
# Ensure Ganache is running on port 7545 first
truffle compile                # Compile Solidity contracts
truffle migrate --reset        # Deploy on Ganache (default network)
truffle console               # Interactive console for contract testing
```

#### Using Hyperledger Besu (Recommended)
```bash
# 1. Start Besu in a separate terminal
./besu-config/start-besu.sh

# 2. Compile and deploy
truffle compile
truffle migrate --network besu --reset

# 3. Console with Besu
truffle console --network besu
```

### Post-Deployment (CRITICAL STEP)
After EVERY `truffle migrate`, copy the contract ABI to web interface:
```bash
# macOS/Linux
cp build/contracts/BNCalcolatoreOnChain.json web-interface/

# Windows PowerShell
Copy-Item "build\contracts\BNCalcolatoreOnChain.json" -Destination "web-interface\" -Force
```

### Web Interface
```bash
cd web-interface
python -m http.server 8000     # Serve on http://localhost:8000

# Alternative:
npx http-server -p 8000
```

### Testing & Simulation
```bash
node simula_oracolo.js         # Run off-chain oracle simulator (creates shipment + sends evidence)
```

## Workflow Patterns

### Standard Development Cycle
When modifying contracts:
1. Edit Solidity files in `contracts/`
2. Run `truffle compile` to check for syntax errors
3. Run `truffle migrate --reset` to redeploy
4. Copy ABI to `web-interface/` (see command above)
5. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)

### After `git pull`
Always execute this sequence:
```bash
truffle compile
truffle migrate --reset
cp build/contracts/BNCalcolatoreOnChain.json web-interface/
# Remove any backup files that may cause issues
rm -f web-interface/*.backup
```

### MetaMask Configuration
Add Ganache network:
- Network Name: `Ganache Local`
- RPC URL: `http://127.0.0.1:7545`
- Chain ID: `1337`
- Currency: `ETH`

Import accounts by copying private keys from Ganache GUI.

### Testing Roles
Default role assignments from migration script:
- `accounts[0]`: Admin + Oracle + Sensor + Sender (all roles for testing)
- `accounts[1]`: Sensor
- `accounts[2]`: Sender
- `accounts[3]`: Courier (any account can be courier)

## Contract Interaction Patterns

### Creating a Shipment
```javascript
// From accounts[0] or accounts[2] (MITTENTE role)
await contract.methods.creaSpedizione(courierAddress)
  .send({ from: senderAddress, value: web3.utils.toWei("1", "ether") })
```

### Sending Evidence
```javascript
// From accounts[0] or accounts[1] (SENSORE role)
// Evidence ID: 1-5, Value: true/false
await contract.methods.inviaEvidenza(shipmentId, evidenceId, value)
  .send({ from: sensorAddress })
```

### Validating Payment
```javascript
// From courier address
await contract.methods.validaPagamento(shipmentId)
  .send({ from: courierAddress })
```

## Common Issues & Solutions

### "Contract not deployed on network 1337"
**Cause**: Contract not deployed or wrong network
**Fix**: `truffle migrate --reset` then copy ABI

### "Cannot read property 'methods' of undefined"
**Cause**: Missing `BNCalcolatoreOnChain.json` in web-interface/
**Fix**: Copy ABI file (see commands above)

### "Internal JSON-RPC error"
**Causes**:
- Account lacks required role → Use accounts[0] which has all roles
- All 5 evidence values not submitted → Submit E1-E5 before validating
- Shipment already paid → Check shipment state first

### Transaction Failures
Check in browser console (F12):
```javascript
contract._address              // Verify contract loaded
contract.methods._contatoreIdSpedizione().call() // Check shipment counter
```

### Backup Files Causing Issues
```bash
rm -f web-interface/*.backup   # Remove backup files
```

## Project Structure Notes

### Key Files
- `contracts/BNCalcolatoreOnChain.sol`: Main contract (~300 lines, includes CPT storage and Bayesian calculation)
- `migrations/2_deploy_oracolo.js`: Initializes CPT tables with realistic probabilities
- `web-interface/app.js`: Web3 integration and UI logic
- `web-interface/index.html`: Multi-role interface with role selector

### Documentation
- `README.md`: Quick start and overview
- `GUIDA_INSTALLAZIONE_E_TROUBLESHOOTING.md`: Detailed installation guide
- `MANUALE_UTENTE.md`: User manual for each role
- `MIGRAZIONE_BESU.md`: Guide for migrating from Ganache to Hyperledger Besu
- `DUAL_STRIDE_ANALYSIS.md`: Security analysis (STRIDE + i* diagrams)

### Design Patterns
- **Escrow Pattern**: ETH locked in contract until validation
- **Oracle Pattern**: Off-chain computation simulated, but Bayesian calculation is ON-CHAIN
- **Role-Based Access Control**: OpenZeppelin's AccessControl for permissions
- **Conditional Probability Tables (CPT)**: Stored on-chain as structs with 4 values each (p_FF, p_FT, p_TF, p_TT)

## Critical Constraints

### Compiler Configuration
- **Optimizer**: DISABLED (to avoid compiler bugs with nested functions)
- **EVM Version**: paris
- **Solidity Version**: 0.8.20 (specified in truffle-config.js)

### Gas Considerations
- Contract deployment: ~6.7M gas
- Create shipment: ~200k gas
- Send evidence: ~100k gas each
- Validate payment: ~150k gas

### Local Development Only
This is a LOCAL development environment. Each developer runs their own Ganache instance. The blockchain state is NOT shared between machines without advanced configuration.

## Security Context

The system implements:
- Access control for all critical functions
- Immutable evidence recording on-chain
- Escrow-based payment protection
- Transparent audit trail

For detailed security analysis, see `DUAL_STRIDE_ANALYSIS.md` which contains STRIDE threat models and i* diagrams with attack trees.
