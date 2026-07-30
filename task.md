# Active Task: Windows-safe Cursor hook launcher

- **Status:** Re-applied (prior uncommitted fix was discarded)
- **Objective:** Stop intermittent IDE open of stop-checkpoint.sh on agent stop
- **Acceptance:** hooks.json commands use run-hook.cmd + basename only (no .sh token); stop never ShellExecutes .sh
- **Issue/Ticket:** local / Cursor Windows .sh association

## Work Packet (SFDBN)

- **Status:** Committed; apply from this tree installs run-hook.cmd
- **Files:** `.cursor/hooks/run-hook.cmd`, `.cursor/hooks.json`, `templates/project/.cursor/hooks/*`, `lib/scaffold.sh`, `lib/apply.sh`, `tests/host-contract-smoke.sh`, `tests/test-phase2.sh`, `tests/test-phase10.sh`
- **Decisions:** Bare `.sh` in hooks.json → Windows opens file. Basename-only via run-hook.cmd. `azg apply` refreshes from template — commit required so reinstall does not regress.
- **Blocked:** None
- **Next:** Reload Window; confirm stop no longer opens stop-checkpoint.sh

## Todo
- [x] Recreate run-hook.cmd after discard
- [x] hooks.json without .sh path tokens
- [x] Scaffold/apply + tests
- [x] Commit so fix cannot vanish again
- [ ] User reload + verify

## Blockers / Notes
- Prior intermittent open: uncommitted fix discarded / apply from HEAD restored bare `.sh`.
