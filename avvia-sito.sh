#!/bin/bash
# Script di avvio per macOS/Linux

cd web-interface

echo "==================================================="
echo "  AVVIO INTERFACCIA WEB (Mac/Linux)"
echo "==================================================="
echo ""
echo "Sto avviando un server locale per il sito."
echo "Se richiesto, installa http-server premendo 'y'."
echo ""
echo "Quando appare l'indirizzo (es: http://127.0.0.1:8080):"
echo "1. Apri quel link nel browser"
echo "2. Assicurati che MetaMask sia connesso a Localhost 8545 (Chain ID 2024)"
echo ""

# Esegui il server con caching disabilitato (-c-1)
npx http-server -c-1
