#!/bin/bash
# OpenClaw Gateway Watchdog
# Checks if gateway is healthy; restarts if down; rolls back config on repeated failure

set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
GATEWAY_PID_FILE="/home/ubuntu/.openclaw/gateway.pid"
CONFIG_PATH="/home/ubuntu/.openclaw/openclaw.json"
BACKUP_DIR="/home/ubuntu/.openclaw/config-backups"
LOG_FILE="/tmp/openclaw-watchdog.log"
MAX_FAILURES=3
FAILURE_STATE_FILE="/tmp/openclaw-failures.state"

# Create backup dir if not exists
mkdir -p "$BACKUP_DIR"

# Function to log
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$LOG_FILE"
}

# Count current consecutive failures
get_failures() {
  if [[ -f "$FAILURE_STATE_FILE" ]]; then
    cat "$FAILURE_STATE_FILE"
  else
    echo 0
  fi
}

set_failures() {
  echo "$1" > "$FAILURE_STATE_FILE"
}

increment_failures() {
  local current
  current=$(get_failures)
  local next=$((current + 1))
  set_failures "$next"
  return $next
}

reset_failures() {
  set_failures 0
}

# Check if port 18789 is listening
check_port() {
  if ss -tuln | grep -q ':18789 '; then
    return 0  # healthy
  else
    return 1  # down
  fi
}

# Backup current config with timestamp
backup_config() {
  local ts=$(date +%Y%m%d-%H%M%S)
  cp "$CONFIG_PATH" "$BACKUP_DIR/openclaw.json.$ts"
  log "Backed up config to $BACKUP_DIR/openclaw.json.$ts"
  # Keep only last 10 backups
  ls -t "$BACKUP_DIR"/openclaw.json.* 2>/dev/null | tail -n +11 | xargs -r rm
}

# Restore latest working config if available
restore_last_working() {
  local latest
  latest=$(ls -t "$BACKUP_DIR"/openclaw.json.* 2>/dev/null | head -1 || echo "")
  if [[ -n "$latest" ]]; then
    cp "$latest" "$CONFIG_PATH"
    log "Restored config from $latest"
    return 0
  else
    log "No backup found to restore"
    return 1
  fi
}

# Main check
log "Watchdog running"

if check_port; then
  log "Gateway is healthy"
  reset_failures
  exit 0
fi

log "Gateway is DOWN!"

failures=$(get_failures)
if [[ $failures -lt $MAX_FAILURES ]]; then
  # First few failures: try restart without rollback
  log "Attempting restart (failure $failures/$MAX_FAILURES)..."
  increment_failures
  
  # Try a clean restart via openclaw
  if openclaw gateway restart 2>/dev/null; then
    log "Restart command sent"
  else
    log "Restart command failed, killing any existing process"
    pkill -f "openclaw-gateway" || true
  fi
  
  sleep 3
  if check_port; then
    log "Recovered after restart"
    reset_failures
    exit 0
  fi
else
  # Too many failures: rollback to last working config
  log "Maximum failures reached ($MAX_FAILURES). Triggering config rollback..."
  if restore_last_working; then
    log "Rolling back gateway with restored config..."
    pkill -f "openclaw-gateway" || true
    sleep 2
    # Start gateway with the restored config
    openclaw gateway start 2>/dev/null || true
    sleep 3
    if check_port; then
      log "Recovered after rollback"
      reset_failures
      exit 0
    else
      log "Even after rollback, gateway failed to start"
    fi
  else
    log "No backup to rollback to; cannot recover automatically"
  fi
fi

log "Watchdog failed to recover. Check manually."
exit 1
