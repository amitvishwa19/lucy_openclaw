#!/bin/bash
# Automated backup script: commits and pushes workspace to GitHub
# Excludes sensitive config because config is NOT in workspace (stored in ~/.openclaw/)
# Intended to run via cron every 5 minutes

set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
LOG="/tmp/backup_to_github.log"

cd "$WS"

# Ensure we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  git checkout main 2>/dev/null || git branch -m main && git checkout main
fi

# Fetch remote to check if we're behind (optional, but helps avoid conflicts)
git fetch origin main >> "$LOG" 2>&1 || true

# Sync README.md from home folder if present
if [ -f "/home/ubuntu/README.md" ]; then
  echo "📝 Syncing README.md from /home/ubuntu/" >> "$LOG"
  cp -f "/home/ubuntu/README.md" "$WS/README.md"
fi

# Stage all changes (including new files)
git add -A >> "$LOG" 2>&1

# Check if there are any staged changes to commit
if git diff-index --cached --quiet HEAD --; then
  echo "$(date '+%Y-%m-%d %H:%M:%S'): No changes to backup." >> "$LOG"
  exit 0
fi

# Create commit with timestamp
COMMIT_MSG="Auto-backup $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git commit -m "$COMMIT_MSG" >> "$LOG" 2>&1

# Push to origin/main
if git push origin main >> "$LOG" 2>&1; then
  echo "$(date '+%Y-%m-%d %H:%M:%S'): Backup successful." >> "$LOG"
  # Also create/update the restore snapshot (captures current state)
  if "$WS/scripts/create-snapshot.sh" >> "$LOG" 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Snapshot updated." >> "$LOG"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Snapshot FAILED." >> "$LOG"
  fi
else
  echo "$(date '+%Y-%m-%d %H:%M:%S'): Backup FAILED to push. Check auth/network." >> "$LOG"
  exit 1
fi
