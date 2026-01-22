# Script per verificare lo stato della rete Besu
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RootDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  VERIFICA STATO RETE BESU" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Array di nodi da verificare
$nodes = @(
    @{Name="Node 1"; RPC="http://127.0.0.1:8545"},
    @{Name="Node 2"; RPC="http://127.0.0.1:8546"},
    @{Name="Node 3"; RPC="http://127.0.0.1:8547"},
    @{Name="Node 4"; RPC="http://127.0.0.1:8548"}
)

$allNodesOk = $true

foreach ($node in $nodes) {
    Write-Host "[$($node.Name)] Controllo su $($node.RPC)..." -ForegroundColor Cyan
    
    try {
        # Test connessione HTTP
        $result = Invoke-WebRequest -Uri $node.RPC -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' `
            -TimeoutSec 5 -ErrorAction Stop
        
        $response = $result.Content | ConvertFrom-Json
        if ($response.result) {
            Write-Host "   ✓ Online - Versione: $($response.result)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Online ma risposta non valida" -ForegroundColor Yellow
        }
        
        # Test numero di peer
        $peerResult = Invoke-WebRequest -Uri $node.RPC -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":2}' `
            -TimeoutSec 5 -ErrorAction Stop
        
        $peerResponse = $peerResult.Content | ConvertFrom-Json
        $peerCount = [Convert]::ToInt32($peerResponse.result, 16)
        Write-Host "   Peers connessi: $peerCount" -ForegroundColor Gray
        
        # Test ultimo blocco
        $blockResult = Invoke-WebRequest -Uri $node.RPC -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":3}' `
            -TimeoutSec 5 -ErrorAction Stop
        
        $blockResponse = $blockResult.Content | ConvertFrom-Json
        $blockNumber = [Convert]::ToInt32($blockResponse.result, 16)
        Write-Host "   Ultimo blocco: #$blockNumber" -ForegroundColor Gray
        
        # Test isListening
        $listenResult = Invoke-WebRequest -Uri $node.RPC -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":4}' `
            -TimeoutSec 5 -ErrorAction Stop
        
        $listenResponse = $listenResult.Content | ConvertFrom-Json
        if ($listenResponse.result -eq $true) {
            Write-Host "   P2P Listening: ✓" -ForegroundColor Gray
        } else {
            Write-Host "   P2P Listening: ✗" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "   ✗ OFFLINE o non raggiungibile" -ForegroundColor Red
        Write-Host "   Errore: $($_.Exception.Message)" -ForegroundColor DarkGray
        $allNodesOk = $false
    }
    
    Write-Host ""
}

Write-Host "============================================================" -ForegroundColor Cyan
if ($allNodesOk) {
    Write-Host "  ✓ TUTTI I NODI SONO OPERATIVI" -ForegroundColor Green
} else {
    Write-Host "  ⚠ ALCUNI NODI HANNO PROBLEMI" -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Verifica processi in esecuzione
Write-Host "Processi Besu in esecuzione:" -ForegroundColor Cyan
$besuProcesses = Get-Process | Where-Object {$_.Name -like "*besu*"} | Select-Object Id, ProcessName, @{Name="Memory(MB)";Expression={[Math]::Round($_.WorkingSet64/1MB, 2)}}
if ($besuProcesses) {
    $besuProcesses | Format-Table -AutoSize
} else {
    Write-Host "   Nessun processo Besu trovato!" -ForegroundColor Red
}
Write-Host ""
