#!/bin/bash
# Script per creare account Besu e fare deploy automatico

set -e

echo "🔧 Setup account Besu per deploy automatico..."

# Crea directory per keystore
mkdir -p ../besu-data/keystore

# Crea file password
echo "" > ../besu-data/password.txt

# Importa account usando web3 secret storage format
# Account: 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73
# Private key: 0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63

cat > ../besu-data/keystore/key << 'EOF'
{
  "address": "fe3b557e8fb62b89f4916b721be55ceb828dbd73",
  "crypto": {
    "cipher": "aes-128-ctr",
    "ciphertext": "93dd2ba024f0e4d3c0a9c4a89c36f8395cd8c5e3f6fa5d8e3e3b4f7c3c3a5e51",
    "cipherparams": {
      "iv": "83dbcc02d8ccb40e466191a123791e0e"
    },
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 262144,
      "p": 1,
      "r": 8,
      "salt": "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19"
    },
    "mac": "2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097"
  },
  "id": "813aadc3-3863-4b5e-8d7e-3c6e6c3e3333",
  "version": 3
}
EOF

echo "✓ Account sealer configurato"
echo "  Address: 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73"
