# Slack Integration Setup Guide

## Overview
This sets up Slack integration with dedicated channels for each agent in the Lucy team.

## Agents & Channels

| Agent | Slack Channel | Purpose |
|-------|---------------|---------|
| Lucy (main) | `#lucy-main` | Main interface |
| daily-planner | `#lucy-daily-planner` | Planning & schedules |
| image-analyzer | `#lucy-image-analyzer` | Image analysis results |

## Prerequisites

1. **Slack Workspace** with admin permissions to create apps and channels
2. **Bot Token** (`xoxb-...`) and **Signing Secret** from Slack app

## Step-by-Step Setup

### 1. Create Slack App

1. Go to https://api.slack.com/apps
2. Click **"Create New App"** → **"From scratch"**
3. Name: `Lucy`
4. Workspace: Select your workspace
5. Click **"Create App"**

### 2. Configure Bot Scopes

1. Go to **"OAuth & Permissions"** in the left sidebar
2. Under **"Bot Token Scopes"**, add these scopes:
   - `chat:write` - Send messages
   - `channels:read` - Read public channels (to find channel IDs)
   - `groups:read` - Read private channels
   - `mpim:read` - Read multi-person DMs
   - `im:read` - Read DMs (optional, if you want DM support)
3. Click **"Save Changes"**

### 3. Install App to Workspace

1. At the top of **"OAuth & Permissions"**, click **"Install to Workspace"**
2. Review permissions → Click **"Allow"**
3. **Copy the Bot Token** (`xoxb-...`) - you'll need this
4. **Copy the Signing Secret** - you'll need this too

### 4. Invite Bot to Channels

Create the channels (if they don't exist) and invite the bot:

```bash
# In Slack:
# Create channels:
#   /join #lucy-main
#   /join #lucy-daily-planner
#   /join #lucy-image-analyzer

# Then invite the bot to each channel:
# In each channel, type: /invite @Lucy
```

**Note:** Channels must exist before the bot can post to them.

### 5. Update OpenClaw Config

Edit `/home/ubuntu/.openclaw/openclaw.json` and update the Slack plugin config:

```json
"plugins": {
  "entries": {
    "telegram": {
      "enabled": true
    },
    "slack": {
      "enabled": true,
      "config": {
        "botToken": "xoxb-YOUR_REAL_BOT_TOKEN_HERE",
        "signingSecret": "YOUR_REAL_SIGNING_SECRET_HERE"
      }
    }
  }
},
```

Then restart the gateway:

```bash
openclaw gateway restart
```

### 6. Verify Setup

1. Check that the gateway is running: `openclaw gateway status`
2. Trigger a test from any agent (e.g., ask image-analyzer to analyze something)
3. Verify the result posts to the appropriate Slack channel

## How It Works

- **Agent → Channel Routing**: Each agent is bound to a specific Slack channel via the `bindings` configuration. When an agent sends a message, it automatically posts to its assigned channel.
- **Multi-Channel Support**: Agents can still reply in DMs or other channels if mentioned; only their primary output goes to their dedicated channel.
- **Main Interface**: The main Lucy agent (daily-planner) continues to operate via Telegram by default, but can also be bound to `#lucy-main` if desired.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot doesn't post to channel | Ensure bot is **invited** to the channel (use `/invite @Lucy`) |
| "not_allowed_token" error | Bot token is wrong or missing scopes. Re-check OAuth scopes and reinstall. |
| Channel not found | Ensure channel name is correct (lowercase, no spaces: `#channel-name`) |
| Messages not appearing | Check gateway logs: `journalctl -u openclaw-gateway -f` |
| Bot appears offline | Ensure bot is invited to at least one channel; Slack shows bot as offline if inactive |

## Advanced: Channel Auto-Crection

If you want channels to be created automatically, you can use the Slack API:

```bash
# Create channel (requires admin bot token with admin.channels:write)
curl -X POST -H "Authorization: Bearer xoxb-YOUR_BOT_TOKEN" \
  https://slack.com/api/conversations.create \
  -d "name=lucy-daily-planner" \
  -d "is_private=false"
```

## Next Steps

- Add more agents as needed, each with their own channel
- Consider setting up channel-specific permissions if needed
- Configure message formatting (markdown, etc.) via channel preferences

---

**All set!** Once you've added your real bot token and invited the bot to the channels, each agent will post its work to its dedicated Slack channel. 🎉
