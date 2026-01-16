#!/bin/bash
# Script per fermare la rete Besu distribuita

echo "═══════════════════════════════════════════════════"
echo "  🛑 ARRESTO RETE BESU DISTRIBUITA"
echo "═══════════════════════════════════════════════════"
echo ""

# Ferma tutti i processi Besu relativi ai nodi
echo "🛑 Arresto nodi Besu..."
pkill -f "besu.*node1" && echo "  ✅ Node 1 fermato"
pkill -f "besu.*node2" && echo "  ✅ Node 2 fermato"
pkill -f "besu.*node3" && echo "  ✅ Node 3 fermato"
pkill -f "besu.*node4" && echo "  ✅ Node 4 fermato"

sleep 2

# Verifica che tutti i processi siano effettivamente terminati
REMAINING=$(pgrep -f "besu.*node[1-4]" | wc -l)
if [ "$REMAINING" -eq 0 ]; then
    echo ""
    echo "✅ Tutti i nodi Besu sono stati fermati correttamente"
else
    echo ""
    echo "⚠️  Alcuni processi potrebbero essere ancora attivi ($REMAINING)"
    echo "   Usa 'ps aux | grep besu' per verificare"
    echo "   Force kill: pkill -9 -f besu"
fi

echo ""
echo "═══════════════════════════════════════════════════"
