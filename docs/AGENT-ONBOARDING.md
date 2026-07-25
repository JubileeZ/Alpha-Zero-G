# Agent Onboarding — Zero Context Start

You have **no chat history**. Use **only** the files below to understand what Alpha-Zero-G is and what to build.

## Read order

1. **This file** — orientation (you are here)
2. [`docs/REVAMP-SPEC.md`](REVAMP-SPEC.md) — **canonical** v4 design (what we are building)
3. [`ROADMAP.md`](../ROADMAP.md) — phased checklist (in what order)
4. [`docs/agents/current-state.md`](agents/current-state.md) — what already exists vs gaps

Optional during implementation:

- [`docs/agents/progress.md`](agents/progress.md) — how to update work-state files
- [`docs/FRONTIER-REVAMP-EVAL-PROMPT.md`](FRONTIER-REVAMP-EVAL-PROMPT.md) — prompt for frontier agent project re-evaluation
- [`AGENTS.md`](../AGENTS.md) — commands, safety, pre-commit gate for **this repo**

## One-paragraph summary

Alpha-Zero-G v4 is complete: **budget-conscious, multi-IDE outer harness** with harness-only project templates, filesystem continuity, GitHub-default issue adapter (`gh`, not MCP), 12 curated global skills + Ponytail rule, four enforcement hooks, and one PreCompact observability hook. Phase 10 Fable promotion remains parked pending delivery-cost evidence; `REVAMP-SPEC.md` defines design and `current-state.md` records reality.

## Before writing code

1. Read `current-state.md` — do not rebuild what exists.
2. If phase active, pick **first unchecked** `ROADMAP.md` item; do not resume parked work without approval.
3. Run verify commands from `AGENTS.md` before proposing commits.

## What NOT to read for orientation

- `docs/archive/*` — historical only
- `docs/antigravity-agent-architect/*` — reference material; may contradict v4 spec
- `docs/ALPHA-ZERO-G-V3-PLAN.md` — moved to archive; superseded
