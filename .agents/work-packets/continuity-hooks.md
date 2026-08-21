# Active Task: continuity-hooks

- **Status:** Landed in this repo; adopted repos still need apply
- **Objective:** Retire Stop/PreCompact hijack; git-native Work Packets; wire Cursor safety adapter
- **Acceptance:** `bash tests/test-phase1.sh`, `test-phase2.sh`, `test-azg.sh`, `tests/verify.sh` pass; Cursor `hooks.json` runs block-destructive-ops; no `task.md` seeded
- **Issue/Ticket:**

## Work Packet (SFDBN)

- **Status:** Implementation in this repo complete (ADR 0022)
- **Files:** hooks, apply/scaffold, AGENTS.md, ADR 0022
- **Decisions:** Packet path `.agents/work-packets/<slug>.md`; pointer `.agents/handoff-pointer`; Cursor safety adapter on first unmatched `beforeShellExecution`; missing jq fail-closed; finished packet = checked boxes with no open `- [ ]`
- **Blocked:** None
- **Next:** `azg apply` on adopted repos; new Agent Session so Cursor reloads hooks.json

## Todo
- [ ] Adopted repos: `azg apply` then new Agent Session

## Blockers / Notes
- Independent Request: no packet I/O
