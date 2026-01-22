#!/bin/bash
# Start Node 2 - IBFT 2.0 Validator
# RPC: 8546, P2P: 30304

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Starting Besu Node 2 (Validator)..."

besu --data-path=node2/data \
  --genesis-file=genesis-ibft.json \
  --node-private-key-file=networkFiles/keys/0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd/key \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8546 \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --p2p-enabled=true \
  --p2p-host=127.0.0.1 \
  --p2p-port=30304 \
  --bootnodes=enode://45f0d281c7989da0c1f13ae13fde1ac9d36f34734ed31b94d7b8088cdedbf62c7d2ae47f5649a6412fa7769d4da0cf89d64c5a945e16b8b7f32408e4ac4816d7@127.0.0.1:30303 \
  --min-gas-price=0 \
  --miner-enabled=true \
  --miner-coinbase=0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd \
  --revert-reason-enabled \
  --logging=INFO
