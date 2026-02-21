#!/bin/bash
# Auto-sync workspace to GitHub every 5 minutes (via cron or systemd timer)

set -e

WORKSPACE="/home/ubuntu/.openclaw/workspace"
cd "$WORKSPACE"

# Only commit if there are changes
if git status --porcelain | grep -q .; then
  echo "[$(date)] Changes detected, syncing to GitHub..."

  git add -A
  git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"
  git push origin master

  echo "[$(date)] Sync complete"
else
  echo "[$(date)] No changes to sync"
fi
