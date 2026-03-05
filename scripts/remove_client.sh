#!/bin/bash

# ---------------------------------------------------------
# Видалення клієнта
# ---------------------------------------------------------

WG_INTERFACE=wg0
CLIENT_DIR="/etc/wireguard/clients"

CLIENT_NAME=$1

CLIENT_FILE="$CLIENT_DIR/$CLIENT_NAME.conf"

if [ ! -f "$CLIENT_FILE" ]; then
    echo "Клієнт не знайдений"
    exit
fi

CLIENT_PUBLIC_KEY=$(grep PrivateKey $CLIENT_FILE | awk '{print $3}' | wg pubkey)

wg set $WG_INTERFACE peer $CLIENT_PUBLIC_KEY remove

# Remove from config file to persist after restart
LINE_NUM=$(grep -n "PublicKey = $CLIENT_PUBLIC_KEY" "$WG_CONFIG" 2>/dev/null | cut -d: -f1)
if [ ! -z "$LINE_NUM" ]; then
    # Delete the [Peer] line (one line above), the PublicKey line, and AllowedIPs line (one line below)
    sed -i "$((LINE_NUM-1)),$((LINE_NUM+1))d" "$WG_CONFIG"
fi

rm $CLIENT_FILE

echo "Клієнт видалений"