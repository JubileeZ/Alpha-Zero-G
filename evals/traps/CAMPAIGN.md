# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | Policy: Smoke Filter → Adopt Run (ADR 0012). Unified-pipeline smoke N=3 done (33/33/33); next = official Smoke R=2 then Adopt |
| Rates B/C/Cand (ad-hoc smoke) | **33/33/33** — s2 0/0/0 · s5 1/1/1 · s9 0/0/0 |
| Sole gate | Trap Process Gate (ADR 0012); Lite deleted |
| Smoke Filter | `run-smoke-filter.sh`: s2,s9,s13 × **R=2** · luna-xhigh · not promote |
| Adopt Run | After smoke pass: tiered R (lift 4 · stable 1 · unstable 5 · s14→4 if unsure); stand-in `run-repeats.sh` R=4 full |
| Optional diagnostic | `run-tier-sweep.sh`: low/medium/high, R=1 → `TIERS.md` |
| Single-model default | `gpt-5.6-luna-xhigh` |
| Current Treatment | clean slate @ `a9a68ff` / HEAD worktree for new camps; pin `AZG_CURRENT_REF` as needed |
| Next | `TRAP_CANDIDATE_PACK=unified-pipeline bash evals/traps/run-smoke-filter.sh` — then Adopt only if pass |
| Shipped | `47b2f2e` Candidate staged; ADR 0012 two-tier + `run-smoke-filter.sh` |

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
