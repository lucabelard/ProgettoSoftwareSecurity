#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "============================================="
echo "🚀 Running Performance Test for BN_Simple"
echo "============================================="
truffle test test/performance/simple-performance-test.js --network besu --grep "BN_Simple"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ BN_Simple Failed${NC}"
fi

echo "============================================="
echo "🚀 Running Performance Test for BN_Medium"
echo "============================================="
truffle test test/performance/simple-performance-test.js --network besu --grep "BN_Medium"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ BN_Medium Failed${NC}"
fi

echo "============================================="
echo "🚀 Running Performance Test for BN_Complex"
echo "============================================="
truffle test test/performance/simple-performance-test.js --network besu --grep "BN_Complex"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ BN_Complex Failed${NC}"
fi

echo ""
echo "🏁 All tests completed."
echo "📊 Generazione report grafico..."
node test/performance/generate-report.js
echo "✅ Report generato: test/performance/results/report.html"
