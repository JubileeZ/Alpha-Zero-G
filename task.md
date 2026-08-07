# Active Task: Process Gate adopted — Lite isolation next

- **Status:** Candidate (D+clarity) **adopted** as Current (`87b4eda`); take for now
- **Objective:** Keep adopted gates; next = Lite Agent arms via `run-agent-isolated.sh`
- **Acceptance:** Defaults point at `87b4eda`; continuity records adopt
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Adopt done; Docker Gate closed
- **Files:** `evals/run-trap-cell.sh` · `evals/traps/run-full-first.sh` · CAMPAIGN · ROADMAP · current-state
- **Decisions:** Take Candidate despite 71% three-way tie (mechanical ≥); prior Current `d5711c2` retired for trap defaults
- **Blocked:** None
- **Next:** Wire Lite Agent arms to `run-agent-isolated.sh`

## Todo
- [x] Docker Process Gate
- [x] Adopt Candidate as Current
- [ ] Lite Agent arms via same helper

## Blockers / Notes
- Still open hard fails: s2, s13 (future Candidate material)
