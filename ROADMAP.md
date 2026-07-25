# Alpha-Zero-G — Roadmap

**Status:** v4 complete · post-v4 hardening checklist done (ownership · checkpoint · full skills · Lite gate)

> Zero-context: [`docs/AGENT-ONBOARDING.md`](docs/AGENT-ONBOARDING.md) · Spec: [`docs/REVAMP-SPEC.md`](docs/REVAMP-SPEC.md) · Reality: [`docs/agents/current-state.md`](docs/agents/current-state.md) · Glossary: [`CONTEXT.md`](CONTEXT.md)

---

## Vision

Reliable Delivery: higher Task Success per Delivery Cost than No-Harness Baseline, with Minimal Setup, across devices and Cursor/Antigravity. Repo-native gates own guarantees; IDE hooks are thin adapters.

ADRs: [`0004`](docs/adr/0004-repo-native-reliability-boundary.md) · [`0007` Lite adoption gate](docs/adr/0007-swe-bench-lite-adoption-gate.md) · [`0008` ownership](docs/adr/0008-global-ownership-boundary.md)

---

## Phase 0–9 — complete

v4 harness · Portable Core · Evidence (`run-all` + CI) · legacy Core Pilot (to be replaced by SWE-bench Lite 3-arm per ADR 0007).

---

## Post-v4 hardening (active)

- [x] Global ownership + selective uninstall (ADR 0008)
- [x] Unify Checkpoint Stop adapters (Work Packet)
- [x] Default setup = full vendor skills (no core allowlist)
- [x] Scaffold SWE-bench Lite 3-arm harness
- [x] Delete Blind Judge / old pilot claim suite

---

## Explicitly deferred

Stack wizard · full GitHub MCP default · blocking PreCompact · third-party skill-loop promotion methods

---

> **Pre-commit gate:** `bash tests/run-all.sh` (or `shellcheck` + `test-azg` + affected phase tests) must pass before proposing commits. Project clients: `bash tests/verify.sh`.
