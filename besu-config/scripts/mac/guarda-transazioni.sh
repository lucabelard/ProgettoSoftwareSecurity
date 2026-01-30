#!/bin/bash

# Ottieni path assoluto dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")/../.."

echo "============================================"
echo "  MONITOR TRANSAZIONI BESU"
echo "  (Ascolto blocchi in tempo reale...)"
echo "============================================"
echo ""

cd "$PROJECT_ROOT"
node monitor-transazioni.js
