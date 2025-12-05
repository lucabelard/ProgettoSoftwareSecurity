#!/bin/bash
# Test completo del sistema su blockchain privata

echo "════════════════════════════════════════════════════════════"
echo "   Test Sistema Oracolo Bayesiano - Blockchain Privata      "
echo "════════════════════════════════════════════════════════════"
echo ""

# Killa eventuali Ganache esistenti
pkill -f "ganache" 2>/dev/null || true
sleep 2

# [1/3] Avvio blockchain
echo "[1/3] Avvio blockchain privata (Ganache)..."
npx -y ganache-cli@latest --deterministic --networkId 1337 --port 7545 --defaultBalanceEther 1000 > /dev/null 2>&1 &
GANACHE_PID=$!
echo "✓ Blockchain avviata (PID: $GANACHE_PID)"
sleep 5

# [2/3] Deploy contratto
echo "📦 Deploy smart contract..."
truffle migrate --reset > deploy.log 2>&1
if [ $? -eq 0 ]; then
    CONTRACT_ADDR=$(grep "contract address:" deploy.log | tail -1 | awk '{print $4}')
    echo "✓ Contratto deployato: $CONTRACT_ADDR"
else
    echo "✗ Errore deploy. Vedi deploy.log"
    kill $GANACHE_PID
    exit 1
fi

# [3/3] Esecuzione test
echo "🧪 Esecuzione test suite (24 test)..."
echo ""
truffle test
TEST_RESULT=$?

# Cleanup
echo ""
echo "════════════════════════════════════════════════════════════"
if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ Tutti i test passati!"
else
    echo "⚠️  Alcuni test falliti. Vedi output sopra."
fi
echo "════════════════════════════════════════════════════════════"

kill $GANACHE_PID 2>/dev/null
exit $TEST_RESULT
