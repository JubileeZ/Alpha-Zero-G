# Active Task: Vendor refresh + device re-setup

- **Status:** Done
- **Objective:** Re-vendor skills (drop stale `2026-07-27` locks); reinstall global Cursor/Gemini skills on this device
- **Acceptance:** VENDOR.lock refreshed; `azg setup --force` installs 28 skills + 2 Cursor rules; continuity docs updated; Checkpoint
- **Issue/Ticket:** —

## Work Packet (SFDBN)

- **Status:** Done — `azg update --vendor` + `azg setup --force`; locks at UTC `2026-07-30`
- **Files:** `templates/global/skills/vendor/*/VENDOR.lock`, `task.md`, `.agents/session-handoff.md`, `docs/agents/current-state.md`
- **Decisions:** `date_vendored` uses UTC (`date -u`); mattpocock pin moved `ed37663` → `2ab9580`; device needed Homebrew Bash 5 (macOS `/bin/bash` 3.2 lacks `mapfile`)
- **Blocked:** None
- **Next:** Push when ready; reload Cursor to pick up global rules/skills

## Todo
- [x] `./azg update --vendor`
- [x] `./azg setup --force` (Bash 5 on PATH)
- [x] Update continuity docs
- [x] Checkpoint

## Blockers / Notes
- Stale `.zshrc` alias `azg-upgrade` → missing `setup/bootstrap.sh`; use `./azg update` / `./azg setup` instead
