# Trap Suite Process Gate + Lite model default

Lite remains the Evaluation Suite (Task Success, ADR 0007). Intent/Prove/Domain Candidates use a separate **Process Gate**: vendored Fable-method Trap Suite (MIT) under `evals/traps/vendor/fable-method/`, 3-arm promote Candidate ≥ Current ≥ Baseline on a selected subset (default N=5 via relevance map + random-fill; full corpus allowed for deep/first runs). Objective scoring preferred; LLM judge fallback for fixtures without a local scorer. Adherence mini-campaign retired. Lite Agent CLI default model moves to `gpt-5.6-luna-medium`; traps default `gpt-5.6-luna-low`.

**Status:** accepted

**Considered options:** traps replace Lite (rejected — Task Success still required); adherence-only process smoke (rejected — weaker than planted traps); gate=all scenarios every time (rejected — cost/noise; catalog kept, run subset).
