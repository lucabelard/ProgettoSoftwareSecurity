#!/bin/bash
# Script COMPLETO per deploy automatico su Besu

set -e

echo "════════════════════════════════════════════════════════════"
echo "   Deploy Automatico su Hyperledger Besu (Clique PoA)      "
echo "════════════════════════════════════════════════════════════"
echo ""

# [1] Cleanup
echo "[1/6] Pulizia dati precedenti..."
rm -rf besu-data besu.log
mkdir -p besu-data
echo "✓ Cleanup completato"

# [2] Avvio Besu
echo ""
echo "[2/6] Avvio Hyperledger Besu..."
cd besu-config
./start-besu-simple.sh > ../besu.log 2>&1 &
BESU_PID=$!
cd ..
echo "✓ Besu avviato (PID: $BESU_PID)"

# [3] Attesa avvio
echo ""
echo "[3/6] Attesa avvio Besu (15 secondi)..."
sleep 15

# Verifica connessione
BLOCK=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:8545 | grep -o '"result":"[^"]*"' || echo "FAIL")
if [[ "$BLOCK" == *"FAIL"* ]]; then
    echo "✗ Besu non risponde!"
    kill $BESU_PID 2>/dev/null || true
    exit 1
fi
echo "✓ Besu risponde: $BLOCK"

# [4] Deploy contratto
echo ""
echo "[4/6] Deploy smart contract..."
truffle migrate --network besu --reset > besu-deploy.log 2>&1 &
DEPLOY_PID=$!

# Monitora deploy e trigghiera mining
echo "⛏️  Avvio mining per processare transazioni..."
sleep 3

# Loop di mining per 60 secondi
for i in {1..30}; do
    # Trigger mining
    curl -s -X POST --data '{"jsonrpc":"2.0","method":"miner_start","params":[1],"id":1}' http://127.0.0.1:8545 > /dev/null
    sleep 1
    curl -s -X POST --data '{"jsonrpc":"2.0","method":"miner_stop","params":[],"id":1}' http://127.0.0.1:8545 > /dev/null
    sleep 1
    
    # Controlla se deploy è completato
    if ! kill -0 $DEPLOY_PID 2>/dev/null; then
        break
    fi
done

# Attendi completamento deploy
wait $DEPLOY_PID
DEPLOY_RESULT=$?

# [5] Verifica risultato
echo ""
echo "[5/6] Verifica deploy..."
if [ $DEPLOY_RESULT -eq 0 ]; then
    CONTRACT_ADDR=$(grep "contract address:" besu-deploy.log | tail -1 | awk '{print $4}')
    echo "✓ Contratto deployato: $CONTRACT_ADDR"
    
    # Verifica on-chain
    CODE=$(curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$CONTRACT_ADDR\",\"latest\"],\"id\":1}" http://127.0.0.1:8545 | grep -o '"result":"[^"]*"')
    if [[ "$CODE" == *"0x"* ]] && [[ ${#CODE} -gt 20 ]]; then
        echo "✓ Contratto verificato on-chain"
    else
        echo "⚠️  Warning: contratto potrebbe non essere stato minato"
    fi
else
    echo "✗ Errore durante deploy (vedi besu-deploy.log)"
fi

# [6] Test (opzionale)
echo ""
echo "[6/6] Vuoi eseguire i test? (richiede mining continuo)"
echo "Premi CTRL+C per saltare, o attendi 5 secondi..."
sleep 5

echo "🧪 Esecuzione test..."
truffle test --network besu &
TEST_PID=$!

# Mining continuo durante test
while kill -0 $TEST_PID 2>/dev/null; do
    curl -s -X POST --data '{"jsonrpc":"2.0","method":"miner_start","params":[1],"id":1}' http://127.0.0.1:8545 > /dev/null
    sleep 2
    curl -s -X POST --data '{"jsonrpc":"2.0","method":"miner_stop","params":[],"id":1}' http://127.0.0.1:8545 > /dev/null
    sleep 2
done

wait $TEST_PID

# Cleanup
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Deploy completato su Hyperledger Besu!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📊 Besu è ancora in esecuzione (PID: $BESU_PID)"
echo "Per fermarlo: kill $BESU_PID"
echo ""
