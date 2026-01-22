# Master script per avviare l'intera rete Besu distribuita (4 nodi IBFT 2.0)
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  [START] AVVIO RETE BESU DISTRIBUITA" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configurazione:"
Write-Host "  - 4 Nodi Validator IBFT 2.0"
Write-Host "  - Byzantine Fault Tolerance: f=1"
Write-Host "  - Rete P2P: localhost (simulazione distribuzione)"
Write-Host ""
Write-Host "Porte utilizzate:"
Write-Host "  - Node 1: RPC=8545, P2P=30303"
Write-Host "  - Node 2: RPC=8546, P2P=30304"
Write-Host "  - Node 3: RPC=8547, P2P=30305"
Write-Host "  - Node 4: RPC=8548, P2P=30306"
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Ferma eventuali nodi già in esecuzione
Write-Host "[*] Pulizia eventuali processi Besu esistenti..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.Name -like "*besu*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Funzione per avviare un nodo
function Start-BesuNode {
    param(
        [int]$NodeNumber,
        [string]$ScriptName
    )
    
    Write-Host "[*] Avvio Node $NodeNumber..." -ForegroundColor Green
    
    # Crea la directory dei log se non esiste
    if (-not (Test-Path "node$NodeNumber")) {
        New-Item -ItemType Directory -Path "node$NodeNumber" -Force | Out-Null
    }
    
    # Avvia lo script del nodo in background usando Start-Process
    $processInfo = Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoExit", "-File", $ScriptName `
        -WorkingDirectory $ScriptDir `
        -PassThru
    
    $nodeJobId = $processInfo.Id
    Write-Host "   Process ID: $nodeJobId" -ForegroundColor Gray
    
    return $nodeJobId
}

# Avvia i nodi in background con delay per stabilità
$Node1ID = Start-BesuNode -NodeNumber 1 -ScriptName ".\start-node1.ps1"
Start-Sleep -Seconds 5  # Attendi che Node 1 sia ready come bootstrap

$Node2ID = Start-BesuNode -NodeNumber 2 -ScriptName ".\start-node2.ps1"
Start-Sleep -Seconds 3

$Node3ID = Start-BesuNode -NodeNumber 3 -ScriptName ".\start-node3.ps1"
Start-Sleep -Seconds 3

$Node4ID = Start-BesuNode -NodeNumber 4 -ScriptName ".\start-node4.ps1"

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  [WAIT] Attendi 10 secondi per sincronizzazione P2P..." -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "[OK] Rete Besu avviata!" -ForegroundColor Green
Write-Host ""
Write-Host "Comandi disponibili:" -ForegroundColor Cyan
Write-Host "   .\check-network.ps1    - Verifica stato rete"
Write-Host "   .\stop-network.ps1     - Ferma rete"
Write-Host ""
Write-Host "Process IDs processi:" -ForegroundColor Cyan
Write-Host "   Node 1: $Node1ID"
Write-Host "   Node 2: $Node2ID"
Write-Host "   Node 3: $Node3ID"
Write-Host "   Node 4: $Node4ID"
Write-Host ""
Write-Host "Per visualizzare i log:" -ForegroundColor Cyan
Write-Host "   Get-Process -Id $Node1ID | Select-Object Name, Id, Memory"
Write-Host ""
