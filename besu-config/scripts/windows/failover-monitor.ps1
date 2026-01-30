# Besu Failover Monitor - Mantiene sempre un nodo sulla porta 8545
# Se il nodo principale cade, avvia automaticamente un nodo di backup sulla stessa porta

param(
    [int]$CheckIntervalSeconds = 10
)

$PRIMARY_PORT = 8545
$BESU_DIR = "C:\Users\andre\Documents\GitHub\ProgettoSoftwareSecurity\besu-config"

# Configurazione nodi con le loro porte originali
$NODES = @(
    @{ Name = "Node1"; Port = 8545; P2P = 30303; DataPath = "node1"; Key = "networkFiles/keys/0x8b175a2617911fc7d30b6cb960d4240eab55a58c/key"; Coinbase = "0x8b175a2617911fc7d30b6cb960d4240eab55a58c" },
    @{ Name = "Node2"; Port = 8546; P2P = 30304; DataPath = "node2"; Key = "networkFiles/keys/0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd/key"; Coinbase = "0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd" },
    @{ Name = "Node3"; Port = 8547; P2P = 30305; DataPath = "node3"; Key = "networkFiles/keys/0xba3cc3e7110c0b33d357868178acc766c12c9417/key"; Coinbase = "0xba3cc3e7110c0b33d357868178acc766c12c9417" },
    @{ Name = "Node4"; Port = 8548; P2P = 30306; DataPath = "node4"; Key = "networkFiles/keys/0xd211d619bde1991e23849a16188722e40c0cf334/key"; Coinbase = "0xd211d619bde1991e23849a16188722e40c0cf334" }
)

$currentPrimaryNode = $null

function Test-PortListening {
    param([int]$Port)
    
    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        return $connections.Count -gt 0
    } catch {
        return $false
    }
}

function Test-BesuHealthy {
    param([int]$Port)
    
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port" `
            -Method POST `
            -ContentType "application/json" `
            -Body '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' `
            -TimeoutSec 10 `
            -UseBasicParsing `
            -ErrorAction Stop
        
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Start-BesuNode {
    param($Node, [int]$OverridePort = $null)
    
    $port = if ($OverridePort) { $OverridePort } else { $Node.Port }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] > Avvio $($Node.Name) sulla porta $port..." -ForegroundColor Green
    
    $startJobScript = {
        param($BesuDir, $Node, $Port)
        
        Set-Location $BesuDir
        
        $arguments = @(
            "--data-path=$($Node.DataPath)/data",
            "--genesis-file=genesis-ibft.json",
            "--node-private-key-file=$($Node.Key)",
            "--rpc-http-enabled",
            "--rpc-http-api=ETH,NET,WEB3,IBFT,ADMIN,TXPOOL,MINER",
            "--rpc-http-host=0.0.0.0",
            "--rpc-http-port=$Port",
            "--rpc-http-cors-origins=`"*`"",
            "--host-allowlist=`"*`"",
            "--p2p-enabled=true",
            "--p2p-host=0.0.0.0",
            "--p2p-port=$($Node.P2P)",
            "--discovery-enabled=true",
            "--min-gas-price=0",
            "--miner-enabled=true",
            "--miner-coinbase=$($Node.Coinbase)",
            "--revert-reason-enabled=true",
            "--logging=INFO"
        )
        
        Start-Process -FilePath "besu" `
            -ArgumentList $arguments `
            -WindowStyle Normal `
            -PassThru
    }
    
    $process = & $startJobScript -BesuDir $BESU_DIR -Node $Node -Port $port
    
    # Attendi che il nodo sia pronto
    $maxWait = 30
    $waited = 0
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 2
        $waited += 2
        
        if (Test-BesuHealthy -Port $port) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] OK $($Node.Name) avviato e pronto sulla porta $port" -ForegroundColor Green
            return $process
        }
    }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] WARN $($Node.Name) avviato ma non risponde ancora" -ForegroundColor Yellow
    return $process
}

function Stop-BesuProcess {
    param([int]$Port)
    
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($connection) {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] STOP Terminazione processo sulla porta $Port (PID $($process.Id))" -ForegroundColor Yellow
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
                Start-Sleep -Seconds 2
                return $true
            }
        }
        return $false
    } catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ERROR Errore terminazione processo - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-NextAvailableNode {
    # Trova un nodo non utilizzato per il failover
    foreach ($node in $NODES) {
        $processRunning = Get-Process -Name besu -ErrorAction SilentlyContinue | 
            Where-Object { $_.CommandLine -like "*$($node.DataPath)*" }
        
        if (-not $processRunning) {
            return $node
        }
    }
    
    # Se tutti i nodi sono in esecuzione, usa Node2 come fallback
    return $NODES[1]
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BESU FAILOVER MONITOR - Porta Principale $PRIMARY_PORT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Avvia il nodo primario (Node1) sulla porta principale
$currentPrimaryNode = $NODES[0]
Start-BesuNode -Node $currentPrimaryNode -OverridePort $PRIMARY_PORT | Out-Null

Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Inizio monitoraggio (controllo ogni $CheckIntervalSeconds secondi)..." -ForegroundColor Cyan
Write-Host ""

$failoverCount = 0
$consecutiveFailures = 0
$MAX_FAILURES = 3

while ($true) {
    Start-Sleep -Seconds $CheckIntervalSeconds
    
    # Controlla se la porta principale è ancora attiva e sana
    $portListening = Test-PortListening -Port $PRIMARY_PORT
    $nodeHealthy = Test-BesuHealthy -Port $PRIMARY_PORT
    
    if (-not $portListening -or -not $nodeHealthy) {
        $consecutiveFailures++
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] WARN Check fallito ($consecutiveFailures/$MAX_FAILURES) - Porta aperta: $portListening, Risposta RPC: $nodeHealthy" -ForegroundColor Yellow
        
        if ($consecutiveFailures -ge $MAX_FAILURES) {
            $failoverCount++
            $consecutiveFailures = 0 # Reset counter
            
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host " FAILOVER RILEVATO! Tentativo #$failoverCount" -ForegroundColor Red
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ERROR Nodo sulla porta $PRIMARY_PORT non risponde dopo $MAX_FAILURES tentativi" -ForegroundColor Red
            
            # Termina il processo sulla porta (se esiste)
            Stop-BesuProcess -Port $PRIMARY_PORT
            
            # Trova un nodo di backup disponibile
            $backupNode = Get-NextAvailableNode
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] FAILOVER Avvio $($backupNode.Name) come nodo primario sulla porta $PRIMARY_PORT..." -ForegroundColor Yellow
            
            # Avvia il nodo di backup sulla porta principale
            $currentPrimaryNode = $backupNode
            Start-BesuNode -Node $backupNode -OverridePort $PRIMARY_PORT | Out-Null
            
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Green
            Write-Host " FAILOVER COMPLETATO!" -ForegroundColor Green
            Write-Host " Porta $PRIMARY_PORT ora servita da $($backupNode.Name)" -ForegroundColor Green
            Write-Host "============================================================" -ForegroundColor Green
            Write-Host ""
        }
    } else {
        # Reset counter se il check passa
        $consecutiveFailures = 0
        
        # Nodo sano - log ogni minuto circa
        if ((Get-Date).Second % 60 -lt $CheckIntervalSeconds) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] OK $($currentPrimaryNode.Name) sulla porta $PRIMARY_PORT funzionante" -ForegroundColor Gray
        }
    }
}
