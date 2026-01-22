# Master script per avviare l'intera rete Besu distribuita (4 nodi IBFT 2.0)
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RootDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  AVVIO RETE BESU DISTRIBUITA - 4 NODI IBFT 2.0" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configurazione della Rete:" -ForegroundColor Yellow
Write-Host "  - Consenso: IBFT 2.0 (Istanbul Byzantine Fault Tolerance)" -ForegroundColor Gray
Write-Host "  - Numero Nodi Validator: 4" -ForegroundColor Gray
Write-Host "  - Byzantine Fault Tolerance: f=1" -ForegroundColor Gray
Write-Host "  - Rete: localhost (simulazione distribuzione)" -ForegroundColor Gray
Write-Host ""
Write-Host "Porte dei Nodi:" -ForegroundColor Yellow
Write-Host "  - Node 1 (Bootstrap): RPC=8545, P2P=30303" -ForegroundColor Gray
Write-Host "  - Node 2 (Validator):  RPC=8546, P2P=30304" -ForegroundColor Gray
Write-Host "  - Node 3 (Validator):  RPC=8547, P2P=30305" -ForegroundColor Gray
Write-Host "  - Node 4 (Validator):  RPC=8548, P2P=30306" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Ferma eventuali nodi già in esecuzione
Write-Host "[*] Pulizia eventuali processi Besu esistenti..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.Name -like "*besu*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Funzione per avviare un nodo
function Start-BesuNode {
    param(
        [int]$NodeNumber,
        [string]$ScriptPath
    )
    
    Write-Host "[*] Avvio Node $NodeNumber..." -ForegroundColor Green
    
    # Avvia lo script del nodo in una nuova finestra PowerShell
    $processInfo = Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $ScriptPath `
        -WorkingDirectory $RootDir `
        -PassThru
    
    $nodeJobId = $processInfo.Id
    Write-Host "   PID: $nodeJobId" -ForegroundColor Gray
    
    return $nodeJobId
}

# Avvia i nodi in sequenza con delay per stabilità
Write-Host ""
Write-Host "[FASE 1] Avvio Bootstrap Node (Node 1)..." -ForegroundColor Cyan
$Node1ID = Start-BesuNode -NodeNumber 1 -ScriptPath ".\scripts\windows\start-node1.ps1"
Write-Host "   Attesa 8 secondi per inizializzazione bootstrap node..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "[FASE 2] Avvio Validator Nodes (Nodes 2-4)..." -ForegroundColor Cyan
$Node2ID = Start-BesuNode -NodeNumber 2 -ScriptPath ".\scripts\windows\start-node2.ps1"
Start-Sleep -Seconds 3

$Node3ID = Start-BesuNode -NodeNumber 3 -ScriptPath ".\scripts\windows\start-node3.ps1"
Start-Sleep -Seconds 3

$Node4ID = Start-BesuNode -NodeNumber 4 -ScriptPath ".\scripts\windows\start-node4.ps1"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[FASE 3] Sincronizzazione P2P in corso..." -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   Attendere 12 secondi per peer discovery e handshake..." -ForegroundColor Gray
Start-Sleep -Seconds 12

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  ✓ RETE BESU AVVIATA CON SUCCESSO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Process IDs dei Nodi:" -ForegroundColor Cyan
Write-Host "   Node 1 (Bootstrap): PID $Node1ID" -ForegroundColor Gray
Write-Host "   Node 2 (Validator): PID $Node2ID" -ForegroundColor Gray
Write-Host "   Node 3 (Validator): PID $Node3ID" -ForegroundColor Gray
Write-Host "   Node 4 (Validator): PID $Node4ID" -ForegroundColor Gray
Write-Host ""

Write-Host "Comandi Utili:" -ForegroundColor Cyan
Write-Host "   .\scripts\windows\check-network.ps1  - Verifica stato rete" -ForegroundColor Gray
Write-Host "   .\scripts\windows\stop-network.ps1   - Ferma tutta la rete" -ForegroundColor Gray
Write-Host ""

Write-Host "Endpoints JSON-RPC:" -ForegroundColor Cyan
Write-Host "   Node 1: http://127.0.0.1:8545" -ForegroundColor Gray
Write-Host "   Node 2: http://127.0.0.1:8546" -ForegroundColor Gray
Write-Host "   Node 3: http://127.0.0.1:8547" -ForegroundColor Gray
Write-Host "   Node 4: http://127.0.0.1:8548" -ForegroundColor Gray
Write-Host ""

# Salva i PID in un file per poterli recuperare dopo
$pids = @{
    Node1 = $Node1ID
    Node2 = $Node2ID
    Node3 = $Node3ID
    Node4 = $Node4ID
}
$pids | ConvertTo-Json | Out-File -FilePath ".\besu-network-pids.json" -Encoding UTF8
Write-Host "PID salvati in: besu-network-pids.json" -ForegroundColor Gray
Write-Host ""
