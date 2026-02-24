#!/bin/bash
# Create a full system restore snapshot
# Aggregates key workspace files into restore-snapshot.json

set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
SNAPSHOT="$WS/restore-snapshot.json"
BACKUP_DIR="/home/ubuntu/.openclaw/config-backups"

# Ensure backup dir exists
mkdir -p "$BACKUP_DIR"

# Temporary JSON building
OUTPUT="/tmp/restore-snapshot.$$.json"

# Start JSON
cat > "$OUTPUT" <<'EOF'
{
  "snapshot": {
    "generatedAt": "",
    "gitCommit": "",
    "gitBranch": ""
  },
  "files": {}
}
EOF

# Get current timestamp
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg ts "$ts" '.snapshot.generatedAt = $ts' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"

# Get git info if available
if git -C "$WS" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  commit=$(git -C "$WS" rev-parse HEAD 2>/dev/null || echo "")
  branch=$(git -C "$WS" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  jq --arg commit "$commit" --arg branch "$branch" '.snapshot.gitCommit = $commit | .snapshot.gitBranch = $branch' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
fi

# List of files to include (relative to workspace)
FILES=(
  "MEMORY.md"
  "TODO.md"
  "memory/$(date +%Y-%m-%d).md"
  "memory/2025-06-18.md"
  "USER.md"
  "IDENTITY.md"
  "SOUL.md"
  "HEARTBEAT.md"
  "TOOLS.md"
  "README.md"
  "test-models.json"
  "scripts/backup_to_github.sh"
  "scripts/git_autosync.sh"
  "scripts/restore_from_github.sh"
)

# Also include the main OpenClaw config (outside workspace)
MAIN_CONFIG="/home/ubuntu/.openclaw/openclaw.json"
if [[ -f "$MAIN_CONFIG" ]]; then
  content=$(jq -Rs '.' "$MAIN_CONFIG")
  jq --arg path "openclaw.json" --argjson content "$content" '.files[$path] = $content' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
fi

# For each file, if exists, add its content (as string) to JSON
for f in "${FILES[@]}"; do
  path="$WS/$f"
  if [[ -f "$path" ]]; then
    content=$(jq -Rs '.' "$path")  # read as raw string, JSON-escape
    jq --arg path "$f" --argjson content "$content" '.files[$path] = $content' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
  fi
done

# Also include latest config backup if exists
latest_backup=$(ls -t "$BACKUP_DIR"/openclaw.json.*-working 2>/dev/null | head -1 || true)
if [[ -n "$latest_backup" ]]; then
  relpath="config-backups/$(basename "$latest_backup")"
  content=$(jq -Rs '.' "$latest_backup")
  jq --arg path "$relpath" --argjson content "$content" '.files[$path] = $content' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
fi

# Pretty print
jq '.' "$OUTPUT" > "$SNAPSHOT"
rm -f "$OUTPUT" "$OUTPUT.tmp"

echo "✅ Snapshot created: $SNAPSHOT ($(jq '.files | length' "$SNAPSHOT") files included)"
