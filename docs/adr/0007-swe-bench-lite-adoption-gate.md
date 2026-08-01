# SWE-bench Lite Adoption Gate

Homemade fixtures + Blind Judge (human-calibrated) are replaced as the official adopt/claim path by a frozen SWE-bench Lite slice scored only by automated tests. Adoption compares three arms — No-Harness Baseline, Current Treatment, Candidate Treatment — and promotes a Candidate only when Task Success is not worse than Current and Baseline (`candidate_pass_rate >= current` and `>= baseline`).

**Delivery Cost is not a promote gate** for this campaign or any future 3-arm Lite campaign. When `delivery_cost` is present on scorecards, medians are reported for humans; when absent, omit. No IDE metering today; manual fill only. Aligns with `CONTEXT.md` Delivery Cost. (Previously: optional ≤1.25× Current median when both medians present — removed from the decide rule.)

Scaffold the Lite harness before deleting the old suite so there is never a gap with zero eval. Default skill-profile expansion remains an explicit preference exception only where a later ADR says so; intent-gates Candidate (ADR 0009) uses this gate with no cost exception needed.
