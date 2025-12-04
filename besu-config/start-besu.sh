#!/bin/bash
# Script per avviare Hyperledger Besu in modalità sviluppo

# Crea directory per i dati se non esiste
mkdir -p besu-data

echo "🚀 Avvio Hyperledger Besu..."
echo "📍 Chain ID: 1337"
echo "🌐 RPC: http://127.0.0.1:8545"
echo "🔌 WebSocket: ws://127.0.0.1:8546"
echo ""

besu --data-path=besu-data \
  --genesis-file=besu-config/genesis.json \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,ADMIN,DEBUG,MINER,TXPOOL \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8545 \
  --rpc-http-cors-origins="*" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,WEB3,ADMIN,DEBUG,MINER,TXPOOL \
  --rpc-ws-host=127.0.0.1 \
  --rpc-ws-port=8546 \
  --host-allowlist="*" \
  --revert-reason-enabled \
  --miner-enabled \
  --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
  --min-gas-price=0 \
  --network-id=1337
