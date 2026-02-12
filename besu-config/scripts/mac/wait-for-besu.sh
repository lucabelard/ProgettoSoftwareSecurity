#!/bin/bash

# Configuration
NODE_URL="http://127.0.0.1:8551"
MAX_RETRIES=40
DELAY=3

echo "[*] Waiting for Besu Node 1 to be ready at $NODE_URL..."

for ((i=1; i<=MAX_RETRIES; i++)); do
    # Try to get blockNumber as a simple health check
    RESPONSE=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' -H "Content-Type: application/json" $NODE_URL)
    
    if [[ $RESPONSE == *"result"* ]]; then
        echo "   [OK] Node is responsive!"
        echo "   [*] Giving it 10s to warm up fully..."
        sleep 10
        exit 0
    fi
    
    echo "   [$i/$MAX_RETRIES] Node not ready yet. Retrying in ${DELAY}s..."
    sleep $DELAY
done

echo "[ERROR] Timeout waiting for Besu node."
exit 1
