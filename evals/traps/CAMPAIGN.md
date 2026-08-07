# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | **Clean slate Current** — Think/Prove Candidate **rejected** (reverted `bd94663`; Trap Cand 64/79/71 vs Cur 71/79/79) |
| Rates B/C/Fable | low **71/79/79** · med **71/64/79** · high **64/71/93** |
| Sole gate | Trap Process Gate (ADR 0012); Lite deleted |
| Default decision run | `run-repeats.sh`: 4× full corpus at `gpt-5.6-luna-xhigh` → majority `AGGREGATE.md` |
| Optional diagnostic | `run-tier-sweep.sh`: low/medium/high, R=1 → `TIERS.md` |
| Single-model default | `gpt-5.6-luna-xhigh` |
| Current Treatment | clean slate @ `a9a68ff` / HEAD worktree for new camps; pin `AZG_CURRENT_REF` as needed |
| Next | Re-earn distill from durable Fable>Current gaps **or park** |
| Shipped | `a9a68ff` clean slate + eval-watch |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).

## Durable-ish Fable > clean-Current (from tier sweep)

Prefer majority / multi-tier signal before distill. Noise policy: `docs/research/2026-08-07-trap-suite-noise-policy.md`.

| Signal | Notes |
|--------|-------|
| s9 | Med Fable lift |
| s13 | High only; twin-fleet hard trap |
| s14 | Low only — unstable across tiers |
| s3 | High |
| s10 | High Current miss |

All-fail by design (not distill targets from N=1 alone): **s2**, **s6**, **s13** patterns — see research reports.

## Reproduce

```bash
# Default decision run: full S1–S14 × 4 at luna-xhigh
bash evals/traps/run-repeats.sh

# Optional model-tier diagnostic
bash evals/traps/run-tier-sweep.sh
```

Repeat/tier runners emit `AZG_TRAP_CAMPAIGN_FINISHED` after final artifacts; watch that event first, then use fixed 120-second checks.

## History (pointers only)

| Camp / note | Where |
|-------------|--------|
| Fable vs Current (R=4 luna-xhigh) | `docs/research/2026-08-07-fable-vs-current-4x-repeat-report.md` — B 77%/79%, Cur 79%/79%, Fable 91%/93% (s9, s13 lift) |
| Think/Prove reject (tier sweep) | local `campaigns/think-prove-candidate/TIERS.md` — Cand 64/79/71 vs Cur 71/79/79 |
| Tier sweep detail | local `campaigns/cleanslate-tier-sweep/TIERS.md` |
| Medium×3 majority (archived) | `docs/archive/2026-08-07-fable-medium-r3-full-report.md` |
| Device Home / noise | `docs/research/2026-08-07-eval-device-home-process-gate.md` · noise-policy |
| Pre-iso / inject-era rates | not comparable — see research + git history |
