#!/bin/bash

# ---------------------------------------------------------
# Додавання нового клієнта WireGuard
# ---------------------------------------------------------

WG_INTERFACE=wg0
WG_CONFIG="/etc/wireguard/$WG_INTERFACE.conf"
CLIENT_DIR="/etc/wireguard/clients"

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

mkdir -p $CLIENT_DIR

CLIENT_NAME=$1

if [ -z "$CLIENT_NAME" ]; then
    echo "Використання: ./add_client.sh CLIENT_NAME"
    exit
fi

LAST_IP=$(grep -o -E '10\.8\.0\.[0-9]+' $WG_CONFIG 2>/dev/null | sort -V | tail -n 1)
if [ -z "$LAST_IP" ] || [ "$LAST_IP" == "10.8.0.1" ]; then
    CLIENT_IP="10.8.0.2"
else
    LAST_OCTET=$(echo "$LAST_IP" | awk -F'.' '{print $4}')
    CLIENT_IP="10.8.0.$((LAST_OCTET + 1))"
fi

CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)

SERVER_IP=$(curl -s ifconfig.me)

cat >> $WG_CONFIG <<EOF

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOF

wg set $WG_INTERFACE peer $CLIENT_PUBLIC_KEY allowed-ips $CLIENT_IP/32

cat > $CLIENT_DIR/$CLIENT_NAME.conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 1.1.1.1
MTU = 1280

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "Конфіг клієнта створено:"
cat $CLIENT_DIR/$CLIENT_NAME.conf

# Збереження копії у локальну директорію ./clients в папці проекту
LOCAL_CLIENT_DIR="./clients"
mkdir -p "$LOCAL_CLIENT_DIR"
cp "$CLIENT_DIR/$CLIENT_NAME.conf" "$LOCAL_CLIENT_DIR/"
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER:$(id -g $SUDO_USER 2>/dev/null || echo $SUDO_USER)" "$LOCAL_CLIENT_DIR"
fi
echo ""
echo "Також збережено локально: $LOCAL_CLIENT_DIR/$CLIENT_NAME.conf"

echo ""
echo "QR код:"

qrencode -t ansiutf8 < $CLIENT_DIR/$CLIENT_NAME.conf