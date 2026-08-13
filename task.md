# Active Task: ADR 0018 Earned Traps (checkpoint)

- **Status:** Decision recorded; revisable
- **Objective:** Save grill decision: planted S1–S14 leave adopt corpus; Earned Traps succeed; EP v1 stays shipped until that gate can promote Guidance
- **Acceptance:** ADR 0018 accepted on disk; glossary/ROADMAP/current-state/eval READMEs match; no vendor scenario delete this commit
- **Issue/Ticket:** none

## Work Packet (SFDBN)

- **Status:** Checkpointed; pushed with this commit
- **Files:** `docs/adr/0018-earned-traps-eval-suite.md`, `CONTEXT.md`, `ROADMAP.md`, `docs/SPEC.md`, eval READMEs, `tests/test-eval-isolation.sh`
- **Decisions:** ADR 0018 accepted (revisable). Adopt corpus = Earned Traps (live miss + objective scorer). Planted S1–S14 not a promote input; files stay until explicit archive. Guidance Treatment = housekeeping intent, not `azg setup`. EP v1 remains Current. Also: eval-isolation assertion matches live EP v1 (`Execution Protocol v1` + `INTENT:`).
- **Blocked:** none
- **Next:** archive planted vendor scenarios (ask first); first Earned Trap from a live miss

## Todo
- [x] Accept ADR 0018; update glossary, ROADMAP, current-state, eval docs
- [x] Keep planted vendor scenarios on disk
- [x] Align `tests/test-eval-isolation.sh` with EP v1 staged home
- [ ] Archive planted vendor scenarios (explicit follow-up)
- [ ] First Earned Trap: live miss + objective scorer
- [ ] CI green on main after push

## Blockers / Notes
- Decisions are durable in git/ADRs, not frozen — revise with a new ADR if the gate story changes
- Local `AZG_STRICT=1 run-all` may fail if shellcheck missing (env-only; CI installs deps)
