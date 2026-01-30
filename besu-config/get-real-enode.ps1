# get-real-enode.ps1
$response = Invoke-RestMethod -Uri "http://127.0.0.1:8545" -Method POST -ContentType "application/json" -Body '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}'
$enode = $response.result.enode
Write-Output $enode
