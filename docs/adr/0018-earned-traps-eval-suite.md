# Earned Traps replace planted S1–S14 as Evaluation Suite corpus

**Status:** superseded by ADR 0019 (2026-08-14)

Planted Fable Trap Suite (S1–S14) left the adopt corpus. This ADR made **Earned Traps** (live miss + objective scorer) the successor. ADR 0019 then set the adopt corpus to the **Behavior Corpus** (reviewed executor traps + new azg-owned scenarios, Outcome scorers). Earned-from-live-miss remains an add path, not the sole corpus.

**Accepted:** 2026-08-13

**Considered options:** keep planted S1–S14 as Process Gate (rejected); delete `evals/traps/` and ship Guidance with no gate (rejected); revive SWE-bench Lite (rejected).

**Historical consequences (at accept):** runners/isolation stayed; vendor S1–S14 not Recommend Adopt; gate INCOMPLETE while earned corpus empty; EP v1 stayed Current.

**Amends:** ADR 0012 (corpus only, later 0019); ADR 0016; ADR 0017.

**Superseded by:** [ADR 0019](0019-behavior-corpus-eval.md).
