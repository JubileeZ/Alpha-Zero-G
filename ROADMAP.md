# Alpha-Zero-G — Roadmap

**Status:** v4 complete · Phases 0–9 done · Portable Core (`tests/verify.sh`) shipped

> Zero-context: [`docs/AGENT-ONBOARDING.md`](docs/AGENT-ONBOARDING.md) · Spec: [`docs/REVAMP-SPEC.md`](docs/REVAMP-SPEC.md) · Reality: [`docs/agents/current-state.md`](docs/agents/current-state.md) · Glossary: [`CONTEXT.md`](CONTEXT.md)

---

## Vision

Reliable Delivery: higher Task Success per Delivery Cost than No-Harness Baseline, with Minimal Setup, across devices and Cursor/Antigravity. Repo-native gates own guarantees; IDE hooks are thin adapters.

ADR: [`0004-repo-native-reliability-boundary`](docs/adr/0004-repo-native-reliability-boundary.md)

---

## Phase 0–9 — complete

v4 harness · Portable Core · Evidence (`run-all` + CI) · Core Pilot suite (fixtures, Blind Judge, Long-Horizon, prereg/held-out gate). Claim only after confirmation+held-out + `--apply-claim`.

---

## Explicitly deferred

Stack wizard · full GitHub MCP default · blocking PreCompact · SWE-bench as primary signal · third-party skill-loop promotion methods

---

> **Pre-commit gate:** `bash tests/run-all.sh` (or `shellcheck` + `test-azg` + affected phase tests) must pass before proposing commits. Project clients: `bash tests/verify.sh`.
