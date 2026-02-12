#!/bin/bash
echo "Arresto di tutti i nodi Besu e del Proxy..."

# Kill all besu processes matching the pattern "besu"
# Using -f to match against full command line if needed, but pkill besu usually works if binary is named besu
pkill -f besu

# Kill the proxy script which runs via node
pkill -f "besu-config/scripts/monitoring/rpc-proxy.js"

echo "Fatto."
