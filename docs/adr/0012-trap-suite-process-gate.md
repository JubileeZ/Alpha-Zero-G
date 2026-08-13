# Trap Suite Process Gate (sole eval gate)

**Status:** accepted (amended 2026-08-08 — Preview Round + Adopt Ledger @ `luna-low`); **superseded in part by ADR 0018 (2026-08-13)** — planted S1–S14 no longer the adopt corpus. Runners, docker isolation, 3-arm math remain. Successor corpus = Earned Traps.

Intent/Prove/Domain Candidates and Treatment adopt use the **Process Gate**: vendored Fable-method Trap Suite (MIT) under `evals/traps/vendor/fable-method/`, 3-arm compare on full corpus **and** `isolation=docker` (ADR 0013). Objective scoring preferred; LLM judge fallback for fixtures without a local scorer. Adherence mini-campaign retired. SWE-bench Lite (ADR 0007) **superseded** — harness deleted.

## Sole path

Entrypoint: `evals/traps/run-process-gate.sh`. Sole decision model: **`gpt-5.6-luna-low`**. Arm order: **candidate → current → baseline** (all scenarios parallel within one arm).

1. **Preview Round** — full S1–S14 × R=1 × 3 arms → ledger `r1`. Show full detail; **always ask** before more spend.
2. **Adopt Run** — on consent, four more full rounds (`r2`–`r5`). Preview counts → uniform **Adopt Ledger R=5**.

Decline after Preview: keep `r1`; resume later with `--continue --yes`.

### Recommend (not auto-merge)

Ledger complete (R=5, no nulls, docker) then:

| Overall maj Cand≥Cur≥B | Coverage (Cand mean≥Cur on ≥50% scenarios) | Advice |
|------------------------|--------------------------------------------|--------|
| win | win | **RECOMMEND_ADOPT** |
| lose | lose | **RECOMMEND_REJECT** |
| mixed | | **USER_DECIDES** |
| nulls / R&lt;5 / not docker | | **INCOMPLETE** |

Board: per-scenario pass/fail/null counts, mean rates, Cand vs Cur win/neutral/loss (strict `>`). Coverage gate uses Cand≥Cur (ties help Cand). **Baseline coverage %** reported only. If Baseline majority rate strictly highest → warning (“revise Candidate”); overall already blocks ADOPT.

Analyzer: `evals/traps/analyze_ledger.py` / `evals/analyze-trap-ledger.sh` → `LEDGER.md`.

**Retired:** Smoke Filter (3-id), tiered-R Adopt, `run-repeats`, tier-sweep, `classify-adopt-r`, luna-xhigh Process Gate defaults.

**Considered options:** keep xhigh (rejected — incomparable mix); Preview display-only (rejected — double-spend); family Coverage (rejected — scenario Coverage clearer); Candidate-last arms (rejected — operator chose Candidate-first).

**Consequences:** Live Campaign = `evals/traps/CAMPAIGN.md`. No `evals/lite/`. Prior camps/rate research wiped for apple-to-apple. Delivery Cost never a promote input.
