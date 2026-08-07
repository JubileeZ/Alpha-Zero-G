# Active Task: Process Gate done — adopt vs ablate

- **Status:** Docker Process Gate **complete** (`azg-concept-docker`)
- **Objective:** Recorded; await human adopt (tie≥) or ablate D delta
- **Acceptance:** 42/42 · isolation=docker · promote-result written · continuity updated
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** B/C/Cand = 10/14 each (71%); `promote_process_gate=true` (three-way tie, no lift); auto-loop not needed
- **Files:** `evals/traps/CAMPAIGN.md` · `promote-result.json` (gitignored camp) · ROADMAP · current-state
- **Decisions:** Mechanical promote on ≥; product choice still open — adopt Candidate as Current or ablate D for no aggregate gain
- **Blocked:** None (human decision)
- **Next:** User: adopt or ablate; then Lite Agent `run-agent-isolated` wire

## Todo
- [x] Docker Process Gate 42/42
- [x] Analyze + continuity
- [ ] Adopt or ablate Candidate (D)
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- All-fail: s2-surprise-trap, s13-twin-fleet
- Cand beat Current only on s6; Current beat Cand on s11; Baseline beat both on s3
