#!/bin/bash
# Script per verificare lo stato della rete Besu distribuita

echo "═══════════════════════════════════════════════════"
echo "  🔍 DIAGNOSTICA RETE BESU DISTRIBUITA"
echo "═══════════════════════════════════════════════════"
echo ""

# Funzione per query JSON-RPC
query_rpc() {
    local port=$1
    local method=$2
    local params=$3
    
    curl -s -X POST \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":$params,\"id\":1}" \
        -H "Content-Type: application/json" \
        http://localhost:$port 2>/dev/null
}

# Funzione per convertire hex in decimale
hex_to_dec() {
    local hex=$1
    echo $((hex))
}

echo "📡 CONNETTIVITÀ P2P"
echo "───────────────────────────────────────────────────"
for port in 8545 8546 8547 8548; do
    node_num=$((port - 8544))
    response=$(query_rpc $port "net_peerCount" "[]")
    
    if [ $? -eq 0 ] && [ ! -z "$response" ]; then
        peer_count_hex=$(echo $response | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        peer_count=$(hex_to_dec $peer_count_hex)
        
        if [ "$peer_count" -ge 3 ]; then
            echo "  ✅ Node $node_num (port $port): $peer_count peers connessi"
        elif [ "$peer_count" -ge 1 ]; then
            echo "  ⚠️  Node $node_num (port $port): $peer_count peers (attesi: 3)"
        else
            echo "  ❌ Node $node_num (port $port): Nessun peer connesso"
        fi
    else
        echo "  ❌ Node $node_num (port $port): OFFLINE o non raggiungibile"
    fi
done

echo ""
echo "📦 SINCRONIZZAZIONE BLOCKCHAIN"
echo "───────────────────────────────────────────────────"
blocks=()
for port in 8545 8546 8547 8548; do
    node_num=$((port - 8544))
    response=$(query_rpc $port "eth_blockNumber" "[]")
    
    if [ $? -eq 0 ] && [ ! -z "$response" ]; then
        block_hex=$(echo $response | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        block_dec=$(hex_to_dec $block_hex)
        blocks+=($block_dec)
        echo "  📊 Node $node_num: Blocco #$block_dec"
    else
        blocks+=(0)
        echo "  ❌ Node $node_num: Non disponibile"
    fi
done

# Verifica consenso
echo ""
echo "🔐 CONSENSO IBFT 2.0"
echo "───────────────────────────────────────────────────"
all_same=true
first_block=${blocks[0]}
for block in "${blocks[@]}"; do
    if [ "$block" != "$first_block" ]; then
        all_same=false
        break
    fi
done

if [ "$all_same" = true ] && [ "$first_block" -gt 0 ]; then
    echo "  ✅ Consenso raggiunto: Tutti i nodi al blocco #$first_block"
else
    echo "  ⚠️  Consenso in corso o nodi non sincronizzati"
    echo "     Blocchi: ${blocks[@]}"
fi

echo ""
echo "⚙️  PROCESSI SISTEMA"
echo "───────────────────────────────────────────────────"
node_processes=$(pgrep -f "besu.*node[1-4]" | wc -l)
echo "  Nodi Besu attivi: $node_processes/4"

if [ "$node_processes" -eq 4 ]; then
    echo "  ✅ Tutti i nodi sono in esecuzione"
elif [ "$node_processes" -gt 0 ]; then
    echo "  ⚠️  Solo $node_processes nodi in esecuzione"
else
    echo "  ❌ Nessun nodo Besu in esecuzione"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo ""

# Riepilogo finale
if [ "$node_processes" -eq 4 ] && [ "$all_same" = true ] && [ "$first_block" -gt 0 ]; then
    echo "✅ STATO RETE: OPERATIVA"
    echo "   • 4 nodi attivi e sincronizzati"
    echo "   • Consensus IBFT 2.0 funzionante"
    echo "   • Byzantine Fault Tolerance: ✅"
else
    echo "⚠️  STATO RETE: IN AVVIO O PROBLEMI"
    echo "   Suggerimenti:"
    echo "   • Attendi 30 secondi per la sincronizzazione iniziale"
    echo "   • Controlla i log: tail -f node*/besu.log"
    echo "   • Riavvia la rete: ./stop-network.sh && ./start-network.sh"
fi

echo ""
