# Agent Onboarding — Zero Context Start

You have **no chat history**. Use **only** the files below to understand what Alpha-Zero-G is and what to build.

## Read order

1. **This file** — orientation (you are here)
2. [`docs/SPEC.md`](SPEC.md) — **canonical** v4 design (what we are building)
3. [`ROADMAP.md`](../ROADMAP.md) — phased checklist (in what order)
4. [`docs/agents/current-state.md`](agents/current-state.md) — what already exists vs gaps

Optional during implementation:

- [`docs/agents/progress.md`](agents/progress.md) — how to update work-state files
- [`docs/ARCHITECTURE-AUDIT.md`](ARCHITECTURE-AUDIT.md) — prompt for frontier agent project re-evaluation
- [`AGENTS.md`](../AGENTS.md) — commands, safety, pre-commit gate for **this repo**

## One-paragraph summary

Alpha-Zero-G v4 is complete: **budget-conscious, multi-IDE outer harness** with harness-only project templates, filesystem continuity, GitHub-default issue adapter (`gh`, not MCP), full vendored global skills + Ponytail catalog skill, safety + commit-gate hooks, and Behavior Corpus Process Gate (ADR 0019; Lite suite removed). `SPEC.md` defines design and `current-state.md` records reality.

## Before writing code

1. Read `current-state.md` — do not rebuild what exists.
2. If phase active, pick **first unchecked** `ROADMAP.md` item; do not resume parked work without approval.
3. Run verify commands from `AGENTS.md` before proposing commits.
4. **macOS CI trap:** GHA `macos-latest` runs Bash 3.2. Never add `mapfile`/`readarray`/`declare -A` to `lib/` — that pattern red-gated main repeatedly (ubuntu green, macos red).

## What NOT to read for orientation

- `docs/archive/*` — historical only (recover prior research from git history)
- `docs/ALPHA-ZERO-G-V3-PLAN.md` — moved to archive; superseded
