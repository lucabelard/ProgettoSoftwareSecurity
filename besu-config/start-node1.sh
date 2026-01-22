#!/bin/bash
# Start Node 1 - IBFT 2.0 Validator
# RPC: 8545, P2P: 30303

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Starting Besu Node 1 (Validator)..."

besu --data-path=node1/data \
  --genesis-file=genesis-ibft.json \
  --node-private-key-file=networkFiles/keys/0x8b175a2617911fc7d30b6cb960d4240eab55a58c/key \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8545 \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --p2p-enabled=true \
  --p2p-host=127.0.0.1 \
  --p2p-port=30303 \
  --min-gas-price=0 \
  --miner-enabled=true \
  --miner-coinbase=0x8b175a2617911fc7d30b6cb960d4240eab55a58c \
  --revert-reason-enabled \
  --logging=INFO
