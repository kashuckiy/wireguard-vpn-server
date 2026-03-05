#!/bin/bash

BACKUP_DIR="./backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/wireguard_backup_$DATE.tar.gz /etc/wireguard

echo "Backup створено:"
echo "$BACKUP_DIR/wireguard_backup_$DATE.tar.gz"