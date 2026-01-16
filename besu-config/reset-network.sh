#!/bin/bash
# Script per reset completo della rete Besu (elimina dati blockchain)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "═══════════════════════════════════════════════════"
echo "  🧹 RESET RETE BESU DISTRIBUITA"
echo "═══════════════════════════════════════════════════"
echo ""
echo "⚠️  ATTENZIONE: Questo eliminerà tutti i dati blockchain!"
echo ""
read -p "Confermi il reset? (y/N): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Reset annullato"
    exit 0
fi

echo ""
echo "🛑 Arresto nodi in esecuzione..."
./stop-network.sh

echo ""
echo "🗑️  Eliminazione dati blockchain..."

# Elimina database blockchain di ogni nodo
for i in 1 2 3 4; do
    if [ -d "node$i/data/database" ]; then
        rm -rf "node$i/data/database"
        echo "  ✅ Eliminato database Node $i"
    fi
    
    if [ -d "node$i/data/caches" ]; then
        rm -rf "node$i/data/caches"
        echo "  ✅ Eliminato cache Node $i"
    fi
    
    # Elimina log file
    if [ -f "node$i/besu.log" ]; then
        rm "node$i/besu.log"
        echo "  ✅ Eliminato log Node $i"
    fi
done

echo ""
echo "✅ Reset completato!"
echo ""
echo "Per riavviare la rete con blockchain pulita:"
echo "  ./start-network.sh"
echo ""
