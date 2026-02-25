#!/bin/bash
# Gmail inbox fetch with pagination (up to 20 messages), full headers
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

# Fetch up to 20 messages with pagination
MAX_MESSAGES=20
PAGE_SIZE=10
OUTPUT=""
TOTAL_FETCHED=0
NEXT_PAGE_TOKEN=""

while [[ $TOTAL_FETCHED -lt $MAX_MESSAGES ]]; do
  URL="https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$PAGE_SIZE"
  [[ -n "$NEXT_PAGE_TOKEN" ]] && URL="$URL&pageToken=$NEXT_PAGE_TOKEN"

  RESP=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$URL")
  MSG_IDS=$(echo "$RESP" | jq -r '.messages[]? | .id')
  COUNT=$(echo "$MSG_IDS" | wc -l)

  if [[ $COUNT -eq 0 ]]; then
    break
  fi

  echo "$MSG_IDS" | while read -r id; do
    # Fetch metadata with needed headers
    msg=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=metadata&metadataHeaders=From&metadataHeaders=Subject&metadataHeaders=Date")
    
    subject=$(echo "$msg" | jq -r '.payload.headers[]? | select(.name=="Subject") | .value' | head -1)
    from=$(echo "$msg" | jq -r '.payload.headers[]? | select(.name=="From") | .value' | head -1)
    date=$(echo "$msg" | jq -r '.payload.headers[]? | select(.name=="Date") | .value' | head -1)
    snippet=$(echo "$msg" | jq -r '.snippet // "no snippet"')
    
    # Defaults if missing
    subject=${subject:-"(no subject)"}
    from=${from:-"(unknown sender)"}
    date=${date:-""}
    
    # Truncate
    [[ ${#subject} -gt 100 ]] && subject="${subject:0:100}..."
    [[ ${#from} -gt 50 ]] && from="${from:0:50}..."
    
    echo "----------------------------------------"
    echo "From: $from"
    echo "Date: $date"
    echo "Subject: $subject"
    echo "Snippet: $snippet"
  done

  TOTAL_FETCHED=$((TOTAL_FETCHED + COUNT))
  NEXT_PAGE_TOKEN=$(echo "$RESP" | jq -r '.nextPageToken // empty')
  [[ -z "$NEXT_PAGE_TOKEN" ]] && break
done

echo "========================================="
echo "Total messages fetched: $TOTAL_FETCHED"

# Send to Telegram if enabled
BOT_TOKEN=$(jq -r '.["telegram-bot"].botToken // .channels.telegram.botToken' "$WS/../openclaw.json" 2>/dev/null || true)
CHAT_ID="8228016833"
if [[ -n "$BOT_TOKEN" && "$BOT_TOKEN" != "null" && -n "$CHAT_ID" ]]; then
  FULL_OUTPUT=$( { "$0"; } 2>&1 )
  if [[ ${#FULL_OUTPUT} -gt 3500 ]]; then
    chunks=()
    while [[ ${#FULL_OUTPUT} -gt 0 ]]; do
      chunk="${FULL_OUTPUT:0:3500}"
      FULL_OUTPUT="${FULL_OUTPUT:3500}"
      chunks+=("$chunk")
    done
    for chunk in "${chunks[@]}"; do
      curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="📬 Gmail Inbox (up to $TOTAL_FETCHED messages):\n$chunk" >/dev/null 2>&1 || true
      sleep 0.5
    done
  else
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d chat_id="$CHAT_ID" \
      -d text="📬 Gmail Inbox (up to $TOTAL_FETCHED messages):\n$FULL_OUTPUT" >/dev/null 2>&1 || true
  fi
fi
