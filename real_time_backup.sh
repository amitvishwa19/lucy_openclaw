#!/bin/bash
set -euo pipefail

# Real-time backup watcher for OpenClaw workspace
# Monitors file changes and triggers backup_to_github.sh almost immediately

WORKSPACE="/home/ubuntu/.openclaw/workspace"
BACKUP_SCRIPT="/home/ubuntu/.openclaw/workspace/backup_to_github.sh"
LOG_FILE="/tmp/real_time_backup.log"
PID_FILE="/tmp/real_time_backup.pid"
DEBOUNCE_SECONDS=5

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Ensure backup script is executable
chmod +x "$BACKUP_SCRIPT" 2>/dev/null || true

# Debounce: prevent multiple rapid backups
last_run=0
trigger_backup() {
    now=$(date +%s)
    if (( now - last_run > DEBOUNCE_SECONDS )); then
        last_run=$now
        log "Triggering backup..."
        if "$BACKUP_SCRIPT" >> "$LOG_FILE" 2>&1; then
            log "Backup completed"
        else
            log "Backup failed (see /tmp/backup_to_github.log for details)"
        fi
    else
        log "Backup throttled (debounce)"
    fi
}

log "=== Real-time backup watcher started ==="
echo $$ > "$PID_FILE"

# Watch workspace (exclude .git to avoid infinite loops)
inotifywait -m -r -e close_write,moved_to,create,delete --exclude '\.git' "$WORKSPACE" |
    while read -r directory events filename; do
        # Ignore .git and other VCS files
        if [[ "$filename" != ".git" ]] && [[ "$filename" != ".git/*" ]]; then
            log "Change detected: $events in $directory$filename"
            trigger_backup
        fi
    done