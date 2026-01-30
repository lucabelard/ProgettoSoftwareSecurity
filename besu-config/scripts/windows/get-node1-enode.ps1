# Script per ottenere l'enode URL del Node 1
# Utilizzato per configurare i bootnodes negli altri nodi

$ErrorActionPreference = "Stop"

Write-Host "Recupero enode URL del Node 1..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8545" -Method POST -ContentType "application/json" -Body '{
        "jsonrpc":"2.0",
        "method":"admin_nodeInfo",
        "params":[],
        "id":1
    }' -TimeoutSec 5
    
    $enode = $response.result.enode
    
    Write-Host ""
    Write-Host "Enode Node 1:" -ForegroundColor Green
    Write-Host $enode -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Copia questo enode URL per configurare i bootnodes negli altri nodi." -ForegroundColor Gray
    
    return $enode
} catch {
    Write-Host ""
    Write-Host "ERRORE: Impossibile contattare Node 1 su porta 8545" -ForegroundColor Red
    Write-Host "Assicurati che il Node 1 sia in esecuzione." -ForegroundColor Yellow
    exit 1
}
