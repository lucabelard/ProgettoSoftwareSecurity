#!/bin/bash
# Script per avviare Hyperledger Besu con Clique PoA e sealer unlocked

# Setup sealer account
if [ ! -f "../besu-data/password.txt" ]; then
    echo "🔧 Setup account sealer..."
    ./setup-sealer.sh
fi

echo "🚀 Avvio Hyperledger Besu con Clique PoA (Auto-sealing)..."
echo "📍 Chain ID: 1337"
echo "🌐 RPC: http://127.0.0.1:8545"
echo "🔌 WebSocket: ws://127.0.0.1:8546"
echo "⛏️  Sealer: 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73"
echo ""

besu --data-path=../besu-data \
  --genesis-file=./genesis.json \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,CLIQUE,DEBUG,MINER,TXPOOL,ADMIN \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8545 \
  --rpc-http-cors-origins="*" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,WEB3,CLIQUE,DEBUG,MINER,TXPOOL \
  --rpc-ws-host=127.0.0.1 \
  --rpc-ws-port=8546 \
  --host-allowlist="*" \
  --revert-reason-enabled \
  --miner-enabled \
  --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
  --min-gas-price=0 \
  --tx-pool-price-bump=0 \
  --sync-mode=FULL \
  --discovery-enabled=false &

BESU_PID=$!
echo "Besu started with PID: $BESU_PID"

# Aspetta che Besu sia pronto
sleep 10

# Unlock account via RPC
echo "🔓 Unlocking sealer account..."
curl -X POST --data '{
  "jsonrpc":"2.0",
  "method":"personal_unlockAccount",
  "params":["0xfe3b557e8fb62b89f4916b721be55ceb828dbd73", "", null],
  "id":1
}' http://127.0.0.1:8545

echo ""
echo "✓ Besu pronto per mining automatico!"

# Mantieni processo in foreground
wait $BESU_PID
