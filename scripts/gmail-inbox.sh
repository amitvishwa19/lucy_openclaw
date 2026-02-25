#!/bin/bash
# Gmail inbox fetch using OAuth2 credentials
set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
CREDS="$WS/gmail-creds.json"

if [[ ! -f "$CREDS" ]]; then
  echo "❌ gmail-creds.json not found"
  exit 1
fi

CLIENT_ID=$(jq -r .client_id "$CREDS")
CLIENT_SECRET=$(jq -r .client_secret "$CREDS")
REFRESH_TOKEN=$(jq -r .refresh_token "$CREDS")

# Get access token
TOKEN_RESP=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d client_id="$CLIENT_ID" \
  -d client_secret="$CLIENT_SECRET" \
  -d refresh_token="$REFRESH_TOKEN" \
  -d grant_type=refresh_token)

ACCESS_TOKEN=$(echo "$TOKEN_RESP" | jq -r .access_token)
if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  echo "❌ Failed to get access token: $(echo "$TOKEN_RESP" | jq -r .error_description // .error)"
  exit 1
fi

# Fetch inbox message list (up to 5)
OUTPUT=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=5" \
  | jq -r '.messages[]? | "\(.id) \(.threadId)"' | while read -r id threadId; do
    msg=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=minimal")
    headers=$(echo "$msg" | jq -r '.payload.headers[]? | select(.name=="Subject" or .name=="From") | "\(.name): \(.value)"' | head -2)
    echo "----------------------------------------"
    echo "Message ID: $id"
    echo "$headers"
    echo "Snippet: $(echo "$msg" | jq -r '.snippet // "no snippet"')"
  done)

echo "$OUTPUT"

# Also send to Telegram if bot token and chat ID available
BOT_TOKEN=$(jq -r '.["telegram-bot"].botToken // .channels.telegram.botToken' "$WS/../openclaw.json" 2>/dev/null || true)
CHAT_ID="8228016833"
if [[ -n "$BOT_TOKEN" && "$BOT_TOKEN" != "null" && -n "$CHAT_ID" ]]; then
  # Truncate if too long for Telegram (4096 chars)
  if [[ ${#OUTPUT} -gt 3500 ]]; then
    OUTPUT="${OUTPUT:0:3500}... (truncated)"
  fi
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="📬 Gmail Inbox Summary:\n$OUTPUT" >/dev/null 2>&1 || true
fi
