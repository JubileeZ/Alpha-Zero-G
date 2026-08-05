# Session handoff (SFDBN)

**When:** 2026-08-05
**Branch:** main

- **Status:** Done — SubagentStart spawn-budget double-wire removed
- **Files:** `.agents/hooks.json` · `templates/project/.agents/hooks.json` · `tests/host-contract-smoke.sh` · `docs/adr/0006-…` · `docs/agents/host-contract-smoke.md`
- **Decisions:** Count once on PreToolUse only; SubagentStop `--finish` + SessionStart `--reset` remain. Cursor code-review Task aborts were user/UI interrupt — not budget deny
- **Blocked:** None
- **Next:** Clients need `azg apply` to merge hooks; push needs AUTH
