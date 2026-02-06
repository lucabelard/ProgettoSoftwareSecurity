#!/bin/bash

# Ottieni path assoluto dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")/../.."

if [ -z "$1" ]; then
    echo "UTILIZZO: ./ricarica-account.sh <INDIRIZZO_METAMASK>"
    echo "Esempio: ./ricarica-account.sh 0x123..."
    exit 1
fi

echo "==================================================="
echo "  RICARICA ACCOUNT (Faucet)"
echo "==================================================="
echo "Sto inviando 10 ETH all'indirizzo: $1"

# Installa web3 se manca (temporaneo, usa quello locale del progetto se possibile)
# Assumiamo che node_modules sia nel progetto root
export NODE_PATH="$PROJECT_ROOT/node_modules"

node "$PROJECT_ROOT/besu-config/scripts/top-up.js" "$1"
