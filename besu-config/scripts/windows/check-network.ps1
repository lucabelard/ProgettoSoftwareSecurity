# Check Network Status
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Verifica stato nodi Besu..." -ForegroundColor Cyan
Write-Host "------------------------------------------------"

$nodes = @(
    @{Name="Node 1"; Port=8545},
    @{Name="Node 2"; Port=8546},
    @{Name="Node 3"; Port=8547},
    @{Name="Node 4"; Port=8548}
)

foreach ($node in $nodes) {
    try {
        $uri = "http://127.0.0.1:$($node.Port)"
        # Get Peer Count
        $peers = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' -TimeoutSec 2
        
        # Get Current Block
        $block = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' -TimeoutSec 2
        
        $peerCountInt = [Convert]::ToInt32($peers.result, 16)
        $blockInt = [Convert]::ToInt32($block.result, 16)
        
        Write-Host "$($node.Name) [$uri]" -ForegroundColor Yellow
        Write-Host "   Peers: $peerCountInt" -ForegroundColor Green
        Write-Host "   Block: $blockInt" -ForegroundColor Green
    } catch {
        Write-Host "$($node.Name) : OFFLINE" -ForegroundColor Red
    }
    Write-Host ""
}
