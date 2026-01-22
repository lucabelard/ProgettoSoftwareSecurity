# Start Node 3 - IBFT 2.0 Validator
# RPC: 8547, P2P: 30305
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "[*] Starting Besu Node 3 (Validator)..." -ForegroundColor Green

# Crea cartelle necessarie
if (-not (Test-Path "node3/data")) {
    New-Item -ItemType Directory -Path "node3/data" -Force | Out-Null
}

# Avvia Besu con i parametri configurati
& besu `
    --data-path=node3/data `
    --genesis-file=genesis-ibft.json `
    --node-private-key-file=node3/data/key `
    --rpc-http-enabled `
    --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER `
    --rpc-http-host=127.0.0.1 `
    --rpc-http-port=8547 `
    --rpc-http-cors-origins="*" `
    --host-allowlist="*" `
    --p2p-enabled=true `
    --p2p-host=127.0.0.1 `
    --p2p-port=30305 `
    --p2p-peers-lower-bound=0 `
    --min-gas-price=0 `
    --miner-enabled=true `
    --miner-coinbase=0xab375a2617911fc7d30b6cb960d4240eab55a58c `
    --revert-reason-enabled `
    --logging=INFO
