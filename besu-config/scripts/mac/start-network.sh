#!/bin/bash
# Master script per avviare l'intera rete Besu distribuita (4 nodi IBFT 2.0)
# Mac/Linux version

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$ROOT_DIR"

echo "============================================================"
echo "  AVVIO RETE BESU DISTRIBUITA - 4 NODI IBFT 2.0"
echo "============================================================"
echo ""
echo "Configurazione della Rete:"
echo "  - Consenso: IBFT 2.0 (Istanbul Byzantine Fault Tolerance)"
echo "  - Numero Nodi Validator: 4"
echo "  - Byzantine Fault Tolerance: f=1"
echo "  - Rete: localhost (simulazione distribuzione)"
echo ""
echo "Porte dei Nodi:"
echo "  - Node 1 (Bootstrap): RPC=8545, P2P=30303"
echo "  - Node 2 (Validator):  RPC=8546, P2P=30304"
echo "  - Node 3 (Validator):  RPC=8547, P2P=30305"
echo "  - Node 4 (Validator):  RPC=8548, P2P=30306"
echo ""
echo "============================================================"
echo ""

# Ferma eventuali nodi già in esecuzione
echo "[*] Pulizia eventuali processi Besu esistenti..."
pkill -f "besu.*--data-path=node" 2>/dev/null || true
sleep 2

# Funzione per avviare un nodo in background
start_node() {
    local node_num=$1
    local script_path=$2
    
    echo "[*] Avvio Node $node_num..."
    
    # Rendi eseguibile lo script
    chmod +x "$script_path"
    
    # Avvia il nodo in background e cattura il PID
    "$script_path" > "node${node_num}/node${node_num}.log" 2>&1 &
    local pid=$!
    
    echo "   PID: $pid"
    echo "$pid" > "node${node_num}/node${node_num}.pid"
    
    return 0
}

# Avvia i nodi in sequenza con delay per stabilità
echo ""
echo "[FASE 1] Avvio Bootstrap Node (Node 1)..."
start_node 1 "./scripts/mac/start-node1.sh"
echo "   Attesa 8 secondi per inizializzazione bootstrap node..."
sleep 8

echo ""
echo "[FASE 2] Avvio Validator Nodes (Nodes 2-4)..."
start_node 2 "./scripts/mac/start-node2.sh"
sleep 3

start_node 3 "./scripts/mac/start-node3.sh"
sleep 3

start_node 4 "./scripts/mac/start-node4.sh"

echo ""
echo "============================================================"
echo "[FASE 3] Sincronizzazione P2P in corso..."
echo "============================================================"
echo "   Attendere 12 secondi per peer discovery e handshake..."
sleep 12

echo ""
echo "============================================================"
echo "  ✓ RETE BESU AVVIATA CON SUCCESSO!"
echo "============================================================"
echo ""

# Leggi e mostra i PID
if [ -f "node1/node1.pid" ]; then
    NODE1_PID=$(cat node1/node1.pid)
fi
if [ -f "node2/node2.pid" ]; then
    NODE2_PID=$(cat node2/node2.pid)
fi
if [ -f "node3/node3.pid" ]; then
    NODE3_PID=$(cat node3/node3.pid)
fi
if [ -f "node4/node4.pid" ]; then
    NODE4_PID=$(cat node4/node4.pid)
fi

echo "Process IDs dei Nodi:"
echo "   Node 1 (Bootstrap): PID $NODE1_PID"
echo "   Node 2 (Validator): PID $NODE2_PID"
echo "   Node 3 (Validator): PID $NODE3_PID"
echo "   Node 4 (Validator): PID $NODE4_PID"
echo ""

echo "Comandi Utili:"
echo "   ./scripts/mac/check-network.sh  - Verifica stato rete"
echo "   ./scripts/mac/stop-network.sh   - Ferma tutta la rete"
echo ""

echo "Endpoints JSON-RPC:"
echo "   Node 1: http://127.0.0.1:8545"
echo "   Node 2: http://127.0.0.1:8546"
echo "   Node 3: http://127.0.0.1:8547"
echo "   Node 4: http://127.0.0.1:8548"
echo ""

echo "Log Files:"
echo "   Node 1: tail -f node1/node1.log"
echo "   Node 2: tail -f node2/node2.log"
echo "   Node 3: tail -f node3/node3.log"
echo "   Node 4: tail -f node4/node4.log"
echo ""
