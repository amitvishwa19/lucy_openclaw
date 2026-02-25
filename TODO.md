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

## 🌐 Alternative LLM Providers (Backup/Fallback)

- [ ] Integrate Google AI Studio as secondary provider (separate free quota)
  - [ ] Get API key from https://aistudio.google.com (2M tokens/day free)
  - [ ] Add `google` provider configuration to `openclaw.json`
  - [ ] Add Google models (e.g., `google/gemini-2.0-flash`) to `agents.defaults.models`
  - [ ] Test via `/model google/gemini-2.0-flash`
  - [ ] Document switching command for fallback scenarios
- [ ] Consider Groq (Llama/Mixtral) for high-throughput free tier
- [ ] Set up automatic model fallback when OpenRouter models return `unavailable` or `429`

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

---

## 📚 Documentation & Notes

- [ ] Maintain `memory/YYYY-MM-DD.md` with full conversation logs
- [ ] Periodic review to extract insights into `MEMORY.md` (curated long-term)
- [ ] Ensure all workspace files are backed up to GitHub (automatic)

## 🔄 Multi-Node Pairing (Local + Server)

- [ ] Enable node inbound on server (`gateway.nodes.allowInbound = true` in `openclaw.json`)
- [ ] Install OpenClaw on local machine (laptop/desktop)
- [ ] Pair local node to server via `openclaw node pair --gateway http://<server-ip>:18789`
- [ ] Approve pairing request on server (via `openclaw nodes pending` or Telegram)
- [ ] Verify node appears in `openclaw nodes list` and status is `paired`
- [ ] Test node task execution: run a skill that executes on local node (e.g., `nodes.run` with a simple command)
- [ ] Document node capabilities and intended use cases (e.g., image editing, heavy compute, local file access)
- [ ] Set up secure communication (ensure firewall allows port 18789 inbound from local network)

## 📧 Gmail Integration

- [x] Gmail OAuth2 credentials obtained and stored (`gmail-creds.json`)
- [x] Created `scripts/gmail-inbox.sh` — fetches up to 20 messages with full headers, pagination, Telegram summary
- [x] Added skill manifest for `/gmail inbox` (needs enabling)
- [ ] Enable the `gmail-inbox` skill in OpenClaw (verify auto-discovery or manually enable)
- [ ] Test `/gmail inbox` slash command in Telegram
- [ ] Implement sending email (create `scripts/gmail-send.sh` + skill)
- [ ] Set up automated daily inbox summary via cron
- [ ] Add email parsing rules (auto-replies, filtering)

---

**Completed items will be moved to a separate "Done" section with date.**
