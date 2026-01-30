
Write-Host "Diagnostica RPC Besu su porta 8545..." -ForegroundColor Cyan

$url = "http://127.0.0.1:8545"
$body = '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

try {
    Write-Host "Tentativo connessione a $url..."
    $response = Invoke-WebRequest -Uri $url -Method POST -ContentType "application/json" -Body $body -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
    
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Content: $($response.Content)" -ForegroundColor Gray
    
    if ($response.StatusCode -eq 200) {
        Write-Host "ESITO: SUCCESSO - Il nodo risponde correttamente." -ForegroundColor Green
    } else {
        Write-Host "ESITO: FALLITO - Status code non 200." -ForegroundColor Red
    }
} catch {
    Write-Host "ESITO: ERRORE ECCEZIONE" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.InnerException) {
        Write-Host "Inner: $($_.Exception.InnerException.Message)" -ForegroundColor Red
    }
    Write-Host "Status: $($_.Exception.Status)" -ForegroundColor Red
}

Write-Host "----------------------------------------"
Write-Host "Verifica Processo sulla porta 8545:"
netstat -ano | findstr ":8545"
