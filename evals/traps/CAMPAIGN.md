# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | **Done** — clean-slate tier sweep `cleanslate-tier-sweep` |
| Rates B/C/Fable | low **71/79/79** · med **71/64/79** · high **64/71/93** |
| Sole gate | Trap Process Gate (ADR 0012); Lite deleted |
| Default models | `gpt-5.6-luna-{low,medium,high}` via `run-tier-sweep.sh` |
| Single-model default | `gpt-5.6-luna-medium` |
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
# Default decision grid: full S1–S14 × low/medium/high (R=1)
bash evals/traps/run-tier-sweep.sh

# Majority gap check (usually medium)
bash evals/traps/run-repeats.sh
```

## History (pointers only)

| Camp / note | Where |
|-------------|--------|
| Tier sweep detail | local `campaigns/cleanslate-tier-sweep/TIERS.md` |
| Medium×3 majority | `docs/research/2026-08-07-fable-medium-r3-full-report.md` |
| Device Home / noise | `docs/research/2026-08-07-eval-device-home-process-gate.md` · noise-policy |
| Pre-iso / inject-era rates | not comparable — see research + git history |
