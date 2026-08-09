# Alpha-Zero-G — Roadmap

**Status:** v4 complete · Lite suite **removed** · Trap Process Gate = sole eval (ADR 0012)

> Zero-context: [`docs/AGENT-ONBOARDING.md`](docs/AGENT-ONBOARDING.md) · Spec: [`docs/SPEC.md`](docs/SPEC.md) · Reality: [`docs/agents/current-state.md`](docs/agents/current-state.md) · Glossary: [`CONTEXT.md`](CONTEXT.md)

---

## Vision

Reliable Delivery: higher Task Success per Delivery Cost than No-Harness Baseline, with Minimal Setup, across devices and Cursor/Antigravity. Repo-native gates own guarantees; IDE hooks are thin adapters.

ADRs: [`0004`](docs/adr/0004-repo-native-reliability-boundary.md) · [`0009` intent-gates](docs/adr/0009-distilled-intent-gates.md) · [`0012` Trap sole gate](docs/adr/0012-trap-suite-process-gate.md) · [`0016` Execution Protocol v1](docs/adr/0016-promote-execution-protocol-v1.md)

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
- [x] Wipe incomparable camps + rate research (apple-to-apple)

Live notes: `evals/traps/CAMPAIGN.md`.

---

> **Pre-commit gate:** `bash tests/run-all.sh` (or `shellcheck` + `test-azg` + affected phase tests) must pass before proposing commits. Project clients: `bash tests/verify.sh`.
