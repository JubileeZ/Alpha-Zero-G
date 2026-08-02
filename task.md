# Active Task: Retire work-state-continuity.mdc

- **Status:** Done — Checkpoint
- **Objective:** Lean ritual only in AGENTS.md Session start; remove Cursor duplicate from template + clients; apply prune on reapply
- **Acceptance:** phase2 + test-azg + verify green; alpha-zero-g + 3 downstreams without work-state rule; Session start present
- **Issue/Ticket:** continuity cleanup

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `templates/project/.cursor/rules/` · `.cursor/rules/` · `lib/apply.sh` · `tests/test-phase2.sh` · `tests/test-azg.sh` · `docs/agents/current-state.md` · applied: career-agent · fpl-jubilee-ascent · jubilees-gambit
- **Decisions:** Cross-tool source = project AGENTS.md Session start. Cursor duplicate retired (.mdc + legacy .md). Apply removes orphans so reapply cleans. Keep `read-agents-md.mdc`.
- **Blocked:** None
- **Next:** Checkpoint this repo; PENDING: commit/push three downstreams (ask); leftover `read-agents-md.md` beside `.mdc` on clients is separate optional cleanup

## Todo
- [x] Delete template + this-repo rule
- [x] apply.sh retire prune (.mdc + .md)
- [x] Fix tests
- [x] azg apply self + downstreams
- [x] Gate + Checkpoint

## Blockers / Notes
- Downstream working trees dirty (rule deleted); commit/push not run (no AUTH quote)
