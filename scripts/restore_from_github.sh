#!/bin/bash
# Full restore from GitHub — run after fresh OpenClaw install
# This script restores: workspace files, gateway config, cron jobs, and plugins
# Usage: bash scripts/restore_from_github.sh

set -e

echo "=== Lucy's Recovery Script ==="
echo "Starting restore from GitHub..."

# 1. Clone or pull workspace
WORKSPACE="/home/ubuntu/.openclaw/workspace"
if [ -d "$WORKSPACE/.git" ]; then
  echo "Workspace exists, pulling latest..."
  git -C "$WORKSPACE" pull origin main
else
  echo "Cloning repository..."
  rm -rf "$WORKSPACE"
  git clone https://github.com/amitvishwa19/lucy_openclaw.git "$WORKSPACE"
fi

# 2. Restore OpenClaw config from workspace's .openclaw (if present)
if [ -d "$WORKSPACE/.openclaw" ]; then
  echo "Restoring OpenClaw config..."
  mkdir -p ~/.openclaw
  cp -r "$WORKSPACE/.openclaw/." ~/.openclaw/
else
  echo "⚠ No .openclaw config in repo — you'll need to re-configure Telegram token etc."
fi

# 3. Reinstall plugins (if needed)
echo "Ensuring plugins are installed..."
npm install -g @askjo/wa_meow 2>/dev/null || echo "wa_meow plugin already installed or unavailable"

# 4. Restore cron jobs
echo "Setting up cron jobs..."
(crontab -l 2>/dev/null | grep -v "/home/ubuntu/.openclaw/workspace/scripts/git_autosync.sh" ; echo "*/5 * * * * /home/ubuntu/.openclaw/workspace/scripts/git_autosync.sh") | crontab -
(crontab -l 2>/dev/null | grep -v "/home/ubuntu/.openclaw/workspace/scripts/backup_openclaw.sh" ; echo "0 2 * * * /home/ubuntu/.openclaw/workspace/scripts/backup_openclaw.sh") | crontab -

# 5. Ensure scripts are executable
chmod +x "$WORKSPACE/scripts"/*.sh

# 6. Restart gateway to reload config
echo "Restarting OpenClaw gateway..."
openclaw gateway restart || echo "Gateway may not be running, starting..."
openclaw gateway start || true

# 7. Re-enable WhatsApp plugin (if desired)
echo "Enabling WhatsApp plugin..."
openclaw plugins enable whatsapp || echo "WhatsApp plugin already enabled or failed"

# 8. Final message
echo ""
echo "=== Restore Complete ==="
echo "Workspace files restored to: $WORKSPACE"
echo "OpenClaw config restored from repo's .openclaw/"
echo "Cron jobs installed"
echo "Gateway restarted"
echo ""
echo "Next steps:"
echo "1. Check Telegram channel: openclaw channels list"
echo "2. If WhatsApp needed: run 'openclaw channels login --channel whatsapp' and scan QR via SSH terminal"
echo "3. Test messaging"
echo ""
echo "All set, Lucy is back! 🐶"
