#!/bin/bash
# Run daily-planner agent at scheduled times
# Usage: /home/ubuntu/.openclaw/workspace/scripts/run-daily-planner.sh "morning"|"evening"

set -euo pipefail

WS="/home/ubuntu/.openclaw/workspace"
TYPE="${1:-morning}"  # morning or evening

if [ "$TYPE" = "morning" ]; then
  PROMPT="It's 8:00 AM IST (morning). Review yesterday's incomplete tasks, calendar, and pending items from memory. Create a concise prioritized plan for today (max 10 items) with actionable tasks. Include estimated times in Asia/Kolkata. Send the plan to the user directly."
else
  PROMPT="It's 9:00 PM IST (evening). Review today's activities from memory. Summarize what was accomplished, what got deferred, and any important notes for tomorrow. Send a concise report to the user."
fi

# Use openclaw CLI to spawn the daily-planner agent
# The agent 'daily-planner' is already configured in openclaw.json
# We send it a one-shot message via sessions spawn
/usr/local/bin/openclaw sessions spawn \
  --agentId "daily-planner" \
  --task "$PROMPT" \
  --timeoutSeconds 60 \
  --run-timeout-seconds 120
