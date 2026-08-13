# Alpha-Zero-G — Roadmap

**Status:** v4 complete · Lite **removed** · planted Trap corpus retired (ADR 0018) · Earned Trap corpus empty

> Zero-context: [`docs/AGENT-ONBOARDING.md`](docs/AGENT-ONBOARDING.md) · Spec: [`docs/SPEC.md`](docs/SPEC.md) · Reality: [`docs/agents/current-state.md`](docs/agents/current-state.md) · Glossary: [`CONTEXT.md`](CONTEXT.md)

---

## Vision

Reliable Delivery: higher Task Success per Delivery Cost than No-Harness Baseline, with Minimal Setup, across devices and Cursor/Antigravity. Repo-native gates own guarantees; IDE hooks are thin adapters.

ADRs: [`0004`](docs/adr/0004-repo-native-reliability-boundary.md) · [`0009` intent-gates](docs/adr/0009-distilled-intent-gates.md) · [`0012` Trap machinery](docs/adr/0012-trap-suite-process-gate.md) · [`0016` Execution Protocol v1](docs/adr/0016-promote-execution-protocol-v1.md) · [`0017` EP/judge/orchestrate layering](docs/adr/0017-ep-judge-orchestrate-layering.md) · [`0018` Earned Traps](docs/adr/0018-earned-traps-eval-suite.md)

---

## Phase 0–9 — complete

v4 harness · Portable Core · Evidence (`run-all` + CI) · legacy Core Pilot retired.

---

## Post-v4 hardening (active)

- [x] Global ownership + selective uninstall (ADR 0008)
- [x] Unify Checkpoint Stop adapters (Work Packet)
- [x] Default setup = full vendor skills (no core allowlist)
- [x] Scaffold SWE-bench Lite 3-arm harness — **deleted 2026-08-07** (ADR 0007 superseded)
- [x] Delete Blind Judge / old pilot claim suite
- [x] Distilled Think+Prove + analyst domains (ADR 0010; later clean-slated)
- [x] Trap Eval Isolation + Device Home (ADR 0013)
- [x] Clean slate always-on + delete `skills/azg/`
- [x] Process Gate = Preview + Adopt Ledger **R=5** @ `luna-low` (`run-process-gate.sh`); prior xhigh/Smoke/tiered path retired
- [x] Promote instructions-only Candidate — always-on ponytail retired (ADR 0015); vendor `ponytail-skills` remains
- [x] Promote Execution Protocol v1 always-on (ADR 0016); Trap `gate-execution-protocol-v1` R=5 RECOMMEND_ADOPT
- [x] EP v2 Candidate killed after Preview — keep Current EP v1 (ADR 0017)
- [x] Wipe incomparable camps + rate research (apple-to-apple)
- [x] ADR 0018 Earned Traps — planted S1–S14 leave adopt corpus; keep runners/isolation; EP v1 stays until earned gate can promote Guidance
- [ ] Archive planted vendor scenarios (`evals/traps/vendor/fable-method/scenarios/`) — explicit follow-up; do not `rm` runners
- [ ] First Earned Trap: live miss + objective scorer → corpus; then optional heuristic/skill

Live notes: `evals/traps/CAMPAIGN.md`.

---

> **Pre-commit gate:** `bash tests/run-all.sh` (or `shellcheck` + `test-azg` + affected phase tests) must pass before proposing commits. Project clients: `bash tests/verify.sh`.
