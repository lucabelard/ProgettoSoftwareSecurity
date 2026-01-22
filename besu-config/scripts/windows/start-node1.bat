@echo off
title Besu Node 1 - Bootstrap Validator
echo ========================================
echo [Node 1] Bootstrap Validator
echo ========================================
echo.
echo RPC Port:  8545
echo P2P Port:  30303
echo.

cd /d "%~dp0..\.."

besu ^
  --data-path=node1/data ^
  --genesis-file=genesis-ibft.json ^
  --node-private-key-file=networkFiles/keys/0x8b175a2617911fc7d30b6cb960d4240eab55a58c/key ^
  --rpc-http-enabled ^
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER ^
  --rpc-http-host=0.0.0.0 ^
  --rpc-http-port=8545 ^
  --rpc-http-cors-origins="*" ^
  --host-allowlist="*" ^
  --p2p-enabled=true ^
  --p2p-host=0.0.0.0 ^
  --p2p-port=30303 ^
  --discovery-enabled=true ^
  --min-gas-price=0 ^
  --miner-enabled=true ^
  --miner-coinbase=0x8b175a2617911fc7d30b6cb960d4240eab55a58c ^
  --revert-reason-enabled=true ^
  --logging=INFO
