# Session handoff (SFDBN)

**When:** 2026-08-03
**Branch:** main

- **Status:** Done — converged Stop checkpoint policy across agy + Cursor.
- **Files:** `.agents/hooks/checkpoint.sh` · `.cursor/hooks/stop-checkpoint.sh` · `.cursor/hooks.json` · `templates/project/` mirrors · `tests/test-phase2.sh`
- **Decisions:** agy Stop uses official `decision: continue` + `reason` (system message). Cursor Stop uses `followup_message` + `loop_limit: 3`. Same workstate accept set and reason text on both hosts.
- **Blocked:** None
- **Next:** `azg apply` + commit/push career-agent · fpl-jubilee-ascent · jubilees-gambit
