#!/bin/bash
# Start Node 3 - IBFT 2.0 Validator
# RPC: 8547, P2P: 30305

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Starting Besu Node 3 (Validator)..."

besu --data-path=node3/data \
  --genesis-file=genesis-ibft.json \
  --node-private-key-file=networkFiles/keys/0xba3cc3e7110c0b33d357868178acc766c12c9417/key \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8547 \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --p2p-enabled=true \
  --p2p-host=127.0.0.1 \
  --p2p-port=30305 \
  --bootnodes=enode://45f0d281c7989da0c1f13ae13fde1ac9d36f34734ed31b94d7b8088cdedbf62c7d2ae47f5649a6412fa7769d4da0cf89d64c5a945e16b8b7f32408e4ac4816d7@127.0.0.1:30303 \
  --min-gas-price=0 \
  --miner-enabled=true \
  --miner-coinbase=0xba3cc3e7110c0b33d357868178acc766c12c9417 \
  --revert-reason-enabled \
  --logging=INFO
