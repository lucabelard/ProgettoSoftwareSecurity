# Start Node 1 - IBFT 2.0 Validator
# RPC: 8545, P2P: 30303
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "[*] Starting Besu Node 1 (Validator)..." -ForegroundColor Green

# Crea cartelle necessarie
if (-not (Test-Path "node1/data")) {
    New-Item -ItemType Directory -Path "node1/data" -Force | Out-Null
}

# Avvia Besu con i parametri configurati
& besu `
    --data-path=node1/data `
    --genesis-file=genesis-ibft.json `
    --node-private-key-file=node1/data/key `
    --rpc-http-enabled `
    --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER `
    --rpc-http-host=127.0.0.1 `
    --rpc-http-port=8545 `
    --rpc-http-cors-origins="*" `
    --host-allowlist="*" `
    --p2p-enabled=true `
    --p2p-host=127.0.0.1 `
    --p2p-port=30303 `
    --p2p-peers-lower-bound=0 `
    --min-gas-price=0 `
    --miner-enabled=true `
    --miner-coinbase=0x8b175a2617911fc7d30b6cb960d4240eab55a58c `
    --revert-reason-enabled `
    --logging=INFO
