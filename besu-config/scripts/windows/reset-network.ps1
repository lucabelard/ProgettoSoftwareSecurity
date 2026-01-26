# Script per resettare la rete Besu (mantiene le chiavi, elimina i dati blockchain)
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RootDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  RESET RETE BESU" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ATTENZIONE: Questo script eliminerà tutti i dati blockchain" -ForegroundColor Red
Write-Host "ma manterrà le chiavi dei nodi." -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Sei sicuro di voler procedere? (y/N)"

if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Operazione annullata." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "[STEP 1] Arresto di tutti i nodi..." -ForegroundColor Cyan
& ".\scripts\windows\stop-network.ps1"

Write-Host ""
Write-Host "[STEP 2] Eliminazione dati blockchain..." -ForegroundColor Cyan

foreach ($nodeNum in 1..4) {
    $nodePath = "node$nodeNum\data"
    
    if (Test-Path $nodePath) {
        Write-Host "   [*] Reset Node $nodeNum..." -ForegroundColor Yellow
        
        # Salva la chiave privata
        $keyFile = "$nodePath\key"
        $keyBackup = $null
        if (Test-Path $keyFile) {
            $keyBackup = Get-Content $keyFile -Raw
        }
        
        # Elimina tutti i contenuti della directory data
        Get-ChildItem -Path $nodePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        # Ricrea la directory
        Remove-Item -Path $nodePath -Force -Recurse -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $nodePath -Force | Out-Null
        
        # Ripristina la chiave privata
        if ($keyBackup) {
            Set-Content -Path $keyFile -Value $keyBackup -NoNewline
            Write-Host "      ✓ Chiave privata preservata" -ForegroundColor Green
        }
    } else {
        Write-Host "   [*] Node $nodeNum: path non trovato, creazione..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path $nodePath -Force | Out-Null
    }
}

# Elimina file di stato
Write-Host ""
Write-Host "[STEP 3] Pulizia file di stato..." -ForegroundColor Cyan
if (Test-Path "besu-network-pids.json") {
    Remove-Item "besu-network-pids.json" -Force
    Write-Host "   ✓ File PID eliminato" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  ✓ RESET COMPLETATO" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "La rete è stata resettata. Puoi riavviarla con:" -ForegroundColor Cyan
Write-Host "   .\scripts\windows\start-network.ps1" -ForegroundColor Gray
Write-Host ""
