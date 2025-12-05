#!/bin/bash
# Avvio semplice di Besu per deploy automatico

besu --data-path=../besu-data \
  --genesis-file=./genesis.json \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,WEB3,CLIQUE,MINER,TXPOOL,ADMIN \
  --rpc-http-host=127.0.0.1 \
  --rpc-http-port=8545 \
  --rpc-http-cors-origins="*" \
  --host-allowlist="*" \
  --revert-reason-enabled \
  --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
  --min-gas-price=0 \
  --sync-mode=FULL \
  --discovery-enabled=false
