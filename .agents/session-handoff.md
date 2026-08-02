# Session handoff (SFDBN)

**When:** 2026-08-02
**Branch:** main (Checkpoint pending / just landed)

- **Status:** Retired Cursor `work-state-continuity` (.mdc/.md); lean ritual = AGENTS.md Session start only. `azg apply` prunes orphans. Applied to career-agent, fpl-jubilee-ascent, jubilees-gambit (local). verify 32/32; test-azg 36; phase2 41.
- **Files:** `lib/apply.sh` · template + repo `.cursor/rules/` · tests · `current-state.md` · three downstream trees dirty
- **Decisions:** Keep `read-agents-md.mdc`. Clients still have legacy `read-agents-md.md` beside `.mdc` (optional later).
- **Blocked:** None
- **Next:** Commit/push downstreams if user authorizes; optional clean `read-agents-md.md` orphans
