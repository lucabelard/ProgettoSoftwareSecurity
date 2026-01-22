#!/bin/bash
# Script per verificare lo stato della rete Besu
# Mac/Linux version

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}  VERIFICA STATO RETE BESU${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# Array di nodi da verificare
declare -a nodes=(
    "Node 1:http://127.0.0.1:8545"
    "Node 2:http://127.0.0.1:8546"
    "Node 3:http://127.0.0.1:8547"
    "Node 4:http://127.0.0.1:8548"
)

all_nodes_ok=true

for node_info in "${nodes[@]}"; do
    IFS=':' read -r node_name rpc_proto rpc_rest <<< "$node_info"
    rpc_url="${rpc_proto}:${rpc_rest}"
    
    echo -e "${CYAN}[$node_name] Controllo su $rpc_url...${NC}"
    
    # Test connessione HTTP - web3_clientVersion
    if response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
        -H "Content-Type: application/json" \
        --connect-timeout 5 \
        --max-time 10 \
        "$rpc_url" 2>/dev/null); then
        
        client_version=$(echo "$response" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$client_version" ]; then
            echo -e "   ${GREEN}✓ Online - Versione: $client_version${NC}"
            
            # Test numero di peer
            peer_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":2}' \
                -H "Content-Type: application/json" \
                --connect-timeout 5 \
                "$rpc_url" 2>/dev/null)
            peer_count_hex=$(echo "$peer_response" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
            peer_count=$((peer_count_hex))
            echo "   Peers connessi: $peer_count"
            
            # Test ultimo blocco
            block_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":3}' \
                -H "Content-Type: application/json" \
                --connect-timeout 5 \
                "$rpc_url" 2>/dev/null)
            block_hex=$(echo "$block_response" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
            block_number=$((block_hex))
            echo "   Ultimo blocco: #$block_number"
            
            # Test isListening
            listen_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":4}' \
                -H "Content-Type: application/json" \
                --connect-timeout 5 \
                "$rpc_url" 2>/dev/null)
            is_listening=$(echo "$listen_response" | grep -o '"result":[^,}]*' | cut -d':' -f2)
            
            if [ "$is_listening" == "true" ]; then
                echo "   P2P Listening: ✓"
            else
                echo -e "   ${RED}P2P Listening: ✗${NC}"
            fi
        else
            echo -e "   ${YELLOW}⚠ Online ma risposta non valida${NC}"
            all_nodes_ok=false
        fi
    else
        echo -e "   ${RED}✗ OFFLINE o non raggiungibile${NC}"
        all_nodes_ok=false
    fi
    
    echo ""
done

echo -e "${CYAN}============================================================${NC}"
if [ "$all_nodes_ok" = true ]; then
    echo -e "${GREEN}  ✓ TUTTI I NODI SONO OPERATIVI${NC}"
else
    echo -e "${YELLOW}  ⚠ ALCUNI NODI HANNO PROBLEMI${NC}"
fi
echo -e "${CYAN}============================================================${NC}"
echo ""

# Verifica processi in esecuzione
echo -e "${CYAN}Processi Besu in esecuzione:${NC}"
if pgrep -f "besu.*--data-path=node" > /dev/null; then
    ps aux | grep "besu.*--data-path=node" | grep -v grep | awk '{printf "   PID: %-7s RAM: %-8s CPU: %-6s\n", $2, $6/1024"MB", $3"%"}'
else
    echo -e "${RED}   Nessun processo Besu trovato!${NC}"
fi
echo ""
