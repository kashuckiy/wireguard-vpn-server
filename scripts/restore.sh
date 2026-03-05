#!/bin/bash

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Вкажіть файл backup"
    exit
fi

tar -xzf $BACKUP_FILE -C /

systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

echo "WireGuard відновлено"