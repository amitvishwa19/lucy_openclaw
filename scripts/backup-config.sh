#!/bin/bash
# Backup OpenClaw config after successful start
# Called by systemd ExecStartPost

CONFIG_PATH="/home/ubuntu/.openclaw/openclaw.json"
BACKUP_DIR="/home/ubuntu/.openclaw/config-backups"
mkdir -p "$BACKUP_DIR"

# Keep a timestamped backup of the working config
ts=$(date +%Y%m%d-%H%M%S)
cp "$CONFIG_PATH" "$BACKUP_DIR/openclaw.json.$ts-working"

# Also maintain a "lastworking" symlink for quick recovery
ln -sf "$BACKUP_DIR/openclaw.json.$ts-working" "$BACKUP_DIR/openclaw.json.lastworking"

# Prune old backups (keep last 10)
ls -t "$BACKUP_DIR"/openclaw.json.*-working 2>/dev/null | tail -n +11 | xargs -r rm
