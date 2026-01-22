#!/bin/bash
# Start Besu Network (Mac/Linux)

# Stop existing nodes
pkill -f besu

echo "============================================================"
echo "  AVVIO RETE BESU DISTRIBUITA (4 Nodi)"
echo "============================================================"
echo ""

# Go to script directory
cd "$(dirname "$0")"

echo "[*] Avvio Node 1 (Bootstrap)..."
./start-node1.sh > ../../node1/besu.log 2>&1 &

echo "[*] Attesa inizializzazione Node 1 (5s)..."
sleep 5

echo "[*] Avvio Node 2..."
./start-node2.sh > ../../node2/besu.log 2>&1 &

echo "[*] Avvio Node 3..."
./start-node3.sh > ../../node3/besu.log 2>&1 &

echo "[*] Avvio Node 4..."
./start-node4.sh > ../../node4/besu.log 2>&1 &

echo ""
echo "[*] Esecuzione script di connessione automatica (P2P Discovery)..."
./auto-connect.sh

echo ""
echo "============================================================"
echo "  RETE AVVIATA!"
echo "============================================================"
echo ""
echo "Log disponibili in node*/besu.log"
echo "Per verificare status: ./check-network.sh"
echo "Per fermare: ./stop-network.sh"
