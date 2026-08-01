# Active Task: none (Lite map #85 complete)

- **Status:** Idle — last milestone closed
- **Objective:** —
- **Acceptance:** —
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) closed via [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt

## Work Packet (SFDBN)

- **Status:** Complete — Spawn budget hook fixed (PreToolUse invoke_subagent matcher added) and upgraded to active concurrent slot tracking (max_spawns: 5, max_depth: 1, mode: concurrent).
- **Files:** `.agents/hooks.json` · `.agents/hooks/spawn-budget.sh` · `.agents/spawn-budget.json` · `AGENTS.md` · `docs/adr/0006-spawn-budget-pretooluse.md` · `templates/project/` equivalents · `tests/host-contract-smoke.sh`
- **Decisions:** Enforce PreToolUse on invoke_subagent; active slot release on SubagentStop; default 5 concurrent, depth 1 flat, optional cumulative cap (e.g. 200).
- **Blocked:** None.
- **Next:** Commit changes and provide verification prompt for 3rd party agents.

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86)–[#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) Lite map complete
- [x] Docs + drivers + adopt

## Blockers / Notes
- Campaign artifacts remain gitignored under `evals/lite/campaigns/adr0009-20260801-n5/` (local audit).
