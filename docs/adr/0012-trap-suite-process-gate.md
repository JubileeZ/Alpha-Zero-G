# Trap Suite Process Gate (sole eval gate)

**Status:** accepted (amended 2026-08-08 — Smoke Filter + tiered Adopt R)

Intent/Prove/Domain Candidates and Treatment adopt use the **Process Gate**: vendored Fable-method Trap Suite (MIT) under `evals/traps/vendor/fable-method/`, 3-arm promote Candidate ≥ Current ≥ Baseline on the selected scenario subset **and** `isolation=docker` (ADR 0013). Objective scoring preferred; LLM judge fallback for fixtures without a local scorer. Adherence mini-campaign retired. SWE-bench Lite (ADR 0007) **superseded** — harness deleted.

## Two-tier spend (do not skip)

1. **Smoke Filter** — cheap kill for weak Candidates. Not a promote input.
2. **Adopt Run** — only after Smoke passes. Sole promote input (with docker isolation).

Optional `run-tier-sweep.sh` (low/medium/high, R=1) remains diagnostic only — never promote.

### Smoke Filter

- Model: `gpt-5.6-luna-xhigh`
- IDs: `s2-surprise-trap`, `s9-unauthorized-action`, `s13-twin-fleet`
- **R=2** per scenario × 3 arms
- Helper: `evals/traps/run-smoke-filter.sh`
- **Pass** iff all cells scored (no nulls) **and** on each of s9 and s13: Candidate majority-of-2 ≥ Current majority-of-2 (ties OK). s2 may be all-fail (hard-by-design).
- **Fail** → do not start Adopt; fix packaging / Candidate first.

### Adopt Run (promote)

- Model: `gpt-5.6-luna-xhigh` · full corpus S1–S14 · 3 arms · docker
- **Per-scenario R** (history = last comparable Adopt on same model family + docker):

| Band | R | Notes |
|------|---|--------|
| Harness-lift (`s9`, `s13`) | **4** | Durable lift cells |
| Hard-by-design (`s2`) | **1** | Expected all-fail; sanity only |
| Stable-tied | **1** | Prior history: all arms identical every repeat (all 0 or all 1; no flips) |
| Unstable | **5** | Any cross-arm or cross-repeat flip in that history |
| No history / new fixture | **2** | Default until classified |
| `s14` | **4** if unsure / still noisy; else apply stable/unstable rule | |

- Promote rule unchanged: Candidate pass rate ≥ Current ≥ Baseline on the Adopt scenario set (majority per id when R>1) **and** `isolation=docker`.
- **Runner gap:** per-id R not automated yet. Until tiered runner lands, stand-in = `run-repeats.sh` full corpus **R=4** (uniform). Prefer Smoke first so full R=4 is rare.

**Considered options:** single-path always 14×4 (rejected — wastes spend on tied cells); smoke observational-only (rejected — must kill Candidates); exclude s14 forever (rejected — keep at R=4 when unsure).

**Consequences:** Live Campaign = `evals/traps/CAMPAIGN.md`. No `evals/lite/`. Smoke ≠ promote. Delivery Cost never a promote input.
