# Alpha-Zero-G — Roadmap

**Status:** v4 complete · Lite suite **removed** · Trap Process Gate = sole eval (ADR 0012)

> Zero-context: [`docs/AGENT-ONBOARDING.md`](docs/AGENT-ONBOARDING.md) · Spec: [`docs/SPEC.md`](docs/SPEC.md) · Reality: [`docs/agents/current-state.md`](docs/agents/current-state.md) · Glossary: [`CONTEXT.md`](CONTEXT.md)

---

## Vision

Reliable Delivery: higher Task Success per Delivery Cost than No-Harness Baseline, with Minimal Setup, across devices and Cursor/Antigravity. Repo-native gates own guarantees; IDE hooks are thin adapters.

ADRs: [`0004`](docs/adr/0004-repo-native-reliability-boundary.md) · [`0007` Lite — superseded](docs/adr/0007-swe-bench-lite-adoption-gate.md) · [`0008` ownership](docs/adr/0008-global-ownership-boundary.md) · [`0009` distilled intent-gates](docs/adr/0009-distilled-intent-gates.md) · [`0012` Trap sole gate](docs/adr/0012-trap-suite-process-gate.md)

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
- [x] Default trap path = **tier sweep** low/medium/high + `run-repeats` for majority
- [ ] Re-earn distill from durable Fable>Current gaps (see `evals/traps/CAMPAIGN.md`) or park

Live notes: `evals/traps/CAMPAIGN.md`.

---

> **Pre-commit gate:** `bash tests/run-all.sh` (or `shellcheck` + `test-azg` + affected phase tests) must pass before proposing commits. Project clients: `bash tests/verify.sh`.
