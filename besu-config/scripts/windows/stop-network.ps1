# Script per fermare tutti i nodi Besu della rete
# Windows PowerShell version

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RootDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ARRESTO RETE BESU" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Leggi i PID salvati se esistono
$pidsFile = ".\besu-network-pids.json"
if (Test-Path $pidsFile) {
    Write-Host "[*] Lettura PID salvati da file..." -ForegroundColor Yellow
    $pids = Get-Content $pidsFile | ConvertFrom-Json
    
    Write-Host "[*] Arresto nodi tramite PID..." -ForegroundColor Yellow
    
    foreach ($nodeName in @("Node1", "Node2", "Node3", "Node4")) {
        $pid = $pids.$nodeName
        if ($pid) {
            try {
                $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                if ($process) {
                    Write-Host "   Arresto $nodeName (PID: $pid)..." -ForegroundColor Gray
                    Stop-Process -Id $pid -Force
                }
            } catch {
                Write-Host "   $nodeName (PID: $pid) già arrestato" -ForegroundColor DarkGray
            }
        }
    }
    
    # Rimuovi il file dei PID
    Remove-Item $pidsFile -Force -ErrorAction SilentlyContinue
}

# Fallback: cerca e ferma tutti i processi besu
Write-Host ""
Write-Host "[*] Ricerca di eventuali altri processi Besu..." -ForegroundColor Yellow
$besuProcesses = Get-Process | Where-Object {$_.Name -like "*besu*"}

if ($besuProcesses) {
    Write-Host "   Trovati $($besuProcesses.Count) processi Besu" -ForegroundColor Gray
    $besuProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "   Nessun altro processo Besu trovato" -ForegroundColor Gray
}

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  ✓ RETE BESU ARRESTATA" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
