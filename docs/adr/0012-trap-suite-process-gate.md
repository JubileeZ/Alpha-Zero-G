# Trap Suite Process Gate (sole eval gate)

**Status:** accepted (amended 2026-08-07 — sole gate; Lite suite removed)

Intent/Prove/Domain Candidates and Treatment adopt use the **Process Gate**: vendored Fable-method Trap Suite (MIT) under `evals/traps/vendor/fable-method/`, 3-arm promote Candidate ≥ Current ≥ Baseline on a selected subset (default N=5 via relevance map + random-fill; **full corpus** for tier sweeps / deep runs). Objective scoring preferred; LLM judge fallback for fixtures without a local scorer. Adherence mini-campaign retired. SWE-bench Lite (ADR 0007) **superseded** — harness deleted.

**Defaults:** four full-corpus repeats at `gpt-5.6-luna-xhigh` via `evals/traps/run-repeats.sh`, majority aggregate. Low/medium/high `evals/traps/run-tier-sweep.sh` remains an optional R=1 diagnostic. Eval Isolation required for promote (ADR 0013).

**Considered options:** traps complement Lite (prior) → **rejected 2026-08-07** (operator never runs Lite); adherence-only process smoke (rejected); gate=all scenarios every routine run (rejected for cost — catalog kept; full corpus for tier/gap).

**Consequences:** No `evals/lite/`. Live Campaign = `evals/traps/CAMPAIGN.md`. Promote = Process Gate + `isolation=docker` only.
