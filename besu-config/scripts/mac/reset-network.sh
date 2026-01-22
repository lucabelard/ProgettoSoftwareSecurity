#!/bin/bash
# Script per resettare la rete Besu (mantiene le chiavi, elimina i dati blockchain)
# Mac/Linux version

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}  RESET RETE BESU${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${RED}ATTENZIONE: Questo script eliminerà tutti i dati blockchain${NC}"
echo -e "${YELLOW}ma manterrà le chiavi dei nodi.${NC}"
echo ""

read -p "Sei sicuro di voler procedere? (y/N): " confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo -e "${YELLOW}Operazione annullata.${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}[STEP 1] Arresto di tutti i nodi...${NC}"
./scripts/mac/stop-network.sh

echo ""
echo -e "${CYAN}[STEP 2] Eliminazione dati blockchain...${NC}"

for node_num in {1..4}; do
    node_path="node${node_num}/data"
    
    if [ -d "$node_path" ]; then
        echo -e "${YELLOW}   [*] Reset Node $node_num...${NC}"
        
        # Salva la chiave privata
        key_file="$node_path/key"
        if [ -f "$key_file" ]; then
            key_backup=$(cat "$key_file")
        else
            key_backup=""
        fi
        
        # Elimina tutti i contenuti della directory data
        rm -rf "$node_path"/*
        
        # Ripristina la chiave privata
        if [ -n "$key_backup" ]; then
            echo -n "$key_backup" > "$key_file"
            echo -e "      ${GREEN}✓ Chiave privata preservata${NC}"
        fi
    else
        echo -e "   [*] Node $node_num: path non trovato, creazione..."
        mkdir -p "$node_path"
    fi
    
    # Elimina file PID e log
    rm -f "node${node_num}/node${node_num}.pid"
    rm -f "node${node_num}/node${node_num}.log"
done

echo ""
echo -e "${CYAN}[STEP 3] Pulizia file di stato...${NC}"
if [ -f "besu-network-pids.json" ]; then
    rm -f "besu-network-pids.json"
    echo -e "   ${GREEN}✓ File PID eliminato${NC}"
fi

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  ✓ RESET COMPLETATO${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${CYAN}La rete è stata resettata. Puoi riavviarla con:${NC}"
echo "   ./scripts/mac/start-network.sh"
echo ""
