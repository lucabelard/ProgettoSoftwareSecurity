@echo off
title Besu Node 4 - Validator
echo ========================================
echo [Node 4] Validator
echo ========================================
echo.
echo RPC Port:  8548
echo P2P Port:  30306
echo.


cd /d "%~dp0..\.."

REM Killing process on port 8548
echo [*] Pulizia porta 8548...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8548" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1


besu ^
  --data-path=node4/data ^
  --genesis-file=genesis-ibft.json ^
  --node-private-key-file=networkFiles/keys/0xd211d619bde1991e23849a16188722e40c0cf334/key ^
  --rpc-http-enabled ^
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER ^
  --rpc-http-host=0.0.0.0 ^
  --rpc-http-port=8548 ^
  --rpc-http-cors-origins="*" ^
  --host-allowlist="*" ^
  --p2p-enabled=true ^
  --p2p-host=0.0.0.0 ^
  --p2p-port=30306 ^
  --discovery-enabled=true ^
  --min-gas-price=0 ^
  --miner-enabled=true ^
  --miner-coinbase=0xd211d619bde1991e23849a16188722e40c0cf334 ^
  --revert-reason-enabled=true ^
  --logging=INFO
