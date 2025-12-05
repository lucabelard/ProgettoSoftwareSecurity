#!/bin/bash
# Script DEFINITIVO per test al 100%

echo "🚀 AVVIO TEST COMPLETO..."
echo ""

# Rimuovi build cache
echo "[1/2] Pulizia cache..."
rm -rf build/
echo "✓ Cache pulita"

# Esegui test con truffle develop
echo ""
echo "[2/2] Esecuzione test con Ganache fresco..."
echo "⏳ Questo richiederà circa 30-60 secondi..."
echo ""

# Usa expect o script per automatizzare truffle develop
(echo "test" && sleep 120) | truffle develop 2>&1 | tee test-output.log

# Mostra risultato
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ TEST COMPLETATI!"
echo "════════════════════════════════════════════════════════════"
echo ""

# Conta passing tests
PASSING=$(grep "passing" test-output.log | tail -1)
echo "📊 Risultato: $PASSING"
echo ""
echo "📄 Log completo salvato in: test-output.log"
