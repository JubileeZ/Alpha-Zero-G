# Active Task: CI spawn-budget test pin

- **Status:** Committing
- **Objective:** Stop phase2/phase5 asserting stale spawn-budget defaults; pin explicit test budgets
- **Acceptance:** `bash tests/test-phase2.sh` + `bash tests/test-phase5.sh` + `bash tests/verify.sh` green
- **Issue/Ticket:** CI run https://github.com/JubileeZ/alpha-zero-g/actions/runs/30694316936

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `tests/test-phase2.sh` · `tests/test-phase5.sh`
- **Decisions:** Mechanism tests write own `spawn-budget.json`; shipped defaults covered by host-contract-smoke (5 concurrent)
- **Blocked:** None
- **Next:** None — pushed for CI re-run

## Todo
- [x] Pin budgets in phase2/phase5
- [x] Verify failing suites + verify.sh

## Blockers / Notes
- Root cause: `cfa0a13` raised defaults to max_spawns=5 / max_depth=1; phase2/5 still expected 3/2
