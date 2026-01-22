#!/bin/bash
# Start Node 3 - IBFT 2.0 Validator
# RPC: 8547, P2P: 30305
# Mac/Linux version

# Ottieni la directory dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

# Enode URL del Node 1 (bootstrap)
NODE1_ENODE="enode://a3b8e0409685e99e5f23b6c3e0e00be36d9aebfd5ebf08a1099b6651aed2e9c9ec5e4c61b5c9a1fd4b2f95d6d8e9f3a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6@127.0.0.1:30303"

echo "========================================"
echo "[Node 3] Starting Validator"
echo "========================================"
echo ""
echo "Configuration:"
echo "  RPC Port:  8547"
echo "  P2P Port:  30305"
echo "  Data Path: node3/data"
echo "  Bootstrap: Node 1 (127.0.0.1:30303)"
echo ""

# Crea cartelle necessarie
if [ ! -d "node3/data" ]; then
    echo "[*] Creating node3/data directory..."
    mkdir -p node3/data
fi

echo "[*] Starting Besu Node 3..."
echo ""

# Avvia Besu con i parametri configurati
besu \
    --data-path=node3/data \
    --genesis-file=genesis-ibft.json \
    --node-private-key-file=node3/data/key \
    --rpc-http-enabled \
    --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
    --rpc-http-host=127.0.0.1 \
    --rpc-http-port=8547 \
    --rpc-http-cors-origins="*" \
    --host-allowlist="*" \
    --p2p-enabled=true \
    --p2p-host=127.0.0.1 \
    --p2p-port=30305 \
    --discovery-enabled=true \
    --bootnodes="$NODE1_ENODE" \
    --p2p-peers-lower-bound=0 \
    --min-gas-price=0 \
    --miner-enabled=true \
    --miner-coinbase=0xa3275a2617911fc7d30b6cb960d4240eab55a58c \
    --revert-reason-enabled \
    --logging=INFO
