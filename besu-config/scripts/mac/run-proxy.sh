#!/bin/bash

# run-proxy.sh
# Wrapper per rpc-proxy.js capace di chiudere la finestra al termine

PROJECT_ROOT=$1
PROXY_SCRIPT="$PROJECT_ROOT/besu-config/scripts/rpc-proxy.js"
NODE_NAME="Besu Failover Proxy"

# Imposta titolo
printf "\033]0;%s\007" "$NODE_NAME"

echo "========================================"
echo "Starting $NODE_NAME"
echo "========================================"

cd "$PROJECT_ROOT" || exit 1

# Start Proxy
node "$PROXY_SCRIPT"

EXIT_CODE=$?

# Se il processo termina (normalmente o via pkill che uccide node), chiudiamo la finestra.
# Nota: node potrebbe uscire con vari codici.
# Se pkill colpisce node, node muore. Bash vede exit code.
# Vogliamo chiudere la finestra SE l'utente non ha premuto Ctrl+C interattivamente?
# O sempre se muore per stop-network? stop-network fa pkill -f rpc-proxy.js

# Se l'exit code indica terminazione forzata o successo, chiudi.
# Se è errore "vero", magari no? Ma l'utente vuole che si chiudano.
# Assumiamo behavior come start-node.sh

# 143 = SIGTERM, 130 = SIGINT, 0 = OK
if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 143 ] && [ $EXIT_CODE -ne 130 ]; then
    echo "ERROR: Proxy exited with code $EXIT_CODE"
    read -p "Press Enter to exit..."
else
    # Auto-close
    osascript -e "tell application \"Terminal\" to close (every window whose name contains \"$NODE_NAME\")" &
    exit 0
fi
