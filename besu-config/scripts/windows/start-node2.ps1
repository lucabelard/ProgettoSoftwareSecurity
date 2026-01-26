# Start Node 2 - IBFT 2.0 Validator
# RPC: 8546, P2P: 30304
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RootDir

# Ottieni la chiave pubblica del Node 1 per creare l'enode URL
$node1KeyContent = Get-Content -Path "node1/data/key" -Raw
$node1Key = $node1KeyContent.Trim() -replace "0x", ""

# Calcola l'enode public key dal private key usando besu
# Per ora usiamo un valore hardcoded (da generare con besu public-key export)
$node1Enode = "enode://a3b8e0409685e99e5f23b6c3e0e00be36d9aebfd5ebf08a1099b6651aed2e9c9ec5e4c61b5c9a1fd4b2f95d6d8e9f3a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6@127.0.0.1:30303"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[Node 2] Starting Validator" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  RPC Port:  8546" -ForegroundColor Gray
Write-Host "  P2P Port:  30304" -ForegroundColor Gray
Write-Host "  Data Path: node2/data" -ForegroundColor Gray
Write-Host "  Bootstrap: Node 1 (127.0.0.1:30303)" -ForegroundColor Gray
Write-Host ""

# Crea cartelle necessarie
if (-not (Test-Path "node2/data")) {
    Write-Host "[*] Creating node2/data directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "node2/data" -Force | Out-Null
}

Write-Host "[*] Starting Besu Node 2..." -ForegroundColor Green
Write-Host ""

# Avvia Besu con i parametri configurati
& besu `
    --data-path=node2/data `
    --genesis-file=genesis-ibft.json `
    --node-private-key-file=node2/data/key `
    --rpc-http-enabled `
    --rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER `
    --rpc-http-host=127.0.0.1 `
    --rpc-http-port=8546 `
    --rpc-http-cors-origins="*" `
    --host-allowlist="*" `
    --p2p-enabled=true `
    --p2p-host=127.0.0.1 `
    --p2p-port=30304 `
    --discovery-enabled=true `
    --bootnodes=$node1Enode `
    --p2p-peers-lower-bound=0 `
    --min-gas-price=0 `
    --miner-enabled=true `
    --miner-coinbase=0x9b275a2617911fc7d30b6cb960d4240eab55a58c `
    --revert-reason-enabled `
    --logging=INFO
