# Session handoff (SFDBN)

**When:** 2026-08-05
**Branch:** main

- **Status:** Done — apply strips SubagentStart; fpl-jubilee-ascent applied
- **Files:** `lib/apply.sh` · `tests/test-phase10.sh` · fpl `.agents/hooks.json` (+ lean hook refresh)
- **Decisions:** jq merge must delete retired keys; local scan found only fpl as azg client besides alpha-zero-g
- **Blocked:** None
- **Next:** Commit fpl Checkpoint; push both needs AUTH; other downstream when paths known
