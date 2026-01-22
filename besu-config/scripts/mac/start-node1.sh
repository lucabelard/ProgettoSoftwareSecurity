#!/bin/bash
# Start Node 1 - IBFT 2.0 Validator (Bootstrap Node)
# RPC: 8545, P2P: 30303
# Mac/Linux version

# Ottieni la directory dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

echo "========================================"
echo "[Node 1] Starting Bootstrap Validator"
echo "========================================"
echo ""
echo "Configuration:"
echo "  RPC Port:  8545"
echo "  P2P Port:  30303"
echo "  Data Path: node1/data"
echo ""

# Crea cartelle necessarie
if [ ! -d "node1/data" ]; then
    echo "[*] Creating node1/data directory..."
    mkdir -p node1/data
fi

echo "[*] Starting Besu Node 1..."
echo ""

# Avvia Besu con i parametri configurati
besu \
    --data-path=node1/data \
    --genesis-file=genesis-ibft.json \
    --node-private-key-file=node1/data/key \
    --rpc-http-enabled \
    --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
    --rpc-http-host=127.0.0.1 \
    --rpc-http-port=8545 \
    --rpc-http-cors-origins="*" \
    --host-allowlist="*" \
    --p2p-enabled=true \
    --p2p-host=127.0.0.1 \
    --p2p-port=30303 \
    --discovery-enabled=true \
    --p2p-peers-lower-bound=0 \
    --min-gas-price=0 \
    --miner-enabled=true \
    --miner-coinbase=0x8b175a2617911fc7d30b6cb960d4240eab55a58c \
    --revert-reason-enabled \
    --logging=INFO
