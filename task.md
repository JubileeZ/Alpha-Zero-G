# Active Task: ADR 0010 Think+Prove + Orchestrate + domains

- **Status:** Done — committing
- **Objective:** Distilled always-on Think+Prove; Device Setup skills `azg-orchestrate`, research/data domains, method-refs
- **Acceptance:** cursor-device-setup + verify green; skills install even under vendor smart-sync
- **Issue/Ticket:** ADR 0010

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `templates/global/AGENTS.md` · `templates/global/skills/azg/**` · `lib/setup.sh` · `lib/apply-overlay.sh` · `docs/adr/0010-*.md` · `CONTEXT.md` · tests
- **Decisions:** S always-on; Act=`azg-orchestrate`; G domains; no azg-domain maker
- **Blocked:** None
- **Next:** Commit; `azg setup` on devices; optional Lite promote

## Todo
- [x] ADR + CONTEXT
- [x] Expand AGENT-INSTRUCTIONS
- [x] First-party skills + setup wire
- [x] verify / cursor-device-setup (59) + test-azg (33)
- [x] commit

## Blockers / Notes
- Vendor smart-sync must not skip azg-owned skills; prune must not delete them — covered in setup/tests
