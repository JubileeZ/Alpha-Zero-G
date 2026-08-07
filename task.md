# Active Task: Eval Device Home landed — re-gate next

- **Status:** Fake HOME (device-core) implemented; Process Gate re-run still owed
- **Objective:** Real-world Device Setup mimic under Docker; then full `isolation=docker` Process Gate
- **Acceptance:** stage-eval-home + --home mounts; no WT inject; tests green; re-gate campaign analyzed
- **Issue/Ticket:** Grill Eval Device Home 2026-08-07 · ADR 0013 amend

## Work Packet (SFDBN)

- **Status:** Harness done; re-gate pending
- **Files:** `evals/stage-eval-home.sh` · `evals/run-agent-isolated.sh` · `evals/run-trap-cell.sh` · `tests/test-eval-isolation.sh` · ADR 0013 · CONTEXT
- **Decisions:** Per-arm fake HOME; azg-owned core only; once per ref; no WT inject; re-gate required
- **Blocked:** None
- **Next:** Commit → Docker Process Gate re-run (new camp; Current=`87b4eda` Candidate=`HEAD`)

## Todo
- [x] Grill fake HOME
- [x] Implement + structural tests
- [ ] Commit
- [ ] Docker Process Gate re-run
- [ ] Lite Agent arms (follow-up)

## Blockers / Notes
- Prior 71/71/71 was worktree-inject era — not comparable after this change
