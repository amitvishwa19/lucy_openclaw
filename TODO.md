# Devlomatix Solutions — Task Tracker

**Last updated:** 2026-02-24 07:58 UTC  
**Agent:** Lucy (maintainer)

---

## 🧠 High-Level Initiatives

- [ ] Finalize GST registration for Devlomatix Solutions (include all verticals)
- [ ] Onboard Solar Panel Cleaning vertical (equipment, SAC, invoicing)
- [ ] Set up sub-agent system for task delegation (planning phase)
- [ ] Evaluate and promote additional free LLM models to production

---

## 🧪 LLM Model Testing

- [ ] Test `openrouter/google/gemini-2.0-flash-001:free` (Gemini Flash 2.0)
- [ ] After Gemini, test `openrouter/meta-llama/llama-3.1-8b-instruct:free` (Llama 3.1 8B)
- [ ] Test `openrouter/mistralai/mixtral-8x7b-instruct:free` (Mixtral 8x7B)
- [ ] Test `openrouter/anthropic/claude-3-haiku:free` (Claude 3 Haiku)
- [ ] Compare performance/cost; decide which to keep in production

**Note:** 4 models are in `test-models.json`; need promotion to main config after testing.

---

## 📄 GST & Compliance (Solar Cleaning Vertical)

- [ ] Add SAC code `99871` (or appropriate) to Devlomatix GST registration via portal amendment
- [ ] Configure accounting software (Tally/Zoho) with new cost centre and service item
- [ ] Create invoice template for "Solar Panel Cleaning Service" with 18% GST
- [ ] Train team on invoice issuance and SAC usage
- [ ] Update compliance calendar (GSTR-1, GSTR-3B) to include new vertical

---

## 🛠️ Solar Cleaning Operations

- [ ] Procure basic equipment:
  - Telescopic pole + water-fed kit
  - DI/RO water system
  - Brushes, squeegee, towels
  - Vehicle (existing or purchase)
  - Safety gear (harness, non-slip shoes)
- [ ] Develop service agreement/contract template
- [ ] Set up customer management system (CRM or simple spreadsheet)
- [ ] Get general liability insurance
- [ ] Create pricing model (per panel, per sq. ft., or flat rate)

---

## 🤖 Sub-Agent Architecture (Future)

- [ ] Define agent roles (e.g., GST Specialist, Solar Ops Coordinator, Research Agent)
- [ ] Design skills/tools per agent
- [ ] Draft configuration (`agents.list` entries)
- [ ] Test spawning and reporting flow
- [ ] Implement approval workflow if needed

---

## 🛡️ Resilience & Self-Healing

- [ ] Install systemd service for OpenClaw gateway (auto-restart on crash/boot)
- [ ] Deploy watchdog cron job (1-minute health check + config rollback)
- [ ] Implement config backup/rollback mechanism (last working config)
- [ ] Create and maintain `restore-snapshot.json` (full state capture)
- [ ] Verify self-healing by testing simulated failures

## 📱 Social Media Integration (Posting Only)

- [ ] Check OpenClaw installation for existing `facebook`, `instagram`, `linkedin` plugins
- [ ] Create Meta Developer App (Business type) with products: Facebook Login, Instagram Basic Display, Instagram Graph API, Pages API
- [ ] Request Meta App Review for permissions: `pages_manage_posts`, `pages_read_engagement`, `instagram_basic`, `instagram_content_publish`
- [ ] Add testers (your account) to develop in dev mode while waiting for review
- [ ] Create LinkedIn Developer App; request Marketing Developer Platform access and add products: Sign In with LinkedIn, Share on LinkedIn
- [ ] Obtain credentials:
  - Facebook: App ID, App Secret, Page ID, Page Access Token (long-lived)
  - Instagram: Business Account ID (linked to Page)
  - LinkedIn: Client ID, Client Secret, Organization URN
- [ ] Configure OpenClaw `openclaw.json` with plugin entries for each platform
- [ ] Pair each channel via `/pair facebook`, `/pair instagram`, `/pair linkedin`
- [ ] Test posting:
  - `/facebook post "Test message"`
  - `/instagram post "Test" --image sample.jpg`
  - `/linkedin post "Company update"`
- [ ] Handle token refresh automation (long-lived tokens expire after 60 days)
- [ ] Document posting workflow and rate limits per platform

---

## 📚 Documentation & Notes

- [ ] Maintain `memory/YYYY-MM-DD.md` with full conversation logs
- [ ] Periodic review to extract insights into `MEMORY.md` (curated long-term)
- [ ] Ensure all workspace files are backed up to GitHub (automatic)

---

**Completed items will be moved to a separate "Done" section with date.**
