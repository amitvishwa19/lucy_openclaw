# OpenClaw Workspace Backup & Management

**Owner:** Vishwa (Asia/Kolkata, UTC+5:30)  
**Assistant:** Lucy  
**Last Updated:** Mon Feb 23 2026 09:10 UTC

---

## 📋 Overview

This repository serves as the **backup workspace** for OpenClaw agent configuration, identity files, memory, and utility scripts. It excludes sensitive channel integrations (Telegram/WhatsApp tokens) to keep the repo shareable/private-safe.

**Automated backups:** Every 5 minutes via cron.

---

## 🗂️ Repository Structure

```
workspace/
├── AGENTS.md           - Agent workspace guidelines (SOUL.md section)
├── DEPLOYMENT.md       - Deployment guide for Ashacarewell landing page
├── HEARTBEAT.md        - Heartbeat poll instructions (empty for now)
├── IDENTITY.md         - Assistant identity (Lucy: AI assistant, chill vibe)
├── MEMORY.md           - Long-term memory (curated learnings)
├── SOUL.md             - Core principles & boundaries
├── TOOLS.md            - Local tool notes (safe-config-update script)
├── USER.md             - User profile (Vishwa, India timezone)
├── README.md           - This file - syncs from /home/ubuntu/README.md
├── safe-config-update.sh  - Safe JSON config editing tool
├── backup_to_github.sh    - Automated backup script (runs via cron)
├── SETUP_STATUS.md     - Setup completion checklist (internal)
├── memory/             - Daily memory logs
│   ├── 2025-06-18.md   - Historical memory
│   └── 2026-02-23.md   - Today's session memory
├── scripts/            - Utility scripts
│   ├── README.md
│   ├── backup_openclaw.sh
│   ├── git_autosync.sh
│   └── restore_from_github.sh
└── .openclaw/          - OpenClaw state (workspace-state.json)
```

**Excluded from backups (config is elsewhere):**
- `~/.openclaw/openclaw.json` (main config with tokens)
- Channel credentials (Telegram bot token, WhatsApp sessions)
- Anything with secrets stays out of Git

---

## 🛠️ Tools & Utilities

### Safe Config Updates

Never edit `openclaw.json` manually! Use the safe updater:

```bash
./safe-config-update.sh '.channels.telegram.botToken' '"NEW_TOKEN"'
./safe-config-update.sh -y '.plugins.entries.whatsapp.enabled' 'true'
./safe-config-update.sh -r '.gateway.port' '18790'  # + auto-restart
```

**What it does:**
- Creates timestamped backup
- Applies change via `jq`
- Validates JSON
- Shows diff
- Prompts for confirmation (or `-y` to skip)
- Optionally restarts gateway (`-r`)

### Manual Backup Trigger

```bash
/home/ubuntu/.openclaw/workspace/backup_to_github.sh
```

Check log: `tail -f /tmp/backup_to_github.log`

---

## 🔄 Sync Behavior

**README.md sync:**  
The file `/home/ubuntu/README.md` is automatically copied into the workspace on every backup run. This means you can edit `/home/ubuntu/README.md` directly and it will be backed up. Any changes are committed with timestamp.

**Auto-sync enabled:** Edit `/home/ubuntu/README.md` manually to keep this file updated with project notes.

---

## 📜 Change Log

### 2026-02-23 (Setup Day)

- ✅ Initial workspace bootstrap via OpenClaw wizard
- ✅ Identity established: Lucy (assistant), Vishwa (user)
- ✅ Safe config update tool created & documented
- ✅ SSH authentication configured for GitHub backups
- ✅ Automated backup script (`backup_to_github.sh`) + cron every 5 min
- ✅ README auto-sync from `/home/ubuntu/README.md`
- ✅ Memory files created (today + historical from backup)
- ✅ Backup repo initialized: `amitvishwa19/lucy_openclaw`
- ✅ Excluded Telegram/WhatsApp sensitive configs
- ✅ BOOTSTRAP.md removed (setup complete)
- ✅ Deployment docs & utility scripts synced from backup
- ⚠️ PAT token exposure incident -> revoked warning
- ✅ GitHub push verified (commit 63c9a36)
- 📝 `SETUP_STATUS.md` created (internal completion checklist)

**Notes:** All systems operational. Backups running. SSH auth stable.

---

## 🚀 Quick Start

1. **Edit identity/memory** → just edit files in `~/openclaw/workspace/`
2. **Safe config changes** → use `./safe-config-update.sh`
3. **Manual backup** → run `backup_to_github.sh`
4. **Check status** → `openclaw status` or `gateway status`
5. **Restore from backup** → `git pull origin main` or use `scripts/restore_from_github.sh`

---

## 🔐 Security Notes

- SSH key used: `~/.ssh/lucy_github` (ED25519)
- GitHub repo: currently **public** (switch to private when ready)
- No secrets in this repo (config stored in `~/.openclaw/` not in workspace)
- Remember to revoke any exposed tokens

---

## 📞 Support

Contact: Vishwa via Telegram  
Assistant: Lucy (OpenClaw agent)

---

**This README auto-syncs from `/home/ubuntu/README.md`.**  
Last sync: Mon Feb 23 2026 09:10 UTC
