#!/bin/bash
# Script per fermare tutti i nodi Besu della rete
# Mac/Linux version

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

echo "============================================================"
echo "  ARRESTO RETE BESU"
echo "============================================================"
echo ""

# Funzione per fermare un nodo tramite PID file
stop_node() {
    local node_num=$1
    local pid_file="node${node_num}/node${node_num}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        echo "[*] Arresto Node $node_num (PID: $pid)..."
        
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            sleep 1
            
            # Se ancora attivo, kill -9
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
            echo "   ✓ Node $node_num arrestato"
        else
            echo "   Node $node_num già arrestato"
        fi
        
        rm -f "$pid_file"
    else
        echo "[*] Node $node_num: nessun PID file trovato"
    fi
}

# Arresta i nodi in ordine inverso
stop_node 4
stop_node 3
stop_node 2
stop_node 1

# Fallback: cerca e ferma tutti i processi besu correlati
echo ""
echo "[*] Ricerca di eventuali altri processi Besu..."
BESU_PIDS=$(pgrep -f "besu.*--data-path=node" || true)

if [ -n "$BESU_PIDS" ]; then
    echo "   Trovati processi Besu aggiuntivi: $BESU_PIDS"
    pkill -f "besu.*--data-path=node" || true
    sleep 1
    pkill -9 -f "besu.*--data-path=node" 2>/dev/null || true
else
    echo "   Nessun altro processo Besu trovato"
fi

sleep 2

echo ""
echo "============================================================"
echo "  ✓ RETE BESU ARRESTATA"
echo "============================================================"
echo ""
