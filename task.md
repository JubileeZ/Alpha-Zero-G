# Active Task: Spawn-budget SubagentStart double-wire

- **Status:** Done — Checkpoint now
- **Objective:** Remove SubagentStart spawn-budget; PreToolUse + Stop/Start lifecycle only (ADR 0006)
- **Acceptance:** host-contract-smoke + test-phase5 green; no `"SubagentStart"` in project hooks.json
- **Issue/Ticket:** subagent die diagnosis follow-up

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `.agents/hooks.json` · `templates/project/.agents/hooks.json` · `tests/host-contract-smoke.sh` · ADR 0006 · host-contract-smoke.md
- **Decisions:** Drop SubagentStart wire entirely (cannot block + double-counts); keep PreToolUse / --finish / --reset. Cursor Task abort ≠ budget deny — habit: skip parallel review Task on tiny diffs or `run_in_background: true`
- **Blocked:** None
- **Next:** Downstream `azg apply` refreshes client hooks.json merge — PENDING AUTH for push

## Todo
- [x] Remove SubagentStart from root + template hooks.json
- [x] Assert no SubagentStart in host-contract-smoke
- [x] Tests green (host-contract 14 · phase5 16)
- [x] Checkpoint commit

## Blockers / Notes
- Prior AGENTS telegraphic Checkpoint: `184361b`
