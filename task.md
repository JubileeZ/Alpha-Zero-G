# Active Task: Pull upstream + device sync

- **Status:** Done
- **Objective:** Pull latest `origin/main`; integrate local vendor-lock maintenance; restore Unix hook execute bit
- **Acceptance:** Merge complete; conflicts resolved; `run-hook.cmd` executable; continuity docs updated
- **Issue/Ticket:** —

## Work Packet (SFDBN)

- **Status:** Done — pulled 7 upstream commits; merge `4ead327`; hook mode fixed; checkpoint committed
- **Files:** `task.md`, `.agents/session-handoff.md`, `docs/agents/current-state.md`, `.cursor/hooks/run-hook.cmd`, `templates/project/.cursor/hooks/run-hook.cmd`
- **Decisions:** Conflict resolution favored upstream work packet (Cursor rule rendering complete); local `1749bfc` vendor-lock dates retained in merge
- **Blocked:** None
- **Next:** `./azg setup` on device; push local commits when ready

## Todo
- [x] `git pull` / merge `origin/main`
- [x] Resolve `task.md` + session-handoff conflicts
- [x] `chmod +x` `run-hook.cmd` (repo + template)
- [x] Update continuity docs
- [x] Checkpoint

## Blockers / Notes
- Branch ahead of `origin/main` until push (`1749bfc`, merge, checkpoint)
