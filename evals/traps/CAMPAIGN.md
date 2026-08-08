# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | Protocol reset 2026-08-08: **Preview + Adopt Ledger @ luna-low**; prior camps/rate research wiped |
| Sole gate | Trap Process Gate (ADR 0012) |
| Entrypoint | `evals/traps/run-process-gate.sh` |
| Model | `gpt-5.6-luna-low` |
| Ledger | R=5 (Preview=`r1` + Adopt `r2`–`r5`) |
| Next | Run Process Gate for unified-pipeline (or chosen pack); human confirm after Preview |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).

## Reproduce

```bash
TRAP_CANDIDATE_PACK=unified-pipeline \
  TRAP_CAMP=$PWD/evals/traps/campaigns/gate-unified-pipeline \
  bash evals/traps/run-process-gate.sh
```

## History

Prior xhigh / Smoke Filter / tiered-R camps and rate research **deleted** (not comparable). New ledger starts clean.
