#!/bin/bash

# Parametri: $1=NodeName, $2=DataDir, $3=RpcPort, $4=P2PPort, $5=KeyFile, $6=NetworkId
NODE_NAME=$1
DATA_DIR=$2
RPC_PORT=$3
P2P_PORT=$4
KEY_FILE=$5
GENESIS_FILE="../../networkFiles/genesis-2025.json"

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
cd "$(dirname "$0")/../.."

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
  --min-gas-price=0 \
  --miner-enabled=true \
  --miner-coinbase=$(cat "$KEY_FILE.pub") \
  --revert-reason-enabled=true \
  --logging=INFO
