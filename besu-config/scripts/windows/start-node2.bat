@echo off
title Besu Node 2 - Validator
echo ========================================
echo [Node 2] Validator
echo ========================================
echo.
echo RPC Port:  8546
echo P2P Port:  30304
echo.


cd /d "%~dp0..\.."

REM Killing process on port 8546
echo [*] Pulizia porta 8546...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8546" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1


besu ^
  --data-path=node2/data ^
  --genesis-file=genesis-ibft.json ^
  --node-private-key-file=networkFiles/keys/0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd/key ^
  --rpc-http-enabled ^
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER ^
  --rpc-http-host=0.0.0.0 ^
  --rpc-http-port=8546 ^
  --rpc-http-cors-origins="*" ^
  --host-allowlist="*" ^
  --p2p-enabled=true ^
  --p2p-host=0.0.0.0 ^
  --p2p-port=30304 ^
  --discovery-enabled=true ^
  --min-gas-price=0 ^
  --miner-enabled=true ^
  --miner-coinbase=0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd ^
  --revert-reason-enabled=true ^
  --logging=INFO
