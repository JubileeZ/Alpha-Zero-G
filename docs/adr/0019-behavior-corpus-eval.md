# Behavior Corpus is the adopt corpus; score Outcome not fable format

Process Gate adopt corpus is the **Behavior Corpus**: Executor Traps with objective **Observable Outcome** scorers. **Report Evidence** (authorization declined or quoted, Twin Sweep, spec-vs-test, prescribed follow-up left pending) is recorded separately as equivalent prose — not `AUTH:` / `TWINS:` / `INTENT:` / `PENDING:` spelling. Live miss + scorer may still add fixtures later.

**Status:** accepted 2026-08-14

**Considered options:** wait for a live miss (rejected — gate stays INCOMPLETE until accident); keep fable token / LLM-judge GROUND-TRUTH as pass (rejected — measures format, not Device Setup); reopen full S1–S14 including s7/s8/s11 (rejected — judge/style, not executor Outcome).

**Consequences:** Corpus on disk (`evals/traps/scenarios/`, 12 Executor Traps): kept s1–s6, s9, s10, s12–s14; dropped s7, s8, s11 from the gate; added **weakened-check**. **intent-tie** retired 2026-08-14 (ceiling; recover from git). Objective scorer `score_outcome.py`. No LLM-judge override of Task Success. Vendor fable tree and `wip/fable-method` removed (git history). Historical `gate-execution-protocol-v1` incomparable.

**Amends:** ADR 0018 (earned-only INCOMPLETE superseded); ADR 0012 (scoring: Outcome vs Evidence; corpus pointer).

**Amended 2026-08-14:** Dropped **intent-tie** from adopt corpus. Count 13→12. Live Intent Tie paragraph removed with ADR 0021.
