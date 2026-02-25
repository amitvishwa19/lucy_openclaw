#!/bin/bash
# Web search using ddgr (DuckDuckGo CLI)
# Usage: web-search.sh "query"
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <search query>"
  exit 1
fi

QUERY="$*"
RESULTS=$(ddgr "$QUERY" -n 10 --json 2>/dev/null)

if [[ -z "$RESULTS" || "$RESULTS" == "[]" ]]; then
  echo "No results found for: $QUERY"
  exit 0
fi

# Format output
echo "🔍 Search results for: $QUERY"
echo "========================================"
echo "$RESULTS" | jq -r '.[] | "• \(.title)\n  \(.url)\n  \(.abstract // "No description")\n"' 2>/dev/null || echo "$RESULTS" | python3 -m json.tool 2>/dev/null || echo "$RESULTS"