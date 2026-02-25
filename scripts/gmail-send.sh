#!/bin/bash
set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
CREDS="$WS/gmail-creds.json"

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <to> <subject> <body>"
  exit 1
fi

TO="$1"
SUBJECT="$2"
BODY="$3"

if [[ ! -f "$CREDS" ]]; then
  echo "gmail-creds.json not found"
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
  echo "Failed to get access token: $(echo "$TOKEN_RESP" | jq -r .error_description // .error)"
  exit 1
fi

# Build raw RFC822 message
RAW="From: devlomatix@gmail.com
To: $TO
Subject: $SUBJECT
MIME-Version: 1.0
Content-Type: text/plain; charset=\"UTF-8\"
Content-Transfer-Encoding: 7bit

$BODY"

# Encode as base64url
RAW_B64=$(echo -n "$RAW" | base64 | tr -d '\n' | sed 's/+/-/g; s/\//_/g; s/=//g')

# Send
RESP=$(curl -s -X POST "https://gmail.googleapis.com/gmail/v1/users/me/messages/send" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"raw\":\"$RAW_B64\"}")

if echo "$RESP" | jq -e '.id' >/dev/null 2>&1; then
  echo "Email sent to $TO (subject: $SUBJECT)"
  echo "Message ID: $(echo "$RESP" | jq -r .id)"
else
  echo "Failed to send email: $(echo "$RESP" | jq -r '.error.message // "unknown error")"
  exit 1
fi