#!/bin/bash
# Check Network Status

echo "Verifica stato nodi Besu..."
echo "------------------------------------------------"

check_node() {
    name=$1
    port=$2
    
    # Get Peer Count
    peers=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://127.0.0.1:$port)
    
    # Get Block Number
    block=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:$port)
    
    if [ -z "$peers" ]; then
        echo "$name [http://127.0.0.1:$port]: OFFLINE"
    else
        # Extract hex values and convert to decimal using python or printf if possible, keeping it simple here
        peer_hex=$(echo $peers | grep -o '0x[0-9a-fA-F]*')
        block_hex=$(echo $block | grep -o '0x[0-9a-fA-F]*')
        
        echo "$name [http://127.0.0.1:$port]"
        echo "   Peers: $peer_hex"
        echo "   Block: $block_hex"
    fi
    echo ""
}

check_node "Node 1" 8545
check_node "Node 2" 8546
check_node "Node 3" 8547
check_node "Node 4" 8548
