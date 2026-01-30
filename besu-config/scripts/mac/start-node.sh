#!/bin/bash

# Parametri: $1=NodeName, $2=DataDir, $3=RpcPort, $4=P2PPort, $5=KeyFile, $6=NetworkId
NODE_NAME=$1
DATA_DIR=$2
RPC_PORT=$3
P2P_PORT=$4
KEY_FILE=$5
GENESIS_FILE="besu-config/networkFiles/genesis-2025.json"

# Imposta il titolo del terminale
printf "\033]0;%s\007" "$NODE_NAME"

echo "========================================"
echo "Starting $NODE_NAME"
echo "========================================"
echo "RPC Port:  $RPC_PORT"
echo "P2P Port:  $P2P_PORT"
echo "Chain ID:  2025"
echo ""

# Torna alla root del progetto
cd "$(dirname "$0")/../../.."

# Ensure log directory exists
mkdir -p besu-config/logs
LOG_FILE="besu-config/logs/${NODE_NAME// /_}.log"
echo "Writing logs to $LOG_FILE"

besu \
  --data-path="$DATA_DIR" \
  --genesis-file="$GENESIS_FILE" \
  --node-private-key-file="$KEY_FILE" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
  --rpc-http-host=0.0.0.0 \
  --rpc-http-port=$RPC_PORT \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --p2p-enabled=true \
  --p2p-host=0.0.0.0 \
  --p2p-port=$P2P_PORT \
  --discovery-enabled=true \
  --min-gas-price=1000 \
  --miner-enabled=true \
  --miner-coinbase=$(basename $(dirname "$KEY_FILE")) \
  --revert-reason-enabled=true \
  --logging=INFO 2>&1 | tee "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Besu exited with code $EXIT_CODE"
    echo "Last 20 lines of log:"
    echo "---------------------"
    tail -n 20 "$LOG_FILE"
    echo "---------------------"
    read -p "Press Enter to exit..."
fi
