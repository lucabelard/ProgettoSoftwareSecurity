# Test script per verificare se l'enode URL funziona
$ErrorActionPreference = "Stop"

Write-Host "Test connessione bootnode Node 2..." -ForegroundColor Cyan

cd besu-config

$env:BESU_OPTS = ""

besu `
  --data-path=node2/data `
  --genesis-file=genesis-ibft.json `
  --node-private-key-file=networkFiles/keys/0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd/key `
  --rpc-http-enabled `
  --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER `
  --rpc-http-host=0.0.0.0 `
  --rpc-http-port=8546 `
  --rpc-http-cors-origins="*" `
  --host-allowlist="*" `
  --p2p-enabled=true `
  --p2p-host=0.0.0.0 `
  --p2p-port=30304 `
  --discovery-enabled=true `
  --bootnodes="enode://45f0d281c7989d33e15f94992ca94dd90ef1b6f34e15a1b0aaef2be53b9816d7@127.0.0.1:30303" `
  --min-gas-price=0 `
  --miner-enabled=true `
  --miner-coinbase=0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd `
  --revert-reason-enabled=true `
  --logging=INFO
