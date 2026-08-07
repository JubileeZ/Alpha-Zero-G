# SWE-bench Lite Adoption Gate

Homemade fixtures + Blind Judge (human-calibrated) are replaced as the official adopt/claim path by a frozen SWE-bench Lite slice scored only by automated tests. Adoption compares three arms — No-Harness Baseline, Current Treatment, Candidate Treatment — and promotes a Candidate only when Task Success is not worse than Current and Baseline (`candidate_pass_rate >= current` and `>= baseline`).

**Frozen slice (v2, 2026-08-01):** **N=5** Lite `instance_id`s with **data/numerical-Python bias** (astropy, matplotlib, seaborn, scikit-learn, sympy) — replaces v1 N=10 (django/web-heavy) to cap **agent model spend** at 5 × 3 = **15** runs per campaign. Same promote rule. `evals/lite/instances.json` is the source of truth; mid-campaign ID changes forbidden.

**Delivery Cost is not a promote gate** for this campaign or any future 3-arm Lite campaign. When `delivery_cost` is present on scorecards, medians are reported for humans; when absent, omit. No IDE metering today; manual fill only. Aligns with `CONTEXT.md` Delivery Cost. (Previously: optional ≤1.25× Current median when both medians present — removed from the decide rule.)

Scaffold the Lite harness before deleting the old suite so there is never a gap with zero eval. Default skill-profile expansion remains an explicit preference exception only where a later ADR says so; intent-gates Candidate (ADR 0009) uses this gate with no cost exception needed. Agent runs may use IDE/CLI/subagent workflows; **Task Success** still requires the SWE-bench Docker harness (`resolved`), not API-free proxies.

**Status:** **superseded 2026-08-07** — operator chose Trap Suite Process Gate (ADR 0012) as sole eval/adopt path; Lite tree + runners + `test-lite.sh` **deleted**. Historical Lite adopt (2026-08-01 `promote=true`) remains in git history / research notes only. Do not reintroduce without a new ADR.
