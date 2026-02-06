#!/bin/bash

# Ottieni path assoluto dello script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../../.."

# Cleanup previous processes
echo "[*] Cleaning up old processes..."
pkill -f besu 2>/dev/null
pkill -f "besu-config/scripts/rpc-proxy.js" 2>/dev/null
sleep 2

echo "============================================================"
echo "  AVVIO RETE BESU (MAC OS) - Chain ID 2025"
echo "============================================================"
echo ""

# Funzione per aprire in nuovo terminale
open_terminal() {
    local cmd=$1
    local title=$2
    # Escape backslashes first, then double quotes for AppleScript
    local escaped_cmd=${cmd//\\/\\\\}
    escaped_cmd=${escaped_cmd//\"/\\\"}
    osascript -e "tell application \"Terminal\" to do script \"$escaped_cmd\""
}

# 1. Avvia Proxy
echo "[*] Starting Failover Proxy (Port 8545)..."
# Proxy script wrapper con titolo
<<<<<<< Updated upstream
<<<<<<< Updated upstream
open_terminal "bash \"$SCRIPT_DIR/run-proxy.sh\" \"$PROJECT_ROOT\"" "Besu Proxy"
=======
open_terminal "printf '\033]0;Besu Failover Proxy\007'; cd \"$PROJECT_ROOT\" && node besu-config/scripts/monitoring/rpc-proxy.js" "Besu Proxy"
>>>>>>> Stashed changes
=======
open_terminal "printf '\033]0;Besu Failover Proxy\007'; cd \"$PROJECT_ROOT\" && node besu-config/scripts/monitoring/rpc-proxy.js" "Besu Proxy"
>>>>>>> Stashed changes

# Attendi un attimo
sleep 2

# 2. Avvia Node 1 (Bootstrap)
echo "[*] Starting Node 1 (Port 8551)..."
KEY1="besu-config/networkFiles/keys/0x8b175a2617911fc7d30b6cb960d4240eab55a58c/key"
CMD_NODE1="bash \"$SCRIPT_DIR/start-node.sh\" \"Node 1\" \"besu-config/node1/data\" 8551 30303 \"$KEY1\""
open_terminal "$CMD_NODE1" "Besu Node 1"

sleep 5

# 3. Avvia Node 2
echo "[*] Starting Node 2 (Port 8546)..."
KEY2="besu-config/networkFiles/keys/0x7eac0f7a98f6c004b1c7e0ee0f48897cd14af0cd/key"
CMD_NODE2="bash \"$SCRIPT_DIR/start-node.sh\" \"Node 2\" \"besu-config/node2/data\" 8546 30304 \"$KEY2\""
open_terminal "$CMD_NODE2" "Besu Node 2"

# 4. Avvia Node 3
echo "[*] Starting Node 3 (Port 8547)..."
KEY3="besu-config/networkFiles/keys/0xba3cc3e7110c0b33d357868178acc766c12c9417/key"
CMD_NODE3="bash \"$SCRIPT_DIR/start-node.sh\" \"Node 3\" \"besu-config/node3/data\" 8547 30305 \"$KEY3\""
open_terminal "$CMD_NODE3" "Besu Node 3"

# 5. Avvia Node 4
echo "[*] Starting Node 4 (Port 8548)..."
KEY4="besu-config/networkFiles/keys/0xd211d619bde1991e23849a16188722e40c0cf334/key"
CMD_NODE4="bash \"$SCRIPT_DIR/start-node.sh\" \"Node 4\" \"besu-config/node4/data\" 8548 30306 \"$KEY4\""
open_terminal "$CMD_NODE4" "Besu Node 4"

echo ""
echo "[*] Waiting for Node 1 to initialize..."
bash "$SCRIPT_DIR/wait-for-besu.sh"

echo ""
echo "============================================================"
echo "  RETE AVVIATA & PRONTA!"
echo "============================================================"
