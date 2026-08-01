# Active Task: Windows CI shellcheck install (self-copy fix)

- **Status:** Implemented — awaiting commit/push
- **Objective:** Fix Windows install dying on Copy-Item of shellcheck.exe onto itself after Expand-Archive
- **Acceptance:** Windows Install deps extracts shellcheck.exe and verifies path; no self-overwrite
- **Issue/Ticket:** https://github.com/JubileeZ/alpha-zero-g/actions/runs/30702940431

## Work Packet (SFDBN)

- **Status:** Done locally — not committed
- **Files:** `.github/workflows/ci.yml` · `docs/agents/current-state.md`
- **Decisions:** Drop redundant Copy-Item; assert `shellcheck.exe` in toolsBin after expand; jq still choco+retry
- **Blocked:** None
- **Next:** Commit + push to re-run Windows CI

## Todo
- [x] Diagnose 30702940431 Windows Install failure
- [x] Remove self-copy; keep existence check
- [x] Continuity (task.md + current-state)

## Blockers / Notes
- Ubuntu/macOS green on 30702940431; only Windows Install failed
- Spawn-budget pin run 30702810346 succeeded
