#!/bin/bash

echo "============================================================"
echo "  PULIZIA DATI BESU (MAC OS)"
echo "============================================================"
echo ""
echo "ATTENZIONE: Questo cancellera' il database blockchain locale."
echo "Premi CTRL+C per annullare o INVIO per continuare..."
read

# Stop running processes (which triggers auto-close of terminals)
echo "[*] Stopping running nodes..."
pkill -f besu 2>/dev/null
pkill -f "besu-config/scripts/rpc-proxy.js" 2>/dev/null
sleep 1

# Force close Terminal windows for Nodes and Proxy
echo "[*] Closing terminal windows..."
osascript -e 'tell application "Terminal" to close (every window whose name contains "Besu")'
osascript -e 'tell application "Terminal" to close (every window whose name contains "Node")'
sleep 1

# Vai alla root del progetto
cd "$(dirname "$0")/../../.."

echo "[*] Cleaning Truffle build artifacts..."
rm -rf build

echo "[*] Cleaning Node 1..."
rm -rf besu-config/node1/data
mkdir -p besu-config/node1/data

echo "[*] Cleaning Node 2..."
rm -rf besu-config/node2/data
mkdir -p besu-config/node2/data

echo "[*] Cleaning Node 3..."
rm -rf besu-config/node3/data
mkdir -p besu-config/node3/data

echo ""
echo "!!! IMPORTANTE !!!"
echo "Quando riavvii la rete:"
echo "1. Se MetaMask mostra saldo 0 o transazioni bloccate:"
echo "2. Vai su Impostazioni > Avanzate > Resetta Account"
echo "   (Questo pulisce la cache locale, non cancella i fondi reali)"
echo "!!! IMPORTANTE !!!"
echo ""

echo "[*] Cleaning Node 4..."
rm -rf besu-config/node4/data
mkdir -p besu-config/node4/data

echo ""
echo "[*] Ripristino static-nodes.json..."
cp besu-config/static-nodes.json besu-config/node1/data/static-nodes.json
cp besu-config/static-nodes.json besu-config/node2/data/static-nodes.json
cp besu-config/static-nodes.json besu-config/node3/data/static-nodes.json
cp besu-config/static-nodes.json besu-config/node4/data/static-nodes.json

echo ""
echo "============================================================"
echo "  PULIZIA COMPLETATA"
echo "============================================================"
echo "Ora puoi avviare con start-all.sh"
