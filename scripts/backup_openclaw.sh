#!/bin/bash
# Backup OpenClaw workspace — runs daily at 2 AM

set -e

WORKSPACE="/home/ubuntu/.openclaw/workspace"
BACKUP_DIR="/home/ubuntu/.openclaw/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE="backup_$DATE.tar.gz"

echo "[$(date)] Starting backup of $WORKSPACE"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Create archive (excluding .git to keep it lean, we have remote anyway)
tar -czf "$BACKUP_DIR/$ARCHIVE" -C "$WORKSPACE" \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.npm' \
  .

# Keep only last 30 backups
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz | tail -n +31 | xargs -r rm

echo "[$(date)] Backup completed: $ARCHIVE (kept 30 latest)"
echo "[$(date)] Total backups: $(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)"
