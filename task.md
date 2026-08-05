# Active Task: Project AGENTS telegraphic soft-dup trim

- **Status:** Done — Checkpoint now
- **Objective:** Drop redundant project telegraphic bullet; rely on global AZG:AGENT-INSTRUCTIONS
- **Acceptance:** `test-azg.sh` green; Placeholder fill step 2 still mentions telegraphic; global AGENTS untouched
- **Issue/Ticket:** grill-with-docs AGENTS layering cleanup

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `templates/project/AGENTS.md.tmpl` · `AGENTS.md` (dogfood)
- **Decisions:** Global=habits · project=repo ritual; delete Overrides telegraphic bullet; leave ponytail sync/self-ref; keep both secrets lines; no `.mdc` primary swap
- **Blocked:** None
- **Next:** Optional follow-up: remove duplicate `SubagentStart` spawn-budget wiring (ADR 0006 PreToolUse-only) — not in this Checkpoint

## Todo
- [x] Grill layering + soft-dup decisions locked
- [x] Delete project Overrides telegraphic bullet (tmpl + dogfood)
- [x] `test-azg.sh` 36/36
- [x] Checkpoint commit

## Blockers / Notes
- Code-review subagents aborted (`User aborted/interrupted manually`) — local review substituted; not spawn-budget deny
- Downstream apply/push still PENDING (no AUTH)
- Optional follow-up: SubagentStart spawn-budget double-wire (see session-handoff)
