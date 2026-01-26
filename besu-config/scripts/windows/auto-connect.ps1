# Script per connettere automaticamente i nodi Besu in rete locale
# Eseguito automaticamente da start-network.bat

$ErrorActionPreference = "Stop"

function Get-BesuEnode {
    param([int]$Port)
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$Port" -Method POST -ContentType "application/json" -Body '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' -TimeoutSec 3
        return $response.result.enode
    } catch {
        return $null
    }
}

function Add-BesuPeer {
    param([int]$Port, [string]$EnodeUrl)
    try {
        $body = @{
            jsonrpc = "2.0"
            method = "admin_addPeer"
            params = @($EnodeUrl)
            id = 1
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$Port" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 3
        return $response.result
    } catch {
        Write-Host "   Errore connessione su porta $Port" -ForegroundColor Red
        return $false
    }
}

Write-Host "In attesa che il Node 1 (Bootstrap) sia pronto..." -ForegroundColor Cyan

# Attendi Node 1
$retries = 0
$node1Enode = $null
while ($retries -lt 30) {
    $node1Enode = Get-BesuEnode -Port 8545
    if ($node1Enode) { break }
    Start-Sleep -Seconds 1
    $retries++
    Write-Host "." -NoNewline -ForegroundColor Gray
}
Write-Host ""

if (-not $node1Enode) {
    Write-Host "ERRORE: Impossibile contattare Node 1 dopo 30 secondi." -ForegroundColor Red
    exit 1
}

Write-Host "Node 1 Trovato!" -ForegroundColor Green
Write-Host "Enode: $node1Enode" -ForegroundColor Gray
Write-Host ""
Write-Host "Connessione degli altri nodi al bootstrap..." -ForegroundColor Cyan

# Connetti Node 2, 3, 4
$peers = @(8546, 8547, 8548)
foreach ($port in $peers) {
    Write-Host " - Connessione nodo su porta $port... " -NoNewline
    
    # Attendi che il nodo sia up
    $nodeReady = $false
    for ($i=0; $i -lt 10; $i++) {
        if (Get-BesuEnode -Port $port) { 
            $nodeReady = $true
            break 
        }
        Start-Sleep -Seconds 1
    }
    
    if ($nodeReady) {
        $res = Add-BesuPeer -Port $port -EnodeUrl $node1Enode
        if ($res -eq $true) {
            Write-Host "OK" -ForegroundColor Green
        } else {
            Write-Host "FALLITO" -ForegroundColor Red
        }
    } else {
        Write-Host "TIMEOUT (Il nodo non risponde)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Configurazione rete completata." -ForegroundColor Green
