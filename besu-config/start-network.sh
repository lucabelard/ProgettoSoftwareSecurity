#!/bin/bash
# Master script per avviare l'intera rete Besu distribuita (4 nodi IBFT 2.0)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "═══════════════════════════════════════════════════"
echo "  🚀 AVVIO RETE BESU DISTRIBUITA"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Configurazione:"
echo "  • 4 Nodi Validator IBFT 2.0"
echo "  • Byzantine Fault Tolerance: f=1"
echo "  • Rete P2P: localhost (simulazione distribuzione)"
echo ""
echo "Porte utilizzate:"
echo "  • Node 1: RPC=8545, P2P=30303"
echo "  • Node 2: RPC=8546, P2P=30304"
echo "  • Node 3: RPC=8547, P2P=30305"
echo "  • Node 4: RPC=8548, P2P=30306"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""

# Ferma eventuali nodi già in esecuzione
echo "🧹 Pulizia eventuali processi Besu esistenti..."
pkill -f "besu.*node[1-4]" 2>/dev/null
sleep 2

# Avvia i nodi in background con delay per stabilità
echo "🚀 Avvio Node 1 (Bootstrap)..."
./start-node1.sh > node1/besu.log 2>&1 &
NODE1_PID=$!
echo "   PID: $NODE1_PID"
sleep 5  # Attendi che Node 1 sia ready come bootstrap

echo "🚀 Avvio Node 2..."
./start-node2.sh > node2/besu.log 2>&1 &
NODE2_PID=$!
echo "   PID: $NODE2_PID"
sleep 3

echo "🚀 Avvio Node 3..."
./start-node3.sh > node3/besu.log 2>&1 &
NODE3_PID=$!
echo "   PID: $NODE3_PID"
sleep 3

echo "🚀 Avvio Node 4..."
./start-node4.sh > node4/besu.log 2>&1 &
NODE4_PID=$!
echo "   PID: $NODE4_PID"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  ⏳ Attendi 10 secondi per sincronizzazione P2P..."
echo "═══════════════════════════════════════════════════"
sleep 10

echo ""
echo "✅ Rete Besu avviata!"
echo ""
echo "📊 Verifica stato rete:"
echo "   ./check-network.sh"
echo ""
echo "🛑 Ferma rete:"
echo "   ./stop-network.sh"
echo ""
echo "📋 PIDs processi:"
echo "   Node 1: $NODE1_PID"
echo "   Node 2: $NODE2_PID"
echo "   Node 3: $NODE3_PID"
echo "   Node 4: $NODE4_PID"
echo ""
echo "📜 Log files:"
echo "   tail -f node1/besu.log"
echo "   tail -f node2/besu.log"
echo "   tail -f node3/besu.log"
echo "   tail -f node4/besu.log"
echo ""
