#!/bin/bash
# Restore from snapshot
# Usage:
#  restore-from-snapshot.sh          -> show summary
#  restore-from-snapshot.sh list     -> list files in snapshot
#  restore-from-snapshot.sh show <file> -> show content of a file from snapshot
#  restore-from-snapshot.sh extract <file> [dest] -> extract file to dest (default: workspace)
#  restore-from-snapshot.sh restore  -> restore all files to workspace

set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
SNAPSHOT="$WS/restore-snapshot.json"

if [[ ! -f "$SNAPSHOT" ]]; then
  echo "❌ Snapshot not found: $SNAPSHOT"
  exit 1
fi

cmd="${1:-summary}"

case "$cmd" in
  summary|"")
    echo "📄 Snapshot Summary"
    echo "Generated: $(jq -r '.snapshot.generatedAt' "$SNAPSHOT" 2>/dev/null || echo 'unknown')"
    echo "Git commit: $(jq -r '.snapshot.gitCommit' "$SNAPSHOT" 2>/dev/null || echo 'none')"
    echo "Git branch: $(jq -r '.snapshot.gitBranch' "$SNAPSHOT" 2>/dev/null || echo 'none')"
    echo "Files included: $(jq '.files | length' "$SNAPSHOT")"
    echo ""
    echo "Contents:"
    jq -r '.files | keys[]' "$SNAPSHOT" | sed 's/^/  - /'
    ;;

  list)
    jq -r '.files | keys[]' "$SNAPSHOT" | sed 's/^/  /'
    ;;

  show)
    file="$2"
    if [[ -z "$file" ]]; then
      echo "Usage: $0 show <file>"
      exit 1
    fi
    content=$(jq -r --arg f "$file" '.files[$f]' "$SNAPSHOT")
    if [[ "$content" == "null" ]]; then
      echo "❌ File not in snapshot: $file"
      exit 1
    fi
    echo "$content"
    ;;

  extract)
    file="$2"
    dest="${3:-$WS/$file}"
    if [[ -z "$file" ]]; then
      echo "Usage: $0 extract <file> [dest]"
      exit 1
    fi
    content=$(jq -r --arg f "$file" '.files[$f]' "$SNAPSHOT")
    if [[ "$content" == "null" ]]; then
      echo "❌ File not in snapshot: $file"
      exit 1
    fi
    # Write to destination
    mkdir -p "$(dirname "$dest")"
    echo "$content" > "$dest"
    echo "✅ Extracted to $dest"
    ;;

  restore)
    # Extract all files to their original locations
    echo "🔄 Restoring all files from snapshot..."
    jq -r '.files | keys[]' "$SNAPSHOT" | while read -r file; do
      echo "  restoring: $file"
      content=$(jq -r --arg f "$file" '.files[$f]' "$SNAPSHOT")
      # Special case: openclaw.json goes to /home/ubuntu/.openclaw/, not workspace
      if [[ "$file" == "openclaw.json" ]]; then
        dest="/home/ubuntu/.openclaw/openclaw.json"
      else
        dest="$WS/$file"
      fi
      mkdir -p "$(dirname "$dest")"
      echo "$content" > "$dest"
    done
    echo "✅ Restore complete"
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: $0 [summary|list|show <file>|extract <file> [dest]]"
    exit 1
    ;;
esac
