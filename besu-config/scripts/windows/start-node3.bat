@echo off
title Besu Node 3 - Validator
echo ========================================
echo [Node 3] Validator
echo ========================================
echo.
echo RPC Port:  8547
echo P2P Port:  30305
echo.


cd /d "%~dp0..\.."

REM Killing process on port 8547
echo [*] Pulizia porta 8547...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8547" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1


besu ^
  --data-path=node3/data ^
  --genesis-file=genesis-ibft.json ^
  --node-private-key-file=networkFiles/keys/0xba3cc3e7110c0b33d357868178acc766c12c9417/key ^
  --rpc-http-enabled ^
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER ^
  --rpc-http-host=0.0.0.0 ^
  --rpc-http-port=8547 ^
  --rpc-http-cors-origins="*" ^
  --host-allowlist="*" ^
  --p2p-enabled=true ^
  --p2p-host=0.0.0.0 ^
  --p2p-port=30305 ^
  --discovery-enabled=true ^
  --min-gas-price=1000 ^
  --miner-enabled=true ^
  --miner-coinbase=0xba3cc3e7110c0b33d357868178acc766c12c9417 ^
  --revert-reason-enabled=true ^
  --logging=INFO
