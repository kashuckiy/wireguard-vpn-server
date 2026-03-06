#!/bin/bash

# ---------------------------------------------------------
# Скрипт встановлення WireGuard VPN
# ---------------------------------------------------------

set -e

WG_PORT=51820
WG_INTERFACE=wg0
WG_NETWORK=10.8.0.0/24
WG_SERVER_IP=10.8.0.1

echo "Оновлення пакетів..."
apt update

echo "Встановлення WireGuard..."
apt install -y wireguard qrencode curl

echo "Включаємо IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

echo "Генеруємо ключі сервера..."

wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)

ETH_INTERFACE=$(ip route | grep default | awk '{print $5}')

echo "Створюємо конфігурацію..."

cat > /etc/wireguard/$WG_INTERFACE.conf <<EOF
[Interface]
Address = $WG_SERVER_IP/24
ListenPort = $WG_PORT
MTU = 1280
PrivateKey = $SERVER_PRIVATE_KEY

PostUp = iptables -I INPUT 1 -p udp --dport $WG_PORT -j ACCEPT; iptables -I FORWARD 1 -i $WG_INTERFACE -j ACCEPT; iptables -I FORWARD 1 -o $WG_INTERFACE -j ACCEPT; iptables -t nat -A POSTROUTING -s $WG_NETWORK -o $ETH_INTERFACE -j MASQUERADE
PostDown = iptables -D INPUT -p udp --dport $WG_PORT -j ACCEPT; iptables -D FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -D FORWARD -o $WG_INTERFACE -j ACCEPT; iptables -t nat -D POSTROUTING -s $WG_NETWORK -o $ETH_INTERFACE -j MASQUERADE
EOF

chmod 600 /etc/wireguard/$WG_INTERFACE.conf

systemctl enable wg-quick@$WG_INTERFACE
systemctl start wg-quick@$WG_INTERFACE

echo "WireGuard встановлено"