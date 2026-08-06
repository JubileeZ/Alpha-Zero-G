# ADR 0011 — No spawn-budget hook

## Status

Accepted (2026-08)

## Context

ADR 0006 shipped `spawn-budget.sh` on PreToolUse to cap concurrent and nested subagent spawns. AGENTS.md grill (2026-08) removed all spawn-budget prose — agents had no documented surface for the policy while hosts could still deny spawns silently.

Subagent fan-out is already bounded by host defaults (IDE/agent runtime). A repo-local counter duplicated that with extra hook surface, jq state, apply/scaffold paths, and test suites.

## Decision

1. Remove spawn-budget from the harness: no `spawn-budget.sh`, no `spawn-budget.json`, no PreToolUse / SubagentStop / SessionStart wires in `.agents/hooks.json`.
2. `azg apply` deletes retired spawn-budget files on Downstream repos and strips spawn-budget commands from merged `hooks.json`.
3. Subagent limits = host responsibility. Projects that need explicit caps add their own hook or document host settings in user-zone `AGENTS.md`.

## Consequences

- No silent deny on subagent spawn from azg-owned hooks.
- Smaller scaffold/apply surface; fewer hook lifecycle events on SessionStart/SubagentStop.
- ADR 0006 superseded; host-contract smoke no longer exercises spawn slot lifecycle.
- Downstream must reapply to drop orphaned spawn-budget files and hook wires.

## Supersedes

[ADR 0006 — Spawn-budget blocks on PreToolUse](0006-spawn-budget-pretooluse.md)
