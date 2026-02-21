# Backup & Sync Setup

## Scripts

- `scripts/backup_openclaw.sh` — Daily full workspace backup (tar.gz) to `~/openclaw_backups/`
- `scripts/git_autosync.sh` — Auto-commit & push changes every 5 minutes

## Setup

### 1. Install cron jobs (if not already)

```bash
# Daily backup at 2 AM
crontab -e
# Add: 0 2 * * * /home/ubuntu/.openclaw/workspace/scripts/backup_openclaw.sh

# Autosync every 5 minutes
crontab -e
# Add: */5 * * * * /home/ubuntu/.openclaw/workspace/scripts/git_autosync.sh
```

### 2. Restore from backup

```bash
tar -xzf /home/ubuntu/.openclaw/backups/backup_YYYY-MM-DD_HH-MM-SS.tar.gz -C /tmp/
# Copy files back to workspace
```

### 3. Notes

- Backups exclude `.git` (since we have remote)
- Keeps last 30 backups automatically
- Autosync commits only when changes exist
- Remote PAT stored in remote URL (consider using credential helper)

---

For reinstall: Simply clone the repo, then copy latest backup over if needed.
