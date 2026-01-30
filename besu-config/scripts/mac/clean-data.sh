#!/bin/bash

echo "============================================================"
echo "  PULIZIA DATI BESU (MAC OS)"
echo "============================================================"
echo ""
echo "ATTENZIONE: Questo cancellera' il database blockchain locale."
echo "Premi CTRL+C per annullare o INVIO per continuare..."
read

# Vai alla root del progetto
cd "$(dirname "$0")/../../.."

echo "[*] Cleaning Node 1..."
rm -rf besu-config/node1/data
mkdir -p besu-config/node1/data

echo "[*] Cleaning Node 2..."
rm -rf besu-config/node2/data
mkdir -p besu-config/node2/data

echo "[*] Cleaning Node 3..."
rm -rf besu-config/node3/data
mkdir -p besu-config/node3/data

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
