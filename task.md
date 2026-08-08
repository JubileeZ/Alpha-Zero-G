# Process Gate reset — luna-low Adopt Ledger

**Objective:** Sole Process Gate = Preview Round + Adopt Ledger R=5 @ `gpt-5.6-luna-low`; wipe incomparable history; retire old runners.

**Acceptance:** `run-process-gate.sh` + `analyze_ledger.py`; test-traps green; ADR 0012 amended; old camps/rate research gone.

## Work Packet (SFDBN)

**Status:** done — Process Gate reset shipped (Preview+Ledger R=5 @ luna-low; old path wiped)

**Files:**
- `evals/traps/run-process-gate.sh`
- `evals/traps/analyze_ledger.py`
- `evals/analyze-trap-ledger.sh`
- `evals/traps/{README,CAMPAIGN}.md` · `evals/README.md`
- `docs/adr/0012-trap-suite-process-gate.md`
- `CONTEXT.md` · `docs/agents/current-state.md` · `ROADMAP.md` · `AGENTS.md`
- `tests/test-traps.sh`
- `task.md`

**Decisions:**
- Model luna-low only; Preview=r1 full corpus; Adopt r2–r5; arm order Cand→Cur→B
- Coverage = Cand mean≥Cur on ≥50% scenarios; Baseline coverage display-only
- Recommend matrix ADOPT / REJECT / USER_DECIDES / INCOMPLETE
- Hard wipe prior camps + rate research/archive

**Blocked:** none

**Next:** Operator runs `run-process-gate.sh` for Candidate; human confirm after Preview
