# Trap spend policy (Smoke → Adopt)

**Objective:** Record two-tier Trap spend (ADR 0012 amend): Smoke Filter + tiered Adopt R; ship `run-smoke-filter.sh`.

**Acceptance:** ADR 0012 documents Smoke/Adopt; CONTEXT terms; CAMPAIGN/README/current-state updated; `evals/traps/run-smoke-filter.sh` runnable.

## Work Packet (SFDBN)

**Status:** done — policy saved; smoke helper landed

**Files:**
- `docs/adr/0012-trap-suite-process-gate.md`
- `CONTEXT.md` (Smoke Filter, Adopt Run)
- `evals/traps/run-smoke-filter.sh`
- `evals/traps/{README,CAMPAIGN}.md`
- `docs/agents/current-state.md`
- `task.md`

**Decisions:**
- Smoke: s2,s9,s13 × R=2; pass = no nulls + Cand≥Cur maj on s9/s13
- Adopt: tiered R (lift 4 · s2 1 · stable 1 · unstable 5 · no-hist 2 · s14→4 if unsure)
- Stand-in until per-id runner: full `run-repeats.sh` R=4
- Q8=C: policy + smoke helper

**Blocked:** none

**Next:** Optional — run official Smoke for unified-pipeline; tiered-R runner later
