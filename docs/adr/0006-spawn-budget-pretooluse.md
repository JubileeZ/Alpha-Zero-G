# ADR 0006 — Spawn-budget blocks on PreToolUse, not SubagentStart

## Status

Superseded by [ADR 0011](0011-no-spawn-budget.md) (2026-08).

## Context

Antigravity hook table: `SubagentStart` **cannot** block. Deny JSON on that event is observe-only. Template previously wired `spawn-budget.sh` only on `SubagentStart`, so budget limits could not prevent spawns on hosts that follow that table.

Subagent spawn appears as tool `invoke_subagent` (Antigravity SDK / CLI); `PreToolUse` **can** deny.

## Decision

1. Enforce `spawn-budget.sh` on `PreToolUse` matcher `invoke_subagent` (and aliases `START_SUBAGENT|task|Task|spawn_subagent|subagent|agent` for host variance). Do **not** also run it on `SubagentStart` (cannot block; would double-count vs one `--finish`).
2. Track active concurrent subagents dynamically (default `max_spawns: 5`, `max_depth: 1`). No cumulative session cap or `mode` switch — sequential work uses slot release via `--finish`.
3. `SubagentStop` fires `spawn-budget.sh --finish` to release active slots when subagents complete tasks.
4. `SessionStart` resets via `spawn-budget.sh --reset`.

## Consequences

- Deny on budget exceed is host-enforceable where PreToolUse is honored.
- Active concurrent tracking allows long-running batch sessions to process arbitrary sequential subagents without artificial session cumulative caps.
- Strict `max_depth: 1` prevents subagent nesting and recursive runaway fan-out loops.
- Host-contract smoke automates spawn-over-budget and slot-release (allow → deny → finish → reuse).
- `--finish` releases a slot only when the stop payload includes `subagent_id` (or `subagent.session_id`); missing id is a no-op — SessionStart `--reset` is the stuck-cap backstop.
