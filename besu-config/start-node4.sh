#!/bin/bash
# Start Node 4 - IBFT 2.0 Validator
# RPC: 8548, P2P: 30306

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Starting Besu Node 4 (Validator)..."

besu --data-path=node4/data \
  --genesis-file=genesis-ibft.json \
  --node-private-key-file=node4/data/key \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8548 \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --p2p-enabled=true \
  --p2p-host=127.0.0.1 \
  --p2p-port=30306 \
  --bootnodes=enode://45f0d281c7989da0c1f13ae13fde1ac9d36f34734ed31b94d7b8088cdedbf62c7d2ae47f5649a6412fa7769d4da0cf89d64c5a945e16b8b7f32408e4ac4816d7@127.0.0.1:30303 \
  --min-gas-price=0 \
  --miner-enabled=true \
  --miner-coinbase=0xd211d619bde1991e23849a16188722e40c0cf334 \
  --revert-reason-enabled \
  --logging=INFO
