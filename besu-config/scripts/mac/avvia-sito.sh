#!/bin/bash

# Ottieni path assoluto dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")/../.."

echo "==================================================="
echo "  AVVIO INTERFACCIA WEB"
echo "==================================================="
echo ""
echo "Sto avviando un server locale per il sito."
echo "Se richiesto, installa http-server premendo 'y'."
echo ""
echo "Quando appare l'indirizzo (es: http://127.0.0.1:8080):"
echo "1. Apri quel link nel browser"
echo "2. Assicurati che MetaMask sia connesso a Localhost 8545 (Chain ID 2025)"
echo ""

cd "$PROJECT_ROOT/web-interface"
npx http-server -c-1
