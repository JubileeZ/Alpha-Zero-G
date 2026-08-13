# Earned Traps replace planted S1–S14 as Evaluation Suite corpus

Planted Fable Trap Suite (S1–S14) is no longer the adopt corpus. Successor Evaluation Suite = **Earned Traps**: fixtures created from live observed misses, each with an objective scorer, still 3-arm vs No-Harness Baseline and Current, docker isolation (ADR 0013), `gpt-5.6-luna-low`, Preview then Adopt Ledger R=5 on the earned corpus. Always-on lines and skills are earned the same way (broad heuristic → one Device Setup line; repeated procedure → skill; never a fixture answer key). Execution Protocol v1 stays shipped (ADR 0016) until an Earned Trap campaign can promote a change. Guidance Treatment (housekeeping-only always-on) is intent, not `azg setup` in this ADR.

**Status:** accepted 2026-08-13

Accept session: no vendor/scenario delete. Archive planted S1–S14 is an explicit follow-up.

**Considered options:** keep planted S1–S14 as Process Gate (rejected — operator: create traps as misses appear); delete `evals/traps/` and ship Guidance on policy with no gate (rejected — no promote path; silent 0016 rollback); revive SWE-bench Lite (rejected — different corpus, ADR 0007 still superseded).

**Consequences (on accept, not before):**
- ADR 0012 superseded for *corpus*. Runners, docker Eval Isolation, Device Home stager, analyze/recommend math stay until an earned fixture exists.
- Archive planted vendor scenarios (`evals/traps/vendor/fable-method/scenarios/`); do not use S1–S14 for Recommend Adopt. Do not `rm` runners or isolation tests in the same step as accept.
- Process Gate is **INCOMPLETE** while earned corpus is empty — no Device Setup always-on promote, including Guidance Treatment.
- First Earned Trap: live miss → objective scorer → fixture in corpus → then optional heuristic/skill. Inverse of a just-written instruction is not an Earned Trap.
- EP v1 remains Current Treatment until that gate can run.

**Amends:** ADR 0012 (corpus only); ADR 0016 (unchanged ship; next always-on change must pass Earned Trap gate); ADR 0017 (re-earn via Earned Trap, not planted S1–S14).
