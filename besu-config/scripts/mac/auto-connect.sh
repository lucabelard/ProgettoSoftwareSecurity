#!/bin/bash
# Script per connettere automaticamente i nodi Besu in rete locale
# Eseguito automaticamente da start-network.sh

echo "In attesa che il Node 1 (Bootstrap) sia pronto..."

# Funzione per ottenere l'enode
get_enode() {
    port=$1
    curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://127.0.0.1:$port | grep -o 'enode://[^"]*'
}

# Funzione per aggiungere peer
add_peer() {
    port=$1
    enode=$2
    curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_addPeer\",\"params\":[\"$enode\"],\"id\":1}" http://127.0.0.1:$port > /dev/null
}

# Attendi Node 1
max_retries=30
count=0
node1_enode=""

while [ $count -lt $max_retries ]; do
    node1_enode=$(get_enode 8545)
    if [ ! -z "$node1_enode" ]; then
        break
    fi
    sleep 1
    echo -n "."
    count=$((count+1))
done
echo ""

if [ -z "$node1_enode" ]; then
    echo "ERRORE: Impossibile contattare Node 1 dopo 30 secondi."
    exit 1
fi

echo "Node 1 Trovato!"
echo "Enode: $node1_enode"
echo ""
echo "Connessione degli altri nodi al bootstrap..."

# Connetti Node 2, 3, 4
ports=(8546 8547 8548)
for port in "${ports[@]}"; do
    echo -n " - Connessione nodo su porta $port... "
    
    # Attendi che il nodo sia up
    node_ready=false
    for i in {1..10}; do
        if [ ! -z "$(get_enode $port)" ]; then
            node_ready=true
            break
        fi
        sleep 1
    done
    
    if [ "$node_ready" = true ]; then
        add_peer $port "$node1_enode"
        echo "OK"
    else
        echo "TIMEOUT (Il nodo non risponde)"
    fi
done

echo ""
echo "Configurazione rete completata."
